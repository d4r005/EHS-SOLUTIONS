# Plan: Uso de Plantilla para Certificados (DC-3)

Este plan detalla cómo integrar tu plantilla personalizada (PDF o Imagen) en el sistema de generación de certificados de EHS Solutions.

## User Review Required

> [!IMPORTANT]
> Para usar tu plantilla, necesitamos decidir el formato técnico:
> 1. **Opción A (Recomendada por simplicidad)**: Convertir tu PDF a una imagen **PNG de alta resolución (300 DPI)**. Esto permite usar la librería actual (`jsPDF`) y es muy fácil de ajustar.
> 2. **Opción B (Vectorial)**: Usar el PDF directamente con una nueva librería llamada `pdf-lib`. Es más complejo de configurar pero mantiene la calidad original del PDF.

## Propuesta: Opción A (Imagen de Fondo)

### 1. Preparación de Archivo
- Debes guardar tu plantilla como `template.png` en la carpeta `frontend/lms/public/assets/`.
- Si no existe la carpeta, la crearemos.

### 2. Modificación de Código
#### [MODIFY] [certificateService.js](file:///C:/Users/dtruj/AndroidStudioProjects/EHS-SOLUTIONS/frontend/lms/src/services/certificateService.js)
- Reemplazar el código de "dibujo manual" (bordes, logos, títulos) por una sola instrucción que cargue `template.png` como fondo de página completa.
- Ajustar las coordenadas (X, Y) del Nombre del Alumno, Nombre del Curso, Fecha y Folio para que coincidan exactamente con los espacios en blanco de tu plantilla.

## Pasos a seguir

1. **Confirmar Formato**: ¿Prefieres usar una imagen de fondo (PNG) o el PDF directo?
2. **Subir Archivo**: Necesitarás colocar el archivo en la ruta que te indicaré.
3. **Calibración**: Una vez aplicado el código, generaremos un certificado de prueba para mover los textos unos milímetros arriba/abajo hasta que queden perfectos en los huecos de tu diseño.

## Verificación Plan
- Descargar un certificado con la nueva plantilla.
- Verificar que el texto no se encime con tus logos o firmas ya impresas en la plantilla.
