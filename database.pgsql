-- 1. GEOGRAFÍA (UBIGEO)
CREATE TABLE departamentos (
    id_departamento SERIAL PRIMARY KEY,
    nombre_departamento VARCHAR(255) NOT NULL
);

CREATE TABLE provincias (
    id_provincia SERIAL PRIMARY KEY,
    id_departamento INT NOT NULL,
    nombre_provincia VARCHAR(255) NOT NULL,
    CONSTRAINT fk_dep_prov FOREIGN KEY (id_departamento) REFERENCES departamentos(id_departamento)
);

CREATE TABLE distritos (
    id_distrito SERIAL PRIMARY KEY,
    id_provincia INT NOT NULL,
    nombre_distrito VARCHAR(255) NOT NULL,
    CONSTRAINT fk_prov_dist FOREIGN KEY (id_provincia) REFERENCES provincias(id_provincia)
);

-- 2. GESTIÓN DE ACCESO Y ROLES
CREATE TABLE roles (
    id_rol SERIAL PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE, -- Admin, Director, Profesor, etc.
    descripcion TEXT
);

CREATE TABLE permisos (
    id_permiso SERIAL PRIMARY KEY,
    nombre_permiso VARCHAR(50) NOT NULL UNIQUE, -- 'ver_notas', 'editar_notas'
    descripcion TEXT
);

-- Tabla 'acciones' (del script original)
CREATE TABLE acciones (
    id_accion SERIAL PRIMARY KEY,
    nombre_accion VARCHAR(50) NOT NULL UNIQUE, -- 'CREAR', 'LEER', 'ACTUALIZAR', 'BORRAR'
    descripcion TEXT
);

CREATE TABLE permisos_roles (
    id_permiso INT NOT NULL,
    id_rol INT NOT NULL,
    PRIMARY KEY (id_permiso, id_rol),
    CONSTRAINT fk_perm_rol_p FOREIGN KEY (id_permiso) REFERENCES permisos(id_permiso) ON DELETE CASCADE,
    CONSTRAINT fk_perm_rol_r FOREIGN KEY (id_rol) REFERENCES roles(id_rol) ON DELETE CASCADE
);

-- Tabla 'acciones_roles' (del script original)
CREATE TABLE acciones_roles (
    id_accion INT NOT NULL,
    id_rol INT NOT NULL,
    PRIMARY KEY (id_accion, id_rol),
    CONSTRAINT fk_accion_rol_a FOREIGN KEY (id_accion) REFERENCES acciones(id_accion) ON DELETE CASCADE,
    CONSTRAINT fk_accion_rol_r FOREIGN KEY (id_rol) REFERENCES roles(id_rol) ON DELETE CASCADE
);

-- 3. ESTRUCTURA ACADÉMICA GENERAL
CREATE TABLE anios_lectivos (
    id_anio SERIAL PRIMARY KEY,
    nombre VARCHAR(10) NOT NULL UNIQUE, -- '2025'
    nombre_anio_peru VARCHAR(255), -- Nombre oficial del año (MINEDU)
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    activo BOOLEAN DEFAULT FALSE
);

CREATE TABLE periodos (
    id_periodo SERIAL PRIMARY KEY,
    id_anio INT NOT NULL,
    nombre_periodo VARCHAR(50) NOT NULL, -- 'I Bimestre', 'II Trimestre'
    fecha_inicio DATE,
    fecha_fin DATE,
    activo BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_anio_periodo FOREIGN KEY (id_anio) REFERENCES anios_lectivos(id_anio)
);

CREATE TABLE niveles (
    id_nivel SERIAL PRIMARY KEY,
    nombre_nivel VARCHAR(50) NOT NULL -- Primaria, Secundaria
);

CREATE TABLE sectores (
    id_sector SERIAL PRIMARY KEY,
    nombre_sector VARCHAR(100) NOT NULL -- Menor (Primaria a 2do sec), Mayor (3ro a 5to sec)
);

CREATE TABLE grados (
    id_grado SERIAL PRIMARY KEY,
    nombre_grado VARCHAR(50) NOT NULL, -- 'Primero', 'Segundo'
    id_nivel INT NOT NULL,
    id_sector INT,
    CONSTRAINT fk_grado_nivel FOREIGN KEY (id_nivel) REFERENCES niveles(id_nivel),
    CONSTRAINT fk_grado_sector FOREIGN KEY (id_sector) REFERENCES sectores(id_sector)
);

-- 4. MALLA CURRICULAR (Jerarquía Perú CORREGIDA)
CREATE TABLE cursos (
    id_curso SERIAL PRIMARY KEY,
    nombre_curso VARCHAR(100) NOT NULL UNIQUE, -- Matemáticas, Comunicación, Ciencias
    descripcion TEXT
);

CREATE TABLE materias (
    id_materia SERIAL PRIMARY KEY,
    id_curso INT NOT NULL, -- A qué curso pertenece
    nombre_materia VARCHAR(100) NOT NULL, -- Álgebra, Geometría, Biología
    CONSTRAINT fk_curso_materia FOREIGN KEY (id_curso) REFERENCES cursos(id_curso),
    UNIQUE (id_curso, nombre_materia)
);

-- 5. RECURSOS HUMANOS (Empleados y Profesores)
CREATE TABLE cargos (
    id_cargo SERIAL PRIMARY KEY,
    nombre_cargo VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    es_docente BOOLEAN DEFAULT FALSE
);

CREATE TABLE empleados (
    id_empleado SERIAL PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellido_paterno VARCHAR(50) NOT NULL,
    apellido_materno VARCHAR(50) NOT NULL,
    dni VARCHAR(15) UNIQUE NOT NULL,
    direccion VARCHAR(255),
    telefono VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    id_cargo INT NOT NULL,
    fecha_ingreso DATE NOT NULL,
    estado BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_emp_cargo FOREIGN KEY (id_cargo) REFERENCES cargos(id_cargo)
);

CREATE TABLE profesores (
    id_profesor SERIAL PRIMARY KEY,
    id_empleado INT UNIQUE NOT NULL,
    especialidad_principal INT, -- CORREGIDO: Referencia a 'cursos'
    CONSTRAINT fk_prof_emp FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado),
    CONSTRAINT fk_prof_esp FOREIGN KEY (especialidad_principal) REFERENCES cursos(id_curso)
);

-- 6. USUARIOS DEL SISTEMA
CREATE TABLE usuarios (
    id_usuario SERIAL PRIMARY KEY,
    id_empleado INT UNIQUE,
    nombre_usuario VARCHAR(50) NOT NULL UNIQUE,
    contrasena_hash VARCHAR(255) NOT NULL,
    id_rol INT NOT NULL,
    ultimo_acceso TIMESTAMP WITH TIME ZONE,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_usu_emp FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado),
    CONSTRAINT fk_usu_rol FOREIGN KEY (id_rol) REFERENCES roles(id_rol)
);

-- 7. ESTUDIANTES Y FAMILIA (Normalizado)
CREATE TABLE estudiantes (
    id_estudiante SERIAL PRIMARY KEY,
    codigo_estudiante VARCHAR(20) UNIQUE,
    nombres VARCHAR(100) NOT NULL,
    apellido_paterno VARCHAR(50) NOT NULL,
    apellido_materno VARCHAR(50) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    dni VARCHAR(15) UNIQUE,
    direccion VARCHAR(255),
    id_distrito INT,
    estado BOOLEAN DEFAULT TRUE, -- Activo/Retirado
    CONSTRAINT fk_est_dist FOREIGN KEY (id_distrito) REFERENCES distritos(id_distrito)
);

CREATE TABLE familiares (
    id_familiar SERIAL PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    dni VARCHAR(15) UNIQUE,
    telefono VARCHAR(20),
    email VARCHAR(100),
    direccion VARCHAR(255)
);

CREATE TABLE estudiantes_familiares (
    id_estudiante INT NOT NULL,
    id_familiar INT NOT NULL,
    parentesco VARCHAR(50) NOT NULL, -- Padre, Madre, Apoderado, Tío
    es_apoderado_legal BOOLEAN DEFAULT FALSE,
    vive_con_estudiante BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (id_estudiante, id_familiar),
    CONSTRAINT fk_rel_est FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante) ON DELETE CASCADE,
    CONSTRAINT fk_rel_fam FOREIGN KEY (id_familiar) REFERENCES familiares(id_familiar) ON DELETE CASCADE
);

-- 8. MATRÍCULA Y GESTIÓN ACADÉMICA
CREATE TABLE secciones (
    id_seccion SERIAL PRIMARY KEY,
    id_grado INT NOT NULL,
    id_anio INT NOT NULL,
    letra_seccion CHAR(1) NOT NULL, -- A, B, C
    vacantes_maximas INT DEFAULT 30,
    tutor_id INT,
    CONSTRAINT fk_sec_grado FOREIGN KEY (id_grado) REFERENCES grados(id_grado),
    CONSTRAINT fk_sec_anio FOREIGN KEY (id_anio) REFERENCES anios_lectivos(id_anio),
    CONSTRAINT fk_sec_tutor FOREIGN KEY (tutor_id) REFERENCES profesores(id_profesor),
    UNIQUE (id_grado, id_anio, letra_seccion)
);

CREATE TABLE tipos_matricula (
    id_tipo_matricula SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL DEFAULT 'Regular' -- Promovido, Repitente, Traslado
);

CREATE TABLE matriculas (
    id_matricula SERIAL PRIMARY KEY,
    id_estudiante INT NOT NULL,
    id_seccion INT NOT NULL,
    fecha_matricula TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    id_tipo_matricula INT NOT NULL,
    CONSTRAINT fk_mat_est FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante),
    CONSTRAINT fk_mat_tip FOREIGN KEY (id_tipo_matricula) REFERENCES tipos_matricula (id_tipo_matricula),
    CONSTRAINT fk_mat_sec FOREIGN KEY (id_seccion) REFERENCES secciones(id_seccion),
    UNIQUE (id_estudiante, id_seccion)
);

-- CORREGIDO: Renombrado a 'clases_programadas'
CREATE TABLE clases_programadas (
    id_clase_programada SERIAL PRIMARY KEY,
    id_seccion INT NOT NULL,
    id_materia INT NOT NULL,
    id_profesor INT NOT NULL,
    horas_semanales INT DEFAULT 2,
    CONSTRAINT fk_clase_sec FOREIGN KEY (id_seccion) REFERENCES secciones(id_seccion),
    CONSTRAINT fk_clase_mat FOREIGN KEY (id_materia) REFERENCES materias(id_materia),
    CONSTRAINT fk_clase_prof FOREIGN KEY (id_profesor) REFERENCES profesores(id_profesor),
    UNIQUE (id_seccion, id_materia)
);

-- 9. HORARIOS Y TURNOS (de v3)
CREATE TABLE turnos (
    id_turno SERIAL PRIMARY KEY,
    nombre_turno VARCHAR(50) NOT NULL UNIQUE, -- 'Mañana', 'Tarde'
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL
);

CREATE TABLE programacion_clases (
    id_programacion SERIAL PRIMARY KEY,
    id_clase_programada INT NOT NULL, -- "Álgebra en 1ro A"
    dia_semana INT NOT NULL, -- 1=Lunes, 2=Martes, ..., 7=Domingo
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    id_turno INT NOT NULL,
    UNIQUE(id_clase_programada, dia_semana, hora_inicio),
    CONSTRAINT fk_prog_clase FOREIGN KEY (id_clase_programada) REFERENCES clases_programadas(id_clase_programada) ON DELETE CASCADE,
    CONSTRAINT fk_prog_turno FOREIGN KEY (id_turno) REFERENCES turnos(id_turno),
    CONSTRAINT chk_dia_semana CHECK (dia_semana BETWEEN 1 AND 7)
);

-- 10. EVALUACIONES Y ASISTENCIA
CREATE TABLE tipos_evaluacion (
    id_tipo_ev SERIAL PRIMARY KEY,
    nombre_tipo VARCHAR(50) NOT NULL -- Examen Mensual, Práctica, Revisión Cuaderno
);

CREATE TABLE notas (
    id_nota SERIAL PRIMARY KEY,
    id_matricula INT NOT NULL,
    id_clase_programada INT NOT NULL, -- CORREGIDO: FK a 'clases_programadas'
    id_periodo INT NOT NULL,
    id_tipo_ev INT NOT NULL,
    valor_nota DECIMAL(5,2) NOT NULL,
    fecha_registro DATE DEFAULT CURRENT_DATE,
    observacion TEXT,
    CONSTRAINT fk_nota_matr FOREIGN KEY (id_matricula) REFERENCES matriculas(id_matricula) ON DELETE CASCADE,
    CONSTRAINT fk_nota_clase FOREIGN KEY (id_clase_programada) REFERENCES clases_programadas(id_clase_programada),
    CONSTRAINT fk_nota_per FOREIGN KEY (id_periodo) REFERENCES periodos(id_periodo),
    CONSTRAINT fk_nota_tipo FOREIGN KEY (id_tipo_ev) REFERENCES tipos_evaluacion(id_tipo_ev)
);

CREATE TABLE tipos_estados_asistencias (
    id_tipo_asistencia SERIAL PRIMARY KEY,
    tipo_asistencia VARCHAR(50) NOT NULL, -- 'Asistió', 'Falta', 'Tardanza', 'Falta Justificada'}
    tipo_asistencia_iniciales varchar(2) not null
);

CREATE TABLE asistencias (
    id_asistencia SERIAL PRIMARY KEY,
    id_matricula INT NOT NULL,
    id_clase_programada INT, -- CORREGIDO: FK a 'clases_programadas'
    fecha DATE NOT NULL,
    id_tipo_asistencia INT NOT NULL,
    observacion TEXT,
    CONSTRAINT fk_asis_matr FOREIGN KEY (id_matricula) REFERENCES matriculas(id_matricula) ON DELETE CASCADE,
    CONSTRAINT fk_asis_clase FOREIGN KEY (id_clase_programada) REFERENCES clases_programadas(id_clase_programada),
    CONSTRAINT fk_asis_tipo FOREIGN KEY (id_tipo_asistencia) REFERENCES tipos_estados_asistencias(id_tipo_asistencia)
);

-- 11. AUTENTICACIÓN Y AUDITORÍA (de v3)
CREATE TABLE sesiones_refresh (
    id_refresh_token UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    id_usuario INT NOT NULL,
    user_agent TEXT,
    ip_direccion VARCHAR(50),
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion TIMESTAMP WITH TIME ZONE NOT NULL,
    revocado BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_sesion_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE
);

CREATE TABLE auditoria_sistema (
    id_auditoria BIGSERIAL PRIMARY KEY,
    id_usuario INT,
    accion_realizada VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(100),
    id_registro_afectado VARCHAR(255),
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    fecha_evento TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ip_origen VARCHAR(50),
    CONSTRAINT fk_auditoria_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE SET NULL
);

-- 12. FUNCIONES Y TRIGGERS DE AUDITORÍA
CREATE OR REPLACE FUNCTION fn_auditar_cambios()
RETURNS TRIGGER AS $$
DECLARE
    v_id_usuario INT;
    v_ip_origen VARCHAR(50);
    v_tabla_pk TEXT;
    v_id_registro TEXT;
BEGIN
    -- 1. Obtener el ID de usuario y la IP (seteados por la API de Go/Fiber)
    BEGIN
        v_id_usuario := current_setting('myapp.user_id')::INT;
        v_ip_origen := current_setting('myapp.ip_address');
    EXCEPTION WHEN OTHERS THEN
        v_id_usuario := NULL;
        v_ip_origen := '::1'; -- IP Local por defecto
    END;

    -- 2. Determinar la PK de la tabla dinámicamente (simplificado)
    -- Asumimos PKs simples para este ejemplo (ej. id_nota, id_matricula)
    IF (TG_TABLE_NAME = 'notas') THEN
        v_id_registro := CASE WHEN TG_OP = 'DELETE' THEN OLD.id_nota::TEXT ELSE NEW.id_nota::TEXT END;
    ELSIF (TG_TABLE_NAME = 'matriculas') THEN
        v_id_registro := CASE WHEN TG_OP = 'DELETE' THEN OLD.id_matricula::TEXT ELSE NEW.id_matricula::TEXT END;
    ELSIF (TG_TABLE_NAME = 'asistencias') THEN
        v_id_registro := CASE WHEN TG_OP = 'DELETE' THEN OLD.id_asistencia::TEXT ELSE NEW.id_asistencia::TEXT END;
    END IF;

    -- 3. Insertar en la auditoría
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO auditoria_sistema (id_usuario, accion_realizada, tabla_afectada, id_registro_afectado, datos_nuevos, ip_origen)
        VALUES (v_id_usuario, 'INSERT', TG_TABLE_NAME, v_id_registro, row_to_json(NEW), v_ip_origen);
        RETURN NEW;
        
    ELSIF (TG_OP = 'UPDATE') THEN
        -- Solo auditar si los datos realmente cambiaron
        IF row_to_json(OLD.*) IS DISTINCT FROM row_to_json(NEW.*) THEN
            INSERT INTO auditoria_sistema (id_usuario, accion_realizada, tabla_afectada, id_registro_afectado, datos_anteriores, datos_nuevos, ip_origen)
            VALUES (v_id_usuario, 'UPDATE', TG_TABLE_NAME, v_id_registro, row_to_json(OLD), row_to_json(NEW), v_ip_origen);
        END IF;
        RETURN NEW;
        
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO auditoria_sistema (id_usuario, accion_realizada, tabla_afectada, id_registro_afectado, datos_anteriores, ip_origen)
        VALUES (v_id_usuario, 'DELETE', TG_TABLE_NAME, v_id_registro, row_to_json(OLD), v_ip_origen);
        RETURN OLD;
        
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 13. ADJUNTAR TRIGGERS
CREATE TRIGGER tr_auditar_notas
AFTER INSERT OR UPDATE OR DELETE ON notas
FOR EACH ROW EXECUTE FUNCTION fn_auditar_cambios();

CREATE TRIGGER tr_auditar_matriculas
AFTER INSERT OR UPDATE OR DELETE ON matriculas
FOR EACH ROW EXECUTE FUNCTION fn_auditar_cambios();

CREATE TRIGGER tr_auditar_asistencias
AFTER INSERT OR UPDATE OR DELETE ON asistencias
FOR EACH ROW EXECUTE FUNCTION fn_auditar_cambios();