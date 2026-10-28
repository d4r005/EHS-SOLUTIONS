-- ============================================================
-- EHS SOLUTIONS - CONTENIDO DEL CURSO:
-- SEGURIDAD EN OPERACIÓN Y MANTENIMIENTO DE INSTALACIONES ELÉCTRICAS
-- Referencia normativa: NOM-029-STPS-2011 (Mantenimiento de las
-- instalaciones eléctricas en los centros de trabajo)
-- Ejecutar en Supabase -> SQL Editor
-- Idempotente: se puede volver a ejecutar sin duplicar contenido.
-- ============================================================

BEGIN;

-- 0. Verificación del título del curso (debe coincidir exactamente)
DO $guard$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.courses WHERE title = 'Seguridad en Trabajos de Operación y Mantenimiento de Instalaciones Eléctricas (NOM-029-STPS-2011)') THEN
    RAISE EXCEPTION 'Curso no encontrado. Se requiere el título exacto: Seguridad en Trabajos de Operación y Mantenimiento de Instalaciones Eléctricas (NOM-029-STPS-2011)';
  END IF;
END
$guard$;

DELETE FROM public.quizzes
WHERE lesson_id IN (
  SELECT l.id FROM public.lessons l
  JOIN public.modules m ON m.id = l.module_id
  WHERE m.course_id = (SELECT id FROM public.courses WHERE title = 'Seguridad en Trabajos de Operación y Mantenimiento de Instalaciones Eléctricas (NOM-029-STPS-2011)')
);

DELETE FROM public.modules
WHERE course_id = (SELECT id FROM public.courses WHERE title = 'Seguridad en Trabajos de Operación y Mantenimiento de Instalaciones Eléctricas (NOM-029-STPS-2011)');

INSERT INTO public.modules (course_id, title, description, order_index) VALUES
  ((SELECT id FROM public.courses WHERE title = 'Seguridad en Trabajos de Operación y Mantenimiento de Instalaciones Eléctricas (NOM-029-STPS-2011)'),
   'Riesgos Eléctricos y Marco Normativo',
   'Efectos de la corriente en el cuerpo, clasificación de trabajos y distancias de seguridad.',
   1),
  ((SELECT id FROM public.courses WHERE title = 'Seguridad en Trabajos de Operación y Mantenimiento de Instalaciones Eléctricas (NOM-029-STPS-2011)'),
   'Trabajo Seguro: Desenergizado y Energizado',
   'Las cinco reglas de oro, bloqueo, verificación, equipo de protección y arco eléctrico.',
   2);

INSERT INTO public.lessons (module_id, title, description, content_type, content, video_url, duration_minutes, order_index, is_required) VALUES

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title = 'Seguridad en Trabajos de Operación y Mantenimiento de Instalaciones Eléctricas (NOM-029-STPS-2011)')
     AND order_index = 1),
  'Efectos de la corriente eléctrica y marco normativo',
  'Fisiología del contacto eléctrico, tipos de lesión y obligaciones de la NOM-029-STPS-2011.',
  'mixed',
  '# Efectos de la Corriente Eléctrica y Marco Normativo

La electricidad no avisa. No hay olor, no hay ruido y el contacto no produce una señal perceptible antes del daño. Por eso el trabajo eléctrico se gobierna con procedimientos, no con percepción.

## Cómo daña la corriente al cuerpo

El daño depende de la intensidad, del recorrido de la corriente por el cuerpo y del tiempo de exposición. La intensidad está determinada por la tensión y por la resistencia del cuerpo, que disminuye con la humedad, con el sudor y con las lesiones en la piel.

| Intensidad | Efecto fisiológico aproximado |
| 1 a 3 mA | Percepción, cosquilleo |
| 10 a 20 mA | Contracción muscular, dificultad para soltar |
| 20 a 50 mA | Paro respiratorio por tetanización |
| 50 a 100 mA | Fibrilación ventricular |
| Mayor a 100 mA | Quemaduras graves y paro cardíaco |

La corriente alterna a frecuencia industrial, que es la de la red eléctrica, es especialmente peligrosa porque provoca tetanización: la persona pierde el control de sus músculos y no puede soltar el conductor.

## Tipos de lesión

- Contacto eléctrico directo: la persona toca una parte energizada.
- Contacto indirecto: la persona toca una parte metálica que quedó energizada por una falla de aislamiento.
- Arco eléctrico: no hay contacto físico, pero la energía del arco produce quemadura térmica, radiación, presión y proyección de metal fundido.
- Caída secundaria: el impacto eléctrico provoca una caída desde altura, que en muchas ocasiones resulta más grave que la descarga.

## Marco normativo

La NOM-029-STPS-2011 establece las condiciones de seguridad para el mantenimiento de las instalaciones eléctricas en los centros de trabajo. Aplica tanto a trabajos con la instalación energizada como desenergizada.

Obligaciones principales del patrón:

1. Identificar y evaluar los riesgos eléctricos de las instalaciones.
2. Establecer procedimientos de trabajo seguro para cada tipo de actividad eléctrica.
3. Autorizar por escrito al personal que realiza mantenimiento eléctrico.
4. Proporcionar equipo de protección personal dieléctrico y verificarlo periódicamente.
5. Señalizar las instalaciones y delimitar las áreas de riesgo.
6. Capacitar y adiestrar al personal en seguridad eléctrica.
7. Mantener los diagramas unifilares y la documentación de la instalación actualizados.
8. Realizar mantenimiento preventivo conforme a un programa documentado.

IMPORTANTE: solo el personal autorizado puede intervenir una instalación eléctrica. La autorización debe ser específica para el nivel de tensión y para el tipo de trabajo a realizar.

## Reglas de oro de la seguridad eléctrica

Antes de cualquier intervención, el personal debe tener presente el principio básico: la instalación se considera energizada hasta que se demuestre lo contrario mediante verificación directa con instrumento adecuado.

# Conclusiones

El riesgo eléctrico no se reduce con experiencia ni con costumbre: se reduce con procedimiento, verificación y equipo certificado. La mayoría de los accidentes eléctricos graves ocurren en trabajos que se consideraban de rutina.',
  'https://www.youtube.com/embed/kz9ArmUROaw',
  30, 1, true
),

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title = 'Seguridad en Trabajos de Operación y Mantenimiento de Instalaciones Eléctricas (NOM-029-STPS-2011)')
     AND order_index = 1),
  'Clasificación de trabajos eléctricos y distancias de seguridad',
  'Trabajo desenergizado, energizado y en proximidad; niveles de tensión y delimitación de áreas.',
  'mixed',
  '# Clasificación de Trabajos Eléctricos y Distancias de Seguridad

Clasificar correctamente el trabajo es lo que determina el procedimiento, el equipo de protección y el personal autorizado. Un trabajo mal clasificado es la causa más frecuente de accidente eléctrico.

## Clasificación de los trabajos

- Trabajo desenergizado: la instalación fue aislada de toda fuente y se verificó ausencia de tensión. Es la condición preferente para cualquier intervención.
- Trabajo energizado: se realiza con la instalación en tensión. Solo se justifica cuando la desenergización no es técnicamente posible o cuando implica un riesgo mayor.
- Trabajo en proximidad: se realiza sin contacto, pero dentro de la zona de riesgo definida por la tensión de la instalación.
- Trabajo en instalaciones de baja tensión con herramientas aisladas: aplica procedimientos específicos y equipo dieléctrico verificado.

## Niveles de tensión

En México, las instalaciones se clasifican por niveles de tensión conforme a la normatividad de instalaciones eléctricas. De forma general se distingue:

| Nivel | Rango aproximado | Ejemplo de uso |
| Baja tensión | Hasta 1000 V en corriente alterna | Contactos, alumbrado, fuerza |
| Media tensión | Mayor a 1000 V y hasta 35 kV | Acometidas y subestaciones |
| Alta tensión | Superior a 35 kV | Transmisión y grandes subestaciones |

El procedimiento, el equipo de protección y la autorización del personal cambian en cada nivel. Un electricista autorizado para baja tensión no está autorizado para intervenir media tensión.

## Distancias de seguridad

La norma establece distancias mínimas de aproximación a partes energizadas, en función del nivel de tensión. Estas distancias definen tres zonas:

- Zona de trabajo: donde el trabajador puede operar con su equipo.
- Zona de riesgo: zona restringida donde solo se entra con procedimiento y equipo dieléctrico.
- Zona prohibida: no se permite el ingreso; el contacto o la descarga son probables.

IMPORTANTE: las distancias se miden considerando la posición del cuerpo, las herramientas y cualquier objeto conductor que se manipule. Una herramienta larga reduce la distancia real y puede introducir al trabajador en la zona prohibida.

## Delimitación y señalización

- Delimitar con barreras físicas el área de trabajo eléctrico
- Colocar señalización de riesgo eléctrico y de prohibición de acceso
- Identificar los tableros y circuitos con nomenclatura clara
- Mantener actualizado el diagrama unifilar en el punto de acceso
- Restringir el acceso a personal autorizado

## Documentación del trabajo

Antes de iniciar una intervención eléctrica se requiere:

1. Análisis de riesgo específico de la actividad
2. Permiso de trabajo eléctrico cuando aplique
3. Procedimiento de trabajo seguro por escrito
4. Lista de verificación de equipo de protección
5. Designación del responsable del trabajo y del personal que interviene

# Conclusiones

La clasificación del trabajo eléctrico no es un trámite administrativo: define si el trabajo se puede realizar, quién puede hacerlo y con qué protección. Cuando se clasifica mal, todo lo que sigue se construye sobre una base equivocada.',
  'https://www.youtube.com/embed/AK8OAKOq4mo',
  30, 2, true
),

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title = 'Seguridad en Trabajos de Operación y Mantenimiento de Instalaciones Eléctricas (NOM-029-STPS-2011)')
     AND order_index = 2),
  'Trabajo desenergizado: las cinco reglas de oro',
  'Desconexión, bloqueo y etiquetado, verificación de ausencia de tensión, puesta a tierra y delimitación.',
  'mixed',
  '# Trabajo Desenergizado: las Cinco Reglas de Oro

Todo trabajo eléctrico debe realizarse con la instalación desenergizada, salvo justificación técnica documentada. Las cinco reglas de oro son el procedimiento universal para garantizar esa condición.

## Las cinco reglas, en orden

### 1. Desconectar

Abrir todas las fuentes de alimentación que puedan energizar la instalación, incluidos los respaldos: plantas de emergencia, bancos de baterías, sistemas de respaldo y alimentaciones cruzadas.

### 2. Bloquear y etiquetar

Aplicar candado y tarjeta en cada punto de desconexión. Solo el trabajador que colocó su candado puede retirarlo. La tarjeta debe indicar el nombre del responsable, la fecha, el trabajo a realizar y el medio de contacto.

### 3. Verificar ausencia de tensión

Comprobar con instrumento verificador adecuado al nivel de tensión, antes y después de la intervención. El verificador debe probarse en una fuente conocida antes y después de la medición, para descartar falla del instrumento.

### 4. Poner a tierra y en cortocircuito

Instalar la puesta a tierra temporal en todos los conductores, desde el lado de la instalación hacia la fuente. Esta regla protege contra una energización accidental o por retroalimentación.

### 5. Delimitar y señalizar el área

Colocar barreras, cintas y señalización que impidan el acceso de personas ajenas al trabajo. Informar al personal del área.

IMPORTANTE: el orden de las reglas no es opcional. Verificar ausencia de tensión antes de bloquear expone al trabajador a una reenergización accidental. Saltarse una regla invalida todo el procedimiento.

## Bloqueo y etiquetado aplicado a electricidad

- Utilizar candados personales, no candados de área compartidos
- Identificar cada candado con el nombre del trabajador
- Usar tarjetas resistentes al agua y a los solventes
- Aplicar bloqueo en seccionadores, interruptores de cuchillas y protecciones
- Documentar el bloqueo en el permiso de trabajo

## Verificación de ausencia de tensión

- Confirmar la tensión nominal del circuito antes de elegir el instrumento
- Verificar el funcionamiento del instrumento en una fuente conocida
- Medir en los tres conductores y entre conductores y tierra
- Repetir la verificación del instrumento al terminar la medición
- Registrar la verificación en el permiso de trabajo

## Reenergización

La reenergización es tan crítica como la desconexión. Se realiza solo cuando:

1. El trabajo está terminado y el área está libre de personal y herramienta
2. Las puestas a tierra temporales fueron retiradas
3. Los bloqueos fueron retirados por quien los colocó
4. Se avisó al personal del área
5. Se restablece la alimentación de forma controlada y verificando la ausencia de fallas

# Puntos clave

- La instalación se considera energizada hasta que se verifique lo contrario
- El bloqueo es personal e intransferible
- El verificador se prueba antes y después de cada medición
- La puesta a tierra temporal protege contra retroalimentación
- Nadie restablece la energía sin confirmar que el área está despejada

# Conclusiones

Las cinco reglas de oro son un procedimiento repetible que convierte una tarea de alto riesgo en una tarea controlada. Su valor está en la disciplina de ejecutarlas completas y en orden, incluso cuando el trabajo parece sencillo.',
  'https://www.youtube.com/embed/kESQ_f6OKoI',
  30, 1, true
),

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title = 'Seguridad en Trabajos de Operación y Mantenimiento de Instalaciones Eléctricas (NOM-029-STPS-2011)')
     AND order_index = 2),
  'Trabajo energizado, arco eléctrico y equipo de protección',
  'Justificación del trabajo en tensión, EPP dieléctrico, riesgos de arco y respuesta a accidentes eléctricos.',
  'mixed',
  '# Trabajo Energizado, Arco Eléctrico y Protección Personal

El trabajo energizado es la excepción, no la regla. Se justifica únicamente cuando la desenergización no es factible o cuando interrumpir el suministro genera un riesgo mayor que el propio trabajo en tensión.

## Condiciones para autorizar trabajo energizado

- Justificación técnica documentada y aprobada
- Procedimiento específico por escrito para esa actividad
- Personal calificado y autorizado para ese nivel de tensión
- Equipo de protección dieléctrico inspeccionado y vigente
- Supervisión permanente durante la actividad
- Análisis de riesgo y permiso de trabajo vigentes

## Equipo de protección personal dieléctrico

| Elemento | Función | Verificación |
| Guantes dieléctricos | Aislamiento de manos | Prueba de inflado y fecha de ensayo |
| Mangas o guantes de protección mecánica | Protección del guante dieléctrico | Integridad y talla |
| Careta facial | Protección contra arco y proyecciones | Sin fisuras ni rayaduras |
| Ropa resistente al arco | Protección térmica del cuerpo | Categoría adecuada a la energía incidente |
| Calzado dieléctrico | Aislamiento de pies | Suela íntegra y sin humedad |
| Casco dieléctrico | Protección de cabeza | Clase eléctrica y estado |
| Tapete o banqueta aislante | Aislamiento del piso | Superficie limpia y seca |
| Herramienta aislada | Manipulación en tensión | Certificación y estado del aislamiento |

IMPORTANTE: los guantes dieléctricos se inspeccionan antes de cada uso mediante prueba de inflado y se envían a ensayo eléctrico periódico conforme a la normatividad. Un guante con una perforación mínima pierde toda su capacidad de aislamiento.

## Arco eléctrico

El arco eléctrico es una descarga a través del aire que libera energía en forma de calor extremo, luz intensa, presión y proyección de partículas. Puede alcanzar temperaturas superiores a las de la superficie del sol y producir quemaduras graves sin contacto físico.

Factores que incrementan el riesgo de arco:

- Manipulación de seccionadores con carga
- Herramientas o materiales que reducen la distancia de seguridad
- Conexiones flojas o con corrosión
- Equipos con mantenimiento deficiente
- Trabajo en tableros energizados sin protección facial

Medidas de control:

- Operar seccionadores sin carga siempre que sea posible
- Usar ropa y careta con clasificación de arco conforme a la energía incidente calculada
- Mantener distancia y postura corporal alejada del tablero
- No usar reloj, anillos, cadenas ni objetos metálicos
- Verificar el estado de las conexiones antes de intervenir

## Respuesta ante un accidente eléctrico

1. No tocar a la víctima mientras esté en contacto con la fuente.
2. Cortar la energía o separar a la persona con material aislante.
3. Solicitar ayuda y activar el servicio médico de emergencia.
4. Verificar consciencia y respiración.
5. Iniciar reanimación cardiopulmonar si no hay respiración ni pulso, si se cuenta con capacitación.
6. Atender quemaduras con agua y cubrir con material limpio.
7. Trasladar a valoración médica en todos los casos, incluso si la persona se siente bien: las arritmias pueden presentarse horas después.

# Puntos clave

- El trabajo energizado requiere justificación, procedimiento y supervisión
- El EPP dieléctrico tiene vigencia y debe ensayarse periódicamente
- El arco eléctrico lesiona sin contacto físico
- Toda persona que recibió una descarga debe ser valorada médicamente

# Conclusiones

La protección eléctrica se construye en capas: evitar el contacto, aislar la energía, proteger el cuerpo y responder con rapidez si algo falla. Ninguna capa es suficiente por sí sola, y omitir una traslada el riesgo a la siguiente.',
  'https://www.youtube.com/embed/wlGOtvUpnhw',
  30, 2, true
);

INSERT INTO public.quizzes (lesson_id, title, description, passing_score, total_questions, is_active)
SELECT l.id,
       'Examen Final: Seguridad en Trabajos de Operación y Mantenimiento de Instalaciones Eléctricas (NOM-029-STPS-2011)',
       'Evaluación técnica de 10 preguntas. Requiere 80% para aprobar.',
       80, 10, true
FROM public.lessons l
JOIN public.modules m ON m.id = l.module_id
JOIN public.courses c ON c.id = m.course_id
WHERE c.title = 'Seguridad en Trabajos de Operación y Mantenimiento de Instalaciones Eléctricas (NOM-029-STPS-2011)'
ORDER BY l.id DESC
LIMIT 1;

INSERT INTO public.quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.correct, v.exp, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Qué norma establece las condiciones de seguridad para el mantenimiento de instalaciones eléctricas en los centros de trabajo?',
   'NOM-006-STPS', 'NOM-019-STPS', 'NOM-029-STPS', 'NOM-036-1-STPS', 'c',
   'La NOM-029-STPS-2011 regula las condiciones de seguridad para el mantenimiento de las instalaciones eléctricas en los centros de trabajo.', 1),
  ('¿Por qué la corriente alterna de frecuencia industrial es especialmente peligrosa?',
   'Porque no genera calor', 'Porque provoca tetanización y la persona no puede soltar el conductor', 'Porque solo afecta a los equipos', 'Porque es de bajo voltaje', 'b',
   'La corriente alterna provoca contracción muscular sostenida, de modo que la persona pierde el control de sus músculos y no puede separarse del conductor.', 2),
  ('¿Cuál es el orden correcto de las cinco reglas de oro?',
   'Bloquear, desconectar, señalizar, verificar, aterrizar', 'Desconectar, bloquear y etiquetar, verificar ausencia de tensión, poner a tierra y delimitar', 'Verificar, desconectar, aterrizar, bloquear, señalizar', 'Aterrizar, bloquear, desconectar, verificar, señalizar', 'b',
   'El orden es desconectar, bloquear y etiquetar, verificar ausencia de tensión, poner a tierra y en cortocircuito, y delimitar y señalizar el área.', 3),
  ('¿Quién puede retirar el candado de bloqueo de un punto de desconexión?',
   'Cualquier integrante del equipo de mantenimiento', 'Únicamente el trabajador que lo colocó', 'El supervisor de turno', 'El jefe de seguridad patrimonial', 'b',
   'El bloqueo es personal e intransferible: solo quien colocó el candado puede retirarlo, lo que garantiza que el trabajo haya terminado.', 4),
  ('¿Para qué se prueba el verificador de tensión antes y después de cada medición?',
   'Para calibrarlo con precisión', 'Para descartar que el instrumento esté defectuoso y dé una lectura falsa', 'Para medir la resistencia del cuerpo', 'Para cargar su batería', 'b',
   'Probar el verificador en una fuente conocida antes y después descarta fallas del instrumento que podrían hacer concluir erróneamente que no hay tensión.', 5),
  ('¿Cuándo se justifica realizar un trabajo con la instalación energizada?',
   'Cuando se requiere terminar rápido', 'Cuando la desenergización no es factible o genera un riesgo mayor, con justificación documentada', 'Cuando el trabajador tiene experiencia', 'Siempre que se use casco', 'b',
   'El trabajo energizado es la excepción y requiere justificación técnica documentada, procedimiento específico, personal autorizado y supervisión permanente.', 6),
  ('¿Cómo se inspecciona un guante dieléctrico antes de cada uso?',
   'Con una prueba de inflado para detectar perforaciones', 'Solo revisando la fecha impresa', 'Con una prueba visual de color', 'No requiere inspección si está guardado', 'a',
   'La prueba de inflado detecta perforaciones que a simple vista no se observan. Además, los guantes deben someterse a ensayo eléctrico periódico.', 7),
  ('¿Cuál es una causa frecuente de arco eléctrico?',
   'Trabajar con la instalación desenergizada', 'Manipular seccionadores con carga', 'Usar herramienta aislada', 'Verificar ausencia de tensión', 'b',
   'Operar seccionadores bajo carga es una causa frecuente de arco eléctrico, que puede producir quemaduras graves sin contacto físico.', 8),
  ('¿Qué se debe hacer primero si una persona está en contacto con un conductor energizado?',
   'Jalarla de inmediato con las manos', 'Cortar la energía o separarla con material aislante', 'Rociar agua para dispersar la corriente', 'Esperar a que se suelte sola', 'b',
   'Nunca se toca a la víctima mientras esté en contacto con la fuente. Primero se corta la energía o se separa con material aislante.', 9),
  ('¿Por qué toda persona que recibió una descarga eléctrica debe ser valorada médicamente aunque se sienta bien?',
   'Por requisito administrativo', 'Porque pueden presentarse arritmias u otras complicaciones horas después', 'Para documentar el incidente', 'Porque la corriente altera la presión arterial de forma permanente', 'b',
   'Las alteraciones cardíacas y otras complicaciones pueden manifestarse horas después de la descarga, por lo que la valoración médica siempre es necesaria.', 10)
) AS v(qt, a, b, c, d, correct, exp, ord)
WHERE q.title = 'Examen Final: Seguridad en Trabajos de Operación y Mantenimiento de Instalaciones Eléctricas (NOM-029-STPS-2011)';

COMMIT;

SELECT c.title AS curso,
       (SELECT COUNT(*) FROM public.modules m WHERE m.course_id = c.id) AS modulos,
       (SELECT COUNT(*) FROM public.lessons l
        JOIN public.modules m ON m.id = l.module_id
        WHERE m.course_id = c.id) AS lecciones
FROM public.courses c
WHERE c.title = 'Seguridad en Trabajos de Operación y Mantenimiento de Instalaciones Eléctricas (NOM-029-STPS-2011)';
