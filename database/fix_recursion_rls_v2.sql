-- ============================================================
-- FIX DEFINITIVO v2: Recursión infinita en RLS de "users"
--
-- El fix anterior (fix_recursion_rls.sql) no fue suficiente.
-- CAUSA REAL: las funciones estaban en LANGUAGE sql (SQL simple).
-- Postgres puede "inlinear" (pegar) el cuerpo de una función SQL
-- simple directo dentro de la política que la llama. Al hacer eso,
-- la política de "users" termina conteniendo literalmente un
-- "SELECT ... FROM users" DENTRO de sí misma → recursión, y el
-- SECURITY DEFINER deja de proteger porque ya no es una llamada
-- de función real, es código pegado inline.
--
-- FIX: cambiar las funciones a LANGUAGE plpgsql. Las funciones
-- plpgsql NUNCA se inlinean — Postgres las trata siempre como una
-- caja negra, así que el SECURITY DEFINER (bypass RLS) sí aplica
-- de forma confiable, incluso llamadas desde dentro de una política
-- de la misma tabla que protegen.
-- ============================================================

CREATE OR REPLACE FUNCTION public.current_user_id()
RETURNS integer
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  result integer;
BEGIN
  SELECT id INTO result FROM public.users WHERE auth_id = auth.uid();
  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS text
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public
AS $$
DECLARE
  result text;
BEGIN
  SELECT role INTO result FROM public.users WHERE auth_id = auth.uid();
  RETURN result;
END;
$$;

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  RETURN public.current_user_role() = 'admin';
END;
$$;

ALTER FUNCTION public.current_user_id() OWNER TO postgres;
ALTER FUNCTION public.current_user_role() OWNER TO postgres;
ALTER FUNCTION public.is_admin() OWNER TO postgres;

SELECT 'Fix v2 aplicado - funciones ahora son plpgsql (no inlineables)' as resultado;
