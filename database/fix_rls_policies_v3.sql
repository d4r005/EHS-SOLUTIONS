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
