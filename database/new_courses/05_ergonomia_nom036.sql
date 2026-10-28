-- ============================================================
-- EHS SOLUTIONS - CONTENIDO DEL CURSO:
-- ERGONOMÍA Y MANEJO MANUAL DE CARGAS
-- Referencia normativa: NOM-036-1-STPS-2018 (Factores de riesgo
-- ergonómico en el trabajo. Parte 1: manejo manual de cargas)
-- Ejecutar en Supabase -> SQL Editor
-- Idempotente: se puede volver a ejecutar sin duplicar contenido.
-- ============================================================

BEGIN;

-- 0. Verificación del título del curso (debe coincidir exactamente)
DO $guard$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.courses WHERE title = 'Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018)') THEN
    RAISE EXCEPTION 'Curso no encontrado. Se requiere el título exacto: Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018)';
  END IF;
END
$guard$;

DELETE FROM public.quizzes
WHERE lesson_id IN (
  SELECT l.id FROM public.lessons l
  JOIN public.modules m ON m.id = l.module_id
  WHERE m.course_id = (SELECT id FROM public.courses WHERE title = 'Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018)')
);

DELETE FROM public.modules
WHERE course_id = (SELECT id FROM public.courses WHERE title = 'Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018)');

INSERT INTO public.modules (course_id, title, description, order_index) VALUES
  ((SELECT id FROM public.courses WHERE title = 'Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018)'),
   'Marco Normativo y Factores de Riesgo',
   'Obligaciones de la NOM-036-1-STPS-2018 y factores ergonómicos del manejo manual de cargas.',
   1),
  ((SELECT id FROM public.courses WHERE title = 'Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018)'),
   'Evaluación, Técnica y Control',
   'Evaluación ergonómica del puesto, técnica de levantamiento y programa de control.',
   2);

INSERT INTO public.lessons (module_id, title, description, content_type, content, video_url, duration_minutes, order_index, is_required) VALUES

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title = 'Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018)')
     AND order_index = 1),
  'Marco normativo y obligaciones en manejo manual de cargas',
  'Alcance de la NOM-036-1-STPS-2018, obligaciones del patrón y derechos del trabajador.',
  'mixed',
  '# Marco Normativo y Obligaciones en Manejo Manual de Cargas

Los trastornos musculoesqueléticos son la primera causa de incapacidad temporal en la industria. No aparecen de un día para otro: se acumulan por años de movimientos repetitivos, posturas forzadas y cargas mal manejadas.

## Por qué es un problema de operación y no solo de salud

Un trabajador con lumbalgia reduce su productividad, falta con frecuencia y en muchos casos termina en una incapacidad permanente. El costo no es solo médico: incluye reemplazo de personal, retrasos, errores y deterioro del clima laboral.

Los factores que más contribuyen son acumulativos:

- Levantamiento frecuente de cargas
- Posturas forzadas sostenidas
- Movimientos repetitivos de alta frecuencia
- Vibración transmitida al cuerpo
- Trabajo con fuerza excesiva en relación con la capacidad individual

## Marco normativo

La NOM-036-1-STPS-2018 establece los factores de riesgo ergonómico en el trabajo, en su parte 1 correspondiente al manejo manual de cargas. Define las obligaciones del patrón para identificar, analizar, prevenir y controlar estos factores.

La norma aplica a los centros de trabajo donde las actividades impliquen manejo manual de cargas y donde exista personal expuesto a factores de riesgo ergonómico.

## Obligaciones del patrón

1. Identificar y analizar los factores de riesgo ergonómico por puesto de trabajo.
2. Evaluar el nivel de riesgo y determinar las medidas de prevención y control.
3. Proporcionar capacitación y adiestramiento al personal expuesto.
4. Aplicar controles de ingeniería y administrativos cuando el riesgo lo justifique.
5. Practicar exámenes médicos específicos al personal expuesto.
6. Informar a los trabajadores sobre los riesgos de su puesto y las medidas de protección.
7. Documentar el programa y conservar los registros.
8. Vigilar la eficacia de las medidas implementadas.

IMPORTANTE: la norma no se limita a fijar un peso máximo. Exige identificar el riesgo por puesto, evaluarlo con metodología reconocida y controlarlo. Un cartel de no levantar más de 25 kilos no es un programa ergonómico.

## Derechos y responsabilidades del trabajador

- Recibir capacitación sobre manejo manual de cargas
- Conocer los riesgos de su puesto y las medidas de control
- Contar con ayudas mecánicas cuando la carga lo requiera
- Someterse a los exámenes médicos específicos que correspondan
- Reportar dolor o molestias antes de que se conviertan en lesión
- Utilizar correctamente las ayudas mecánicas y seguir la técnica indicada

## Grupos de especial atención

Algunas condiciones requieren control adicional en la asignación de tareas con carga:

- Trabajadoras en estado de gestación
- Personal con lesiones o padecimientos musculoesqueléticos previos
- Personal menor de edad, conforme a las restricciones aplicables
- Personal en reincorporación después de una incapacidad
- Personal de nuevo ingreso sin adaptación física al puesto

# Conclusiones

La ergonomía se gestiona con datos del puesto, no con percepciones generales. Identificar qué tarea, con qué peso, con qué frecuencia y en qué postura es lo que permite decidir si se requiere una ayuda mecánica, una rotación o un rediseño de la estación.',
  'https://www.youtube.com/embed/5gQCHGyIANg',
  30, 1, true
),

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title = 'Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018)')
     AND order_index = 1),
  'Factores de riesgo ergonómico y anatomía de la lesión',
  'Cómo se lesiona la columna, tipos de trastorno musculoesquelético y factores que agravan el riesgo.',
  'mixed',
  '# Factores de Riesgo Ergonómico y Anatomía de la Lesión

Entender cómo se lesiona el cuerpo permite tomar mejores decisiones en el puesto de trabajo. La mayoría de las lesiones de espalda no provienen de un solo evento, sino de la suma de esfuerzos repetidos.

## La columna bajo carga

La columna lumbar soporta el peso de la parte superior del cuerpo y transmite las fuerzas hacia la pelvis y las piernas. Cuando se levanta un objeto con la espalda flexionada, la carga sobre los discos intervertebrales se multiplica.

De forma aproximada, levantar un objeto de 20 kilogramos con la espalda inclinada puede generar una compresión en la zona lumbar equivalente a varios cientos de kilogramos. Con las piernas flexionadas y la espalda recta, esa compresión se reduce significativamente porque la fuerza se transmite por la musculatura de las piernas.

## Factores de riesgo principales

| Factor | Descripción | Medida de control |
| Peso de la carga | Excede la capacidad individual | Ayuda mecánica o reducción de peso |
| Frecuencia | Levantamientos por minuto u hora | Rotación y pausas activas |
| Distancia horizontal | Carga alejada del cuerpo | Acercar la carga al tronco |
| Altura de manejo | Manejo por debajo de rodillas o sobre hombros | Adecuar la altura de la estación |
| Asimetría | Giro o inclinación durante el levantamiento | Rediseñar el flujo de material |
| Agarre deficiente | Sin asas o superficie resbalosa | Contenedores con asas |
| Postura forzada | Tronco flexionado o en torsión | Capacitación y rediseño |
| Repetición | Ciclos cortos con alta cadencia | Automatización parcial |

## Tipos de trastorno musculoesquelético

- Lumbalgia por sobreesfuerzo: dolor lumbar agudo o crónico asociado a manejo de cargas
- Hernia discal: desplazamiento del disco que puede comprimir raíces nerviosas
- Tendinitis y tenosinovitis: inflamación de tendones por movimientos repetitivos
- Síndrome del túnel del carpo: compresión del nervio mediano en la muñeca
- Epicondilitis: dolor en la inserción de los músculos del antebrazo
- Lesiones de hombro por elevación repetida por encima de la cabeza

## Señales de alerta temprana

- Dolor que aparece al final del turno y desaparece con el descanso
- Rigidez matutina en la espalda o en las muñecas
- Hormigueo o adormecimiento en manos y dedos
- Pérdida de fuerza en el agarre
- Dolor que obliga a cambiar la forma de hacer la tarea

IMPORTANTE: el dolor que aparece al final del turno y desaparece con el descanso es la etapa en la que la lesión todavía es reversible. Ignorarlo es lo que la convierte en crónica.

## Doble carga: la combinación que más daña

El riesgo se multiplica cuando se combinan dos o más factores. Levantar una carga moderada con el tronco girado y a una frecuencia alta es más peligroso que levantar una carga mayor de forma ocasional, con buena técnica y cerca del cuerpo.

# Puntos clave

- La compresión lumbar se multiplica con la flexión del tronco
- La distancia horizontal de la carga es tan importante como su peso
- Los síntomas iniciales son reversibles si se atienden a tiempo
- La combinación de factores es más peligrosa que un factor aislado

# Conclusiones

La ergonomía no busca eliminar el esfuerzo, sino mantenerlo dentro de la capacidad del cuerpo. Conocer qué factor está presente en cada tarea permite elegir la medida de control correcta y no solo repartir recomendaciones genéricas.',
  'https://www.youtube.com/embed/WVNANyIJbts',
  30, 2, true
),

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title = 'Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018)')
     AND order_index = 2),
  'Evaluación ergonómica del puesto de trabajo',
  'Metodologías de evaluación, criterios de valoración y priorización de puestos.',
  'mixed',
  '# Evaluación Ergonómica del Puesto de Trabajo

La evaluación ergonómica transforma una queja difusa en un dato comparable. Permite decidir qué puesto intervenir primero y con qué medida.

## Pasos de la evaluación

1. Identificar los puestos con manejo manual de cargas.
2. Describir la tarea: qué se maneja, cuánto pesa, con qué frecuencia y en qué postura.
3. Aplicar una metodología de evaluación reconocida.
4. Clasificar el nivel de riesgo resultante.
5. Definir las medidas de control proporcionales al riesgo.
6. Revaluar después de la intervención para verificar la eficacia.

## Datos mínimos por tarea

| Dato | Cómo se obtiene |
| Peso de la carga | Báscula, ficha del producto |
| Frecuencia | Conteo en un periodo representativo |
| Duración | Tiempo efectivo de manejo por turno |
| Distancia horizontal | Medición desde el cuerpo al centro de la carga |
| Altura de manejo | Altura inicial y final en el ciclo |
| Asimetría | Grados de giro del tronco |
| Agarre | Calidad y tipo de asas |
| Pausas | Descansos y rotación existentes |

## Metodologías de referencia

Existen metodologías reconocidas internacionalmente para evaluar el manejo manual de cargas y los factores ergonómicos asociados. Su elección depende del tipo de tarea:

- Métodos de ecuacion de levantamiento, para tareas de levantamiento con parámetros definidos
- Métodos de evaluación de posturas, para tareas con posturas forzadas sostenidas
- Métodos de evaluación de movimientos repetitivos, para ciclos de alta cadencia
- Métodos de evaluación integral, cuando coexisten varios factores

Lo importante no es el nombre del método, sino que la evaluación sea sistemática, reproducible y documentada.

## Instrumentos de campo

- Báscula para verificar pesos reales
- Cinta métrica para distancias y alturas
- Cronómetro para frecuencia y duración
- Goniómetro o aplicación de medición de ángulos
- Formato de evaluación y cámara para evidencia

IMPORTANTE: el peso declarado en la documentación del proveedor no siempre coincide con el peso real. Si es posible, se pesa la carga. Una diferencia de cinco kilos cambia por completo el resultado de la evaluación.

## Priorización de puestos

Una vez evaluados los puestos, se priorizan con criterios objetivos:

1. Nivel de riesgo determinado por la metodología
2. Número de personas expuestas
3. Frecuencia de exposición
4. Antecedentes de molestias o incapacidades en ese puesto
5. Factibilidad técnica de la intervención

## Medidas de control

- Eliminación: evitar el manejo manual mediante cambio de proceso
- Ingeniería: ayudas mecánicas, rediseño de estación, ajuste de alturas
- Administrativas: rotación, límites de peso, pausas activas
- Equipo de protección personal: se considera el último recurso, no el principal

# Conclusiones

Una evaluación ergonómica bien hecha produce una lista corta y priorizada de intervenciones con costo estimado. Sin evaluación, la ergonomía se vuelve una serie de recomendaciones generales que nadie ejecuta porque no se sabe dónde está el problema mayor.',
  'https://www.youtube.com/embed/4INOqcqwa_8',
  30, 1, true
),

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title = 'Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018)')
     AND order_index = 2),
  'Técnica de levantamiento y programa de prevención',
  'Técnica correcta, uso de ayudas mecánicas, pausas activas y programa de vigilancia.',
  'mixed',
  '# Técnica de Levantamiento y Programa de Prevención

La técnica individual reduce el riesgo, pero no sustituye el control del puesto. Aun así, todo trabajador debe dominar la técnica correcta porque hay tareas que no se pueden rediseñar de inmediato.

## Técnica correcta de levantamiento

1. Planear el levantamiento: verificar peso, ruta y destino antes de cargar.
2. Colocarse frente a la carga, con los pies separados al ancho de los hombros.
3. Flexionar las rodillas y mantener la espalda recta, conservando sus curvaturas naturales.
4. Acercar la carga al cuerpo, con el centro de gravedad pegado al tronco.
5. Agarrar firmemente con toda la mano, evitando el agarre solo con los dedos.
6. Levantar con la fuerza de las piernas, manteniendo el tronco sin giro.
7. Evitar la torsión: si hay que girar, se mueven los pies.
8. Transportar con la carga cerca del cuerpo y a la altura de la cintura.
9. Descender con el mismo control, flexionando las rodillas.

## Reglas prácticas

- No levantar una carga por encima de los hombros sin apoyo
- No levantar objetos del piso con las piernas rectas
- No cargar objetos que impidan ver el camino
- Preferir empujar antes que jalar
- Dividir la carga en partes si es posible
- Pedir ayuda cuando la carga o la ruta lo requieran

IMPORTANTE: si la carga supera la capacidad individual, la respuesta correcta no es hacer más fuerza: es usar una ayuda mecánica o solicitar apoyo. La fuerza adicional se paga con una lesión.

## Ayudas mecánicas

- Carretillas, diablitos y patines
- Transpaletas manuales y eléctricas
- Mesas elevadoras y plataformas ajustables
- Grúas de brazo y polipastos
- Brazos articulados y ventosas para placas
- Bandas transportadoras y rodillos

La selección depende del peso, del volumen, de la frecuencia y de la ruta. Una ayuda mecánica mal elegida termina sin usarse.

## Pausas activas y rotación

- Programar micropausas en tareas de alta frecuencia
- Aplicar estiramientos guiados de espalda, hombros y muñecas
- Rotar a tareas con demanda física distinta
- Evitar la exposición continua a un mismo movimiento durante todo el turno

## Programa de vigilancia a la salud

- Exámenes médicos específicos al ingreso, periódicos y al egreso
- Registro de molestias y su seguimiento
- Valoración médica ante síntomas persistentes
- Reincorporación gradual después de una incapacidad
- Vigilancia especial a los grupos de mayor vulnerabilidad

## Indicadores del programa

| Indicador | Qué mide |
| Puestos evaluados | Cobertura de la evaluación |
| Puestos con riesgo alto | Magnitud del problema |
| Intervenciones ejecutadas | Avance del control |
| Incidencia de lumbalgia | Efecto en la salud |
| Días de incapacidad | Impacto operativo |
| Uso de ayudas mecánicas | Adopción real de los controles |

# Puntos clave

- La técnica reduce el riesgo individual, pero el rediseño lo elimina
- Empujar es preferible a jalar
- Toda carga que excede la capacidad requiere ayuda mecánica
- Las micropausas son parte del control, no una pausa de producción
- El programa se mide con indicadores, no con capacitaciones impartidas

# Conclusiones

Un programa ergonómico efectivo combina tres cosas: puestos evaluados y rediseñados, trabajadores capacitados en la técnica y seguimiento a la salud. Cuando falta una de las tres, el riesgo aparece por el lado que quedó descubierto.',
  'https://www.youtube.com/embed/SmCddoxzw2A',
  30, 2, true
);

INSERT INTO public.quizzes (lesson_id, title, description, passing_score, total_questions, is_active)
SELECT l.id,
       'Examen Final: Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018)',
       'Evaluación técnica de 10 preguntas. Requiere 80% para aprobar.',
       80, 10, true
FROM public.lessons l
JOIN public.modules m ON m.id = l.module_id
JOIN public.courses c ON c.id = m.course_id
WHERE c.title = 'Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018)'
ORDER BY l.id DESC
LIMIT 1;

INSERT INTO public.quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.correct, v.exp, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Qué regula la NOM-036-1-STPS-2018?',
   'Las comisiones de seguridad e higiene', 'Los factores de riesgo ergonómico en el manejo manual de cargas', 'El mantenimiento de instalaciones eléctricas', 'El manejo de montacargas', 'b',
   'La NOM-036-1-STPS-2018 establece los factores de riesgo ergonómico en el trabajo, en su parte 1 correspondiente al manejo manual de cargas.', 1),
  ('¿Cuál es la principal causa de sobrecarga en la zona lumbar al levantar una carga?',
   'Levantar con las piernas flexionadas', 'Flexionar la espalda con la carga alejada del cuerpo', 'Mantener la carga cerca del tronco', 'Usar un cinturón de apoyo', 'b',
   'La flexión del tronco combinada con la distancia horizontal de la carga multiplica la compresión sobre los discos lumbares.', 2),
  ('¿Cuál es una señal de alerta temprana de un trastorno musculoesquelético?',
   'Dolor que aparece al final del turno y desaparece con el descanso', 'Dolor constante después de un año', 'Ausencia total de molestias', 'Dolor que solo aparece en vacaciones', 'a',
   'Dolor que aparece al final del turno y cede con el descanso indica una etapa todavía reversible. Ignorarlo permite que se vuelva crónico.', 3),
  ('¿Qué medida de control debe aplicarse primero según la jerarquía de controles?',
   'Equipo de protección personal', 'Eliminar el manejo manual mediante cambio de proceso', 'Capacitación en técnica de levantamiento', 'Rotación de personal', 'b',
   'La jerarquía prefiere la eliminación del riesgo. El equipo de protección personal es el último recurso, no el principal.', 4),
  ('¿Cuál es la postura correcta al levantar una carga del piso?',
   'Espalda recta, rodillas flexionadas y carga cerca del cuerpo', 'Espalda inclinada, piernas rectas y brazos extendidos', 'Girar el tronco mientras se levanta', 'Levantar con un tirón rápido', 'a',
   'Se flexionan las rodillas, se mantiene la espalda recta y la carga se acerca al cuerpo para reducir la compresión lumbar.', 5),
  ('¿Por qué la distancia horizontal de la carga es crítica?',
   'Porque afecta el agarre únicamente', 'Porque al alejar la carga del cuerpo aumenta el momento y la compresión lumbar', 'Porque cambia el peso de la carga', 'Porque mejora la visibilidad', 'b',
   'Al alejar la carga del tronco aumenta el momento de fuerza sobre la columna y, con ello, la compresión sobre los discos lumbares.', 6),
  ('¿Qué se recomienda cuando una carga excede la capacidad individual del trabajador?',
   'Levantarla más despacio', 'Usar una ayuda mecánica o solicitar apoyo', 'Hacer más fuerza con la espalda', 'Levantarla entre dos sin coordinación', 'b',
   'Cuando la carga supera la capacidad individual, la respuesta correcta es una ayuda mecánica o apoyo adicional, no más esfuerzo físico.', 7),
  ('¿Qué acción es preferible para mover una carga pesada a nivel de piso?',
   'Jalar la carga', 'Empujar la carga', 'Levantarla y caminar con ella', 'Arrastrarla con el cuerpo inclinado', 'b',
   'Empujar permite aplicar fuerza con todo el cuerpo y con mejor alineación postural, lo que reduce la carga sobre la espalda frente a jalar.', 8),
  ('¿Para qué sirven las pausas activas en tareas de manejo manual de cargas?',
   'Para sustituir las ayudas mecánicas', 'Para interrumpir la exposición continua y reducir la acumulación de fatiga muscular', 'Para aumentar la producción', 'Para eliminar la necesidad de evaluación ergonómica', 'b',
   'Las pausas activas interrumpen la exposición sostenida, activan la circulación y reducen la acumulación de fatiga en músculos y articulaciones.', 9),
  ('¿Qué debe hacerse después de aplicar una medida de control ergonómico?',
   'Considerar el caso cerrado', 'Revaluar el puesto para verificar la eficacia de la medida', 'Retirar la ayuda mecánica', 'Suspender los exámenes médicos', 'b',
   'Toda intervención debe revaluarse para comprobar que el nivel de riesgo disminuyó realmente y no solo cambió de lugar.', 10)
) AS v(qt, a, b, c, d, correct, exp, ord)
WHERE q.title = 'Examen Final: Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018)';

COMMIT;

SELECT c.title AS curso,
       (SELECT COUNT(*) FROM public.modules m WHERE m.course_id = c.id) AS modulos,
       (SELECT COUNT(*) FROM public.lessons l
        JOIN public.modules m ON m.id = l.module_id
        WHERE m.course_id = c.id) AS lecciones
FROM public.courses c
WHERE c.title = 'Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018)';
