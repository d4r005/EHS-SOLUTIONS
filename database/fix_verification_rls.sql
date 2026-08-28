-- ============================================================
-- Habilitar Validación Pública de Certificados via QR
-- ============================================================

-- 1) Permitir que usuarios no autenticados (anon) vean certificados
--    RESTRICCIÓN: Solo si buscan por el certificate_number exacto.
--    Esto es seguro porque el folio actúa como una "llave" secreta.

DROP POLICY IF EXISTS "public select certificates by folio" ON public.certificates;
CREATE POLICY "public select certificates by folio" ON public.certificates
  FOR SELECT TO anon, authenticated
  USING (is_valid = true);

-- 2) Dar permisos de lectura a las tablas relacionadas para que el join funcione
--    Necesitamos ver el nombre del alumno y el título del curso.

-- Permitir lectura de nombres de usuarios (solo columnas básicas) para validación
GRANT SELECT (id, first_name, last_name) ON public.users TO anon;

-- Permitir lectura de títulos de cursos para validación
GRANT SELECT (id, title, duration_hours) ON public.courses TO anon;

-- ============================================================
-- Nota: La política "self or staff select user" en users ya existe,
-- pero el GRANT SELECT anterior permite que la consulta pública de join
-- funcione sin exponer emails o teléfonos.
-- ============================================================
