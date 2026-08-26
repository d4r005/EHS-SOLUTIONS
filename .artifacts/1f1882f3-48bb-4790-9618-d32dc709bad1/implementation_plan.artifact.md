# Plan de Implementación: Estabilización de Acceso Admin y Visualización de Exámenes

Este plan corrige la inconsistencia detectada donde el rol de Administrador no siempre desbloquea el modo revisión y asegura que los exámenes (Quizzes) aparezcan en las lecciones correspondientes.

## User Review Required

> [!IMPORTANT]
> Se requiere que el usuario verifique si los cursos tienen lecciones cargadas con el título exacto que contiene la palabra "Rescate", ya que el script de Quizzes depende de esto para vincular el examen.

## 1. Corrección de Inconsistencia en Modo Revisión (Admin)

### Problema
En algunos cursos, el Administrador ve el botón "Inscribirme" en lugar de "Revisar contenido". Esto ocurre por una condición de carrera (race condition) donde la información del curso se carga antes de que el perfil del usuario (y su rol) esté listo en el cliente.

### Solución
Modificar `CourseDetailPage.jsx` para esperar a que el estado de autenticación termine de cargar antes de decidir qué botón mostrar.

#### [MODIFY] [CourseDetailPage.jsx](file:///C:/Users/dtruj/AndroidStudioProjects/EHS-SOLUTIONS/frontend/lms/src/pages/CourseDetailPage.jsx)
- Importar `loading` desde `useAuth`.
- Si `authLoading` es true, mostrar el spinner de carga en lugar de renderizar el contenido con datos de usuario incompletos.
- Asegurar que `canViewContent` se recalcule correctamente cuando `user` cambie.

## 2. Asegurar Visualización de Exámenes (Quizzes)

### Problema
Los exámenes no aparecen al final de las lecciones. Esto puede deberse a que el script SQL no encontró la lección correcta para vincular el `quiz_id` debido a IDs desincronizados.

### Solución
Proporcionar un script SQL de "Vinculación Manual de Quizzes" basado en nombres de cursos y lecciones, y mejorar la visualización en el frontend.

#### [MODIFY] [LessonViewerPage.jsx](file:///C:/Users/dtruj/AndroidStudioProjects/EHS-SOLUTIONS/frontend/lms/src/pages/LessonViewerPage.jsx)
- Añadir un log de depuración (opcional para desarrollo) para verificar si se está intentando buscar un quiz.
- Asegurar que el botón de examen sea prominente.

## 3. Mejora en Dashboard para Admin

#### [MODIFY] [DashboardPage.jsx](file:///C:/Users/dtruj/AndroidStudioProjects/EHS-SOLUTIONS/frontend/lms/src/pages/DashboardPage.jsx)
- Si el usuario es Admin, permitir que el botón "Continuar Aprendiendo" funcione incluso si el progreso es 0 o no hay inscripción formal (modo revisión).

## Verificación Plan
1. Entrar como Admin y verificar que en TODOS los cursos aparece el botón de "Revisar contenido".
2. Navegar a la lección final de "Seguridad en Alturas" y confirmar que el botón "📋 Tomar examen" es visible.
