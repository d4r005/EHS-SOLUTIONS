-- ============================================================
-- MEJORA: Gestión Administrativa de Inscripciones
-- Ejecutar en Supabase → SQL Editor
-- ============================================================

-- 1) Política para que los Admins puedan INSCRIBIR a cualquier alumno
-- (Actualmente la política "self insert enrollment" solo deja que el alumno se inscriba a sí mismo)
DROP POLICY IF EXISTS "admin insert enrollment" ON public.enrollments;
CREATE POLICY "admin insert enrollment" ON public.enrollments
  FOR INSERT TO authenticated
  WITH CHECK (public.current_user_role() = 'admin');

-- 2) Política para que los Admins puedan DESINSCRIBIR (DELETE) alumnos
DROP POLICY IF EXISTS "admin delete enrollment" ON public.enrollments;
CREATE POLICY "admin delete enrollment" ON public.enrollments
  FOR DELETE TO authenticated
  USING (public.current_user_role() = 'admin');

-- 3) Asegurar que los Admins puedan ACTUALIZAR inscripciones (por si cambian progreso manual)
DROP POLICY IF EXISTS "admin update enrollment" ON public.enrollments;
CREATE POLICY "admin update enrollment" ON public.enrollments
  FOR UPDATE TO authenticated
  USING (public.current_user_role() = 'admin');

-- 4) Política para que los Admins puedan ACTUALIZAR el folio de un certificado
-- (Necesario para pasar de folio TEMP a EHS-2026-NNNN)
DROP POLICY IF EXISTS "admin update certificate" ON public.certificates;
CREATE POLICY "admin update certificate" ON public.certificates
  FOR UPDATE TO authenticated
  USING (public.current_user_role() = 'admin');

-- ============================================================
-- Listo. Las funciones de Admin Dashboard ahora tendrán permisos
-- para gestionar alumnos manualmente.
-- ============================================================
