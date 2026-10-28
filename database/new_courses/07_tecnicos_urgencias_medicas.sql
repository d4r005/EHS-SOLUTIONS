-- ============================================================
-- EHS SOLUTIONS - CONTENIDO DEL CURSO:
-- TÉCNICOS EN URGENCIAS MÉDICAS NIVEL 1 (BÁSICO)
-- Referencia: atención médica prehospitalaria (NOM-237-SSA1-2004)
-- Ejecutar en Supabase -> SQL Editor
-- Idempotente: se puede volver a ejecutar sin duplicar contenido.
-- ============================================================

BEGIN;

-- 0. Verificación del título del curso (debe coincidir exactamente)
DO $guard$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.courses WHERE title = 'Técnicos en Urgencias Médicas Nivel 1 (Básico)') THEN
    RAISE EXCEPTION 'Curso no encontrado. Se requiere el título exacto: Técnicos en Urgencias Médicas Nivel 1 (Básico)';
  END IF;
END
$guard$;

DELETE FROM public.quizzes
WHERE lesson_id IN (
  SELECT l.id FROM public.lessons l
  JOIN public.modules m ON m.id = l.module_id
  WHERE m.course_id = (SELECT id FROM public.courses WHERE title = 'Técnicos en Urgencias Médicas Nivel 1 (Básico)')
);

DELETE FROM public.modules
WHERE course_id = (SELECT id FROM public.courses WHERE title = 'Técnicos en Urgencias Médicas Nivel 1 (Básico)');

INSERT INTO public.modules (course_id, title, description, order_index) VALUES
  ((SELECT id FROM public.courses WHERE title = 'Técnicos en Urgencias Médicas Nivel 1 (Básico)'),
   'Fundamentos de la Atención Prehospitalaria',
   'Marco legal, roles del TUM, bioseguridad y evaluación inicial del paciente.',
   1),
  ((SELECT id FROM public.courses WHERE title = 'Técnicos en Urgencias Médicas Nivel 1 (Básico)'),
   'Atención de Emergencias y Traslado',
   'Manejo inicial del trauma, búsqueda, rescate y traslado seguro.',
   2);

INSERT INTO public.lessons (module_id, title, description, content_type, content, video_url, duration_minutes, order_index, is_required) VALUES

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title = 'Técnicos en Urgencias Médicas Nivel 1 (Básico)')
     AND order_index = 1),
  'Rol del TUM, marco legal y bioseguridad',
  'Funciones del técnico en urgencias médicas, responsabilidad legal, precauciones estándar y control de infecciones.',
  'text',
  '# Rol del TUM, Marco Legal y Bioseguridad

El Técnico en Urgencias Médicas de nivel básico es el primer respondiente en la mayoría de las emergencias. Su función no es diagnosticar ni sustituir al médico: es estabilizar, evitar el deterioro y trasladar en condiciones seguras.

## Alcance del nivel básico

El TUM básico está capacitado para:

- Evaluar la escena y garantizar su propia seguridad
- Realizar la evaluación inicial y secundaria del paciente
- Abrir la vía aérea con técnicas manuales y adjuntas básicas
- Aplicar oxígeno suplementario
- Controlar hemorragias externas con presión directa y vendaje
- Inmovilizar columnas y extremidades
- Aplicar reanimación cardiopulmonar y uso de desfibrilador externo automático
- Asistir en la atención del parto de emergencia
- Realizar el traslado y la entrega formal del paciente

No corresponde al nivel básico la administración de medicamentos, la realización de procedimientos invasivos ni la interpretación de estudios.

## Marco legal y responsabilidad

La atención médica prehospitalaria en México está regulada por la normatividad sanitaria correspondiente, que establece las condiciones para la prestación de los servicios y la competencia del personal que los brinda.

Principios que rigen la actuación del TUM:

- Consentimiento informado: el paciente debe autorizar la atención cuando esté consciente y sea mayor de edad
- Consentimiento presunto: en un paciente inconsciente o en riesgo de muerte se actúa sin esperar autorización
- Confidencialidad: la información clínica del paciente es reservada
- Actuación dentro del alcance: no se realizan procedimientos para los que no se está capacitado
- Registro: toda intervención se documenta en la hoja de atención prehospitalaria
- Continuidad: el paciente se entrega formalmente al personal receptor, con informe verbal y escrito

IMPORTANTE: actuar fuera del alcance de competencia expone al paciente a daño y al técnico a responsabilidad legal. Negarse a realizar un procedimiento para el que no se está capacitado no es una omisión: es una actuación profesional correcta.

## Bioseguridad y precauciones estándar

Las precauciones estándar se aplican a todos los pacientes, sin excepción, porque no siempre es posible saber quién es portador de un agente infeccioso.

| Situación | Barrera requerida |
| Contacto con sangre o fluidos | Guantes de látex o nitrilo |
| Riesgo de salpicadura en ojos | Lentes de protección |
| Riesgo de salpicadura en mucosas | Cubrebocas y lentes |
| Atención con exposición amplia a fluidos | Bata o mandil impermeable |
| Sospecha de enfermedad transmisible por vía aérea | Mascarilla de alta eficiencia |

Reglas de bioseguridad:

1. Usar barreras en todo contacto con sangre, fluidos corporales, mucosas y piel no intacta.
2. Retirar los guantes sin tocar su superficie externa y desecharlos de inmediato.
3. Realizar higiene de manos antes y después de cada atención.
4. No recapsular agujas ni manipular material punzocortante.
5. Descontaminar el equipo y la unidad después de cada servicio.
6. Reportar toda exposición accidental y acudir a valoración médica de inmediato.

## Seguridad de la escena

Antes de acercarse al paciente, el TUM evalúa la escena. La regla es clara: no se convierte en una segunda víctima.

- Valorar riesgos de tránsito, fuego, cables caídos, derrames químicos o violencia
- Solicitar el apoyo de seguridad, bomberos o protección civil cuando corresponda
- Usar chaleco reflectante y señalizar la zona en vía pública
- Determinar el número de pacientes y la necesidad de recursos adicionales
- Identificar el mecanismo de lesión, que orienta la sospecha clínica

# Conclusiones

La actuación del TUM se sostiene en tres decisiones previas al contacto con el paciente: garantizar la seguridad de la escena, protegerse con las barreras adecuadas y actuar dentro del alcance de su competencia. Cuando esas tres se respetan, la atención es segura para el paciente y para el técnico.',
  NULL,
  30, 1, true
),

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title = 'Técnicos en Urgencias Médicas Nivel 1 (Básico)')
     AND order_index = 1),
  'Evaluación inicial del paciente: método ABCDE',
  'Evaluación de la escena, valoración primaria ABCDE, evaluación secundaria y signos vitales.',
  'mixed',
  '# Evaluación Inicial del Paciente: Método ABCDE

La evaluación inicial es un proceso ordenado y repetible que busca identificar y corregir primero lo que mata. No es un interrogatorio ni una exploración completa: es una secuencia jerárquica.

## Evaluación de la escena

Antes de tocar al paciente se responde:

- ¿La escena es segura para mí y para el paciente?
- ¿Cuál es el mecanismo de lesión o la naturaleza de la enfermedad?
- ¿Cuántos pacientes hay?
- ¿Necesito recursos adicionales?

## Valoración primaria: ABCDE

### A. Vía aérea con control cervical

Verificar si la vía aérea está permeable. En un paciente inconsciente, la lengua puede obstruirla. Se realiza apertura manual con tracción mandibular o elevación del mentón, manteniendo alineación cervical cuando el mecanismo sugiera lesión de columna.

Signos de obstrucción: estridor, voz alterada, dificultad para hablar, cianosis, movimientos respiratorios sin paso de aire.

### B. Ventilación y respiración

Valorar si el paciente respira y con qué eficacia.

- Frecuencia respiratoria
- Profundidad y simetría del movimiento torácico
- Ruidos respiratorios anormales
- Saturación de oxígeno cuando se cuente con oxímetro
- Presencia de cianosis

### C. Circulación y control de hemorragias

- Verificar pulso central y su calidad
- Evaluar llenado capilar, color y temperatura de la piel
- Buscar y controlar hemorragias externas con presión directa
- Valorar signos de choque: palidez, sudoración fría, taquicardia, alteración del estado mental

### D. Estado neurológico

- Nivel de consciencia con la escala de Glasgow o con el método AVDI: alerta, responde a voz, responde a dolor, inconsciente
- Tamaño y reactividad pupilar
- Movilidad y sensibilidad de extremidades
- Glucemia cuando se cuente con el recurso y el protocolo lo permita

### E. Exposición y control ambiental

Exponer al paciente para buscar lesiones que pasan desapercibidas, y cubrirlo de inmediato para prevenir hipotermia. La hipotermia agrava la coagulopatía y el choque en el paciente traumatizado.

IMPORTANTE: el orden ABCDE se repite cada vez que el paciente cambia de condición. Un paciente que estaba estable puede descompensarse durante el traslado, y la revaluación es lo que detecta ese cambio a tiempo.

## Evaluación secundaria

Se realiza cuando el paciente está estable y las condiciones lo permiten. Incluye:

1. Entrevista con el paciente, familiares o testigos
2. Historia clínica dirigida: síntomas, alergias, medicamentos, antecedentes, última ingesta y eventos previos
3. Exploración céfalo-caudal ordenada
4. Toma completa de signos vitales
5. Registro de hallazgos en la hoja de atención

## Signos vitales de referencia en el adulto

| Signo | Rango de referencia |
| Frecuencia respiratoria | 12 a 20 por minuto |
| Frecuencia cardíaca | 60 a 100 por minuto |
| Tensión arterial | Aproximadamente 120/80 mmHg |
| Temperatura | 36 a 37.5 grados centígrados |
| Saturación de oxígeno | 94 a 100 por ciento |

Estos valores son referencias generales. Lo relevante en la práctica es la tendencia: un paciente que empeora de forma progresiva requiere intervención y traslado prioritario, aunque sus cifras aún parezcan aceptables.

# Puntos clave

- Primero la seguridad de la escena, después el paciente
- El ABCDE se ejecuta en orden y se repite ante cualquier cambio
- La hemorragia externa masiva se controla en la letra C
- La exposición siempre se acompaña de control de la temperatura
- La tendencia de los signos vitales vale más que una sola medición

# Conclusiones

El ABCDE es la herramienta que evita que el primer respondiente se distraiga con lesiones llamativas mientras pasa por alto una vía aérea obstruida o una hemorragia activa. Su valor está en la disciplina de repetirlo en el mismo orden, siempre.',
  'https://www.youtube.com/embed/J-1L6Oi9t9Q',
  30, 2, true
),

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title = 'Técnicos en Urgencias Médicas Nivel 1 (Básico)')
     AND order_index = 2),
  'Manejo inicial del trauma y soporte vital básico',
  'Control de hemorragias, inmovilización, reanimación cardiopulmonar y uso de desfibrilador.',
  'mixed',
  '# Manejo Inicial del Trauma y Soporte Vital Básico

El trauma y el paro cardio-respiratorio son las dos condiciones donde la intervención del primer respondiente tiene mayor impacto en la sobrevida.

## Control de hemorragias

La hemorragia externa masiva es la causa de muerte evitable más frecuente en el trauma. Su control es prioritario sobre cualquier otra maniobra.

1. Presión directa firme y sostenida sobre la herida con gasa o apósito limpio.
2. No retirar el apósito empapado: agregar otro encima y mantener la presión.
3. Elevar la extremidad cuando no exista sospecha de fractura.
4. Usar torniquete cuando la hemorragia en extremidad no se controla con presión directa, registrando la hora de colocación.
5. Inmovilizar la extremidad y vigilar el sangrado durante el traslado.

## Manejo del trauma

- Sospechar lesión de columna cervical en todo trauma con mecanismo de alta energía
- Inmovilizar con collarín y tabla espinal cuando esté indicado por el protocolo
- No retirar objetos empalados: estabilizarlos en su posición
- Cubrir heridas de tórax con apósito oclusivo ante sospecha de neumotórax abierto
- Inmovilizar fracturas en la posición encontrada, valorando pulso y sensibilidad distal
- Prevenir la hipotermia con manta o cobertor térmico

IMPORTANTE: en el paciente traumatizado la hemorragia se controla antes de la vía aérea. Esa es la lógica del enfoque XABCDE, donde la X corresponde a la hemorragia exanguinante.

## Reanimación cardiopulmonar en el adulto

Secuencia básica de soporte vital:

1. Verificar la escena y confirmar inconsciencia.
2. Solicitar ayuda y activar el sistema de emergencia, pidiendo el desfibrilador.
3. Verificar respiración y pulso en no más de diez segundos.
4. Iniciar compresiones torácicas: centro del tórax, profundidad aproximada de cinco a seis centímetros, frecuencia de cien a ciento veinte por minuto.
5. Permitir la expansión completa del tórax entre compresiones y minimizar las interrupciones.
6. Combinar con ventilaciones de rescate en la relación establecida por el protocolo vigente, si se cuenta con barrera y capacitación.
7. Continuar hasta la llegada del desfibrilador, el relevo del equipo o la recuperación del paciente.

## Desfibrilador externo automático

- Encender el equipo y seguir las indicaciones de voz
- Colocar los parches según el esquema del dispositivo
- Asegurar que nadie toque al paciente durante el análisis y la descarga
- Reanudar las compresiones inmediatamente después de la descarga
- No retirar los parches hasta la llegada del equipo de traslado

## Otras emergencias frecuentes

- Obstrucción de la vía aérea: maniobras de desobstrucción según consciencia del paciente
- Reacción alérgica grave: identificar signos de dificultad respiratoria e identificar el uso de autoinyector cuando el protocolo lo permita
- Crisis convulsiva: proteger la cabeza, no introducir objetos en la boca, cronometrar la duración
- Evento vascular cerebral: reconocer inicio súbito de asimetría facial, debilidad de extremidad y alteración del habla, y registrar la hora de inicio de los síntomas
- Parto de emergencia: preparar el área, sostener la cabeza del recién nacido y abrigarlo de inmediato

# Puntos clave

- La hemorragia masiva se controla antes que cualquier otra maniobra
- El torniquete requiere registro de la hora de colocación
- La calidad de las compresiones determina la sobrevida en el paro
- El desfibrilador se usa lo antes posible y sin interrumpir las compresiones más de lo necesario
- En el evento vascular cerebral, la hora de inicio de los síntomas es un dato crítico

# Conclusiones

El soporte vital básico no depende de la tecnología, sino de reconocer rápido, actuar en el orden correcto y no interrumpir las maniobras que mantienen la circulación. Cada minuto de retraso en la desfibrilación reduce de forma significativa la probabilidad de sobrevida.',
  'https://www.youtube.com/embed/qNRIyBUgzyM',
  30, 1, true
),

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title = 'Técnicos en Urgencias Médicas Nivel 1 (Básico)')
     AND order_index = 2),
  'Búsqueda, rescate y traslado seguro del paciente',
  'Extracción, movilización, transporte y entrega formal del paciente al servicio receptor.',
  'mixed',
  '# Búsqueda, Rescate y Traslado Seguro

El traslado no es un traslado de un punto a otro: es una fase de la atención donde el paciente sigue bajo responsabilidad del TUM y puede deteriorarse en cualquier momento.

## Búsqueda y rescate

La búsqueda y el rescate en escenarios complejos requiere personal especializado. El TUM básico participa en la atención del paciente una vez que el área fue asegurada y el paciente fue extraído por personal capacitado.

Consideraciones generales:

- No ingresar a espacios confinados, estructuras colapsadas o zonas con riesgo de derrumbe sin equipo y formación específica
- Coordinar con bomberos y protección civil el acceso al paciente atrapado
- Estabilizar al paciente antes de la extracción cuando la situación lo permita
- Mantener comunicación con la familia y con el mando del incidente
- Documentar el tiempo de atrapamiento, que influye en el pronóstico

## Movilización del paciente

- Usar técnica de movilización en bloque cuando exista sospecha de lesión de columna
- Asegurar la alineación de cabeza, cuello y tronco durante toda la maniobra
- Emplear tabla espinal, camilla de cuchara o camilla rígida según el caso
- Asegurar al paciente con correas antes de moverlo
- Verificar el peso y la capacidad del equipo de traslado antes de levantar

IMPORTANTE: un paciente que se moviliza de forma inadecuada puede agravar una lesión medular. La inmovilización no es un trámite: es la protección de la función neurológica antes de llegar al hospital.

## Preparación del traslado

1. Confirmar la estabilidad del paciente con una revaluación completa.
2. Asegurar vía aérea, ventilación y control de hemorragias.
3. Comunicar al centro receptor: edad, mecanismo, lesiones, signos vitales y tiempo estimado de llegada.
4. Asegurar al paciente en el vehículo y verificar el equipo.
5. Acompañar y monitorizar durante todo el trayecto.

## Monitoreo durante el trayecto

- Reevaluar ABCDE al menos cada cinco minutos en paciente inestable
- Vigilar permeabilidad de la vía aérea y calidad de la ventilación
- Controlar que las inmovilizaciones no generen compresión
- Mantener la comunicación con el paciente consciente
- Registrar hora de cada intervención y de los cambios detectados

## Entrega formal al servicio receptor

La entrega debe ser verbal y escrita. El informe incluye:

- Datos de identificación del paciente, cuando se conozcan
- Hora y lugar del evento
- Mecanismo de lesión o causa aparente
- Hallazgos de la evaluación inicial y secundaria
- Signos vitales y su evolución
- Intervenciones realizadas y hora de cada una
- Cambios observados durante el traslado
- Datos de familiares o testigos

## Salud mental del respondiente

La exposición repetida a eventos críticos tiene un efecto acumulativo. El agotamiento emocional afecta la calidad de la atención y la seguridad del equipo.

- Reconocer signos de fatiga por estrés: insomnio, irritabilidad, dificultad para concentrarse
- Participar en las sesiones de defusing o debriefing posterior a eventos críticos
- Solicitar apoyo psicológico sin estigma
- Respetar los periodos de descanso entre turnos

# Puntos clave

- El rescate en escenarios complejos requiere personal especializado
- La movilización en bloque protege la función neurológica
- La comunicación previa con el hospital receptor mejora el resultado clínico
- La entrega formal transfiere la responsabilidad del paciente
- La salud mental del respondiente es parte de la seguridad del servicio

# Conclusiones

Un traslado bien ejecutado es aquel donde el paciente llega en igual o mejor condición que como salió del sitio del evento. Eso se logra con preparación, monitorización constante y una entrega ordenada que le permita al equipo hospitalario continuar la atención sin perder información.',
  'https://www.youtube.com/embed/GpZOKajjCjU',
  30, 2, true
);

INSERT INTO public.quizzes (lesson_id, title, description, passing_score, total_questions, is_active)
SELECT l.id,
       'Examen Final: Técnicos en Urgencias Médicas Nivel 1 (Básico)',
       'Evaluación técnica de 10 preguntas. Requiere 80% para aprobar.',
       80, 10, true
FROM public.lessons l
JOIN public.modules m ON m.id = l.module_id
JOIN public.courses c ON c.id = m.course_id
WHERE c.title = 'Técnicos en Urgencias Médicas Nivel 1 (Básico)'
ORDER BY l.id DESC
LIMIT 1;

INSERT INTO public.quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.correct, v.exp, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Cuál es la primera acción del TUM al llegar a la escena de una emergencia?',
   'Tocar al paciente de inmediato', 'Evaluar la seguridad de la escena', 'Tomar los signos vitales', 'Solicitar datos del seguro médico', 'b',
   'Antes de acercarse al paciente se evalúa la seguridad de la escena para no convertirse en una segunda víctima.', 1),
  ('¿Qué significa la letra A en la valoración primaria ABCDE?',
   'Alerta', 'Vía aérea con control cervical', 'Abdomen', 'Alergias', 'b',
   'La A corresponde a la vía aérea con control cervical: verificar su permeabilidad y mantener la alineación de la columna cuando el mecanismo lo sugiera.', 2),
  ('¿Cuándo se aplican las precauciones estándar de bioseguridad?',
   'Solo con pacientes con diagnóstico infeccioso conocido', 'A todos los pacientes, sin excepción', 'Solo cuando hay sangrado visible', 'Solo en el traslado', 'b',
   'Las precauciones estándar se aplican a todos los pacientes porque no siempre es posible saber quién es portador de un agente infeccioso.', 3),
  ('¿Qué maniobra es prioritaria en un paciente con hemorragia externa masiva en extremidad?',
   'Inmovilizar la extremidad primero', 'Controlar la hemorragia con presión directa o torniquete', 'Realizar la evaluación secundaria', 'Administrar oxígeno', 'b',
   'La hemorragia exanguinante se controla antes que cualquier otra maniobra. Es la lógica del enfoque XABCDE.', 4),
  ('¿Cuál es la profundidad recomendada de las compresiones torácicas en el adulto?',
   'De uno a dos centímetros', 'De cinco a seis centímetros', 'De ocho a diez centímetros', 'La que permita el paciente', 'b',
   'Las compresiones deben alcanzar de cinco a seis centímetros de profundidad, con frecuencia de cien a ciento veinte por minuto.', 5),
  ('¿Qué se debe hacer antes de aplicar una descarga con el desfibrilador externo automático?',
   'Verificar que nadie toque al paciente', 'Retirar los parches', 'Suspender la ventilación', 'Aplicar agua sobre el tórax', 'a',
   'Antes de la descarga se debe asegurar que nadie toque al paciente para evitar que la corriente afecte a los respondedores.', 6),
  ('¿Por qué la letra E del ABCDE incluye cubrir al paciente después de exponerlo?',
   'Por comodidad del paciente', 'Porque la hipotermia agrava la coagulopatía y el choque en el trauma', 'Para evitar que la familia observe', 'Porque facilita el registro fotográfico', 'b',
   'La exposición permite detectar lesiones ocultas, pero la hipotermia agrava la coagulopatía y el choque, por lo que el paciente debe cubrirse de inmediato.', 7),
  ('En un paciente con mecanismo de trauma de alta energía, ¿qué se debe sospechar?',
   'Lesión de columna cervical', 'Solo lesiones externas visibles', 'Que no requiere inmovilización', 'Que puede caminar sin valoración', 'a',
   'Todo trauma con mecanismo de alta energía obliga a sospechar lesión de columna cervical y a inmovilizar conforme al protocolo.', 8),
  ('¿Qué dato es crítico registrar en un paciente con sospecha de evento vascular cerebral?',
   'El peso corporal', 'La hora de inicio de los síntomas', 'El grupo sanguíneo', 'El antecedente de tabaquismo', 'b',
   'La hora de inicio de los síntomas es determinante para las decisiones terapéuticas del equipo hospitalario.', 9),
  ('¿Cómo debe realizarse la entrega del paciente al servicio receptor?',
   'Solo de forma verbal', 'De forma verbal y escrita, con hallazgos, signos vitales e intervenciones', 'Dejando al paciente sin informe', 'Solo con la hoja de traslado sin explicación', 'b',
   'La entrega formal es verbal y escrita, e incluye mecanismo, hallazgos, signos vitales, intervenciones y cambios durante el traslado.', 10)
) AS v(qt, a, b, c, d, correct, exp, ord)
WHERE q.title = 'Examen Final: Técnicos en Urgencias Médicas Nivel 1 (Básico)';

COMMIT;

SELECT c.title AS curso,
       (SELECT COUNT(*) FROM public.modules m WHERE m.course_id = c.id) AS modulos,
       (SELECT COUNT(*) FROM public.lessons l
        JOIN public.modules m ON m.id = l.module_id
        WHERE m.course_id = c.id) AS lecciones
FROM public.courses c
WHERE c.title = 'Técnicos en Urgencias Médicas Nivel 1 (Básico)';
