-- ============================================================
-- EHS SOLUTIONS - CARGA MAESTRA DE 70 PREGUNTAS TÉCNICAS
-- 10 preguntas por curso, vinculadas a la última lección.
-- Ejecutar en Supabase → SQL Editor
-- ============================================================

-- 1. Limpieza total de exámenes y preguntas previas para evitar duplicados
DELETE FROM public.quiz_questions;
DELETE FROM public.quizzes;

-- 2. Procedimiento de Carga Masiva
DO $$
DECLARE
    r RECORD;
    new_quiz_id INT;
BEGIN
    FOR r IN (
        -- Seleccionar la última lección de cada curso publicado
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

        -- A. Crear el Examen con meta de aprobación del 80%
        INSERT INTO public.quizzes (lesson_id, title, description, passing_score, total_questions, is_active)
        VALUES (r.lesson_id, 'Examen Final: ' || r.course_title, 'Evaluación técnica de 10 preguntas. Requiere 80% para aprobar.', 80, 10, true)
        RETURNING id INTO new_quiz_id;

        -- B. Insertar las 10 preguntas por curso

        -- 1. ALTURAS
        IF r.course_title ILIKE '%Alturas%' THEN
            INSERT INTO public.quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, order_index) VALUES
            (new_quiz_id, '¿A partir de qué altura se considera trabajo en alturas según la NOM-009-STPS?', '1.5 metros', '1.8 metros', '2.0 metros', '2.5 metros', 'b', 1),
            (new_quiz_id, '¿Cuál es la resistencia mínima de un punto de anclaje por persona?', '1,000 kg', '1,500 kg', '2,267 kg (5,000 lbs)', '5,000 kg', 'c', 2),
            (new_quiz_id, '¿Qué es el síndrome de suspensión?', 'Miedo a las alturas', 'Pérdida de conciencia por caída', 'Acumulación de sangre en piernas por suspensión inerte', 'Falla del arnés', 'c', 3),
            (new_quiz_id, '¿Cada cuánto debe inspeccionarse el EPP contra caídas?', 'Cada mes', 'Cada año', 'Antes de cada uso', 'Semestralmente', 'c', 4),
            (new_quiz_id, '¿Cuál es el factor de caída más peligroso?', 'Factor 0', 'Factor 1', 'Factor 2', 'Son iguales', 'c', 5),
            (new_quiz_id, 'Distancia máxima de caída libre permitida con sistema de arresto:', '1.0 metros', '1.8 metros', '3.5 metros', '5.0 metros', 'b', 6),
            (new_quiz_id, 'Altura reglamentaria de un barandal de seguridad:', '70 cm', '90 cm (+/- 10cm)', '120 cm', '150 cm', 'b', 7),
            (new_quiz_id, '¿Qué componente absorbe la energía del impacto en una caída?', 'El arnés', 'El punto de anclaje', 'El amortiguador de impacto', 'El conector', 'c', 8),
            (new_quiz_id, '¿Qué tipo de nudo está permitido en una línea de vida de cuerda?', 'Nudo de ocho', 'Nudo corredizo', 'Ninguno, debe ser certificada de fábrica', 'Nudo de guía', 'c', 9),
            (new_quiz_id, 'Vigencia de la capacitación según estándares técnicos:', '6 meses', '1 año', '2 años', 'Indefinida', 'b', 10);

        -- 2. SOLDADURA
        ELSIF r.course_title ILIKE '%Soldadura%' THEN
            INSERT INTO public.quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, order_index) VALUES
            (new_quiz_id, '¿Qué norma regula la soldadura y oxicorte en México?', 'NOM-001', 'NOM-009', 'NOM-027', 'NOM-033', 'c', 1),
            (new_quiz_id, 'Distancia mínima para retirar combustibles del área de soldadura:', '3 metros', '5 metros', '11 metros', '15 metros', 'c', 2),
            (new_quiz_id, 'Grado de sombra mínimo para soldadura de arco (SMAW):', 'DIN 5', 'DIN 8', 'DIN 10', 'DIN 14', 'c', 3),
            (new_quiz_id, 'Función del arrestador de flama:', 'Apagar el soplete', 'Evitar el retroceso de llama al cilindro', 'Regular la presión', 'Ahorrar gas', 'b', 4),
            (new_quiz_id, 'Separación mínima entre cilindros de O2 y combustibles:', '1 metro', '3 metros', '6 metros', '10 metros', 'c', 5),
            (new_quiz_id, 'Tiempo mínimo de vigilancia del vigía tras terminar la soldadura:', '10 min', '20 min', '30 a 60 min', 'No es necesario', 'c', 6),
            (new_quiz_id, 'Riesgo principal de soldar en ambientes húmedos:', 'Mala calidad de soldadura', 'Explosión', 'Choque eléctrico / Electrocución', 'Oxidación', 'c', 7),
            (new_quiz_id, '¿Qué gas es un comburente en el equipo de oxicorte?', 'Acetileno', 'Propano', 'Oxígeno', 'Argón', 'c', 8),
            (new_quiz_id, 'EPP obligatorio para protección de pies en soldadura:', 'Tenis', 'Botas con casquillo y polainas', 'Botas de hule', 'Zapatos de vestir', 'b', 9),
            (new_quiz_id, '¿Cómo se deben mover los cilindros de gas?', 'Rodando horizontalmente', 'Cargados al hombro', 'En carretilla diseñada y encadenados', 'Arrastrándolos', 'c', 10);

        -- 3. BRIGADAS
        ELSIF r.course_title ILIKE '%Brigadas%' THEN
            INSERT INTO public.quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, order_index) VALUES
            (new_quiz_id, '¿Qué significa la S en el método PASS de extintores?', 'Safe / Seguro', 'Squeeze / Apretar', 'Sweep / Barrer', 'Ambas B y C son correctas', 'd', 1),
            (new_quiz_id, 'Frecuencia de compresiones torácicas en RCP adulto:', '60-80 lpm', '80-100 lpm', '100-120 lpm', '150 lpm', 'c', 2),
            (new_quiz_id, 'Relación compresión-ventilación en RCP (un reanimador):', '15:2', '30:2', '5:1', '10:1', 'b', 3),
            (new_quiz_id, 'Primer paso en la regla de oro de primeros auxilios:', 'Socorrer', 'Avisar', 'Proteger (asegurar escena)', 'Trasladar', 'c', 4),
            (new_quiz_id, 'Tipo de fuego Clase C involucra:', 'Madera y papel', 'Líquidos inflamables', 'Equipos eléctricos energizados', 'Metales', 'c', 5),
            (new_quiz_id, 'Profundidad de las compresiones en un adulto:', '2-3 cm', '5-6 cm', '8-10 cm', 'No importa la profundidad', 'b', 6),
            (new_quiz_id, '¿Dónde se aplica el torniquete como último recurso?', 'En el cuello', 'Directo sobre la articulación', 'Entre la herida y el corazón (extremidades)', 'En el abdomen', 'c', 7),
            (new_quiz_id, 'Color de seguridad para fluidos contra incendio (tuberías):', 'Verde', 'Amarillo', 'Rojo', 'Azul', 'c', 8),
            (new_quiz_id, 'Fase de evacuación donde se da la orden de salida:', 'Detección', 'Alarma', 'Preparación', 'Ejecución', 'd', 9),
            (new_quiz_id, 'Maniobra para desobstrucción de vía aérea por objeto extraño:', 'Maniobra de Valsalva', 'Maniobra de Heimlich', 'RCP', 'Posición lateral', 'b', 10);

        -- 4. CONFINADOS
        ELSIF r.course_title ILIKE '%Confinados%' THEN
            INSERT INTO public.quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, order_index) VALUES
            (new_quiz_id, 'Nivel mínimo aceptable de Oxígeno para ingresar:', '16.0%', '18.0%', '19.5%', '20.9%', 'c', 1),
            (new_quiz_id, 'Nivel máximo aceptable de Oxígeno para evitar explosiones:', '21.0%', '23.5%', '25.0%', '30.0%', 'b', 2),
            (new_quiz_id, 'El Monóxido de Carbono (CO) es peligroso porque:', 'Huele muy mal', 'Es altamente corrosivo', 'Es inodoro, incoloro y desplaza el O2 en sangre', 'Es de color verde', 'c', 3),
            (new_quiz_id, '¿Qué gas huele a "huevos podridos" a bajas concentraciones?', 'Metano', 'CO2', 'H2S (Ácido Sulfhídrico)', 'Nitrógeno', 'c', 4),
            (new_quiz_id, 'Orden correcto del monitoreo atmosférico:', 'Tóxicos -> O2 -> LEL', 'O2 -> LEL -> Tóxicos', 'LEL -> Tóxicos -> O2', 'Cualquier orden', 'b', 5),
            (new_quiz_id, 'Función principal del Vigía (Atendedor):', 'Entrar a ayudar', 'Limpiar el área', 'Mantener comunicación y activar rescate', 'Reparar el equipo', 'c', 6),
            (new_quiz_id, 'Un espacio Tipo II se caracteriza por:', 'Riesgo mínimo', 'Atmósfera IDLH o peligro inminente', 'Ser muy espacioso', 'Tener buena ventilación natural', 'b', 7),
            (new_quiz_id, 'Gases más ligeros que el aire se encuentran en:', 'El fondo del espacio', 'La parte superior', 'En medio', 'No se mueven', 'b', 8),
            (new_quiz_id, 'Límite Inferior de Explosividad (LEL) máximo para entrada:', '0% LEL', '10% LEL', '50% LEL', '100% LEL', 'a', 9),
            (new_quiz_id, '¿Quién autoriza el permiso de entrada?', 'El trabajador', 'El vigía', 'El supervisor / responsable de seguridad', 'El chofer', 'c', 10);

        -- 5. LOTO
        ELSIF r.course_title ILIKE '%LOTO%' THEN
            INSERT INTO public.quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, order_index) VALUES
            (new_quiz_id, '¿Qué significa LOTO?', 'Logística de Operación', 'Lockout / Tagout', 'Level of Total Output', 'Ley de Organización', 'b', 1),
            (new_quiz_id, 'Definición de "Energía Cero":', 'Bajar el interruptor', 'Eliminar energías residuales y bloquear fuentes', 'Poner una etiqueta', 'Desconectar un cable', 'b', 2),
            (new_quiz_id, '¿Quién es el Personal Autorizado?', 'Quien opera la máquina', 'Quien realiza el bloqueo y mantenimiento', 'El gerente', 'El visitante', 'b', 3),
            (new_quiz_id, '¿Quién puede retirar un candado de seguridad?', 'El supervisor', 'Cualquier compañero', 'Únicamente el dueño del candado', 'El de mantenimiento', 'c', 4),
            (new_quiz_id, 'Paso final del procedimiento LOTO antes de trabajar:', 'Poner el candado', 'Poner la tarjeta', 'Verificación de aislamiento (probar arranque)', 'Limpiar', 'c', 5),
            (new_quiz_id, '¿Qué información NO es obligatoria en una tarjeta LOTO?', 'Nombre del trabajador', 'Motivo del bloqueo', 'Fecha', 'Sueldo del trabajador', 'd', 6),
            (new_quiz_id, 'Tipos de energía a bloquear:', 'Eléctrica y mecánica', 'Neumática e hidráulica', 'Química y térmica', 'Todas las anteriores', 'd', 7),
            (new_quiz_id, 'Propósito del dispositivo de bloqueo múltiple (pinza):', 'Para que el candado no se caiga', 'Permitir que varios trabajadores pongan su candado', 'Para cerrar válvulas grandes', 'Estética', 'b', 8),
            (new_quiz_id, '¿Qué hacer si un candado se queda puesto y el dueño no está?', 'Cortarlo sin avisar', 'Seguir protocolo de retiro forzado con supervisor', 'Esperar al día siguiente', 'Dejar la máquina encendida', 'b', 9),
            (new_quiz_id, '¿El Tagout (etiqueta) por sí solo bloquea la energía?', 'Sí, es suficiente', 'No, es solo una advertencia visual', 'Depende del color', 'Solo en equipos pequeños', 'b', 10);

        -- 6. INSTRUCTORES
        ELSIF r.course_title ILIKE '%Instructores%' THEN
            INSERT INTO public.quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, order_index) VALUES
            (new_quiz_id, '¿Qué es la Andragogía?', 'Educación de niños', 'Enseñanza de idiomas', 'Educación y aprendizaje de adultos', 'Teoría de la comunicación', 'c', 1),
            (new_quiz_id, 'En objetivos SMART, la M significa:', 'Motivante', 'Medible', 'Moderno', 'Manual', 'b', 2),
            (new_quiz_id, 'Nivel de Kirkpatrick que mide si el alumno aplica lo aprendido:', 'Nivel 1 (Reacción)', 'Nivel 2 (Aprendizaje)', 'Nivel 3 (Transferencia / Comportamiento)', 'Nivel 4 (Resultados)', 'c', 3),
            (new_quiz_id, 'Documento legal en México que acredita habilidades laborales:', 'Título profesional', 'Diploma de honor', 'Formato DC-3', 'Acta de nacimiento', 'c', 4),
            (new_quiz_id, 'Técnica de feedback "Sándwich":', 'Crítica - Positivo - Crítica', 'Positivo - Crítica constructiva - Positivo', 'Solo críticas', 'Solo elogios', 'b', 5),
            (new_quiz_id, 'Un instructor efectivo debe dedicar más tiempo a:', 'Leer diapositivas', 'Interacción y dinámicas prácticas', 'Hablar de su vida personal', 'Dictar notas', 'b', 6),
            (new_quiz_id, 'Estilo de aprendizaje basado en "hacer" y experimentar:', 'Visual', 'Auditivo', 'Kinestésico', 'Lecto-escritura', 'c', 7),
            (new_quiz_id, '¿Qué debe hacerse al inicio de un curso?', 'Examen final', 'Rompehielo y encuadre (objetivos/reglas)', 'Cerrar la sesión', 'Pedir la DC-3', 'b', 8),
            (new_quiz_id, 'La evaluación de reacción se aplica:', '6 meses después', 'Antes de empezar', 'Al finalizar el curso (satisfacción)', 'Nunca', 'c', 9),
            (new_quiz_id, 'Propósito del material de apoyo:', 'Sustituir al instructor', 'Entretener al grupo', 'Facilitar la comprensión del contenido', 'Llenar tiempo', 'c', 10);

        -- 7. SUPERVISORES
        ELSIF r.course_title ILIKE '%Supervisores%' THEN
            INSERT INTO public.quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, order_index) VALUES
            (new_quiz_id, 'Diferencia entre Peligro y Riesgo:', 'Son lo mismo', 'Peligro es la fuente, Riesgo es la probabilidad de daño', 'Riesgo es la fuente, Peligro la probabilidad', 'No existen diferencias', 'b', 1),
            (new_quiz_id, 'Medida más efectiva en la Jerarquía de Controles:', 'EPP', 'Controles Administrativos', 'Eliminación', 'Sustitución', 'c', 2),
            (new_quiz_id, '¿Qué norma establece los servicios preventivos de seguridad?', 'NOM-017', 'NOM-030', 'NOM-035', 'NOM-026', 'b', 3),
            (new_quiz_id, 'Metodología para investigar causas raíz de un accidente:', 'Cuestionario de culpa', 'Árbol de causas', 'Lanzar una moneda', 'Intuición', 'b', 4),
            (new_quiz_id, '¿Qué es un Acto Inseguro?', 'Una falla en la máquina', 'Comportamiento humano que rompe el procedimiento', 'Falta de iluminación', 'Piso resbaloso', 'b', 5),
            (new_quiz_id, '¿Qué es una Condición Insegura?', 'No usar casco', 'Correr en la planta', 'Instalación o equipo en mal estado', 'Llegar tarde', 'c', 6),
            (new_quiz_id, 'Función del Análisis de Seguridad en el Trabajo (AST):', 'Calcular la nómina', 'Identificar peligros paso a paso en una tarea', 'Hacer inventario', 'Evaluar el clima laboral', 'b', 7),
            (new_quiz_id, 'Norma para la integración de la Comisión de Seguridad e Higiene:', 'NOM-001', 'NOM-019', 'NOM-025', 'NOM-031', 'b', 8),
            (new_quiz_id, 'La "Seguridad Basada en el Comportamiento" se enfoca en:', 'Las máquinas', 'Los procesos químicos', 'Las acciones y decisiones de las personas', 'El presupuesto', 'c', 9),
            (new_quiz_id, '¿Qué significa ser un líder visible en seguridad?', 'Tener un chaleco reflejante', 'Estar en la oficina siempre', 'Demostrar compromiso con acciones y presencia en campo', 'Tener muchas cámaras', 'c', 10);
        END IF;

    END LOOP;
END $$;

-- 3. Verificación Final de Carga
SELECT q.title as examen, l.title as leccion, c.title as curso, count(qq.id) as total_preguntas
FROM public.quizzes q
JOIN public.quiz_questions qq ON qq.quiz_id = q.id
JOIN public.lessons l ON q.lesson_id = l.id
JOIN public.modules m ON l.module_id = m.id
JOIN public.courses c ON m.course_id = c.id
GROUP BY q.title, l.title, c.title;
