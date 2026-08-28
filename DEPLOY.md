# EHS Solutions - Guía de Deploy

## Arquitectura
- **Marketing** (`/`): sitio estático (`index.html`) — landing actual, sin cambios de contenido.
- **Plataforma LMS** (`/app`): React + Vite, con login/registro/dashboard/cursos.
- **Backend**: Supabase REST API (PostgREST) + Supabase Auth — directo desde el navegador, sin servidor propio.
- **Funciones de servidor**: Cloudflare Pages Functions (`/functions/api/`) para pagos y emails.
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

#### Frontend (públicas, prefijo VITE_)
| Variable | Valor |
|---|---|
| `VITE_SUPABASE_URL` | `https://tsqlpjliqslgzookdqvg.supabase.co` |
| `VITE_SUPABASE_KEY` | tu anon key de Supabase (Dashboard → Settings → API → anon public) |

#### Servidor (secretas — solo las lee Cloudflare en el servidor)
| Variable | Descripción |
|---|---|
| `SUPABASE_SERVICE_ROLE_KEY` | Service Role key de Supabase (Dashboard → Settings → API → service_role). La usa el webhook para crear inscripciones automáticamente. |
| `MERCADOPAGO_ACCESS_TOKEN` | Token de acceso de MercadoPago (https://www.mercadopago.com.mx/developers/panel/app → Credenciales → Access Token) |
| `RESEND_API_KEY` | API key de Resend (https://resend.com/api-keys) |
| `RESEND_FROM_EMAIL` | Email remitente, ej: `EHS Solutions <cursos@ehs-solutions.com>` (debe ser un dominio verificado en Resend, o usa `onboarding@resend.dev` para pruebas) |

---

## Configuración en MercadoPago

1. Entra a https://www.mercadopago.com.mx/developers/panel/app
2. Crea una aplicación (si no existe)
3. Copia el **Access Token** y guárdalo como `MERCADOPAGO_ACCESS_TOKEN` en Cloudflare
4. Ve a **Notificaciones/Webhooks** de tu aplicación
   - URL: `https://tu-dominio.pages.dev/api/mercadopago-webhook`
   - Evento: `payment`
5. Para pruebas usa las credenciales de prueba (sandbox)

---

## Configuración en Resend

1. Crea cuenta en https://resend.com (gratis hasta 100 emails/día)
2. API Keys → Create API Key → copia el key
3. Domains → agrega tu dominio (o usa `onboarding@resend.dev` para pruebas)
4. Guarda `RESEND_API_KEY` y `RESEND_FROM_EMAIL` en Cloudflare

---

## Configuración en Supabase

1. Ejecuta `database/schema.sql` (si no se ha ejecutado)
2. Ejecuta `database/fix_admin_access_and_content.sql` (RLS + columna content)
3. Ejecuta `database/add_orders_table.sql` (tabla de órdenes de MercadoPago)
4. Copia la **anon key** y la **service_role key** de Settings → API

---

## Resultado esperado

- `https://tu-sitio.pages.dev/` → landing de marketing
- `https://tu-sitio.pages.dev/app/login` → login
- `https://tu-sitio.pages.dev/app/register` → registro
- `https://tu-sitio.pages.dev/app/dashboard` → dashboard del alumno
- `https://tu-sitio.pages.dev/app/courses` → catálogo de cursos
- `https://tu-sitio.pages.dev/app/instructor` → panel del instructor
- `https://tu-sitio.pages.dev/app/admin` → panel de administración

---

## Usuarios de Prueba

| Email | Contraseña | Rol |
|-------|------------|-----|
| instructor@ehs-solutions.com | Password123! | instructor |
| d4r005@gmail.com | Branco2025 | admin |
| estudiante@ehs-solutions.com | Password123! | student |

---

## Estructura

```
EHS-SOLUTIONS/
├── index.html              ← Marketing (deploy a dist/)
├── logo.png
├── build.sh                 ← Build combinado (marketing + LMS)
├── _redirects                ← Reglas de rutas SPA para /app
├── functions/api/            ← Cloudflare Pages Functions (servidor)
│   ├── create-checkout-session.js  ← Crea preferencia de MercadoPago
│   ├── mercadopago-webhook.js       ← Procesa pago aprobado → inscribe
│   └── send-email.js                ← Envía emails con Resend
├── frontend/lms/            ← Plataforma LMS (compilado a dist/app)
│   ├── src/
│   │   ├── context/AuthContext.jsx    ← Supabase Auth
│   │   ├── services/
│   │   │   ├── courseService.js       ← Supabase REST API
│   │   │   ├── quizService.js         ← Exámenes
│   │   │   ├── certificateService.js  ← Certificados PDF (jsPDF)
│   │   │   ├── paymentService.js      ← Checkout MercadoPago
│   │   │   ├── emailService.js        ← Notificaciones
│   │   │   └── adminService.js        ← Panel admin
│   │   └── pages/
│   │       ├── HomePage.jsx
│   │       ├── LoginPage.jsx
│   │       ├── ForgotPasswordPage.jsx
│   │       ├── ResetPasswordPage.jsx
│   │       ├── DashboardPage.jsx
│   │       ├── CoursesPage.jsx
│   │       ├── CourseDetailPage.jsx
│   │       ├── LessonViewerPage.jsx
│   │       ├── QuizPage.jsx
│   │       ├── ProfilePage.jsx
│   │       ├── instructor/
│   │       │   ├── InstructorDashboard.jsx
│   │       │   └── CourseEditorPage.jsx
│   │       └── admin/
│   │           └── AdminDashboard.jsx
│   ├── vite.config.js       ← base: '/app/'
│   └── package.json
├── database/
│   ├── schema.sql
│   ├── schema_with_seed.sql
│   ├── fix_admin_access_and_content.sql
│   ├── update_lessons_content.sql
│   └── add_orders_table.sql
└── DEPLOY.md
```

<!-- redeploy trigger 2026-08-27T16:31:47Z -->
-- forzando nuevo deploy --
