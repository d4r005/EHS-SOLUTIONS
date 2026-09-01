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
| `STRIPE_SECRET_KEY` | Secret key de Stripe (https://dashboard.stripe.com/apikeys → Secret key). Usa `sk_test_...` para pruebas. |
| `STRIPE_WEBHOOK_SECRET` | Signing secret del webhook de Stripe (whsec_...). Se obtiene al crear el webhook en Stripe Dashboard. |
| `RESEND_API_KEY` | API key de Resend (https://resend.com/api-keys) |
| `RESEND_FROM_EMAIL` | Email remitente, ej: `EHS Solutions <cursos@ehs-solutions.com>` (debe ser un dominio verificado en Resend, o usa `onboarding@resend.dev` para pruebas) |

---

## Configuración en Stripe

1. Entra a https://dashboard.stripe.com (usa cuenta de prueba para sandbox)
2. Copia la **Secret key** (`sk_test_...`) y guárdala como `STRIPE_SECRET_KEY` en Cloudflare
3. Ve a **Developers → Webhooks** y crea un endpoint:
   - URL: `https://tu-dominio.com/api/stripe-webhook`
   - Evento: `checkout.session.completed`
   - Copia el **Signing secret** (`whsec_...`) y guárdalo como `STRIPE_WEBHOOK_SECRET` en Cloudflare
4. Para pruebas usa tarjetas de prueba de Stripe:
   - `4242 4242 4242 4242` — Visa (pago aprobado)
   - `4000 0027 6000 3184` — Tarjeta que requiere 3DS
   - Cualquier fecha futura, CVC cualquiera, CP: 12345

---

## Configuración en Resend

1. Crea cuenta en https://resend.com (gratis hasta 100 emails/día)
2. API Keys → Create API Key → copia el key
3. Domains → agrega tu dominio (o usa `onboarding@resend.dev` para pruebas)
4. Guarda `RESEND_API_KEY` y `RESEND_FROM_EMAIL` en Cloudflare

---

## Configuración en Supabase

1. Ejecuta `database/schema.sql` (si no se ha ejecutado)
2. Ejecuta `database/fix_foundation_v2.sql` (RLS + auto-registro de usuarios)
3. Ejecuta `database/fix_admin_access_and_content.sql` (RLS + columna content)
4. Ejecuta `database/fix_rls_policies_v3.sql` (políticas completas)
5. Ejecuta `database/add_orders_table.sql` (tabla de órdenes de Stripe)
6. Ejecuta `database/add_dc3_fields.sql` (campos CURP, ocupación, empresa)
7. Copia la **anon key** y la **service_role key** de Settings → API

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
├── _routes.json              ← Cloudflare Pages Functions routing
├── functions/api/            ← Cloudflare Pages Functions (servidor)
│   ├── create-checkout-session.js  ← Crea Stripe Checkout Session
│   ├── stripe-webhook.js            ← Procesa pago aprobado → inscribe
│   └── send-email.js                ← Envía emails con Resend
├── frontend/lms/            ← Plataforma LMS (compilado a dist/app)
│   ├── src/
│   │   ├── context/AuthContext.jsx    ← Supabase Auth
│   │   ├── services/
│   │   │   ├── courseService.js       ← Supabase REST API
│   │   │   ├── quizService.js         ← Exámenes
│   │   │   ├── certificateService.js  ← Certificados PDF (jsPDF)
│   │   │   ├── dc3Service.js          ← DC-3 oficial (pdf-lib)
│   │   │   ├── paymentService.js      ← Checkout Stripe
│   │   │   ├── emailService.js        ← Notificaciones
│   │   │   └── adminService.js        ← Panel admin
│   │   └── pages/
│   │       ├── LoginPage.jsx
│   │       ├── RegisterPage.jsx
│   │       ├── VerifyPage.jsx
│   │       ├── ForgotPasswordPage.jsx
│   │       ├── ResetPasswordPage.jsx
│   │       ├── DashboardPage.jsx
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
│   ├── fix_foundation_v2.sql
│   ├── fix_rls_policies_v3.sql
│   ├── add_orders_table.sql     ← Órdenes de Stripe
│   ├── add_dc3_fields.sql       ← Campos DC-3
│   └── full_exams_70_questions.sql
└── DEPLOY.md
```
