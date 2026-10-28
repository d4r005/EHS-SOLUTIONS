-- ============================================================
-- EHS SOLUTIONS - CONTENIDO DEL CURSO:
-- SEGURIDAD EN LA CADENA DE SUMINISTRO Y CONCIENTIZACIÓN CTPAT
-- Referencia: CTPAT (Customs-Trade Partnership Against Terrorism),
-- programa de la Oficina de Aduanas y Protección Fronteriza de EUA
-- Ejecutar en Supabase -> SQL Editor
-- Idempotente: se puede volver a ejecutar sin duplicar contenido.
-- ============================================================

BEGIN;

-- 0. Verificación del título del curso (debe coincidir exactamente)
DO $guard$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.courses WHERE title = 'Seguridad en la Cadena de Suministro y Concientización CTPAT') THEN
    RAISE EXCEPTION 'Curso no encontrado. Se requiere el título exacto: Seguridad en la Cadena de Suministro y Concientización CTPAT';
  END IF;
END
$guard$;

DELETE FROM public.quizzes
WHERE lesson_id IN (
  SELECT l.id FROM public.lessons l
  JOIN public.modules m ON m.id = l.module_id
  WHERE m.course_id = (SELECT id FROM public.courses WHERE title = 'Seguridad en la Cadena de Suministro y Concientización CTPAT')
);

DELETE FROM public.modules
WHERE course_id = (SELECT id FROM public.courses WHERE title = 'Seguridad en la Cadena de Suministro y Concientización CTPAT');

INSERT INTO public.modules (course_id, title, description, order_index) VALUES
  ((SELECT id FROM public.courses WHERE title = 'Seguridad en la Cadena de Suministro y Concientización CTPAT'),
   'Fundamentos del Programa CTPAT',
   'Origen, alcance, beneficios y criterios mínimos de seguridad del programa.',
   1),
  ((SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title = 'Seguridad en la Cadena de Suministro y Concientización CTPAT')
     AND order_index = 2),
   'Implementación y Cultura de Seguridad',
   'Análisis de riesgos, plan de seguridad, concientización del personal y vigilancia.',
   2);

INSERT INTO public.lessons (module_id, title, description, content_type, content, video_url, duration_minutes, order_index, is_required) VALUES

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title = 'Seguridad en la Cadena de Suministro y Concientización CTPAT')
     AND order_index = 1),
  'Origen, alcance y beneficios del programa CTPAT',
  'Qué es CTPAT, por qué nació, quiénes participan y qué beneficios obtiene la empresa certificada.',
  'mixed',
  '# Origen, Alcance y Beneficios del Programa CTPAT

CTPAT son las siglas de Customs-Trade Partnership Against Terrorism, la Asociación Aduanas-Comercio contra el Terrorismo. Es un programa voluntario de la Oficina de Aduanas y Protección Fronteriza de Estados Unidos, conocido como CBP, en el que la iniciativa privada y la autoridad aduanera colaboran para proteger la cadena de suministro.

## Por qué nació

Después de los atentados de 2001, la autoridad aduanera de Estados Unidos cambió su enfoque: dejó de revisar solo la mercancía en la frontera y comenzó a mirar todo el trayecto, desde la fábrica de origen hasta el destino final. La lógica es simple: si el contenedor se interviene en origen, el riesgo se controla antes de llegar a la frontera.

CTPAT se creó en 2001 con un grupo inicial de empresas y desde entonces se convirtió en el estándar de seguridad más utilizado en el comercio con Estados Unidos.

## Quiénes participan

El programa agrupa a distintos tipos de socios comerciales:

- Importadores y exportadores
- Transportistas terrestres, aéreos, marítimos y ferroviarios
- Consolidadores y agentes de carga
- Almacenes y depósitos
- Puertos y terminales
- Fabricantes y proveedores de servicio

Una empresa certificada extiende los requisitos de seguridad a sus socios comerciales: es lo que se conoce como cadena de socios o business partners.

## Beneficios de la certificación

- Reducción del número de inspecciones aduanales
- Acceso a carriles exclusivos o de menor espera en la frontera
- Menor tiempo de cruce y mayor previsibilidad en los tiempos de entrega
- Asignación de un especialista de cuenta del programa
- Prioridad de atención ante incidentes o interrupciones
- Reconocimiento mutuo con programas equivalentes de otros países
- Mejora en la gestión interna de seguridad y en la confianza de los clientes

IMPORTANTE: CTPAT no es un requisito obligatorio para exportar, pero en la práctica se ha convertido en una condición comercial. Muchos grandes compradores solicitan que sus proveedores estén certificados o que cumplan criterios equivalentes.

## Qué espera el programa de la empresa

La certificación no se obtiene con un trámite: se obtiene demostrando que la empresa opera con controles de seguridad verificables en toda su cadena. El programa evalúa, entre otros aspectos:

- Gestión de la seguridad y responsabilidad de la dirección
- Seguridad de los socios comerciales
- Seguridad física de las instalaciones
- Controles de acceso físico
- Seguridad del personal
- Seguridad de los procesos
- Seguridad de la información y ciberseguridad
- Formación y concientización del personal
- Seguridad agrícola cuando aplique

## Proceso general de certificación

1. La empresa presenta su solicitud al programa.
2. Se firma el acuerdo de socio comercial.
3. La empresa realiza una evaluación de riesgos de su cadena.
4. Implementa y documenta los criterios mínimos de seguridad.
5. Recibe una validación por parte de la autoridad.
6. Obtiene la certificación y entra en un ciclo de mejora continua.

# Conclusiones

CTPAT traslada la seguridad de la cadena al origen. Para la empresa significa menos inspecciones y más velocidad, pero también un compromiso permanente: la certificación se sostiene con evidencia de operación, no con el certificado en la pared.',
  'https://www.youtube.com/embed/A4tO6W06jy0',
  30, 1, true
),

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title = 'Seguridad en la Cadena de Suministro y Concientización CTPAT')
     AND order_index = 1),
  'Criterios mínimos de seguridad del programa',
  'Categorías de criterios, requisitos de socios comerciales, seguridad física y controles de acceso.',
  'mixed',
  '# Criterios Mínimos de Seguridad del Programa

Los criterios mínimos de seguridad son el conjunto de requisitos que una empresa debe cumplir y documentar. Están organizados por categorías y se aplican en función del tipo de socio comercial.

## Gestión de la seguridad

- Designar a una persona responsable de la seguridad del programa
- Documentar una política de seguridad aprobada por la dirección
- Realizar una evaluación de riesgos de la cadena de suministro
- Establecer un plan de seguridad por escrito y revisarlo periódicamente
- Mantener registros de las acciones de mejora

## Seguridad de los socios comerciales

- Procedimiento documentado para seleccionar y evaluar socios comerciales
- Verificación del cumplimiento de criterios de seguridad en los socios
- Requisitos contractuales de seguridad
- Evaluación periódica y registro de resultados
- Procedimiento para actuar ante un socio que no cumple

## Seguridad física

- Perímetro definido, con barreras y control de accesos
- Iluminación suficiente en accesos, patios y almacenes
- Sistemas de detección y vigilancia en áreas críticas
- Control de llaves y de dispositivos de acceso
- Mantenimiento de la infraestructura de seguridad

## Controles de acceso físico

- Identificación y registro de toda persona que ingresa
- Distintivos visibles para empleados y visitantes
- Procedimiento para visitantes, con acompañamiento
- Registro de entrada y salida de vehículos
- Restricción de acceso a áreas sensibles: almacén, muelle, sistemas

## Seguridad del personal

- Verificación de antecedentes antes de contratar, conforme a la legislación aplicable
- Procedimiento de baja con recuperación de identificaciones y accesos
- Registro actualizado del personal
- Identificación de empleados con acceso a áreas restringidas

## Seguridad de los procesos

- Procedimientos para el manejo, almacenamiento y despacho de mercancía
- Control de precintos y verificación de su integridad
- Inspección de unidades de transporte antes de cargar
- Control de la documentación y de las discrepancias
- Procedimiento ante mercancía no autorizada o faltante

## Seguridad de la información

- Protección de los sistemas y de los datos de la operación
- Control de acceso a los sistemas informáticos
- Política de contraseñas y de uso de dispositivos
- Respaldo de información y protocolo ante incidentes

IMPORTANTE: la ciberseguridad es hoy una categoría formal del programa. Un ataque a los sistemas de una empresa puede alterar manifiestos, direcciones de entrega o documentación aduanal, y con ello comprometer la cadena completa.

## Concientización y formación

- Programa de formación en seguridad para todo el personal
- Capacitación específica por puesto y por nivel de acceso
- Mecanismo para reportar incidentes o actividades sospechosas
- Registro de las capacitaciones impartidas

## Seguridad agrícola

Aplica a empresas que manejan productos agrícolas o perecederos. Incorpora controles adicionales para prevenir contaminación intencional o introducción de plagas durante el proceso.

# Puntos clave

- Los criterios se cumplen y se demuestran con evidencia documental
- Los requisitos se extienden a los socios comerciales
- El precinto es un elemento crítico de integridad de la carga
- La seguridad de la información forma parte del programa

# Conclusiones

Los criterios mínimos no son una lista de compras de seguridad: son un sistema donde cada categoría refuerza a las demás. Una empresa puede tener cámaras y barda, pero si no controla precintos ni verifica socios, su cadena sigue siendo vulnerable.',
  'https://www.youtube.com/embed/KmUXQlE6skI',
  30, 2, true
),

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title = 'Seguridad en la Cadena de Suministro y Concientización CTPAT')
     AND order_index = 2),
  'Análisis de riesgos y plan de seguridad',
  'Metodología de análisis, identificación de vulnerabilidades y estructura del plan de seguridad.',
  'mixed',
  '# Análisis de Riesgos y Plan de Seguridad

El plan de seguridad de CTPAT se construye sobre un análisis de riesgos. Sin ese análisis, el plan se convierte en una copia de requisitos genéricos que no responde a la operación real de la empresa.

## Metodología de análisis de riesgos

1. Mapear la cadena de suministro: origen, transporte, almacenamiento, aduanas y destino.
2. Identificar los puntos donde la carga cambia de manos o de medio de transporte.
3. Identificar las amenazas relevantes en cada punto.
4. Evaluar la vulnerabilidad existente: qué control hay hoy y qué tan sólido es.
5. Determinar el riesgo combinando amenaza y vulnerabilidad.
6. Definir las medidas de mitigación y su responsable.
7. Revisar el análisis con una periodicidad definida o cuando cambie la operación.

## Puntos críticos de la cadena

- Acceso de personal ajeno a las áreas de carga
- Cambio de transportista o de unidad en ruta
- Perdida de visibilidad de la carga en tramos subcontratados
- Almacenamiento temporal sin control de acceso
- Manejo documental entre áreas y empresas
- Procesos de contratación y baja de personal
- Acceso a sistemas que contienen información de embarques

## Amenazas frecuentes

- Introducción de mercancía no declarada en la unidad
- Contaminación intencional de producto
- Robo con violencia en ruta
- Alteración de documentos o de manifiestos
- Suplantación de identidad de transportista
- Acceso no autorizado a instalaciones
- Filtración de información de embarques

## Estructura del plan de seguridad

- Política de seguridad firmada por la dirección
- Alcance y responsabilidades por puesto
- Resultados del análisis de riesgos
- Medidas de control por categoría de criterio
- Procedimientos operativos de seguridad
- Programa de capacitación y concientización
- Procedimiento de reporte de incidentes
- Plan de auditoría interna y de mejora continua
- Anexos: formatos, registros y evidencia

## Responsabilidades

| Nivel | Responsabilidad |
| Dirección | Aprobar la política y asignar recursos |
| Responsable de seguridad | Coordinar el programa y su documentación |
| Supervisión operativa | Verificar el cumplimiento diario |
| Personal operativo | Cumplir procedimientos y reportar anomalías |

IMPORTANTE: el plan debe describir lo que la empresa realmente hace. Un plan que promete controles que no existen se detecta de inmediato en la validación y, peor aún, deja a la empresa sin defensa ante un incidente real.

## Verificación y mejora continua

- Auditorías internas programadas por área y por criterio
- Revisión de hallazgos con acciones correctivas
- Actualización del análisis de riesgos ante cambios de operación
- Registro de la eficacia de las acciones implementadas

# Conclusiones

El análisis de riesgos es lo que distingue un programa vivo de un manual archivado. Cuando la empresa sabe dónde está expuesta, puede priorizar inversiones y concentrar sus controles en los puntos que realmente importan.',
  'https://www.youtube.com/embed/c2VBV4ckoYI',
  30, 1, true
),

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title = 'Seguridad en la Cadena de Suministro y Concientización CTPAT')
     AND order_index = 2),
  'Concientización del personal y reporte de incidentes',
  'Cultura de seguridad, señales de alerta, canales de reporte y respuesta ante incidentes.',
  'text',
  '# Concientización del Personal y Reporte de Incidentes

La tecnología no reemplaza la vigilancia humana. La mayoría de los intentos de vulnerar una cadena de suministro se detectan porque alguien notó algo fuera de lugar y lo reportó.

## Por qué la concientización es un criterio del programa

Una empresa puede tener barda perimetral, cámaras y control de acceso, pero si el personal no sabe qué observar ni a quién reportar, los controles se vuelven ciegos. La concientización convierte a cada trabajador en un sensor del sistema.

## Qué debe saber todo el personal

- La política de seguridad de la empresa y su razón de ser
- Cuáles son las áreas restringidas y por qué no debe acceder quien no está autorizado
- Cómo identificar a un visitante o proveedor que no cumple el procedimiento
- Qué es un precinto, por qué importa y cómo reconocer una alteración
- Cómo identificar mercancía o paquete no reconocido en su área
- Cómo reportar una situación sospechosa sin temor a represalias

## Señales de alerta

- Personas sin identificación visible en áreas restringidas
- Intentos de acceder a información de embarques sin justificación
- Preguntas inusuales sobre rutas, horarios o medidas de seguridad
- Paquetes o bultos desconocidos en el área de carga
- Precintos con numeración que no coincide con la documentación
- Unidad de transporte que llega sin aviso o con conductor distinto al programado
- Puertas o accesos encontrados abiertos sin justificación
- Fotografías no autorizadas en áreas sensibles

## Canales de reporte

El reporte debe ser fácil, directo y conocido por todo el personal:

1. Reporte inmediato al supervisor de área.
2. Línea telefónica o canal interno de seguridad disponible las 24 horas.
3. Correo o formulario interno de reporte.
4. Registro escrito en la bitácora del turno.

IMPORTANTE: la protección al informante es parte del programa. Si el personal teme represalias por reportar, el canal deja de usarse y el sistema de seguridad pierde su fuente de información más valiosa.

## Procedimiento ante un incidente

1. Asegurar a las personas y alejar a quien no participa en la respuesta.
2. No manipular la escena ni la mercancía involucrada.
3. Informar de inmediato al responsable de seguridad.
4. Documentar con fotografías, nombres y horarios cuando sea seguro hacerlo.
5. Preservar la documentación y los registros del evento.
6. Evaluar si se requiere notificar a la autoridad o al cliente.
7. Analizar la causa y definir acciones correctivas.
8. Actualizar el análisis de riesgos si corresponde.

## Capacitación continua

- Inducción en seguridad para todo el personal de nuevo ingreso
- Reforzamiento periódico con casos reales de la propia operación
- Capacitación específica por puesto: muelle, almacén, transporte, sistemas
- Simulacros y ejercicios de detección
- Registro de asistencia y evaluación del aprendizaje

# Puntos clave

- La concientización es un criterio formal del programa, no un extra
- El personal es la fuente de detección más efectiva
- Todo reporte debe tener un canal claro y una respuesta visible
- Un incidente se documenta antes de corregirlo

# Conclusiones

La cultura de seguridad se construye cuando el trabajador entiende el porqué de cada control y confía en que su reporte será atendido. En CTPAT, la diferencia entre una empresa certificada y una empresa segura está justamente ahí: en lo que pasa en el muelle a las tres de la mañana.',
  NULL,
  30, 2, true
);

INSERT INTO public.quizzes (lesson_id, title, description, passing_score, total_questions, is_active)
SELECT l.id,
       'Examen Final: Seguridad en la Cadena de Suministro y Concientización CTPAT',
       'Evaluación técnica de 10 preguntas. Requiere 80% para aprobar.',
       80, 10, true
FROM public.lessons l
JOIN public.modules m ON m.id = l.module_id
JOIN public.courses c ON c.id = m.course_id
WHERE c.title = 'Seguridad en la Cadena de Suministro y Concientización CTPAT'
ORDER BY l.id DESC
LIMIT 1;

INSERT INTO public.quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.correct, v.exp, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Qué significa CTPAT?',
   'Certificación de Transporte y Producción Agroalimentaria', 'Customs-Trade Partnership Against Terrorism', 'Control Total de Procesos Aduanales y Transporte', 'Centro de Tráfico y Protección Aduanal', 'b',
   'CTPAT es la Asociación Aduanas-Comercio contra el Terrorismo, programa voluntario de la Oficina de Aduanas y Protección Fronteriza de Estados Unidos.', 1),
  ('¿Cuál es la naturaleza del programa CTPAT?',
   'Obligatorio para toda exportación', 'Voluntario, con beneficios para las empresas certificadas', 'Exclusivo para transportistas marítimos', 'Un requisito fiscal', 'b',
   'Es un programa voluntario de colaboración entre la autoridad aduanera y la iniciativa privada, que otorga beneficios a las empresas certificadas.', 2),
  ('¿Cuál es un beneficio típico de la certificación CTPAT?',
   'Exención del pago de aranceles', 'Reducción del número de inspecciones y menor tiempo de cruce', 'Eliminación de los controles de seguridad', 'Sustitución del pedimento aduanal', 'b',
   'La certificación reduce inspecciones y tiempos de cruce, pero no exime del pago de aranceles ni de los controles documentales.', 3),
  ('¿Por qué el programa evalúa la seguridad de los socios comerciales?',
   'Porque el socio comparte la responsabilidad sobre la integridad de la carga', 'Porque lo exige la legislación fiscal', 'Para reducir costos de transporte', 'Para acreditar la calidad del producto', 'a',
   'La cadena es tan segura como su eslabón más débil. La empresa certificada debe verificar que sus socios cumplan criterios de seguridad.', 4),
  ('¿Qué es un precinto en el contexto de CTPAT?',
   'Un documento aduanal', 'Un dispositivo que garantiza la integridad de la unidad de transporte y su numeración debe coincidir con la documentación', 'Una etiqueta de precio', 'Un permiso de conducir', 'b',
   'El precinto asegura la integridad de la carga. Su numeración debe coincidir con la documentación y cualquier alteración es una señal de alerta.', 5),
  ('¿Qué incluye la categoría de seguridad de la información?',
   'Solo el resguardo de equipos de cómputo', 'Control de acceso a sistemas, protección de datos, contraseñas y protocolo ante incidentes', 'Únicamente la instalación de antivirus', 'La publicación de datos de embarques', 'b',
   'La ciberseguridad abarca control de acceso, política de contraseñas, respaldo y protocolo de respuesta ante incidentes informáticos.', 6),
  ('¿Cuál es el primer paso para construir el plan de seguridad?',
   'Comprar cámaras', 'Realizar el análisis de riesgos de la cadena de suministro', 'Contratar más vigilancia', 'Redactar una política general', 'b',
   'El plan se construye sobre el análisis de riesgos. Sin ese análisis, el plan no responde a la operación real de la empresa.', 7),
  ('¿Qué debe hacer un trabajador que detecta un paquete desconocido en el área de carga?',
   'Abrirlo para identificar su contenido', 'Moverlo a un lugar apartado', 'No manipularlo y reportarlo de inmediato por el canal establecido', 'Esperar al siguiente turno', 'c',
   'No se manipula el objeto. Se reporta de inmediato y se sigue el procedimiento, preservando la escena y la documentación.', 8),
  ('¿Por qué la protección al informante es un elemento del programa?',
   'Para cumplir un requisito administrativo', 'Porque si el personal teme represalias deja de reportar y el sistema pierde su principal fuente de detección', 'Para reducir el número de reportes', 'Porque lo solicita el cliente', 'b',
   'Sin confianza en el canal de reporte, el personal deja de informar y la empresa pierde la fuente de detección más efectiva de su cadena.', 9),
  ('¿Cuál es una señal de alerta que debe reportarse?',
   'Un proveedor con identificación y cita programada', 'Un conductor distinto al programado que llega sin aviso', 'Un empleado con distintivo visible', 'Un precinto que coincide con la documentación', 'b',
   'Un cambio de conductor no programado o una unidad que llega sin aviso son señales de alerta que deben reportarse y verificarse antes de cargar.', 10)
) AS v(qt, a, b, c, d, correct, exp, ord)
WHERE q.title = 'Examen Final: Seguridad en la Cadena de Suministro y Concientización CTPAT';

COMMIT;

SELECT c.title AS curso,
       (SELECT COUNT(*) FROM public.modules m WHERE m.course_id = c.id) AS modulos,
       (SELECT COUNT(*) FROM public.lessons l
        JOIN public.modules m ON m.id = l.module_id
        WHERE m.course_id = c.id) AS lecciones
FROM public.courses c
WHERE c.title = 'Seguridad en la Cadena de Suministro y Concientización CTPAT';
