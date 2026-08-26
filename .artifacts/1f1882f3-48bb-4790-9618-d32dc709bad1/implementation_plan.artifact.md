# Plan de Implementación: Activación Total LMS y Corrección de Acceso

Este plan soluciona el error de "No autenticado" al inscribirse y aborda los 9 puntos pendientes para convertir la plataforma en un sistema similar a "Empire Consulting".

## User Review Required

> [!IMPORTANT]
> Para activar las funciones de pago y correos, necesitarás configurar las variables de entorno en Cloudflare (Stripe/MercadoPago y Resend) como se detalla en el archivo `DEPLOY.md`.

## 1. Corrección de Acceso y Sincronización de Usuarios

### Problema
El error "No autenticado" ocurre porque el sistema no encuentra el `userId` en la tabla pública de usuarios, o las políticas de seguridad (RLS) impiden que el usuario se vea a sí mismo.

### Solución
1.  **Automatizar Sincronización**: Implementar un Trigger en Supabase que cree automáticamente el perfil en `public.users` cada vez que alguien se registre en `auth.users`.
2.  **Corregir RLS**: Asegurar que los usuarios puedan leer su propio perfil y realizar inscripciones.

## 2. Activación de Funcionalidades Pendientes

### Módulo A: Pagos y Checkout (Puntos 1, 9)
- **MercadoPago**: Configurar el webhook para que, al detectar un pago aprobado, se cree automáticamente el registro en la tabla `enrollments`.
- **Bloqueo de Contenido**: Los cursos con `price > 0` mostrarán "Comprar" en lugar de "Inscribirme".

### Módulo B: Evaluaciones y Certificados (Puntos 2, 3, 8)
- **Quizzes**: Vincular el botón "Realizar Examen" al final de las lecciones que tengan un quiz asociado.
- **Certificados DC-3**: Al llegar al 100% de progreso y aprobar el examen, habilitar el botón "Descargar Certificado" que genera el PDF con el formato oficial.

### Módulo C: Administración (Puntos 4, 5)
- **Dashboard Admin**: Habilitar la vista de todos los usuarios e ingresos totales.
- **Dashboard Instructor**: Habilitar el editor de cursos para subir contenido sin usar código.

## Propuesta de Orden de Ejecución

1.  **SQL Fix 2.0**: Corregir de raíz la estructura de usuarios y permisos (Inmediato).
2.  **Auth Update**: Refinar la lógica de inicio de sesión para que nunca falle el `userId`.
3.  **LMS UI Sync**: Conectar los botones de Quizzes y Certificados que ya están programados pero no "visibles" para el usuario.

## Verificación Plan
1.  Registrar un nuevo usuario y verificar que se crea en la base de datos automáticamente.
2.  Inscribirse a un curso gratuito y confirmar que desbloquea las lecciones.
3.  Completar un curso al 100% y descargar el certificado.
