-- ############################################################
-- ###  EHS SOLUTIONS - EXAMENES DE LECCION (3 preguntas) DE LOS 7 CURSOS NUEVOS
-- ###
-- ###  Esquema: cada una de las 3 primeras lecciones del curso lleva un examen
-- ###  de 3 preguntas (70% para aprobar). El examen final de 10 preguntas
-- ###  ya existe sobre la ultima leccion y este script NO lo toca.
-- ###
-- ###  Ejecutar despues de los scripts 01 a 07, en Supabase -> SQL Editor.
-- ###  Es idempotente: se puede volver a ejecutar sin duplicar examenes.
-- ############################################################

BEGIN;

-- 0. Verificacion: los 7 cursos deben existir con el titulo exacto
DO $guard$
DECLARE
  faltantes text;
BEGIN
  SELECT string_agg(t, ' | ') INTO faltantes
  FROM (VALUES
    ('Manejo Seguro de Montacargas'),
    ('Formación para Integrantes de la Comisión de Seguridad e Higiene (NOM-019-STPS-2011)'),
    ('Manejo Seguro de Sustancias Químicas Peligrosas (NOM-018-STPS-2015)'),
    ('Seguridad en Trabajos de Operación y Mantenimiento de Instalaciones Eléctricas (NOM-029-STPS-2011)'),
    ('Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018)'),
    ('Seguridad en la Cadena de Suministro y Concientización CTPAT'),
    ('Técnicos en Urgencias Médicas Nivel 1 (Básico)')
  ) AS x(t)
  WHERE NOT EXISTS (SELECT 1 FROM public.courses c WHERE c.title = x.t);

  IF faltantes IS NOT NULL THEN
    RAISE EXCEPTION 'Faltan cursos con el titulo exacto: %', faltantes;
  END IF;
END
$guard$;

-- 1. Limpieza: borra solo los examenes de leccion previos de estos cursos
--    (no toca el examen final de 10 preguntas)
DELETE FROM public.quizzes
WHERE lesson_id IN (
  SELECT l.id
  FROM public.lessons l
  JOIN public.modules m ON m.id = l.module_id
  JOIN public.courses c ON c.id = m.course_id
  WHERE c.title IN (
    'Manejo Seguro de Montacargas', 'Formación para Integrantes de la Comisión de Seguridad e Higiene (NOM-019-STPS-2011)', 'Manejo Seguro de Sustancias Químicas Peligrosas (NOM-018-STPS-2015)', 'Seguridad en Trabajos de Operación y Mantenimiento de Instalaciones Eléctricas (NOM-029-STPS-2011)', 'Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018)', 'Seguridad en la Cadena de Suministro y Concientización CTPAT', 'Técnicos en Urgencias Médicas Nivel 1 (Básico)'
  )
)
AND title NOT LIKE 'Examen Final:%';

-- 2. Examen de 3 preguntas por cada una de las 3 primeras lecciones
INSERT INTO public.quizzes (lesson_id, title, description, passing_score, total_questions, is_active)
SELECT l.id,
       'Examen: ' || l.title,
       'Evaluacion de 3 preguntas. Requiere 70% para aprobar.',
       70, 3, true
FROM (VALUES
    ('Manejo Seguro de Montacargas', 'Marco normativo y responsabilidades del operador'),
    ('Manejo Seguro de Montacargas', 'Tipos de montacargas, componentes y revisión preoperacional'),
    ('Manejo Seguro de Montacargas', 'Estabilidad, centro de carga y capacidad nominal'),
    ('Formación para Integrantes de la Comisión de Seguridad e Higiene (NOM-019-STPS-2011)', 'Marco normativo y obligaciones del patrón'),
    ('Formación para Integrantes de la Comisión de Seguridad e Higiene (NOM-019-STPS-2011)', 'Constitución, integración y funciones de la comisión'),
    ('Formación para Integrantes de la Comisión de Seguridad e Higiene (NOM-019-STPS-2011)', 'Recorridos de verificación de condiciones de seguridad'),
    ('Manejo Seguro de Sustancias Químicas Peligrosas (NOM-018-STPS-2015)', 'Marco normativo y comunicación de peligros'),
    ('Manejo Seguro de Sustancias Químicas Peligrosas (NOM-018-STPS-2015)', 'Sistema armonizado: pictogramas, palabras de advertencia y etiquetas'),
    ('Manejo Seguro de Sustancias Químicas Peligrosas (NOM-018-STPS-2015)', 'Hojas de datos de seguridad (SDS) y su uso real'),
    ('Seguridad en Trabajos de Operación y Mantenimiento de Instalaciones Eléctricas (NOM-029-STPS-2011)', 'Efectos de la corriente eléctrica y marco normativo'),
    ('Seguridad en Trabajos de Operación y Mantenimiento de Instalaciones Eléctricas (NOM-029-STPS-2011)', 'Clasificación de trabajos eléctricos y distancias de seguridad'),
    ('Seguridad en Trabajos de Operación y Mantenimiento de Instalaciones Eléctricas (NOM-029-STPS-2011)', 'Trabajo desenergizado: las cinco reglas de oro'),
    ('Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018)', 'Marco normativo y obligaciones en manejo manual de cargas'),
    ('Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018)', 'Factores de riesgo ergonómico y anatomía de la lesión'),
    ('Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018)', 'Evaluación ergonómica del puesto de trabajo'),
    ('Seguridad en la Cadena de Suministro y Concientización CTPAT', 'Origen, alcance y beneficios del programa CTPAT'),
    ('Seguridad en la Cadena de Suministro y Concientización CTPAT', 'Criterios mínimos de seguridad del programa'),
    ('Seguridad en la Cadena de Suministro y Concientización CTPAT', 'Análisis de riesgos y plan de seguridad'),
    ('Técnicos en Urgencias Médicas Nivel 1 (Básico)', 'Rol del TUM, marco legal y bioseguridad'),
    ('Técnicos en Urgencias Médicas Nivel 1 (Básico)', 'Evaluación inicial del paciente: método ABCDE'),
    ('Técnicos en Urgencias Médicas Nivel 1 (Básico)', 'Manejo inicial del trauma y soporte vital básico')
) AS v(course_title, lesson_title)
JOIN public.courses c ON c.title = v.course_title
JOIN public.modules m ON m.course_id = c.id
JOIN public.lessons l ON l.module_id = m.id AND l.title = v.lesson_title;

-- 3. Las 3 preguntas de cada examen

-- Manejo Seguro de Montacargas :: Marco normativo y responsabilidades del operador
INSERT INTO public.quiz_questions
  (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.ca, v.ex, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Cuál es la norma oficial mexicana que regula el manejo y almacenamiento de materiales mediante el uso de maquinaria?', 'NOM-006-STPS', 'NOM-011-STPS', 'NOM-018-STPS', 'NOM-030-STPS', 'a', 'La NOM-006-STPS establece las condiciones de seguridad para el manejo y almacenamiento de materiales con maquinaria, incluidos los montacargas.', 1),
  ('¿Quién es responsable de verificar la capacidad de carga y las condiciones del equipo antes de operar?', 'El área de almacén', 'El operador', 'El proveedor del equipo', 'El cliente', 'b', 'El operador realiza la revisión preoperacional y es responsable de respetar la capacidad nominal del equipo.', 2),
  ('¿Qué se requiere para operar un montacargas por primera vez en la empresa?', 'Firmar una carta de responsabilidad', 'Capacitación y autorización documentada', 'Tener licencia de conducir automovilista', 'Un año de antigüedad en el puesto', 'b', 'La norma exige capacitación específica y autorización documentada antes de permitir la operación de la maquinaria.', 3)
) AS v(qt, a, b, c, d, ca, ex, ord)
WHERE q.title = 'Examen: Marco normativo y responsabilidades del operador';

-- Manejo Seguro de Montacargas :: Tipos de montacargas, componentes y revisión preoperacional
INSERT INTO public.quiz_questions
  (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.ca, v.ex, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Cuándo debe realizarse la revisión preoperacional del montacargas?', 'Al inicio de cada turno', 'Una vez al mes', 'Una vez al año', 'Solo cuando se reporta una falla', 'a', 'La revisión se hace al inicio de cada turno, antes de usar el equipo, y queda registrada.', 1),
  ('¿Dónde se consulta la capacidad nominal de carga del montacargas?', 'En el manual del proveedor', 'En la placa de datos del equipo', 'En el piso del almacén', 'En el contrato de arrendamiento', 'b', 'La placa de datos indica la capacidad nominal y la distancia al centro de carga con la que fue certificado el equipo.', 2),
  ('Durante la revisión preoperacional se detecta que los frenos no responden. ¿Qué se debe hacer?', 'Operar con precaución', 'Retirar el equipo de servicio y reportarlo', 'Programarlo a mantenimiento al final del turno', 'Bajar la carga a la mitad', 'b', 'Cualquier falla que comprometa la seguridad obliga a sacar el equipo de servicio de inmediato y reportarla.', 3)
) AS v(qt, a, b, c, d, ca, ex, ord)
WHERE q.title = 'Examen: Tipos de montacargas, componentes y revisión preoperacional';

-- Manejo Seguro de Montacargas :: Estabilidad, centro de carga y capacidad nominal
INSERT INTO public.quiz_questions
  (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.ca, v.ex, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Qué es el centro de carga en una carga paletizada?', 'El peso total del pallet', 'El punto de equilibrio de la carga', 'La distancia del talón de la horquilla al centro de gravedad de la carga', 'La altura máxima de elevación', 'c', 'El centro de carga es la distancia horizontal desde el talón de la horquilla hasta el centro de gravedad de la carga.', 1),
  ('Si la carga se acomoda con el centro de gravedad más alejado de la horquilla, la capacidad segura del equipo:', 'Aumenta', 'Disminuye', 'No cambia', 'Se duplica', 'b', 'Al alejarse el centro de carga aumenta el momento sobre el mástil y la capacidad segura del montacargas disminuye.', 2),
  ('¿Cuál es el principal riesgo de trasladarse con la carga elevada y el mástil inclinado hacia adelante?', 'Mayor consumo de combustible', 'Pérdida de estabilidad y riesgo de vuelco', 'Desgaste de las llantas', 'Daño al piso del almacén', 'b', 'Elevar la carga desplaza el centro de gravedad y, junto con la inclinación hacia adelante, provoca pérdida de estabilidad.', 3)
) AS v(qt, a, b, c, d, ca, ex, ord)
WHERE q.title = 'Examen: Estabilidad, centro de carga y capacidad nominal';

-- Formación para Integrantes de la Comisión de Seguridad e Hig :: Marco normativo y obligaciones del patrón
INSERT INTO public.quiz_questions
  (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.ca, v.ex, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Qué regula la NOM-019-STPS-2011?', 'El manejo de sustancias químicas', 'La constitución, integración, organización y funcionamiento de las comisiones de seguridad e higiene', 'El mantenimiento de instalaciones eléctricas', 'El manejo manual de cargas', 'b', 'La NOM-019-STPS-2011 establece cómo se constituyen, integran, organizan y funcionan las comisiones de seguridad e higiene.', 1),
  ('En un centro de trabajo con menos de diez trabajadores, ¿qué se debe designar?', 'Una comisión completa', 'Un encargado de seguridad e higiene', 'Nada, la norma no aplica', 'Un auditor externo', 'b', 'En centros con menos de diez trabajadores se designa un encargado de seguridad e higiene en lugar de una comisión.', 2),
  ('¿Quién debe proporcionar los recursos y facilidades para que la comisión funcione?', 'Los trabajadores', 'El patrón', 'La autoridad laboral', 'La aseguradora', 'b', 'El patrón debe proporcionar los recursos y facilidades necesarias para la operación de la comisión.', 3)
) AS v(qt, a, b, c, d, ca, ex, ord)
WHERE q.title = 'Examen: Marco normativo y obligaciones del patrón';

-- Formación para Integrantes de la Comisión de Seguridad e Hig :: Constitución, integración y funciones de la comisión
INSERT INTO public.quiz_questions
  (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.ca, v.ex, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Cómo se integra la comisión de seguridad e higiene?', 'Solo por representantes del patrón', 'Con igual número de representantes del patrón y de los trabajadores', 'Solo por trabajadores sindicalizados', 'Por personal externo contratado', 'b', 'La comisión se integra con igual número de representantes del patrón y de los trabajadores, con sus respectivos suplentes.', 1),
  ('¿Cuál es una función central de la comisión?', 'Autorizar pagos de nómina', 'Identificar condiciones de riesgo y proponer medidas de control', 'Contratar al personal de vigilancia', 'Diseñar los productos de la empresa', 'b', 'La comisión investiga condiciones peligrosas, propone medidas de prevención y da seguimiento a su implementación.', 2),
  ('Los integrantes de la comisión deben ser:', 'Designados por la autoridad laboral', 'Voluntarios y capacitados para la función', 'Exclusivamente del área de mantenimiento', 'Personal con más de cinco años de antigüedad', 'b', 'Los integrantes se postulan de forma voluntaria y deben recibir capacitación para desempeñar la función.', 3)
) AS v(qt, a, b, c, d, ca, ex, ord)
WHERE q.title = 'Examen: Constitución, integración y funciones de la comisión';

-- Formación para Integrantes de la Comisión de Seguridad e Hig :: Recorridos de verificación de condiciones de seguridad
INSERT INTO public.quiz_questions
  (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.ca, v.ex, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Qué se documenta en el acta de un recorrido de verificación?', 'Solo las áreas que cumplen', 'Las condiciones peligrosas detectadas y las medidas propuestas', 'Los nombres de los trabajadores ausentes', 'El inventario del almacén', 'b', 'El acta registra las condiciones peligrosas detectadas, las medidas de control propuestas y los responsables de atenderlas.', 1),
  ('¿Con qué periodicidad mínima deben realizarse los recorridos de verificación?', 'Diaria', 'Semanal', 'Mensual', 'Trimestral', 'd', 'La norma establece recorridos de verificación al menos trimestrales, sin perjuicio de los que se realicen por situaciones específicas.', 2),
  ('Se detecta una condición de riesgo inminente durante el recorrido. ¿Cuál es la acción correcta?', 'Anotarla en el acta y esperar la siguiente reunión', 'Suspender la actividad y reportar de inmediato', 'Reubicar al personal sin reportar', 'Ignorarla si no hay lesionados', 'b', 'Ante un riesgo inminente se suspende la actividad y se notifica de inmediato para atenderlo antes de continuar.', 3)
) AS v(qt, a, b, c, d, ca, ex, ord)
WHERE q.title = 'Examen: Recorridos de verificación de condiciones de seguridad';

-- Manejo Seguro de Sustancias Químicas Peligrosas (NOM-018-STP :: Marco normativo y comunicación de peligros
INSERT INTO public.quiz_questions
  (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.ca, v.ex, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Qué regula la NOM-018-STPS-2015?', 'El equipo de protección personal', 'El sistema armonizado de identificación y comunicación de peligros de sustancias químicas peligrosas', 'El mantenimiento de instalaciones eléctricas', 'La ergonomía en el trabajo', 'b', 'La NOM-018 establece el sistema armonizado para identificar y comunicar los peligros y riesgos de las sustancias químicas peligrosas.', 1),
  ('¿Qué documento debe estar disponible para cada sustancia química peligrosa?', 'La ficha técnica del proveedor', 'La hoja de datos de seguridad', 'El contrato de compra', 'El certificado de calidad', 'b', 'La hoja de datos de seguridad reúne la información de peligros, primeros auxilios, manejo y respuesta ante derrames.', 2),
  ('¿A quiénes se debe comunicar el peligro de una sustancia química en el centro de trabajo?', 'Solo al personal de mantenimiento', 'A todos los trabajadores expuestos o que puedan estarlo', 'Solo a los supervisores', 'Solo al personal de nuevo ingreso', 'b', 'La comunicación de peligros debe llegar a todo el personal expuesto o que pueda exponerse, incluidos contratistas.', 3)
) AS v(qt, a, b, c, d, ca, ex, ord)
WHERE q.title = 'Examen: Marco normativo y comunicación de peligros';

-- Manejo Seguro de Sustancias Químicas Peligrosas (NOM-018-STP :: Sistema armonizado: pictogramas, palabras de advertencia y etiquetas
INSERT INTO public.quiz_questions
  (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.ca, v.ex, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Cuántos pictogramas contempla el sistema globalmente armonizado?', 'Cinco', 'Siete', 'Nueve', 'Doce', 'c', 'El sistema globalmente armonizado contempla nueve pictogramas que cubren los distintos tipos de peligro.', 1),
  ('¿Qué indica el pictograma de llama?', 'Material inflamable', 'Material corrosivo', 'Riesgo de explosión', 'Peligro para la salud', 'a', 'El pictograma de llama identifica sustancias inflamables y otras con riesgo de ignición.', 2),
  ('La palabra de advertencia Peligro se utiliza para:', 'Los peligros menos graves', 'Los peligros más graves', 'Los residuos no peligrosos', 'Las sustancias sin clasificar', 'b', 'Peligro corresponde a las categorías de mayor gravedad, mientras que Atención se usa para las menos graves.', 3)
) AS v(qt, a, b, c, d, ca, ex, ord)
WHERE q.title = 'Examen: Sistema armonizado: pictogramas, palabras de advertencia y etiquetas';

-- Manejo Seguro de Sustancias Químicas Peligrosas (NOM-018-STP :: Hojas de datos de seguridad (SDS) y su uso real
INSERT INTO public.quiz_questions
  (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.ca, v.ex, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Cuántas secciones tiene una hoja de datos de seguridad conforme al sistema armonizado?', 'Ocho', 'Doce', 'Dieciséis', 'Veinte', 'c', 'La hoja de datos de seguridad se estructura en dieciséis secciones normalizadas.', 1),
  ('¿En qué sección de la hoja de datos de seguridad se encuentran las medidas de primeros auxilios?', 'Sección 2', 'Sección 4', 'Sección 8', 'Sección 14', 'b', 'La sección 4 describe los primeros auxilios que deben aplicarse ante la exposición a la sustancia.', 2),
  ('¿Dónde debe estar disponible la hoja de datos de seguridad?', 'Resguardada en la oficina del gerente', 'Accesible para los trabajadores en el área donde se usa la sustancia', 'Solo en el sistema del proveedor', 'En el expediente del área de compras', 'b', 'La hoja de datos de seguridad debe ser accesible para quien maneja la sustancia, en el idioma del trabajador.', 3)
) AS v(qt, a, b, c, d, ca, ex, ord)
WHERE q.title = 'Examen: Hojas de datos de seguridad (SDS) y su uso real';

-- Seguridad en Trabajos de Operación y Mantenimiento de Instal :: Efectos de la corriente eléctrica y marco normativo
INSERT INTO public.quiz_questions
  (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.ca, v.ex, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Qué norma establece las condiciones de seguridad para el mantenimiento de las instalaciones eléctricas en los centros de trabajo?', 'NOM-004-STPS', 'NOM-029-STPS-2011', 'NOM-036-1-STPS-2018', 'NOM-019-STPS-2011', 'b', 'La NOM-029-STPS-2011 establece las condiciones de seguridad para el mantenimiento de las instalaciones eléctricas.', 1),
  ('¿Qué factor determina principalmente la gravedad del daño por contacto eléctrico?', 'El color del cable', 'La intensidad de la corriente y el tiempo de exposición', 'La marca del equipo', 'La altura del tablero', 'b', 'La gravedad del daño depende de la intensidad, el tiempo de exposición y la trayectoria de la corriente por el cuerpo.', 2),
  ('¿Qué es un arco eléctrico?', 'Una descarga atmosférica', 'Una liberación de energía entre conductores que genera calor extremo y radiación', 'Un cortocircuito sin energía', 'Una falla mecánica del interruptor', 'b', 'El arco eléctrico libera gran cantidad de energía en forma de calor, luz y presión, y puede causar quemaduras graves.', 3)
) AS v(qt, a, b, c, d, ca, ex, ord)
WHERE q.title = 'Examen: Efectos de la corriente eléctrica y marco normativo';

-- Seguridad en Trabajos de Operación y Mantenimiento de Instal :: Clasificación de trabajos eléctricos y distancias de seguridad
INSERT INTO public.quiz_questions
  (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.ca, v.ex, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Cuáles son los dos tipos de trabajo eléctrico que reconoce la norma?', 'Preventivo y correctivo', 'Energizado y desenergizado', 'Interno y externo', 'Simple y complejo', 'b', 'El trabajo eléctrico se clasifica en energizado, cuando la instalación permanece con tensión, y desenergizado, cuando se aísla.', 1),
  ('¿Qué debe respetarse al acercarse a partes energizadas?', 'La distancia de seguridad aplicable al nivel de tensión', 'Solo la señalización del piso', 'La altura del operador', 'El ancho del pasillo', 'a', 'Deben respetarse las distancias de seguridad que la norma establece según el nivel de tensión de la instalación.', 2),
  ('¿Quién puede realizar trabajos en instalaciones eléctricas?', 'Cualquier trabajador de la planta', 'Personal capacitado y autorizado para esa actividad', 'Personal de limpieza con supervisión', 'Cualquier persona con herramientas aisladas', 'b', 'Solo el personal capacitado y autorizado puede intervenir las instalaciones eléctricas.', 3)
) AS v(qt, a, b, c, d, ca, ex, ord)
WHERE q.title = 'Examen: Clasificación de trabajos eléctricos y distancias de seguridad';

-- Seguridad en Trabajos de Operación y Mantenimiento de Instal :: Trabajo desenergizado: las cinco reglas de oro
INSERT INTO public.quiz_questions
  (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.ca, v.ex, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Cuál es el primer paso de las cinco reglas de oro?', 'Verificar la ausencia de tensión', 'Desconectar y cortar todas las fuentes de alimentación', 'Señalizar el área', 'Poner a tierra', 'b', 'Primero se realiza el corte efectivo de todas las fuentes de alimentación que puedan energizar la instalación.', 1),
  ('¿Para qué sirve bloquear y etiquetar la instalación?', 'Para documentar el mantenimiento', 'Para evitar la reconexión accidental mientras se trabaja', 'Para señalizar la salida de emergencia', 'Para medir la tensión', 'b', 'El bloqueo y etiquetado impide que otra persona energice la instalación durante la intervención.', 2),
  ('¿Cómo se verifica la ausencia de tensión?', 'Tocando el conductor con guantes', 'Con equipo detector adecuado y en todas las fases', 'Observando que el foco esté apagado', 'Preguntando al operador del turno anterior', 'b', 'La ausencia de tensión se verifica con un detector adecuado en todos los conductores y fases antes de intervenir.', 3)
) AS v(qt, a, b, c, d, ca, ex, ord)
WHERE q.title = 'Examen: Trabajo desenergizado: las cinco reglas de oro';

-- Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018) :: Marco normativo y obligaciones en manejo manual de cargas
INSERT INTO public.quiz_questions
  (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.ca, v.ex, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Qué regula la NOM-036-1-STPS-2018?', 'Los factores de riesgo ergonómico en el manejo manual de cargas', 'El manejo de sustancias químicas', 'Las instalaciones eléctricas', 'El uso de montacargas', 'a', 'La parte 1 de la NOM-036-1 trata la identificación, análisis, prevención y control de los factores de riesgo ergonómico por manejo manual de cargas.', 1),
  ('¿Qué debe hacer el patrón frente a los factores de riesgo ergonómico?', 'Solo registrarlos en el acta', 'Identificarlos, analizarlos, prevenirlos y controlarlos', 'Delegarlos al trabajador', 'Reportarlos a la aseguradora', 'b', 'La norma obliga a identificar, analizar, prevenir y controlar los factores de riesgo ergonómico del centro de trabajo.', 2),
  ('¿La norma contempla la vigilancia a la salud de los trabajadores expuestos?', 'No, solo la capacitación', 'Sí, mediante exámenes médicos específicos', 'Solo si hay incapacidad', 'Solo para el personal de nuevo ingreso', 'b', 'La norma incluye la vigilancia a la salud con exámenes médicos específicos según el factor de riesgo identificado.', 3)
) AS v(qt, a, b, c, d, ca, ex, ord)
WHERE q.title = 'Examen: Marco normativo y obligaciones en manejo manual de cargas';

-- Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018) :: Factores de riesgo ergonómico y anatomía de la lesión
INSERT INTO public.quiz_questions
  (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.ca, v.ex, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Cuál de los siguientes es un factor de riesgo ergonómico en el manejo manual de cargas?', 'El color del embalaje', 'La frecuencia de levantamiento y la postura', 'El turno de trabajo', 'El tipo de uniforme', 'b', 'Peso, frecuencia, postura, distancia, altura y calidad del agarre son los factores que determinan el nivel de riesgo.', 1),
  ('¿Qué lesión es más frecuente por sobreesfuerzo en manejo manual de cargas?', 'Lumbalgia y lesiones de columna', 'Tendinitis del hombro únicamente', 'Fractura de tobillo', 'Quemadura dérmica', 'a', 'La zona lumbar es la más afectada por el levantamiento repetido de cargas y por giros con peso.', 2),
  ('Girar el tronco mientras se sostiene una carga:', 'Reduce el riesgo', 'Aumenta notablemente el riesgo de lesión', 'No influye en el riesgo', 'Es la técnica recomendada', 'b', 'El giro del tronco con carga combina flexión y rotación, lo que incrementa el esfuerzo sobre la columna.', 3)
) AS v(qt, a, b, c, d, ca, ex, ord)
WHERE q.title = 'Examen: Factores de riesgo ergonómico y anatomía de la lesión';

-- Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018) :: Evaluación ergonómica del puesto de trabajo
INSERT INTO public.quiz_questions
  (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.ca, v.ex, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Para qué sirve la evaluación ergonómica del puesto?', 'Para sancionar al trabajador', 'Para determinar el nivel de riesgo y las medidas de control necesarias', 'Para calcular la nómina', 'Para definir el horario del turno', 'b', 'La evaluación permite clasificar el nivel de riesgo y definir las medidas de prevención y control correspondientes.', 1),
  ('Además del peso de la carga, ¿qué otro elemento debe evaluarse?', 'La frecuencia, la postura y la distancia de transporte', 'El precio del material', 'El color de la etiqueta', 'La marca del equipo', 'a', 'El riesgo depende de la combinación de peso, frecuencia, postura, altura, distancia y calidad del agarre.', 2),
  ('¿Cuál es la medida de control prioritaria?', 'Capacitar al trabajador únicamente', 'Eliminar o reducir el riesgo en su origen, por ejemplo con mecanización', 'Entregar faja lumbar', 'Rotar al personal cada hora', 'b', 'La jerarquía de controles prioriza eliminar o reducir el riesgo en la fuente antes de depender del equipo de protección.', 3)
) AS v(qt, a, b, c, d, ca, ex, ord)
WHERE q.title = 'Examen: Evaluación ergonómica del puesto de trabajo';

-- Seguridad en la Cadena de Suministro y Concientización CTPAT :: Origen, alcance y beneficios del programa CTPAT
INSERT INTO public.quiz_questions
  (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.ca, v.ex, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Qué significa la sigla CTPAT?', 'Customs-Trade Partnership Against Terrorism', 'Control Total de Procesos Aduanales y Transporte', 'Certificación de Transportistas y Patios', 'Centro de Trazabilidad y Procesos Aduaneros', 'a', 'CTPAT es la alianza aduanas-comercio contra el terrorismo, un programa de seguridad de la cadena de suministro.', 1),
  ('¿Quién administra el programa CTPAT?', 'La Secretaría de Economía de México', 'La Oficina de Aduanas y Protección Fronteriza de Estados Unidos', 'La Organización Mundial de Aduanas', 'El consulado del país de destino', 'b', 'El programa es administrado por la Oficina de Aduanas y Protección Fronteriza de Estados Unidos, conocida como CBP.', 2),
  ('¿La participación en CTPAT es obligatoria para exportar?', 'Sí, es requisito indispensable', 'No, es un programa voluntario de certificación', 'Solo para empresas grandes', 'Solo para transportistas', 'b', 'Es un programa voluntario: la empresa decide certificarse para obtener los beneficios de seguridad y agilidad.', 3)
) AS v(qt, a, b, c, d, ca, ex, ord)
WHERE q.title = 'Examen: Origen, alcance y beneficios del programa CTPAT';

-- Seguridad en la Cadena de Suministro y Concientización CTPAT :: Criterios mínimos de seguridad del programa
INSERT INTO public.quiz_questions
  (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.ca, v.ex, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Qué son los criterios mínimos de seguridad del programa?', 'Recomendaciones opcionales', 'Requisitos que el socio comercial debe cumplir y evidenciar', 'Multas por incumplimiento', 'Formatos de facturación', 'b', 'Los criterios mínimos de seguridad son los requisitos que la empresa debe implementar y poder demostrar.', 1),
  ('¿Los criterios de CTPAT incluyen seguridad cibernética?', 'No, solo seguridad física', 'Sí, la seguridad cibernética es parte de los criterios', 'Solo si la empresa usa internet', 'Se evalúa únicamente en transporte', 'b', 'El programa incorpora criterios de seguridad cibernética además de los controles físicos y de proceso.', 2),
  ('¿Qué abarca el criterio de seguridad de socios comerciales?', 'Solo el precio negociado', 'La selección y verificación de proveedores, transportistas y subcontratistas', 'El diseño del empaque', 'La publicidad de la empresa', 'b', 'La empresa debe asegurar que sus socios comerciales cumplen estándares equivalentes de seguridad.', 3)
) AS v(qt, a, b, c, d, ca, ex, ord)
WHERE q.title = 'Examen: Criterios mínimos de seguridad del programa';

-- Seguridad en la Cadena de Suministro y Concientización CTPAT :: Análisis de riesgos y plan de seguridad
INSERT INTO public.quiz_questions
  (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.ca, v.ex, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Qué debe realizar la empresa antes de implementar su plan de seguridad?', 'Un estudio de mercado', 'Un análisis de riesgos de su cadena de suministro', 'Una auditoría contable', 'Un inventario de mobiliario', 'b', 'El plan se construye a partir de un análisis de riesgos que identifica vulnerabilidades en la cadena de suministro.', 1),
  ('¿Qué es un punto de acceso no controlado?', 'Una puerta con vigilancia', 'Una vulnerabilidad física que permite el ingreso sin control', 'Un andén con sello de seguridad', 'Una cámara de vigilancia', 'b', 'Todo acceso que no esté controlado, monitoreado o restringido representa una vulnerabilidad a corregir.', 2),
  ('¿Con qué frecuencia debe revisarse el plan de seguridad?', 'Nunca, una vez aprobado es definitivo', 'Periódicamente y cada vez que cambien las condiciones de operación', 'Solo cuando lo pida el cliente', 'Cada cinco años', 'b', 'El plan debe revisarse periódicamente y actualizarse cuando cambien instalaciones, procesos o socios comerciales.', 3)
) AS v(qt, a, b, c, d, ca, ex, ord)
WHERE q.title = 'Examen: Análisis de riesgos y plan de seguridad';

-- Técnicos en Urgencias Médicas Nivel 1 (Básico) :: Rol del TUM, marco legal y bioseguridad
INSERT INTO public.quiz_questions
  (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.ca, v.ex, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Qué norma regula la prestación de los servicios de atención médica prehospitalaria en México?', 'NOM-059-SSA1-2015', 'NOM-237-SSA1-2004', 'NOM-012-SSA3-2012', 'NOM-197-SSA1-2000', 'b', 'La NOM-237-SSA1-2004 regula los servicios de salud y la atención médica prehospitalaria.', 1),
  ('¿Qué implica la bioseguridad en la atención prehospitalaria?', 'Usar guantes solo si hay sangrado', 'Aplicar precauciones para evitar la transmisión de infecciones entre paciente y personal', 'Desinfectar la ambulancia al final del día', 'Evitar el contacto con el paciente', 'b', 'Las precauciones estándar se aplican a todo paciente, con independencia del diagnóstico aparente.', 2),
  ('¿Cuál es el equipo de protección personal mínimo para la atención de un paciente?', 'Solo casco', 'Guantes, y según el caso cubrebocas y protección ocular', 'Solo uniforme completo', 'Solo goggles', 'b', 'Los guantes son el mínimo indispensable y se complementan con cubrebocas y protección ocular según el escenario.', 3)
) AS v(qt, a, b, c, d, ca, ex, ord)
WHERE q.title = 'Examen: Rol del TUM, marco legal y bioseguridad';

-- Técnicos en Urgencias Médicas Nivel 1 (Básico) :: Evaluación inicial del paciente: método ABCDE
INSERT INTO public.quiz_questions
  (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.ca, v.ex, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Qué se evalúa en la letra A del método ABCDE?', 'La vía aérea con control de la columna cervical', 'La respiración', 'La circulación', 'El estado neurológico', 'a', 'La A corresponde a la vía aérea, que se asegura junto con el control de la columna cervical en el paciente traumatizado.', 1),
  ('¿Qué se evalúa en la letra C del método ABCDE?', 'La circulación y el control de hemorragias', 'La exposición del paciente', 'El nivel de conciencia', 'La temperatura', 'a', 'La C corresponde a circulación: pulso, perfusión y control de hemorragias externas.', 2),
  ('La evaluación ABCDE es:', 'Un procedimiento que se aplica una sola vez', 'Un proceso secuencial que se repite y reevalúa continuamente', 'Un cuestionario administrativo', 'Un estudio de laboratorio', 'b', 'La evaluación es dinámica: si el paciente se deteriora se regresa a la etapa correspondiente y se reevalúa de forma continua.', 3)
) AS v(qt, a, b, c, d, ca, ex, ord)
WHERE q.title = 'Examen: Evaluación inicial del paciente: método ABCDE';

-- Técnicos en Urgencias Médicas Nivel 1 (Básico) :: Manejo inicial del trauma y soporte vital básico
INSERT INTO public.quiz_questions
  (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.ca, v.ex, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Qué es una hemorragia exanguinante?', 'Un sangrado leve que se detiene solo', 'Un sangrado masivo que amenaza la vida del paciente', 'Una hemorragia interna sin síntomas', 'Un hematoma superficial', 'b', 'La hemorragia exanguinante provoca pérdida rápida de volumen sanguíneo y debe controlarse antes que cualquier otra prioridad.', 1),
  ('En soporte vital básico para adulto, la relación de compresiones y ventilaciones es:', '15 compresiones por 1 ventilación', '30 compresiones por 2 ventilaciones', '10 compresiones por 5 ventilaciones', '20 compresiones por 2 ventilaciones', 'b', 'La relación recomendada en soporte vital básico para adulto es de 30 compresiones por 2 ventilaciones.', 2),
  ('Ante un paciente con hemorragia masiva y vía aérea permeable, ¿qué se atiende primero?', 'La inmovilización de un miembro', 'El control de la hemorragia', 'La toma de datos generales', 'El traslado inmediato sin control', 'b', 'El control de la hemorragia masiva es prioritario porque la pérdida de sangre compromete la vida en minutos.', 3)
) AS v(qt, a, b, c, d, ca, ex, ord)
WHERE q.title = 'Examen: Manejo inicial del trauma y soporte vital básico';

COMMIT;

-- 4. Verificacion: 4 examenes por curso (3 de leccion + 1 final) y 19 preguntas
SELECT left(c.title, 42) AS curso,
       count(DISTINCT q.id) AS examenes,
       count(qq.id) AS preguntas
FROM public.courses c
JOIN public.modules m ON m.course_id = c.id
JOIN public.lessons l ON l.module_id = m.id
LEFT JOIN public.quizzes q ON q.lesson_id = l.id
LEFT JOIN public.quiz_questions qq ON qq.quiz_id = q.id
WHERE c.title IN ('Manejo Seguro de Montacargas', 'Formación para Integrantes de la Comisión de Seguridad e Higiene (NOM-019-STPS-2011)', 'Manejo Seguro de Sustancias Químicas Peligrosas (NOM-018-STPS-2015)', 'Seguridad en Trabajos de Operación y Mantenimiento de Instalaciones Eléctricas (NOM-029-STPS-2011)', 'Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018)', 'Seguridad en la Cadena de Suministro y Concientización CTPAT', 'Técnicos en Urgencias Médicas Nivel 1 (Básico)')
GROUP BY c.id, c.title
ORDER BY c.id;
