import { Navigate } from 'react-router-dom';
import { useAuth } from './AuthContext';

// allowedRoles: array opcional. Si se pasa, solo esos roles pueden entrar.
export const ProtectedRoute = ({ children, allowedRoles }) => {
  const { isAuthenticated, user, initializing } = useAuth();

  // Si está cargando el perfil, no redirigir todavía
  if (initializing) {
    return null; // El AppContent mostrará el spinner
  }

  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  if (allowedRoles && user && !allowedRoles.includes(user.role)) {
    return <Navigate to="/dashboard" replace />;
  }

  return children;
};
