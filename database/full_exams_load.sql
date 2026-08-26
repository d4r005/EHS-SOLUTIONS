-- ============================================================
-- EHS SOLUTIONS - CARGA MASIVA DE EXÁMENES TÉCNICOS
-- Crea exámenes finales para los 7 cursos con 3 preguntas c/u.
-- Ejecutar en Supabase → SQL Editor
-- ============================================================

-- 1. Limpieza de registros previos
DELETE FROM public.quiz_questions WHERE quiz_id IN (SELECT id FROM public.quizzes WHERE title LIKE 'Examen Final%');
DELETE FROM public.quizzes WHERE title LIKE 'Examen Final%';

-- 2. Procedimiento para carga automática
DO $$
DECLARE
    r RECORD;
    new_quiz_id INT;
BEGIN
    FOR r IN (
        -- Buscar la última lección de cada curso publicado
        SELECT DISTINCT ON (c.id)
            c.id as course_id,
            c.title as course_title,
            l.id as lesson_id
        FROM public.courses c
        JOIN public.modules m ON m.course_id = c.id
        JOIN public.lessons l ON l.module_id = m.id
        WHERE c.is_published = true
        ORDER BY c.id, l.id DESC
    ) LOOP

        -- A. Crear el Examen
        INSERT INTO public.quizzes (lesson_id, title, description, passing_score, total_questions, is_active)
        VALUES (r.lesson_id, 'Examen Final: ' || r.course_title, 'Evaluación técnica integral del curso.', 80, 3, true)
        RETURNING id INTO new_quiz_id;

        -- B. Insertar Preguntas según el curso
        IF r.course_title ILIKE '%Alturas%' THEN
            INSERT INTO public.quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, order_index) VALUES
            (new_quiz_id, '¿A partir de qué altura se considera trabajo en alturas según la NOM-009-STPS?', '1.5 metros', '1.8 metros', '2.0 metros', '2.5 metros', 'b', 1),
            (new_quiz_id, '¿Cuál es la resistencia mínima de un punto de anclaje por persona?', '1,000 kg', '1,500 kg', '2,267 kg (5,000 lbs)', '5,000 kg', 'c', 2),
            (new_quiz_id, '¿Qué es el síndrome de suspensión?', 'Miedo a las alturas', 'Pérdida de conciencia por caída', 'Acumulación de sangre en piernas por suspensión inerte', 'Falla del arnés', 'c', 3);

        ELSIF r.course_title ILIKE '%Soldadura%' THEN
            INSERT INTO public.quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, order_index) VALUES
            (new_quiz_id, '¿Cuál es el grado de oscurecimiento mínimo para soldadura SMAW?', 'DIN 5', 'DIN 8', 'DIN 10', 'DIN 14', 'c', 1),
            (new_quiz_id, '¿A qué distancia mínima deben retirarse materiales combustibles antes de soldar?', '2 metros', '5 metros', '11 metros', '20 metros', 'c', 2),
            (new_quiz_id, '¿Qué gas se utiliza comúnmente en oxicorte junto con el oxígeno?', 'Helio', 'Acetileno', 'Nitrógeno', 'Argón', 'b', 3);

        ELSIF r.course_title ILIKE '%Brigadas%' THEN
            INSERT INTO public.quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, order_index) VALUES
            (new_quiz_id, '¿Qué significan las siglas PASS en el uso de extintores?', 'Pulsar, Apuntar, Salir, Sentarse', 'Pull, Aim, Squeeze, Sweep', 'Presión, Aire, Seguridad, Salida', 'Parar, Avisar, Socorrer, Seguir', 'b', 1),
            (new_quiz_id, '¿Cuál es el primer paso en la regla de oro de primeros auxilios?', 'Avisar', 'Socorrer', 'Proteger', 'Trasladar', 'c', 2),
            (new_quiz_id, '¿Qué frecuencia de compresiones se recomienda en RCP?', '60-80 por minuto', '80-100 por minuto', '100-120 por minuto', '140-160 por minuto', 'c', 3);

        ELSIF r.course_title ILIKE '%Confinados%' THEN
            INSERT INTO public.quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, order_index) VALUES
            (new_quiz_id, '¿Cuál es el rango seguro de oxígeno para ingreso humano?', '15% - 20%', '19.5% - 23.5%', '21% - 25%', '18% - 22%', 'b', 1),
            (new_quiz_id, '¿Qué gas es inodoro, incoloro y letal en espacios confinados?', 'H2S', 'Cloro', 'Monóxido de Carbono (CO)', 'Dióxido de Carbono', 'c', 2),
            (new_quiz_id, '¿Qué rol debe permanecer SIEMPRE fuera del espacio confinado?', 'Rescatista', 'Vigía o Atendedor', 'Supervisor', 'Ingeniero', 'b', 3);

        ELSIF r.course_title ILIKE '%LOTO%' THEN
            INSERT INTO public.quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, order_index) VALUES
            (new_quiz_id, '¿Qué significa la sigla LOTO?', 'Low Tension Operation', 'Lockout / Tagout', 'Level of Total Output', 'Logistics of Training Operations', 'b', 1),
            (new_quiz_id, '¿Cuál es el paso final indispensable antes de iniciar el trabajo con LOTO?', 'Poner el candado', 'Poner la etiqueta', 'Verificación de energía cero', 'Firmar el permiso', 'c', 2),
            (new_quiz_id, '¿Quién es el único autorizado para retirar un candado?', 'El supervisor', 'El dueño del candado', 'El gerente de planta', 'Cualquier compañero', 'b', 3);

        ELSIF r.course_title ILIKE '%Instructores%' THEN
            INSERT INTO public.quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, order_index) VALUES
            (new_quiz_id, '¿Cómo se le llama a la disciplina que estudia el aprendizaje en adultos?', 'Pedagogía', 'Andragogía', 'Psicología', 'Sociología', 'b', 1),
            (new_quiz_id, '¿Qué porcentaje del tiempo de capacitación debe ser idealmente interacción?', '20%', '50%', '80%', '100%', 'c', 2),
            (new_quiz_id, '¿Qué nivel de evaluación de Kirkpatrick mide la aplicación en el trabajo?', 'Nivel 1: Reacción', 'Nivel 2: Aprendizaje', 'Nivel 3: Comportamiento', 'Nivel 4: Resultados', 'c', 3);

        ELSIF r.course_title ILIKE '%Supervisores%' THEN
            INSERT INTO public.quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, order_index) VALUES
            (new_quiz_id, '¿Qué norma mexicana regula los servicios preventivos de seguridad y salud?', 'NOM-001', 'NOM-019', 'NOM-030', 'NOM-035', 'c', 1),
            (new_quiz_id, '¿Cuál es el objetivo principal de la investigación de accidentes?', 'Buscar culpables', 'Encontrar causas raíz para prevenir', 'Llenar registros legales', 'Sancionar trabajadores', 'b', 2),
            (new_quiz_id, 'En la jerarquía de controles, ¿cuál es la medida más efectiva?', 'EPP', 'Señalización', 'Eliminación del riesgo', 'Controles de ingeniería', 'c', 3);
        END IF;

    END LOOP;
END $$;

-- Verificación final
SELECT q.title as examen, l.title as leccion_final, c.title as curso, count(qq.id) as num_preguntas
FROM public.quizzes q
JOIN public.lessons l ON q.lesson_id = l.id
JOIN public.modules m ON l.module_id = m.id
JOIN public.courses c ON m.course_id = c.id
JOIN public.quiz_questions qq ON qq.quiz_id = q.id
GROUP BY q.title, l.title, c.title;
