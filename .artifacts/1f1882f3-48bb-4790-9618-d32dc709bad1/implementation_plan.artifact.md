# Plan: Reparación de Registro y Asignación de Administrador

Este plan resuelve el error técnico que impide el registro de nuevos usuarios y detalla el proceso para establecer a Dario Robles como el administrador oficial de la plataforma.

## User Review Required

> [!IMPORTANT]
> El error `null value in column "password"` ocurre porque la base de datos exige una contraseña en la tabla pública, pero ahora las contraseñas las maneja Supabase de forma segura. Debemos eliminar esa restricción.

## 1. Reparación Técnica de Registro (SQL)

### [MODIFY] [public.users table]
- Eliminar la restricción `NOT NULL` de la columna `password` en la tabla `public.users`. Esto permitirá que el sistema cree tu perfil automáticamente al registrarte sin errores.

## 2. Proceso de Cambio de Administrador

### Paso 1: Registro (Tú lo realizas)
Debes intentar registrarte nuevamente en la página con los datos:
- **Email**: `d4r005@gmail.com`
- **Contraseña**: `Branco2025`
- **Nombre**: `Dario Robles`

### Paso 2: Promoción a Admin (SQL)
Una vez que el registro sea exitoso, ejecutaremos un comando SQL para darte el rol de `admin` de forma manual en la base de datos.

## 3. Actualización de Identidad de Marca

#### [MODIFY] [DEPLOY.md](file:///C:/Users/dtruj/AndroidStudioProjects/EHS-SOLUTIONS/DEPLOY.md)
- Actualizar las credenciales maestras en la documentación técnica del proyecto.

#### [MODIFY] [schema_with_seed.sql](file:///C:/Users/dtruj/AndroidStudioProjects/EHS-SOLUTIONS/database/schema_with_seed.sql)
- Actualizar el usuario semilla (seed) para futuros despliegues.

## Verificación Plan
- Al registrarte, ya no deberías ver el mensaje rojo de error.
- Al ejecutar el comando de promoción, verás las pestañas "Instructor" y "Admin" en tu menú superior.
