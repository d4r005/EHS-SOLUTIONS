-- ============================================================
-- FIX DEFINITIVO v3: Recursión infinita en RLS de "users"
--
-- Ni plpgsql ni SECURITY DEFINER bastan: PostgreSQL detecta la
-- recursión a nivel estático del planificador de políticas, antes
-- de ejecutar la función. Si una política en "users" llama a
-- cualquier función que lea "users", truena con 42P17.
--
-- SOLUCIÓN REAL:
-- 1) Self-access: auth_id = auth.uid() (sin función, sin recursión)
-- 2) Admin/instructor: auth.jwt() ->> 'user_metadata' ->> 'role'
--    (lee del JWT, no de la tabla → no hay recursión)
-- 3) Quitar TODA política en users que llame current_user_role()/is_admin()
-- 4) Para otras tablas (enrollments, etc.) las funciones plpgsql SÍ
--    funcionan porque la política está en otra tabla, no en users.
-- ============================================================

-- 1) Drop TODA política existente en users que use funciones
DROP POLICY IF EXISTS "self or staff select user" ON public.users;
DROP POLICY IF EXISTS "self select user" ON public.users;
DROP POLICY IF EXISTS "staff select user" ON public.users;
DROP POLICY IF EXISTS "public select instructors" ON public.users;
DROP POLICY IF EXISTS "self insert profile" ON public.users;
DROP POLICY IF EXISTS "self update profile" ON public.users;
DROP POLICY IF EXISTS "admin update any user" ON public.users;

-- 2) Self-access: auth.uid() directo. SIN función. Cero recursión.
CREATE POLICY "self select user" ON public.users
  FOR SELECT TO authenticated
  USING (auth_id = auth.uid());

-- 3) Admin/instructor access: leer role del JWT (no de la tabla)
--    El JWT tiene user_metadata.role que se asigna al registrarse.
--    Nota: si cambias el role de un usuario en la BD, el JWT no se
--    actualiza hasta que el usuario vuelva a hacer login. Esto es
--    aceptable para el panel de admin (el admin sigue siendo admin).
CREATE POLICY "staff select user" ON public.users
  FOR SELECT TO authenticated
  USING (
    (auth.jwt() -> 'user_metadata' ->> 'role') IN ('admin', 'instructor')
  );

-- 4) anon: solo instructores (para catálogo público)
CREATE POLICY "public select instructors" ON public.users
  FOR SELECT TO anon
  USING (role = 'instructor');

-- 5) Insert: usuario crea su propio perfil al registrarse
CREATE POLICY "self insert profile" ON public.users
  FOR INSERT TO authenticated
  WITH CHECK (auth_id = auth.uid());

-- 6) Update: usuario edita su propio perfil (sin role/is_active)
CREATE POLICY "self update profile" ON public.users
  FOR UPDATE TO authenticated
  USING (auth_id = auth.uid())
  WITH CHECK (auth_id = auth.uid());

-- 7) Admin update: admin puede editar cualquier usuario
--    Usar JWT para evitar recursión
CREATE POLICY "admin update any user" ON public.users
  FOR UPDATE TO authenticated
  USING (
    (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
  )
  WITH CHECK (
    (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
  );

-- 8) Las funciones plpgsql siguen existiendo para OTRAS tablas
--    (enrollments, quiz_results, etc.) donde no hay auto-referencia
--    y por tanto no hay recursión.

SELECT 'Fix v3 aplicado - policies en users usan auth.jwt() sin recursión' as resultado;
