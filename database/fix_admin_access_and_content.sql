-- ============================================================
-- FIX: acceso de admin al contenido (textos y videos)
-- Ejecutar en Supabase → SQL Editor (proyecto tsqlpjliqslgzookdqvg)
--
-- DIAGNÓSTICO (confirmado con la service_role key):
-- 1) A la tabla `lessons` en la BD real le falta la columna `content`
--    (existe en database/schema.sql pero nunca se migró a Supabase).
--    Por eso ninguna lección de tipo texto puede guardar/mostrar contenido.
-- 2) La tabla `enrollments` (y probablemente lesson_progress/quiz_results/
--    certificates) tiene políticas RLS rotas: comparan `student_id`
--    (entero, FK a public.users.id) contra auth.uid() (UUID de Auth).
--    Como son sistemas de ID distintos y nunca están vinculados, TODO
--    insert de inscripción falla con 403 para TODOS los usuarios,
--    incluido el admin. Por eso nadie puede "entrar" a revisar el
--    contenido: el botón Inscribirme nunca inscribe a nadie.
-- ============================================================

-- 1) Columna faltante para el contenido de texto de las lecciones
ALTER TABLE public.lessons ADD COLUMN IF NOT EXISTS content TEXT;

-- 2) Vincular public.users con auth.users (Supabase Auth) para que RLS
--    pueda saber "quién soy" de forma consistente
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

-- 3) Políticas correctas (se suman a las que ya existan; no hace falta
--    borrar las rotas porque las políticas permisivas se combinan con OR)

-- Enrollments: cada estudiante puede inscribirse/ver lo suyo; admin/instructor ven todo
CREATE POLICY IF NOT EXISTS "self insert enrollment" ON public.enrollments
  FOR INSERT TO authenticated
  WITH CHECK (student_id = public.current_user_id());

CREATE POLICY IF NOT EXISTS "self or staff select enrollment" ON public.enrollments
  FOR SELECT TO authenticated
  USING (student_id = public.current_user_id()
         OR public.current_user_role() IN ('admin', 'instructor'));

-- Lesson progress: mismo criterio
CREATE POLICY IF NOT EXISTS "self insert progress" ON public.lesson_progress
  FOR INSERT TO authenticated
  WITH CHECK (student_id = public.current_user_id());

CREATE POLICY IF NOT EXISTS "self upsert progress" ON public.lesson_progress
  FOR UPDATE TO authenticated
  USING (student_id = public.current_user_id());

CREATE POLICY IF NOT EXISTS "self or staff select progress" ON public.lesson_progress
  FOR SELECT TO authenticated
  USING (student_id = public.current_user_id()
         OR public.current_user_role() IN ('admin', 'instructor'));

-- ============================================================
-- Después de correr esto: cierra sesión y vuelve a entrar como
-- admin@ehs-solutions.com — el dashboard/panel seguirá sin ser un
-- "panel admin" real (eso falta construirse, ver lista de pendientes),
-- pero ya podrás inscribirte y abrir cualquier lección para revisar
-- textos y videos.
-- ============================================================
