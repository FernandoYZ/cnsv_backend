-- 0. DATOS DE LA INSTITUCIÓN
CREATE TABLE institucion (
    id_institucion INT PRIMARY KEY DEFAULT 1,
    nombre_institucion VARCHAR(255) NOT NULL,
    ruc VARCHAR(11) NOT NULL UNIQUE,
    direccion VARCHAR(255),
    telefono VARCHAR(20),
    celular VARCHAR(20),
    email_contacto citext, -- MEJORA: Case-insensitive
    sitio_web VARCHAR(100),
    logo_url TEXT,
    cuenta_bancaria_1 VARCHAR(100),
    cuenta_bancaria_2 VARCHAR(100),
    CONSTRAINT id_institucion_singleton CHECK (id_institucion = 1)
);

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
    nombre_rol VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
);

CREATE TABLE permisos (
    id_permiso SERIAL PRIMARY KEY,
    nombre_permiso VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
);

CREATE TABLE acciones (
    id_accion SERIAL PRIMARY KEY,
    nombre_accion VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
);

CREATE TABLE permisos_roles (
    id_permiso INT NOT NULL,
    id_rol INT NOT NULL,
    PRIMARY KEY (id_permiso, id_rol),
    CONSTRAINT fk_perm_rol_p FOREIGN KEY (id_permiso) REFERENCES permisos(id_permiso) ON DELETE CASCADE,
    CONSTRAINT fk_perm_rol_r FOREIGN KEY (id_rol) REFERENCES roles(id_rol) ON DELETE CASCADE
);

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
    nombre VARCHAR(10) NOT NULL UNIQUE,
    nombre_anio_peru VARCHAR(255),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    activo BOOLEAN DEFAULT FALSE
);

CREATE TABLE periodos (
    id_periodo SERIAL PRIMARY KEY,
    id_anio INT NOT NULL,
    nombre_periodo VARCHAR(50) NOT NULL,
    fecha_inicio DATE,
    fecha_fin DATE,
    activo BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_anio_periodo FOREIGN KEY (id_anio) REFERENCES anios_lectivos(id_anio)
);

CREATE TABLE niveles (
    id_nivel SERIAL PRIMARY KEY,
    nombre_nivel VARCHAR(50) NOT NULL
);

CREATE TABLE sectores (
    id_sector SERIAL PRIMARY KEY,
    nombre_sector VARCHAR(100) NOT NULL
);

CREATE TABLE grados (
    id_grado SERIAL PRIMARY KEY,
    nombre_grado VARCHAR(50) NOT NULL,
    id_nivel INT NOT NULL,
    id_sector INT,
    CONSTRAINT fk_grado_nivel FOREIGN KEY (id_nivel) REFERENCES niveles(id_nivel),
    CONSTRAINT fk_grado_sector FOREIGN KEY (id_sector) REFERENCES sectores(id_sector)
);

-- 4. MALLA CURRICULAR
CREATE TABLE cursos (
    id_curso SERIAL PRIMARY KEY,
    nombre_curso VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT
);

CREATE TABLE materias (
    id_materia SERIAL PRIMARY KEY,
    id_curso INT NOT NULL,
    nombre_materia VARCHAR(100) NOT NULL,
    CONSTRAINT fk_curso_materia FOREIGN KEY (id_curso) REFERENCES cursos(id_curso),
    UNIQUE (id_curso, nombre_materia)
);

-- 5. RECURSOS HUMANOS
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
    email citext UNIQUE, -- MEJORA: Case-insensitive y UNIQUE
    id_cargo INT NOT NULL,
    fecha_ingreso DATE NOT NULL,
    activo BOOLEAN DEFAULT TRUE, -- MEJORA: Soft Delete
    eliminado_en TIMESTAMP WITH TIME ZONE DEFAULT NULL -- MEJORA: Soft Delete
);

CREATE TABLE profesores (
    id_profesor SERIAL PRIMARY KEY,
    id_empleado INT UNIQUE NOT NULL,
    especialidad_principal INT,
    CONSTRAINT fk_prof_emp FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado),
    CONSTRAINT fk_prof_esp FOREIGN KEY (especialidad_principal) REFERENCES cursos(id_curso)
);

CREATE TABLE profesores_aptitudes (
    id_profesor INT NOT NULL,
    id_curso INT NOT NULL,
    PRIMARY KEY (id_profesor, id_curso),
    CONSTRAINT fk_apt_prof FOREIGN KEY (id_profesor) REFERENCES profesores(id_profesor) ON DELETE CASCADE,
    CONSTRAINT fk_apt_curso FOREIGN KEY (id_curso) REFERENCES cursos(id_curso) ON DELETE CASCADE
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

-- 7. ESTUDIANTES Y FAMILIA
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
    activo BOOLEAN DEFAULT TRUE, -- MEJORA: Soft Delete
    eliminado_en TIMESTAMP WITH TIME ZONE DEFAULT NULL, -- MEJORA: Soft Delete
    CONSTRAINT fk_est_dist FOREIGN KEY (id_distrito) REFERENCES distritos(id_distrito)
);

CREATE TABLE familiares (
    id_familiar SERIAL PRIMARY KEY,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    dni VARCHAR(15) UNIQUE,
    telefono VARCHAR(20),
    email citext, -- MEJORA: Case-insensitive
    direccion VARCHAR(255)
);

CREATE TABLE estudiantes_familiares (
    id_estudiante INT NOT NULL,
    id_familiar INT NOT NULL,
    parentesco VARCHAR(50) NOT NULL,
    es_apoderado_legal BOOLEAN DEFAULT FALSE,
    vive_con_estudiante BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (id_estudiante, id_familiar),
    CONSTRAINT fk_rel_est FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante) ON DELETE CASCADE,
    CONSTRAINT fk_rel_fam FOREIGN KEY (id_familiar) REFERENCES familiares(id_familiar) ON DELETE CASCADE
);

CREATE TABLE estudiantes_datos_adicionales (
    id_estudiante INT PRIMARY KEY,
    tipo_sangre VARCHAR(5),
    alergias TEXT,
    condiciones_medicas TEXT,
    seguro_medico_nombre VARCHAR(100),
    seguro_medico_poliza VARCHAR(100),
    observaciones_psicopedagogicas TEXT,
    CONSTRAINT fk_datos_est FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante) ON DELETE CASCADE
);

-- 8. MATRÍCULA Y GESTIÓN ACADÉMICA
CREATE TABLE secciones (
    id_seccion SERIAL PRIMARY KEY,
    id_grado INT NOT NULL,
    id_anio INT NOT NULL,
    letra_seccion CHAR(1) NOT NULL,
    vacantes_maximas INT DEFAULT 30,
    tutor_id INT,
    CONSTRAINT fk_sec_grado FOREIGN KEY (id_grado) REFERENCES grados(id_grado),
    CONSTRAINT fk_sec_anio FOREIGN KEY (id_anio) REFERENCES anios_lectivos(id_anio),
    CONSTRAINT fk_sec_tutor FOREIGN KEY (tutor_id) REFERENCES profesores(id_profesor),
    UNIQUE (id_grado, id_anio, letra_seccion)
);

CREATE TABLE tipos_matricula (
    id_tipo_matricula SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL DEFAULT 'Regular'
);

CREATE TABLE matriculas (
    id_matricula SERIAL PRIMARY KEY,
    id_estudiante INT NOT NULL,
    id_seccion INT NOT NULL,
    fecha_matricula TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    id_tipo_matricula INT NOT NULL,
    -- MEJORA: Auditoría Inline
    creado_en TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    creado_por INT REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
    actualizado_por INT REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
    CONSTRAINT fk_mat_est FOREIGN KEY (id_estudiante) REFERENCES estudiantes(id_estudiante),
    CONSTRAINT fk_mat_tip FOREIGN KEY (id_tipo_matricula) REFERENCES tipos_matricula (id_tipo_matricula),
    CONSTRAINT fk_mat_sec FOREIGN KEY (id_seccion) REFERENCES secciones(id_seccion),
    UNIQUE (id_estudiante, id_seccion)
);

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

-- 9. HORARIOS Y TURNOS
CREATE TABLE turnos (
    id_turno SERIAL PRIMARY KEY,
    nombre_turno VARCHAR(50) NOT NULL UNIQUE,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL
);

CREATE TABLE programacion_clases (
    id_programacion SERIAL PRIMARY KEY,
    id_clase_programada INT NOT NULL,
    dia_semana INT NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    id_turno INT NOT NULL,
    UNIQUE(id_clase_programada, dia_semana, hora_inicio),
    CONSTRAINT fk_prog_clase FOREIGN KEY (id_clase_programada) REFERENCES clases_programadas(id_clase_programada) ON DELETE CASCADE,
    CONSTRAINT fk_prog_turno FOREIGN KEY (id_turno) REFERENCES turnos(id_turno),
    CONSTRAINT chk_dia_semana CHECK (dia_semana BETWEEN 1 AND 7)
);

-- 10. EVALUACIONES Y ASISTENCIA
CREATE TABLE criterios_evaluacion (
    id_criterio_eval SERIAL PRIMARY KEY,
    id_clase_programada INT NOT NULL,
    id_periodo INT NOT NULL,
    nombre_criterio VARCHAR(100) NOT NULL,
    peso DECIMAL(5,2) NOT NULL,
    CONSTRAINT fk_crit_clase FOREIGN KEY (id_clase_programada) REFERENCES clases_programadas(id_clase_programada) ON DELETE CASCADE,
    CONSTRAINT fk_crit_periodo FOREIGN KEY (id_periodo) REFERENCES periodos(id_periodo),
    UNIQUE(id_clase_programada, id_periodo, nombre_criterio)
);

CREATE TABLE notas (
    id_nota SERIAL PRIMARY KEY,
    id_matricula INT NOT NULL,
    id_clase_programada INT NOT NULL,
    id_periodo INT NOT NULL,
    id_criterio_eval INT NOT NULL,
    valor_nota DECIMAL(5,2) NOT NULL,
    fecha_registro DATE DEFAULT CURRENT_DATE,
    observacion TEXT,
    -- MEJORA: Auditoría Inline
    creado_en TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    creado_por INT REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
    actualizado_por INT REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
    CONSTRAINT fk_nota_matr FOREIGN KEY (id_matricula) REFERENCES matriculas(id_matricula) ON DELETE CASCADE,
    CONSTRAINT fk_nota_clase FOREIGN KEY (id_clase_programada) REFERENCES clases_programadas(id_clase_programada),
    CONSTRAINT fk_nota_per FOREIGN KEY (id_periodo) REFERENCES periodos(id_periodo),
    CONSTRAINT fk_nota_criterio FOREIGN KEY (id_criterio_eval) REFERENCES criterios_evaluacion(id_criterio_eval)
);

CREATE TABLE tipos_estados_asistencias (
    id_tipo_asistencia SERIAL PRIMARY KEY,
    tipo_asistencia VARCHAR(50) NOT NULL,
    tipo_asistencia_iniciales varchar(2) not null
);

CREATE TABLE asistencias (
    id_asistencia SERIAL PRIMARY KEY,
    id_matricula INT NOT NULL,
    id_clase_programada INT,
    fecha DATE NOT NULL,
    id_tipo_asistencia INT NOT NULL,
    observacion TEXT,
    -- MEJORA: Auditoría Inline
    creado_en TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    creado_por INT REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
    actualizado_por INT REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
    CONSTRAINT fk_asis_matr FOREIGN KEY (id_matricula) REFERENCES matriculas(id_matricula) ON DELETE CASCADE,
    CONSTRAINT fk_asis_clase FOREIGN KEY (id_clase_programada) REFERENCES clases_programadas(id_clase_programada),
    CONSTRAINT fk_asis_tipo FOREIGN KEY (id_tipo_asistencia) REFERENCES tipos_estados_asistencias(id_tipo_asistencia)
);

-- 11. AUTENTICACIÓN Y AUDITORÍA
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

-- =================================================================
-- 12. MÓDULOS ADICIONALES (Expediente, Disciplina, Tesorería, Comms)
-- =================================================================

-- 12.1. EXPEDIENTE ACADÉMICO
CREATE TABLE expediente_academico (
    id_expediente SERIAL PRIMARY KEY,
    id_matricula INT NOT NULL,
    id_curso INT NOT NULL,
    promedio_final DECIMAL(5,2) NOT NULL,
    situacion_final VARCHAR(50) NOT NULL, -- 'Aprobado', 'Desaprobado'
    observaciones TEXT,
    -- MEJORA: Auditoría Inline
    creado_en TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    creado_por INT REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
    actualizado_por INT REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
    CONSTRAINT fk_exp_matricula FOREIGN KEY (id_matricula) REFERENCES matriculas(id_matricula) ON DELETE CASCADE,
    CONSTRAINT fk_exp_curso FOREIGN KEY (id_curso) REFERENCES cursos(id_curso),
    UNIQUE(id_matricula, id_curso)
);

-- 12.2. MÓDULO DE DISCIPLINA
CREATE TABLE tipos_incidencia (
    id_tipo_incidencia SERIAL PRIMARY KEY,
    nombre_tipo VARCHAR(100) NOT NULL,
    descripcion TEXT
);

CREATE TABLE incidencias_estudiantes (
    id_incidencia SERIAL PRIMARY KEY,
    id_matricula INT NOT NULL,
    id_tipo_incidencia INT NOT NULL,
    id_usuario_reporta INT,
    fecha_incidencia DATE NOT NULL DEFAULT CURRENT_DATE,
    descripcion_hechos TEXT NOT NULL,
    medida_correctiva TEXT,
    -- MEJORA: Auditoría Inline
    creado_en TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    creado_por INT REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
    actualizado_por INT REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
    CONSTRAINT fk_inc_matricula FOREIGN KEY (id_matricula) REFERENCES matriculas(id_matricula) ON DELETE CASCADE,
    CONSTRAINT fk_inc_tipo FOREIGN KEY (id_tipo_incidencia) REFERENCES tipos_incidencia(id_tipo_incidencia),
    CONSTRAINT fk_inc_usuario FOREIGN KEY (id_usuario_reporta) REFERENCES usuarios(id_usuario) ON DELETE SET NULL
);

-- 12.3. MÓDULO DE TESORERÍA (REDISEÑADO)
CREATE TABLE tipos_metodo_pago (
    id_metodo_pago SERIAL PRIMARY KEY,
    nombre_metodo VARCHAR(50) NOT NULL UNIQUE,
    requiere_referencia BOOLEAN DEFAULT FALSE
);

CREATE TABLE estados_pago (
    id_estado_pago SERIAL PRIMARY KEY,
    nombre_estado VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE servicios_catalogo (
    id_servicio SERIAL PRIMARY KEY,
    id_anio INT NOT NULL,
    nombre_servicio VARCHAR(100) NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    es_pension BOOLEAN DEFAULT FALSE,
    fecha_vencimiento DATE,
    CONSTRAINT fk_serv_anio FOREIGN KEY (id_anio) REFERENCES anios_lectivos(id_anio),
    UNIQUE(id_anio, nombre_servicio)
);

CREATE TABLE servicios_requisitos (
    id_requisito SERIAL PRIMARY KEY,
    id_servicio INT NOT NULL,
    nombre_requisito TEXT NOT NULL,
    CONSTRAINT fk_req_serv FOREIGN KEY (id_servicio) REFERENCES servicios_catalogo(id_servicio) ON DELETE CASCADE
);

CREATE TABLE cuentas_por_cobrar_estudiante (
    id_cuenta_por_cobrar SERIAL PRIMARY KEY,
    id_matricula INT NOT NULL,
    id_servicio INT NOT NULL,
    monto_original DECIMAL(10,2) NOT NULL,
    descuento DECIMAL(10,2) DEFAULT 0.00,
    monto_a_pagar DECIMAL(10,2) NOT NULL,
    monto_pagado DECIMAL(10,2) DEFAULT 0.00,
    id_estado_pago INT NOT NULL,
    fecha_emision DATE DEFAULT CURRENT_DATE,
    fecha_vencimiento DATE,
    observacion TEXT,
    -- MEJORA: Auditoría Inline
    creado_en TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    creado_por INT REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
    actualizado_por INT REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
    CONSTRAINT fk_cuenta_matr FOREIGN KEY (id_matricula) REFERENCES matriculas(id_matricula),
    CONSTRAINT fk_cuenta_serv FOREIGN KEY (id_servicio) REFERENCES servicios_catalogo(id_servicio),
    CONSTRAINT fk_cuenta_estado FOREIGN KEY (id_estado_pago) REFERENCES estados_pago(id_estado_pago)
);

CREATE TABLE transacciones_pago (
    id_transaccion SERIAL PRIMARY KEY,
    id_cuenta_por_cobrar INT NOT NULL,
    id_usuario_registra INT,
    monto_transaccion DECIMAL(10,2) NOT NULL,
    id_metodo_pago INT NOT NULL,
    fecha_transaccion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    numero_referencia VARCHAR(100),
    observacion TEXT,
    -- MEJORA: Auditoría Inline (solo 'creado_en' y 'creado_por', los pagos no se editan)
    creado_en TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    creado_por INT REFERENCES usuarios(id_usuario) ON DELETE SET NULL,
    CONSTRAINT fk_trans_cuenta FOREIGN KEY (id_cuenta_por_cobrar) REFERENCES cuentas_por_cobrar_estudiante(id_cuenta_por_cobrar),
    CONSTRAINT fk_trans_usuario FOREIGN KEY (id_usuario_registra) REFERENCES usuarios(id_usuario),
    CONSTRAINT fk_trans_metodo FOREIGN KEY (id_metodo_pago) REFERENCES tipos_metodo_pago(id_metodo_pago)
);

-- 12.4. MÓDULO DE COMUNICACIONES
CREATE TABLE calendario_eventos (
    id_evento SERIAL PRIMARY KEY,
    id_anio INT NOT NULL,
    titulo_evento VARCHAR(255) NOT NULL,
    descripcion TEXT,
    fecha_inicio TIMESTAMP WITH TIME ZONE NOT NULL,
    fecha_fin TIMESTAMP WITH TIME ZONE,
    tipo_evento VARCHAR(50) NOT NULL,
    CONSTRAINT fk_evento_anio FOREIGN KEY (id_anio) REFERENCES anios_lectivos(id_anio)
);

CREATE TABLE anuncios (
    id_anuncio SERIAL PRIMARY KEY,
    id_usuario_autor INT NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    cuerpo TEXT NOT NULL,
    fecha_publicacion TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    fecha_expiracion TIMESTAMP WITH TIME ZONE,
    CONSTRAINT fk_anuncio_autor FOREIGN KEY (id_usuario_autor) REFERENCES usuarios(id_usuario)
);

CREATE TABLE anuncios_destinatarios (
    id_anuncio_destino SERIAL PRIMARY KEY,
    id_anuncio INT NOT NULL,
    tipo_destino VARCHAR(20) NOT NULL, -- 'GLOBAL', 'ROL', 'SECCION', 'GRADO'
    id_destino INT,
    CONSTRAINT fk_destino_anuncio FOREIGN KEY (id_anuncio) REFERENCES anuncios(id_anuncio) ON DELETE CASCADE,
    UNIQUE(id_anuncio, tipo_destino, id_destino)
);