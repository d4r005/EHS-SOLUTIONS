import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export const HomePage = () => {
  const { isAuthenticated, user } = useAuth();

  return (
    <div className="min-h-screen bg-white">
      {/* Hero */}
      <div className="bg-gradient-to-br from-navy to-navy-deep text-white py-20 px-4">
        <div className="max-w-4xl mx-auto text-center">
          <div className="w-20 h-20 bg-green-600 rounded-2xl flex items-center justify-center mx-auto mb-6">
            <span className="text-4xl font-bold">EHS</span>
          </div>
          <h1 className="text-5xl font-bold mb-4">EHS Solutions</h1>
          <p className="text-xl text-gray-300 mb-8">
            Plataforma de Capacitación en Seguridad, Salud y Medio Ambiente
          </p>

          <div className="flex gap-4 justify-center flex-wrap">
            {isAuthenticated ? (
              <>
                <Link
                  to="/dashboard"
                  className="px-8 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 transition font-bold"
                >
                  Ver Dashboard
                </Link>
                <Link
                  to="/courses"
                  className="px-8 py-3 bg-white text-navy rounded-lg hover:bg-gray-100 transition font-bold"
                >
                  Explorar Cursos
                </Link>
              </>
            ) : (
              <>
                <Link
                  to="/login"
                  className="px-8 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 transition font-bold"
                >
                  Iniciar Sesión
                </Link>
                <Link
                  to="/register"
                  className="px-8 py-3 bg-white text-navy rounded-lg hover:bg-gray-100 transition font-bold"
                >
                  Registrarse
                </Link>
              </>
            )}
          </div>
        </div>
      </div>

      {/* Features */}
      <div className="max-w-6xl mx-auto py-16 px-4">
        <h2 className="text-3xl font-bold text-center text-navy mb-12">
          ¿Por qué EHS Solutions?
        </h2>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <FeatureCard
            icon="🎓"
            title="Cursos Especializados"
            description="Capacitación profesional en Seguridad Industrial, Salud Ocupacional y Medio Ambiente"
          />
          <FeatureCard
            icon="📱"
            title="Plataforma Moderna"
            description="Acceso desde cualquier dispositivo, en cualquier momento y lugar"
          />
          <FeatureCard
            icon="🏆"
            title="Certificados"
            description="Obtén certificados validados al completar cada curso"
          />
          <FeatureCard
            icon="👥"
            title="Instructores Expertos"
            description="Aprende de profesionales con años de experiencia en EHS"
          />
          <FeatureCard
            icon="📊"
            title="Seguimiento"
            description="Monitorea tu progreso en tiempo real"
          />
          <FeatureCard
            icon="💬"
            title="Comunidad"
            description="Conecta con otros estudiantes y comparte experiencias"
          />
        </div>
      </div>

      {/* CTA */}
      <div className="bg-green-50 py-16 px-4">
        <div className="max-w-3xl mx-auto text-center">
          <h3 className="text-3xl font-bold text-navy mb-4">
            Comienza tu Capacitación Hoy
          </h3>
          <p className="text-gray-600 mb-8">
            Únete a cientos de profesionales que ya están mejorando sus habilidades en EHS
          </p>

          {!isAuthenticated && (
            <Link
              to="/register"
              className="inline-block px-8 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 transition font-bold"
            >
              Registrarse Gratis
            </Link>
          )}
        </div>
      </div>

      {/* Footer */}
      <footer className="bg-navy text-white py-8 px-4">
        <div className="max-w-6xl mx-auto text-center">
          <p className="mb-2">© 2024 EHS Solutions. Todos los derechos reservados.</p>
          <p className="text-gray-400">
            Plataforma de Capacitación en Seguridad, Salud y Medio Ambiente
          </p>
        </div>
      </footer>
    </div>
  );
};

const FeatureCard = ({ icon, title, description }) => (
  <div className="bg-white border border-gray-200 rounded-xl p-6 hover:shadow-lg transition">
    <div className="text-4xl mb-4">{icon}</div>
    <h3 className="text-xl font-bold text-navy mb-2">{title}</h3>
    <p className="text-gray-600">{description}</p>
  </div>
);
