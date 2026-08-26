import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export const Navbar = () => {
  const { user, logout } = useAuth();

  return (
    <nav className="bg-white shadow-md sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-6 py-4 flex justify-between items-center">
        <Link to="/" className="flex items-center gap-2">
          <div className="w-10 h-10 bg-green-600 rounded-lg flex items-center justify-center">
            <span className="text-white font-bold">EHS</span>
          </div>
          <span className="font-bold text-navy">EHS Solutions</span>
        </Link>

        <div className="flex items-center gap-6">
          {user ? (
            <>
              <Link to="/dashboard" className="text-navy hover:text-green-600">
                Dashboard
              </Link>
              <Link to="/courses" className="text-navy hover:text-green-600">
                Cursos
              </Link>
              <div className="flex items-center gap-3 pl-6 border-l border-gray-200">
                <div>
                  <p className="text-sm font-semibold text-navy">{user.first_name}</p>
                  <p className="text-xs text-gray-500">{user.role}</p>
                </div>
                <button
                  onClick={logout}
                  className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition"
                >
                  Salir
                </button>
              </div>
            </>
          ) : (
            <>
              <Link
                to="/login"
                className="text-navy hover:text-green-600 font-semibold"
              >
                Iniciar Sesión
              </Link>
              <Link
                to="/register"
                className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition"
              >
                Registrarse
              </Link>
            </>
          )}
        </div>
      </div>
    </nav>
  );
};
