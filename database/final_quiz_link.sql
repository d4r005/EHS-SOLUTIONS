-- ============================================================
-- VINCULACIÓN DEFINITIVA DE EXÁMENES (REPARACIÓN FINAL)
-- Ejecutar en Supabase → SQL Editor
-- ============================================================

-- 1. Limpiar cualquier examen mal vinculado que no tenga preguntas
DELETE FROM public.quizzes WHERE id NOT IN (SELECT quiz_id FROM public.quiz_questions);

-- 2. Vincular examen de ALTURAS a su lección correspondiente
-- Busca la lección que contenga "Rescate" del curso "Seguridad en Trabajos en Alturas"
UPDATE public.quizzes q
SET lesson_id = (
  SELECT l.id
  FROM public.lessons l
  JOIN public.modules m ON l.module_id = m.id
  JOIN public.courses c ON m.course_id = c.id
  WHERE c.title ILIKE '%Alturas%'
  AND l.title ILIKE '%Rescate%'
  LIMIT 1
)
WHERE q.title ILIKE '%Alturas%';

-- 3. Vincular examen de ESPACIOS CONFINADOS
UPDATE public.quizzes q
SET lesson_id = (
  SELECT l.id
  FROM public.lessons l
  JOIN public.modules m ON l.module_id = m.id
  JOIN public.courses c ON m.course_id = c.id
  WHERE c.title ILIKE '%Espacios Confinados%'
  AND l.title ILIKE '%Rescate%'
  LIMIT 1
)
WHERE q.title ILIKE '%Espacios Confinados%';

-- 4. Verificar vinculaciones
SELECT q.title as examen, l.title as leccion_vinculada, c.title as curso
FROM public.quizzes q
JOIN public.lessons l ON q.lesson_id = l.id
JOIN public.modules m ON l.module_id = m.id
JOIN public.courses c ON m.course_id = c.id;
