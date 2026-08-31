-- ============================================================
-- FIX URGENTE: Recursión infinita en RLS de tabla "users"
--
-- PROBLEMA: La política "self or staff select user" llamaba a
-- current_user_role() que lee la tabla users → RLS evalúa la
-- política → llama current_user_role() → recursión infinita.
-- Error: 42P17 "infinite recursion detected in policy for relation users"
--
-- SOLUCIÓN:
-- 1) Recrear funciones con SET search_path (necesario en Supabase)
-- 2) Dividir la política en dos: self-access SIN función (rompe el ciclo)
--    admin-access CON función (Security Definer bypassa RLS)
-- ============================================================

-- 1) Recrear funciones helper con SET search_path = public
CREATE OR REPLACE FUNCTION public.current_user_id()
RETURNS integer
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public
AS $$
  SELECT id FROM public.users WHERE auth_id = auth.uid()
$$;

CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS text
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public
AS $$
  SELECT role FROM public.users WHERE auth_id = auth.uid()
$$;

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public
AS $$
  SELECT public.current_user_role() = 'admin'
$$;

-- 2) Asegurar owner = postgres (tiene BYPASSRLS en Supabase)
ALTER FUNCTION public.current_user_id() OWNER TO postgres;
ALTER FUNCTION public.current_user_role() OWNER TO postgres;
ALTER FUNCTION public.is_admin() OWNER TO postgres;

-- 3) EL FIX CLAVE: dividir la política de users
DROP POLICY IF EXISTS "self or staff select user" ON public.users;
DROP POLICY IF EXISTS "self select user" ON public.users;
DROP POLICY IF EXISTS "staff select user" ON public.users;

-- 3a) Usuario lee SU PROPIA fila (auth.uid() directo, SIN función → no recursión)
CREATE POLICY "self select user" ON public.users
  FOR SELECT TO authenticated
  USING (auth_id = auth.uid());

-- 3b) Admin/instructor lee cualquier fila (la función ya bypassa RLS)
CREATE POLICY "staff select user" ON public.users
  FOR SELECT TO authenticated
  USING (public.current_user_role() IN ('admin', 'instructor'));

-- 4) Listo. El login debería funcionar de inmediato.
SELECT 'Fix aplicado correctamente' as resultado;
