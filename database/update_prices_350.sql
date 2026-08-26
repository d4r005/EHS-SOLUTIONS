-- ============================================
-- EHS SOLUTIONS - ACTUALIZACIÓN DE PRECIOS
-- Establecer costo de 350 MXN para los cursos
-- ============================================

-- Actualizar todos los cursos publicados con un precio de 350
UPDATE public.courses
SET price = 350.00
WHERE is_published = true;

-- Verificar cambios
-- SELECT id, title, price FROM public.courses WHERE is_published = true;
