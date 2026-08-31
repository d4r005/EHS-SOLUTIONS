-- ============================================================
-- FIX DE SEGURIDAD - EHS Solutions LMS
-- Ejecutar en Supabase → SQL Editor (proyecto tsqlpjliqslgzookdqvg)
-- 100% re-ejecutable (DROP IF EXISTS antes de cada CREATE)
-- ============================================================

-- ============================================================
-- 0) PRE-REQUISITO: crear/asegurar funciones helper de las que
--    depende todo lo demás (por si fix_foundation_v2.sql o
--    fix_rls_policies_v3.sql no se ejecutaron antes en este proyecto).
-- ============================================================

-- Asegurar columna auth_id en users (necesaria para las funciones helper)
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS auth_id UUID REFERENCES auth.users(id);

CREATE OR REPLACE FUNCTION public.current_user_id()
RETURNS integer LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT id FROM public.users WHERE auth_id = auth.uid();
$$;

CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS text LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT role FROM public.users WHERE auth_id = auth.uid();
$$;

-- ============================================================
-- 1) CRÍTICO: Cerrar fuga de certificados vía verificación pública
--    Antes: anon podía leer TODOS los certificados válidos.
--    Ahora: anon solo puede verificar por folio vía función.
-- ============================================================

-- Función SECURITY DEFINER: busca por folio y devuelve solo campos públicos
CREATE OR REPLACE FUNCTION public.verify_certificate_by_folio(folio text)
RETURNS TABLE (
  certificate_number text,
  student_first_name text,
  student_last_name text,
  course_title text,
  course_duration_hours integer,
  issued_date timestamptz,
  is_valid boolean
)
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT
    c.certificate_number,
    u.first_name,
    u.last_name,
    co.title,
    co.duration_hours,
    c.issued_date,
    c.is_valid
  FROM public.certificates c
  JOIN public.users u ON u.id = c.student_id
  JOIN public.courses co ON co.id = c.course_id
  WHERE c.is_valid = true
    AND c.certificate_number = folio;
$$;

-- Dar permiso de ejecución a anon y authenticated
GRANT EXECUTE ON FUNCTION public.verify_certificate_by_folio(text) TO anon, authenticated;

-- Quitar el GRANT SELECT directo a anon en certificates (ya no lo necesita)
REVOKE SELECT ON public.certificates FROM anon;

-- Eliminar la política anterior que era demasiado amplia
DROP POLICY IF EXISTS "public select certificates by folio" ON public.certificates;

-- Reforzar users: anon solo ve columnas de instructor
REVOKE SELECT ON public.users FROM anon;
GRANT SELECT (id, first_name, last_name, avatar_url, bio) ON public.users TO anon;

-- ============================================================
-- 2) ALTO: RLS de escritura en COURSES, MODULES, LESSONS
--    Solo admin e instructor pueden escribir.
-- ============================================================

-- COURSES
DROP POLICY IF EXISTS "staff manage courses" ON public.courses;
CREATE POLICY "staff manage courses" ON public.courses
  FOR ALL TO authenticated
  USING (public.current_user_role() IN ('admin', 'instructor'))
  WITH CHECK (public.current_user_role() IN ('admin', 'instructor'));

-- Lectura pública (refuerzo)
DROP POLICY IF EXISTS "allow_read_published" ON public.courses;
CREATE POLICY "allow_read_published" ON public.courses
  FOR SELECT TO authenticated, anon
  USING (is_published = true OR instructor_id = public.current_user_id() OR public.current_user_role() = 'admin');

-- MODULES
ALTER TABLE public.modules ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "read published modules" ON public.modules;
CREATE POLICY "read published modules" ON public.modules
  FOR SELECT TO authenticated, anon
  USING (
    EXISTS (
      SELECT 1 FROM public.courses c
      WHERE c.id = modules.course_id
      AND (c.is_published = true OR c.instructor_id = public.current_user_id() OR public.current_user_role() = 'admin')
    )
  );

DROP POLICY IF EXISTS "staff manage modules" ON public.modules;
CREATE POLICY "staff manage modules" ON public.modules
  FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.courses c
      WHERE c.id = modules.course_id
      AND public.current_user_role() IN ('admin', 'instructor')
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.courses c
      WHERE c.id = modules.course_id
      AND public.current_user_role() IN ('admin', 'instructor')
    )
  );

-- LESSONS
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "read published lessons" ON public.lessons;
CREATE POLICY "read published lessons" ON public.lessons
  FOR SELECT TO authenticated, anon
  USING (
    EXISTS (
      SELECT 1 FROM public.modules m
      JOIN public.courses c ON c.id = m.course_id
      WHERE m.id = lessons.module_id
      AND (c.is_published = true OR c.instructor_id = public.current_user_id() OR public.current_user_role() = 'admin')
    )
  );

DROP POLICY IF EXISTS "staff manage lessons" ON public.lessons;
CREATE POLICY "staff manage lessons" ON public.lessons
  FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.modules m
      JOIN public.courses c ON c.id = m.course_id
      WHERE m.id = lessons.module_id
      AND public.current_user_role() IN ('admin', 'instructor')
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.modules m
      JOIN public.courses c ON c.id = m.course_id
      WHERE m.id = lessons.module_id
      AND public.current_user_role() IN ('admin', 'instructor')
    )
  );

-- GRANTs explícitos
GRANT SELECT ON public.modules TO anon, authenticated;
GRANT SELECT ON public.lessons TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.modules TO authenticated;
GRANT INSERT, UPDATE, DELETE ON public.lessons TO authenticated;
GRANT SELECT ON public.courses TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.courses TO authenticated;

-- ============================================================
-- 3) ALTO: Admin-only para cambiar role e is_active en users
-- ============================================================

-- Función helper
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT public.current_user_role() = 'admin';
$$;

-- Extender GRANT UPDATE para incluir role e is_active
GRANT UPDATE (
  first_name, last_name, bio, avatar_url, phone,
  curp, ocupacion, puesto, company_name, company_rfc,
  role, is_active
) ON public.users TO authenticated;

-- Usuario actualiza su propio perfil (sin role ni is_active)
DROP POLICY IF EXISTS "self update profile" ON public.users;
CREATE POLICY "self update profile" ON public.users
  FOR UPDATE TO authenticated
  USING (auth_id = auth.uid())
  WITH CHECK (auth_id = auth.uid());

-- Admin puede actualizar cualquier usuario
DROP POLICY IF EXISTS "admin update any user" ON public.users;
CREATE POLICY "admin update any user" ON public.users
  FOR UPDATE TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- ============================================================
-- 4) MEDIO: Admin puede gestionar inscripciones (INSERT/DELETE)
-- ============================================================

DROP POLICY IF EXISTS "admin manage enrollments" ON public.enrollments;
CREATE POLICY "admin manage enrollments" ON public.enrollments
  FOR ALL TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

GRANT DELETE ON public.enrollments TO authenticated;

-- ============================================================
-- 5) MEDIO: UNIQUE constraint en certificates (student_id, course_id)
-- ============================================================

-- Eliminar duplicados existentes
DELETE FROM public.certificates
WHERE id NOT IN (
  SELECT MIN(id) FROM public.certificates
  GROUP BY student_id, course_id
);

ALTER TABLE public.certificates
  DROP CONSTRAINT IF EXISTS uniq_student_course_certificate;
ALTER TABLE public.certificates
  ADD CONSTRAINT uniq_student_course_certificate UNIQUE (student_id, course_id);

-- ============================================================
-- 6) Refuerzo: admin lectura total en enrollments, certificates, orders
-- ============================================================

DROP POLICY IF EXISTS "admin select all enrollments" ON public.enrollments;
CREATE POLICY "admin select all enrollments" ON public.enrollments
  FOR SELECT TO authenticated
  USING (public.is_admin());

DROP POLICY IF EXISTS "admin select all certificates" ON public.certificates;
CREATE POLICY "admin select all certificates" ON public.certificates
  FOR SELECT TO authenticated
  USING (public.is_admin());

DROP POLICY IF EXISTS "admin select all orders" ON public.orders;
CREATE POLICY "admin select all orders" ON public.orders
  FOR SELECT TO authenticated
  USING (public.is_admin());

-- ============================================================
-- FIN.
-- Verificar: SELECT tablename, policyname, cmd FROM pg_policies WHERE schemaname = 'public' ORDER BY tablename, policyname;
-- ============================================================
