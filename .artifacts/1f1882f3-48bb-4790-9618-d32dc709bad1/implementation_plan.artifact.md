# Plan: Activación Global de Exámenes y Solución de Error "No encontrado"

Este plan aborda el error técnico que impide visualizar los exámenes y realiza la carga masiva de evaluaciones para los 7 cursos de la plataforma.

## User Review Required

> [!IMPORTANT]
> El script SQL creará un total de **21 preguntas técnicas** distribuidas en los 7 cursos. Se vincularán automáticamente a la última lección de cada programa.

## 1. Correcciones de Código (Frontend)

### [MODIFY] [quizService.js](file:///C:/Users/dtruj/AndroidStudioProjects/EHS-SOLUTIONS/frontend/lms/src/services/quizService.js)
- Agregar método `getQuizById(id)` para centralizar la obtención de datos del examen con los encabezados de seguridad correctos.

### [MODIFY] [QuizPage.jsx](file:///C:/Users/dtruj/AndroidStudioProjects/EHS-SOLUTIONS/frontend/lms/src/pages/QuizPage.jsx)
- Reemplazar el `fetch` directo por la llamada al servicio `quizService.getQuizById`.
- Asegurar que el estado `loading` se maneje correctamente para evitar parpadeos de "Examen no encontrado".

## 2. Carga Masiva de Contenido (Base de Datos)

### [NEW] [full_exams_load.sql](file:///C:/Users/dtruj/AndroidStudioProjects/EHS-SOLUTIONS/database/full_exams_load.sql)
Prepararé un script que:
1. **Borra** registros de exámenes previos para evitar duplicidad.
2. **Crea** un examen para cada uno de los 7 cursos vinculándolo a la lección final.
3. **Inserta** 3 preguntas técnicas por curso basadas en:
   - **Alturas**: NOM-009, EPP, Rescate.
   - **Soldadura**: NOM-027, Riesgos eléctricos, Radiación.
   - **Brigadas**: Primeros auxilios, Evacuación, Incendios.
   - **Espacios Confinados**: NOM-033, Atmósferas, Monitoreo.
   - **LOTO**: Bloqueo, Energías peligrosas, Verificación.
   - **Instructores**: Andragogía, Diseño didáctico, Evaluación.
   - **Supervisores**: Liderazgo SST, Investigación de accidentes, Gestión.

## Verificación Plan
- Acceder a cada uno de los 7 cursos y confirmar que la última lección muestra el botón de examen.
- Abrir un examen y confirmar que las preguntas se cargan correctamente.
- Realizar un examen y verificar que el sistema califica y guarda el resultado.
