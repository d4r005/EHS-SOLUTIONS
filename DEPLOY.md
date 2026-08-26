# EHS Solutions - Guía de Deploy

## Arquitectura
- **Marketing** (`/`): sitio estático (`index.html`) — landing actual, sin cambios de contenido.
- **Plataforma LMS** (`/app`): React + Vite, con login/registro/dashboard/cursos.
- **Backend**: Supabase REST API (PostgREST) + Supabase Auth — directo desde el navegador, sin servidor propio.
- **Base de Datos**: Supabase PostgreSQL.

Un solo build combina ambos: `build.sh` copia el marketing a `dist/` y compila el LMS dentro de `dist/app/`.

---

## Configuración en Cloudflare Pages

En **Settings → Builds & deployments** de tu proyecto (`ehs-solutions`):

| Campo | Valor |
|---|---|
| **Framework preset** | None |
| **Build command** | `bash build.sh` |
| **Build output directory** | `dist` |
| **Root directory** | `/` (raíz del repo) |

### Variables de entorno (Settings → Environment variables)
- `VITE_SUPABASE_URL` = `https://tsqlpjliqslgzookdqvg.supabase.co`
- `VITE_SUPABASE_KEY` = tu anon key de Supabase (Dashboard → Settings → API → Project API keys → anon public)

> Si ya tienes `VITE_SUPABASE_KEY` guardada como Secret, perfecto — solo asegúrate de que también exista `VITE_SUPABASE_URL` (puede ser variable de texto normal, no necesita ser secreta).

Después de cambiar el build command / output directory, dispara un **Retry deployment** (o haz push a `main`) para que tome la nueva configuración.

---

## Resultado esperado

- `https://tu-sitio.pages.dev/` → landing de marketing (sin cambios)
- `https://tu-sitio.pages.dev/app/login` → login de la plataforma LMS
- `https://tu-sitio.pages.dev/app/register` → registro
- `https://tu-sitio.pages.dev/app/dashboard` → dashboard del alumno (requiere sesión)

El botón **"Iniciar Sesión"** ya está agregado en el menú de la landing y apunta a `/app/login`.

---

## Usuarios de Prueba

| Email | Contraseña | Rol |
|-------|------------|-----|
| instructor@ehs-solutions.com | Password123! | instructor |
| admin@ehs-solutions.com | Password123! | admin |
| estudiante@ehs-solutions.com | Password123! | student |

---

## Estructura

```
EHS-SOLUTIONS/
├── index.html              ← Marketing (deploy a dist/)
├── logo.png
├── build.sh                 ← Build combinado (marketing + LMS)
├── _redirects                ← Reglas de rutas SPA para /app
├── frontend/lms/            ← Plataforma LMS (compilado a dist/app)
│   ├── src/
│   │   ├── context/AuthContext.jsx    ← Supabase Auth
│   │   ├── services/courseService.js  ← Supabase REST API
│   │   └── pages/
│   ├── vite.config.js       ← base: '/app/'
│   └── package.json
├── database/schema_with_seed.sql
└── DEPLOY.md
```
