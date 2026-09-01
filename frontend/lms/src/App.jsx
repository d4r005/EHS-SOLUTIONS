import { BrowserRouter as Router, Routes, Route, Navigate, useNavigate } from 'react-router-dom';
import { useEffect } from 'react';
import { AuthProvider, useAuth } from './context/AuthContext';
import { ProtectedRoute } from './context/ProtectedRoute';
import { Navbar } from './components/Navbar';

// Pages
import { HomePage } from './pages/HomePage';
import { LoginPage } from './pages/LoginPage';
import { RegisterPage } from './pages/RegisterPage';
import { ForgotPasswordPage } from './pages/ForgotPasswordPage';
import { ResetPasswordPage } from './pages/ResetPasswordPage';
import { DashboardPage } from './pages/DashboardPage';
import { CoursesPage } from './pages/CoursesPage';
import { CourseDetailPage } from './pages/CourseDetailPage';
import { LessonViewerPage } from './pages/LessonViewerPage';
import { QuizPage } from './pages/QuizPage';
import { ProfilePage } from './pages/ProfilePage';
import { InstructorDashboard } from './pages/instructor/InstructorDashboard';
import { CourseEditorPage } from './pages/instructor/CourseEditorPage';
import { AdminDashboard } from './pages/admin/AdminDashboard';
import { VerifyPage } from './pages/VerifyPage';
import { AuthCallbackPage } from './pages/AuthCallbackPage';

const PublicRoute = ({ children }) => {
  const { isAuthenticated } = useAuth();
  if (isAuthenticated) {
    return <Navigate to="/dashboard" replace />;
  }
  return children;
};

function AppContent() {
  const { loading } = useAuth();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center">
          <div className="animate-spin text-5xl mb-4">⏳</div>
          <p className="text-gray-600 font-semibold">Cargando perfil...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />
      <Routes>
        {/* Public Routes */}
        <Route path="/" element={<HomePage />} />
        <Route path="/courses" element={<CoursesPage />} />
        <Route path="/courses/:id" element={<CourseDetailPage />} />
        <Route path="/verify" element={<VerifyPage />} />
        <Route path="/auth/callback" element={<AuthCallbackPage />} />

        {/* Auth Routes */}
        <Route
          path="/login"
          element={
            <PublicRoute>
              <LoginPage />
            </PublicRoute>
          }
        />
        <Route
          path="/register"
          element={
            <PublicRoute>
              <RegisterPage />
            </PublicRoute>
          }
        />
        <Route path="/forgot-password" element={<ForgotPasswordPage />} />
        <Route path="/reset-password" element={<ResetPasswordPage />} />

        {/* Protected Routes - cualquier usuario autenticado */}
        <Route
          path="/dashboard"
          element={
            <ProtectedRoute>
              <DashboardPage />
            </ProtectedRoute>
          }
        />
        <Route
          path="/profile"
          element={
            <ProtectedRoute>
              <ProfilePage />
            </ProtectedRoute>
          }
        />
        <Route
          path="/courses/:id/lessons/:lessonId"
          element={
            <ProtectedRoute>
              <LessonViewerPage />
            </ProtectedRoute>
          }
        />
        <Route
          path="/courses/:id/quiz/:quizId"
          element={
            <ProtectedRoute>
              <QuizPage />
            </ProtectedRoute>
          }
        />

        {/* Instructor / Admin */}
        <Route
          path="/instructor"
          element={
            <ProtectedRoute allowedRoles={['instructor', 'admin']}>
              <InstructorDashboard />
            </ProtectedRoute>
          }
        />
        <Route
          path="/instructor/courses/:id"
          element={
            <ProtectedRoute allowedRoles={['instructor', 'admin']}>
              <CourseEditorPage />
            </ProtectedRoute>
          }
        />

        {/* Admin */}
        <Route
          path="/admin"
          element={
            <ProtectedRoute allowedRoles={['admin']}>
              <AdminDashboard />
            </ProtectedRoute>
          }
        />

        {/* 404 */}
        <Route path="*" element={<NotFound />} />
      </Routes>
    </div>
  );
}

function App() {
  return (
    <Router basename="/app">
      <AuthProvider>
        <AppContent />
      </AuthProvider>
    </Router>
  );
}

const NotFound = () => {
  // Auto-redirige al home. Esto también repara a usuarios cuyo navegador
  // guardó en caché un redirect 308 viejo de Cloudflare (ej. /app/200),
  // de cuando el _redirects anterior convertía /app/login en ese path.
  const navigate = useNavigate();
  useEffect(() => {
    const timer = setTimeout(() => navigate('/', { replace: true }), 1200);
    return () => clearTimeout(timer);
  }, [navigate]);

  return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="text-center">
        <h1 className="text-4xl font-bold text-navy mb-4">404</h1>
        <p className="text-gray-600">Página no encontrada. Redirigiendo al inicio...</p>
      </div>
    </div>
  );
};

export default App;
