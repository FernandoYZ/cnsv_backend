-- 1. FUNCIONES Y TRIGGERS DE AUDITORÍA

-- MEJORA: Función para 'actualizado_en'
CREATE OR REPLACE FUNCTION fn_actualizar_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.actualizado_en = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- MEJORA: Función para 'creado_por' y 'actualizado_por'
CREATE OR REPLACE FUNCTION fn_set_audit_user()
RETURNS TRIGGER AS $$
DECLARE
    v_id_usuario INT;
BEGIN
    BEGIN
        v_id_usuario := current_setting('myapp.user_id')::INT;
    EXCEPTION WHEN OTHERS THEN
        v_id_usuario := NULL;
    END;

    IF (TG_OP = 'INSERT') THEN
        NEW.creado_por = v_id_usuario;
        NEW.actualizado_por = v_id_usuario;
    ELSIF (TG_OP = 'UPDATE') THEN
        NEW.actualizado_por = v_id_usuario;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- MEJORA: Función de auditoría robusta usando TG_ARGV[0]
CREATE OR REPLACE FUNCTION fn_auditar_cambios()
RETURNS TRIGGER AS $$
DECLARE
    v_id_usuario INT;
    v_ip_origen VARCHAR(50);
    v_id_registro TEXT;
BEGIN
    BEGIN
        v_id_usuario := current_setting('myapp.user_id')::INT;
        v_ip_origen := current_setting('myapp.ip_address');
    EXCEPTION WHEN OTHERS THEN
        v_id_usuario := NULL;
        v_ip_origen := '::1';
    END;

    IF (TG_OP = 'INSERT') THEN
        v_id_registro := (row_to_json(NEW)->>TG_ARGV[0]); -- MEJORA: PK por argumento
        INSERT INTO auditoria_sistema (id_usuario, accion_realizada, tabla_afectada, id_registro_afectado, datos_nuevos, ip_origen)
        VALUES (v_id_usuario, 'INSERT', TG_TABLE_NAME, v_id_registro, row_to_json(NEW), v_ip_origen);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        v_id_registro := (row_to_json(NEW)->>TG_ARGV[0]); -- MEJORA: PK por argumento
        IF row_to_json(OLD.*) IS DISTINCT FROM row_to_json(NEW.*) THEN
            INSERT INTO auditoria_sistema (id_usuario, accion_realizada, tabla_afectada, id_registro_afectado, datos_anteriores, datos_nuevos, ip_origen)
            VALUES (v_id_usuario, 'UPDATE', TG_TABLE_NAME, v_id_registro, row_to_json(OLD), row_to_json(NEW), v_ip_origen);
        END IF;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        v_id_registro := (row_to_json(OLD)->>TG_ARGV[0]); -- MEJORA: PK por argumento
        INSERT INTO auditoria_sistema (id_usuario, accion_realizada, tabla_afectada, id_registro_afectado, datos_anteriores, ip_origen)
        VALUES (v_id_usuario, 'DELETE', TG_TABLE_NAME, v_id_registro, row_to_json(OLD), v_ip_origen);
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 2. ADJUNTAR TRIGGERS
-- MEJORA: Triggers de auditoría robustos
CREATE TRIGGER tr_auditar_notas
AFTER INSERT OR UPDATE OR DELETE ON notas
FOR EACH ROW EXECUTE FUNCTION fn_auditar_cambios('id_nota');

CREATE TRIGGER tr_auditar_matriculas
AFTER INSERT OR UPDATE OR DELETE ON matriculas
FOR EACH ROW EXECUTE FUNCTION fn_auditar_cambios('id_matricula');

CREATE TRIGGER tr_auditar_asistencias
AFTER INSERT OR UPDATE OR DELETE ON asistencias
FOR EACH ROW EXECUTE FUNCTION fn_auditar_cambios('id_asistencia');


-- =================================================================
-- 3. ADJUNTAR TRIGGERS DE AUDITORÍA INLINE (v7)
-- =================================================================

-- Tablas con campos de auditoría inline
-- MATRICULAS
CREATE TRIGGER tr_matriculas_timestamp
BEFORE UPDATE ON matriculas
FOR EACH ROW EXECUTE FUNCTION fn_actualizar_timestamp();

CREATE TRIGGER tr_matriculas_audit_user
BEFORE INSERT OR UPDATE ON matriculas
FOR EACH ROW EXECUTE FUNCTION fn_set_audit_user();

-- NOTAS
CREATE TRIGGER tr_notas_timestamp
BEFORE UPDATE ON notas
FOR EACH ROW EXECUTE FUNCTION fn_actualizar_timestamp();

CREATE TRIGGER tr_notas_audit_user
BEFORE INSERT OR UPDATE ON notas
FOR EACH ROW EXECUTE FUNCTION fn_set_audit_user();

-- ASISTENCIAS
CREATE TRIGGER tr_asistencias_timestamp
BEFORE UPDATE ON asistencias
FOR EACH ROW EXECUTE FUNCTION fn_actualizar_timestamp();

CREATE TRIGGER tr_asistencias_audit_user
BEFORE INSERT OR UPDATE ON asistencias
FOR EACH ROW EXECUTE FUNCTION fn_set_audit_user();

-- EXPEDIENTE ACADEMICO
CREATE TRIGGER tr_expediente_timestamp
BEFORE UPDATE ON expediente_academico
FOR EACH ROW EXECUTE FUNCTION fn_actualizar_timestamp();

CREATE TRIGGER tr_expediente_audit_user
BEFORE INSERT OR UPDATE ON expediente_academico
FOR EACH ROW EXECUTE FUNCTION fn_set_audit_user();

-- INCIDENCIAS ESTUDIANTES
CREATE TRIGGER tr_incidencias_timestamp
BEFORE UPDATE ON incidencias_estudiantes
FOR EACH ROW EXECUTE FUNCTION fn_actualizar_timestamp();

CREATE TRIGGER tr_incidencias_audit_user
BEFORE INSERT OR UPDATE ON incidencias_estudiantes
FOR EACH ROW EXECUTE FUNCTION fn_set_audit_user();

-- CUENTAS POR COBRAR
CREATE TRIGGER tr_cuentas_cobrar_timestamp
BEFORE UPDATE ON cuentas_por_cobrar_estudiante
FOR EACH ROW EXECUTE FUNCTION fn_actualizar_timestamp();

CREATE TRIGGER tr_cuentas_cobrar_audit_user
BEFORE INSERT OR UPDATE ON cuentas_por_cobrar_estudiante
FOR EACH ROW EXECUTE FUNCTION fn_set_audit_user();

-- TRANSACCIONES PAGO (Solo usuarios, no se actualiza)
CREATE TRIGGER tr_transacciones_audit_user
BEFORE INSERT ON transacciones_pago
FOR EACH ROW EXECUTE FUNCTION fn_set_audit_user();

-- MEJORA: Adjuntar triggers de auditoría robustos a tablas de tesorería
CREATE TRIGGER tr_auditar_cuentas_cobrar
AFTER INSERT OR UPDATE OR DELETE ON cuentas_por_cobrar_estudiante
FOR EACH ROW EXECUTE FUNCTION fn_auditar_cambios('id_cuenta_por_cobrar');

CREATE TRIGGER tr_auditar_transacciones
AFTER INSERT OR DELETE ON transacciones_pago -- Los pagos no se actualizan, se anulan con otra transacción
FOR EACH ROW EXECUTE FUNCTION fn_auditar_cambios('id_transaccion');