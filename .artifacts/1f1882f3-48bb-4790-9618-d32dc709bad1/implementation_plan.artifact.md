# Plan: Corrección de Navegación en Dashboard y Formato de Contenido

## Objetivo
Solucionar el fallo del botón "Continuar Aprendiendo" en el dashboard y mejorar la legibilidad del contenido técnico en las lecciones.

## Cambios Propuestos

### 1. Dashboard de Estudiante
#### [MODIFY] [DashboardPage.jsx](file:///C:/Users/dtruj/AndroidStudioProjects/EHS-SOLUTIONS/frontend/lms/src/pages/DashboardPage.jsx)
- **Navegación**: Implementar `useNavigate` en el componente `CourseCard` para que el botón "Continuar Aprendiendo" funcione correctamente y lleve al usuario al detalle del curso.
- **Identificación**: Mostrar el **título real del curso** (ej. "Seguridad en Espacios Confinados") en lugar de un ID genérico ("Curso #4").
- **Visuales**: Asegurar que la miniatura del curso se muestre correctamente si existe.

### 2. Visor de Lecciones
#### [MODIFY] [LessonViewerPage.jsx](file:///C:/Users/dtruj/AndroidStudioProjects/EHS-SOLUTIONS/frontend/lms/src/pages/LessonViewerPage.jsx)
- **Refinamiento de Texto**: Mejorar la función `renderContent` para que también interprete negritas (`**texto**`) y limpie mejor los espacios en blanco, asegurando una presentación técnica de alta calidad.
- **Consistencia**: Garantizar que el contenido cargado desde la base de datos se presente de forma profesional y estructurada.

## Verificación Plan
### Pruebas de Navegación
- Ir al Dashboard como estudiante.
- Hacer clic en "Continuar Aprendiendo".
- Confirmar redirección a `/courses/:id`.

### Pruebas de Contenido
- Abrir una lección técnica (ej. Espacios Confinados).
- Verificar que los títulos, párrafos y negritas se rendericen correctamente sin símbolos Markdown visibles.
