-- ============================================================
-- FIX DEFINITIVO: Políticas RLS (sintaxis corregida)
-- Ejecutar en Supabase → SQL Editor (proyecto tsqlpjliqslgzookdqvg)
--
-- POR QUÉ FALLABAN LOS SCRIPTS ANTERIORES:
-- PostgreSQL NO soporta "CREATE POLICY IF NOT EXISTS" — esa sintaxis
-- solo existe para CREATE TABLE / CREATE INDEX. Los archivos
-- database/fix_admin_access_and_content.sql y database/add_orders_table.sql
-- usaban esa sintaxis inválida y por eso tronaban con:
--   ERROR: 42601: syntax error at or near "NOT"
-- La forma correcta en Postgres es: DROP POLICY IF EXISTS ... seguido de
-- CREATE POLICY ... (sin "IF NOT EXISTS"). Este archivo reemplaza a
-- esos dos y es 100% seguro de re-ejecutar cuantas veces quieras.
-- ============================================================

-- 1) Columna de contenido de texto en lecciones (ya puede existir)
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS content TEXT;

-- 2) Vincular public.users con auth.users (ya puede existir, es idempotente)
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS auth_id UUID REFERENCES auth.users(id);

UPDATE public.users u
SET auth_id = a.id
FROM auth.users a
WHERE a.email = u.email AND u.auth_id IS NULL;

CREATE OR REPLACE FUNCTION public.current_user_id()
RETURNS integer LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT id FROM public.users WHERE auth_id = auth.uid()
$$;

CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS text LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT role FROM public.users WHERE auth_id = auth.uid()
$$;

-- ============================================================
-- 3) ENROLLMENTS
-- ============================================================
ALTER TABLE public.enrollments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "self insert enrollment" ON public.enrollments;
CREATE POLICY "self insert enrollment" ON public.enrollments
  FOR INSERT TO authenticated
  WITH CHECK (student_id = public.current_user_id());

DROP POLICY IF EXISTS "self or staff select enrollment" ON public.enrollments;
CREATE POLICY "self or staff select enrollment" ON public.enrollments
  FOR SELECT TO authenticated
  USING (student_id = public.current_user_id()
         OR public.current_user_role() IN ('admin', 'instructor'));

DROP POLICY IF EXISTS "self update enrollment" ON public.enrollments;
CREATE POLICY "self update enrollment" ON public.enrollments
  FOR UPDATE TO authenticated
  USING (student_id = public.current_user_id());

-- ============================================================
-- 4) LESSON_PROGRESS
-- ============================================================
ALTER TABLE public.lesson_progress ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "self insert progress" ON public.lesson_progress;
CREATE POLICY "self insert progress" ON public.lesson_progress
  FOR INSERT TO authenticated
  WITH CHECK (student_id = public.current_user_id());

DROP POLICY IF EXISTS "self upsert progress" ON public.lesson_progress;
CREATE POLICY "self upsert progress" ON public.lesson_progress
  FOR UPDATE TO authenticated
  USING (student_id = public.current_user_id());

DROP POLICY IF EXISTS "self or staff select progress" ON public.lesson_progress;
CREATE POLICY "self or staff select progress" ON public.lesson_progress
  FOR SELECT TO authenticated
  USING (student_id = public.current_user_id()
         OR public.current_user_role() IN ('admin', 'instructor'));

-- ============================================================
-- 5) QUIZ_RESULTS
-- ============================================================
ALTER TABLE public.quiz_results ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "self insert quiz_result" ON public.quiz_results;
CREATE POLICY "self insert quiz_result" ON public.quiz_results
  FOR INSERT TO authenticated
  WITH CHECK (student_id = public.current_user_id());

DROP POLICY IF EXISTS "self update quiz_result" ON public.quiz_results;
CREATE POLICY "self update quiz_result" ON public.quiz_results
  FOR UPDATE TO authenticated
  USING (student_id = public.current_user_id());

DROP POLICY IF EXISTS "self or staff select quiz_result" ON public.quiz_results;
CREATE POLICY "self or staff select quiz_result" ON public.quiz_results
  FOR SELECT TO authenticated
  USING (student_id = public.current_user_id()
         OR public.current_user_role() IN ('admin', 'instructor'));

-- ============================================================
-- 6) QUIZZES / QUIZ_QUESTIONS (lectura pública para alumnos autenticados)
-- ============================================================
ALTER TABLE public.quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz_questions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "authenticated select quizzes" ON public.quizzes;
CREATE POLICY "authenticated select quizzes" ON public.quizzes
  FOR SELECT TO authenticated
  USING (true);

DROP POLICY IF EXISTS "staff manage quizzes" ON public.quizzes;
CREATE POLICY "staff manage quizzes" ON public.quizzes
  FOR ALL TO authenticated
  USING (public.current_user_role() IN ('admin', 'instructor'));

DROP POLICY IF EXISTS "authenticated select quiz_questions" ON public.quiz_questions;
CREATE POLICY "authenticated select quiz_questions" ON public.quiz_questions
  FOR SELECT TO authenticated
  USING (true);

DROP POLICY IF EXISTS "staff manage quiz_questions" ON public.quiz_questions;
CREATE POLICY "staff manage quiz_questions" ON public.quiz_questions
  FOR ALL TO authenticated
  USING (public.current_user_role() IN ('admin', 'instructor'));

-- ============================================================
-- 7) CERTIFICATES
-- ============================================================
ALTER TABLE public.certificates ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "self insert certificate" ON public.certificates;
CREATE POLICY "self insert certificate" ON public.certificates
  FOR INSERT TO authenticated
  WITH CHECK (student_id = public.current_user_id());

DROP POLICY IF EXISTS "self or staff select certificate" ON public.certificates;
CREATE POLICY "self or staff select certificate" ON public.certificates
  FOR SELECT TO authenticated
  USING (student_id = public.current_user_id()
         OR public.current_user_role() IN ('admin', 'instructor'));

-- ============================================================
-- 8) ORDERS (tabla de pagos de MercadoPago — ya existe en tu BD)
-- ============================================================
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "self select orders" ON public.orders;
CREATE POLICY "self select orders" ON public.orders
  FOR SELECT TO authenticated
  USING (student_id = public.current_user_id());

DROP POLICY IF EXISTS "admin select orders" ON public.orders;
CREATE POLICY "admin select orders" ON public.orders
  FOR SELECT TO authenticated
  USING (public.current_user_role() = 'admin');

-- Nota: los INSERT a "orders" y "enrollments" tras un pago los hace
-- el webhook de MercadoPago (functions/api/mercadopago-webhook.js)
-- usando la Service Role Key, que ignora RLS — por eso no necesita
-- una política de INSERT aquí.

-- ============================================================
-- Listo. Este archivo puede volver a ejecutarse sin riesgo.
-- Los archivos fix_admin_access_and_content.sql y add_orders_table.sql
-- quedan obsoletos — usa siempre este (fix_rls_policies_v3.sql).
-- ============================================================

-- ============================================================
-- 9) USERS — cerrar la fuga de datos (password hashes, email, teléfono
--    expuestos públicamente porque esta tabla NUNCA tuvo RLS activado)
-- ============================================================

-- 9.1) Trigger: vincular auth_id automáticamente al registrarse
--      (antes solo se vinculaba con un UPDATE manual, dejando a los
--      usuarios nuevos sin poder leer/actualizar su propio perfil)
CREATE OR REPLACE FUNCTION public.set_auth_id_on_insert()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  IF NEW.auth_id IS NULL THEN
    NEW.auth_id := auth.uid();
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_set_auth_id ON public.users;
CREATE TRIGGER trg_set_auth_id BEFORE INSERT ON public.users
  FOR EACH ROW EXECUTE FUNCTION public.set_auth_id_on_insert();

-- 9.2) Activar RLS y quitar los permisos amplios por defecto
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.users FROM anon, authenticated;

-- 9.3) anon (visitantes sin sesión): solo nombre/foto/bio de INSTRUCTORES
--      (lo necesario para mostrar "impartido por" en el catálogo público)
GRANT SELECT (id, first_name, last_name, avatar_url, bio) ON public.users TO anon;

DROP POLICY IF EXISTS "public select instructors" ON public.users;
CREATE POLICY "public select instructors" ON public.users
  FOR SELECT TO anon
  USING (role = 'instructor');

-- 9.4) authenticated: su propio perfil completo (sin password), o si es
--      admin/instructor, el perfil de cualquiera (para gestión/roster).
--      La columna "password" queda excluida del GRANT para TODOS —
--      ya no se usa (login es 100% Supabase Auth) y nunca debe leerse por API.
GRANT SELECT (
  id, first_name, last_name, email, role, bio, avatar_url, phone,
  is_active, created_at, updated_at, auth_id,
  curp, ocupacion, puesto, company_name, company_rfc
) ON public.users TO authenticated;

DROP POLICY IF EXISTS "self or staff select user" ON public.users;
CREATE POLICY "self or staff select user" ON public.users
  FOR SELECT TO authenticated
  USING (auth_id = auth.uid() OR public.current_user_role() IN ('admin', 'instructor'));

-- 9.5) authenticated puede insertar su propio perfil al registrarse
GRANT INSERT ON public.users TO authenticated;

DROP POLICY IF EXISTS "self insert profile" ON public.users;
CREATE POLICY "self insert profile" ON public.users
  FOR INSERT TO authenticated
  WITH CHECK (auth_id = auth.uid());

-- 9.6) authenticated puede actualizar SOLO su propio perfil, y solo
--      columnas de datos personales (nunca role, email ni password)
GRANT UPDATE (
  first_name, last_name, bio, avatar_url, phone,
  curp, ocupacion, puesto, company_name, company_rfc
) ON public.users TO authenticated;

DROP POLICY IF EXISTS "self update profile" ON public.users;
CREATE POLICY "self update profile" ON public.users
  FOR UPDATE TO authenticated
  USING (auth_id = auth.uid())
  WITH CHECK (auth_id = auth.uid());

-- ============================================================
-- Fin de la sección 9. Este archivo sigue siendo 100% re-ejecutable.
-- ============================================================
