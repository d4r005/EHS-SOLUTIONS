-- ============================================
-- EHS SOLUTIONS - QUIZZES Y PRECIOS
-- ============================================

-- 1. Actualizar precios de todos los cursos a 350 MXN
UPDATE public.courses SET price = 350.00;

-- 2. Agregar Quizzes para los cursos principales
-- Curso 31: Seguridad en Trabajos en Alturas
-- Lección final del curso 31 (Procedimientos de Rescate y Emergencia)
INSERT INTO public.quizzes (lesson_id, title, description, passing_score, total_questions, time_limit_minutes)
VALUES (
    (SELECT id FROM lessons WHERE title LIKE '%Rescate%' AND module_id IN (SELECT id FROM modules WHERE course_id = 31) LIMIT 1),
    'Examen Final: Seguridad en Alturas',
    'Evaluación de conocimientos sobre NOM-009, EPP y planes de rescate.',
    80, 5, 15
) ON CONFLICT DO NOTHING;

-- Preguntas para el Quiz de Alturas
WITH q_id AS (SELECT id FROM public.quizzes WHERE title = 'Examen Final: Seguridad en Alturas' LIMIT 1)
INSERT INTO public.quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, order_index)
SELECT id, '¿A partir de qué altura se considera trabajo en alturas según la NOM-009-STPS?', '1.5 metros', '1.8 metros', '2.0 metros', '2.5 metros', 'b', 1 FROM q_id
UNION ALL
SELECT id, '¿Cuál es la resistencia mínima que debe soportar un punto de anclaje por persona?', '1,000 kg', '1,500 kg', '2,267 kg (5,000 lbs)', '5,000 kg', 'c', 2 FROM q_id
UNION ALL
SELECT id, '¿Qué es el síndrome de suspensión?', 'Miedo a las alturas', 'Falta de oxígeno en el cerebro', 'Acumulación de sangre en las piernas por suspensión prolongada', 'Mareo por calor', 'c', 3 FROM q_id
UNION ALL
SELECT id, '¿Cada cuánto debe inspeccionarse el EPP contra caídas?', 'Cada mes', 'Cada año', 'Antes de cada uso', 'Cuando se vea sucio', 'c', 4 FROM q_id
UNION ALL
SELECT id, '¿Cuál es el factor de caída máximo permitido?', 'Factor 0', 'Factor 1', 'Factor 2', 'Factor 3', 'c', 5 FROM q_id
ON CONFLICT DO NOTHING;

-- Curso 32: Espacios Confinados
INSERT INTO public.quizzes (lesson_id, title, description, passing_score, total_questions, time_limit_minutes)
VALUES (
    (SELECT id FROM lessons WHERE title LIKE '%Rescate%' AND module_id IN (SELECT id FROM modules WHERE course_id = 32) LIMIT 1),
    'Examen Final: Espacios Confinados',
    'Evaluación sobre atmósferas, monitoreo y seguridad en entrada.',
    80, 5, 15
) ON CONFLICT DO NOTHING;

-- Preguntas para el Quiz de Espacios Confinados
WITH q_id AS (SELECT id FROM public.quizzes WHERE title = 'Examen Final: Espacios Confinados' LIMIT 1)
INSERT INTO public.quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, order_index)
SELECT id, '¿Cuál es el rango seguro de oxígeno para entrar a un espacio confinado?', '15% - 20%', '19.5% - 23.5%', '21% - 25%', '18% - 22%', 'b', 1 FROM q_id
UNION ALL
SELECT id, '¿Qué gas es conocido como el asesino silencioso por ser inodoro e incoloro?', 'H2S', 'Metano', 'Monóxido de Carbono (CO)', 'Oxígeno', 'c', 3 FROM q_id
ON CONFLICT DO NOTHING;
