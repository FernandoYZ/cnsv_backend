-- =================================================================
-- 1. ÍNDICES ESTRATÉGICOS
-- =================================================================
CREATE INDEX idx_provincias_departamento ON provincias(id_departamento);
CREATE INDEX idx_distritos_provincia ON distritos(id_provincia);
CREATE INDEX idx_perm_roles_rol ON permisos_roles(id_rol);
CREATE INDEX idx_acc_roles_rol ON acciones_roles(id_rol);
CREATE INDEX idx_periodos_anio ON periodos(id_anio);
CREATE INDEX idx_grados_nivel ON grados(id_nivel);
CREATE INDEX idx_grados_sector ON grados(id_sector);
CREATE INDEX idx_materias_curso ON materias(id_curso);
CREATE INDEX idx_empleados_cargo ON empleados(id_cargo);
CREATE INDEX idx_profesores_especialidad ON profesores(especialidad_principal);
CREATE INDEX idx_prof_apt_curso ON profesores_aptitudes(id_curso);
CREATE INDEX idx_usuarios_rol ON usuarios(id_rol);
CREATE INDEX idx_estudiantes_distrito ON estudiantes(id_distrito);
CREATE INDEX idx_est_fam_familiar ON estudiantes_familiares(id_familiar);
CREATE INDEX idx_secciones_grado ON secciones(id_grado);
CREATE INDEX idx_secciones_anio ON secciones(id_anio);
CREATE INDEX idx_secciones_tutor ON secciones(tutor_id);
CREATE INDEX idx_matriculas_estudiante ON matriculas(id_estudiante);
CREATE INDEX idx_matriculas_seccion ON matriculas(id_seccion);
CREATE INDEX idx_matriculas_tipo ON matriculas(id_tipo_matricula);
CREATE INDEX idx_clases_seccion ON clases_programadas(id_seccion);
CREATE INDEX idx_clases_materia ON clases_programadas(id_materia);
CREATE INDEX idx_clases_profesor ON clases_programadas(id_profesor);
CREATE INDEX idx_prog_clase ON programacion_clases(id_clase_programada);
CREATE INDEX idx_prog_turno ON programacion_clases(id_turno);
CREATE INDEX idx_criterios_clase ON criterios_evaluacion(id_clase_programada);
CREATE INDEX idx_criterios_periodo ON criterios_evaluacion(id_periodo);
CREATE INDEX idx_notas_matricula ON notas(id_matricula);
CREATE INDEX idx_notas_clase ON notas(id_clase_programada);
CREATE INDEX idx_notas_periodo ON notas(id_periodo);
CREATE INDEX idx_notas_criterio ON notas(id_criterio_eval);
CREATE INDEX idx_asistencias_matricula ON asistencias(id_matricula);
CREATE INDEX idx_asistencias_clase ON asistencias(id_clase_programada);
CREATE INDEX idx_asistencias_tipo ON asistencias(id_tipo_asistencia);
CREATE INDEX idx_asistencias_fecha ON asistencias(fecha);
CREATE INDEX idx_sesiones_usuario ON sesiones_refresh(id_usuario);
CREATE INDEX idx_auditoria_usuario ON auditoria_sistema(id_usuario);
CREATE INDEX idx_auditoria_tabla_registro ON auditoria_sistema(tabla_afectada, id_registro_afectado);
CREATE INDEX idx_empleados_email ON empleados(email);
CREATE INDEX idx_estudiantes_dni ON estudiantes(dni);

-- =================================================================
-- 2. ÍNDICES PARA MÓDULOS ADICIONALES
-- =================================================================
-- 0. Institución
CREATE INDEX idx_institucion_ruc ON institucion(ruc);

-- 15.1. Expediente
CREATE INDEX idx_expediente_matricula ON expediente_academico(id_matricula);
CREATE INDEX idx_expediente_curso ON expediente_academico(id_curso);

-- 15.2. Disciplina
CREATE INDEX idx_incidencias_matricula ON incidencias_estudiantes(id_matricula);
CREATE INDEX idx_incidencias_tipo ON incidencias_estudiantes(id_tipo_incidencia);
CREATE INDEX idx_incidencias_usuario ON incidencias_estudiantes(id_usuario_reporta);

-- 15.3. Tesorería
CREATE INDEX idx_servicios_anio ON servicios_catalogo(id_anio);
CREATE INDEX idx_servicios_req_servicio ON servicios_requisitos(id_servicio);
CREATE INDEX idx_cuentas_matricula ON cuentas_por_cobrar_estudiante(id_matricula);
CREATE INDEX idx_cuentas_servicio ON cuentas_por_cobrar_estudiante(id_servicio);
CREATE INDEX idx_cuentas_estado ON cuentas_por_cobrar_estudiante(id_estado_pago);
CREATE INDEX idx_transacciones_cuenta ON transacciones_pago(id_cuenta_por_cobrar);
CREATE INDEX idx_transacciones_usuario ON transacciones_pago(id_usuario_registra);
CREATE INDEX idx_transacciones_metodo ON transacciones_pago(id_metodo_pago);

-- 15.4. Comunicaciones
CREATE INDEX idx_eventos_anio ON calendario_eventos(id_anio);
CREATE INDEX idx_anuncios_autor ON anuncios(id_usuario_autor);
CREATE INDEX idx_destinatarios_anuncio ON anuncios_destinatarios(id_anuncio);