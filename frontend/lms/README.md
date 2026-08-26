# 🎓 Frontend - LMS Platform

## Descripción

Plataforma LMS (Learning Management System) para cursos en línea con certificación. Construida con React/Vue.js y conectada al backend Node.js.

**Estado:** ⏳ FASE 2 (Por desarrollar)

## 🎯 Características

- Dashboard personalizado por rol (estudiante/instructor/admin)
- Catálogo de cursos filtrable
- Visor interactivo de lecciones
- Seguimiento de progreso en tiempo real
- Cuestionarios y evaluaciones
- Generación de certificados
- Panel de instructor para crear cursos
- Reportes administrativos

## 📁 Estructura (Futura)

```
frontend/lms/
├── public/
│   └── index.html
├── src/
│   ├── components/
│   │   ├── Navbar.jsx
│   │   ├── Sidebar.jsx
│   │   ├── CourseCard.jsx
│   │   ├── LessonViewer.jsx
│   │   └── ...
│   ├── pages/
│   │   ├── Dashboard.jsx
│   │   ├── CourseCatalog.jsx
│   │   ├── CourseDetails.jsx
│   │   ├── Lesson.jsx
│   │   ├── Quiz.jsx
│   │   └── ...
│   ├── services/
│   │   ├── authService.js       # API auth
│   │   ├── courseService.js     # API cursos
│   │   └── ...
│   ├── context/
│   │   └── AuthContext.jsx      # Estado global de autenticación
│   ├── styles/
│   │   └── index.css            # Estilos globales
│   ├── App.jsx
│   └── main.jsx
├── package.json
├── vite.config.js               # Configuración Vite
└── README.md
```

## 🛠️ Stack Tecnológico (Propuesto)

- **Bundler:** Vite (rápido, moderno)
- **Framework:** React 18 + Hooks
- **UI:** TailwindCSS + Headless UI
- **State:** Redux o Zustand
- **HTTP:** Axios
- **Router:** React Router v6
- **Autenticación:** JWT con localStorage

## 🚀 Próxima Implementación

En FASE 2:
1. Crear proyecto Vite + React
2. Estructura de componentes
3. Sistema de enrutamiento
4. Integración con backend
5. Páginas principales (dashboard, catálogo, lecciones)

## 📋 Roadmap FASE 2

- [ ] Setup Vite + React
- [ ] Autenticación y login
- [ ] Dashboard estudiante
- [ ] Catálogo de cursos
- [ ] Visor de lecciones
- [ ] Progreso y seguimiento
- [ ] Dashboard instructor
- [ ] Diseño responsivo
- [ ] PWA (Progressive Web App)

---

**Nota:** Este folder será inicializado en FASE 2 con `npm create vite@latest lms -- --template react`
