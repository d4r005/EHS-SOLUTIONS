import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { emailService } from '../services/emailService';

export const RegisterPage = () => {
  const [formData, setFormData] = useState({
    nombres: '',
    apellidoPaterno: '',
    apellidoMaterno: '',
    email: '',
    password: '',
    confirmPassword: '',
  });
  const [formError, setFormError] = useState('');
  const [registrationSuccess, setRegistrationSuccess] = useState(false);
  const [successEmail, setSuccessEmail] = useState('');
  const { register, loading } = useAuth();
  const navigate = useNavigate();

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setFormError('');
    setRegistrationSuccess(false);

    // Validaciones
    if (!formData.nombres || !formData.apellidoPaterno || !formData.email || !formData.password) {
      setFormError('Todos los campos son requeridos (excepto Apellido Materno)');
      return;
    }

    if (formData.password !== formData.confirmPassword) {
      setFormError('Las contraseñas no coinciden');
      return;
    }

    if (formData.password.length < 8) {
      setFormError('La contraseña debe tener al menos 8 caracteres');
      return;
    }

    const result = await register(
      formData.nombres,
      formData.apellidoPaterno,
      formData.apellidoMaterno,
      formData.email,
      formData.password
    );

    if (result.success) {
      emailService.sendWelcomeEmail(formData.email, formData.nombres);
      navigate('/dashboard');
    } else if (result.needsConfirmation) {
      // Cuenta creada pero requiere confirmar el correo antes de iniciar sesión
      setRegistrationSuccess(true);
      setSuccessEmail(formData.email);
    } else {
      setFormError(result.message || 'Error al registrarse');
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-navy to-navy-deep flex items-center justify-center px-4 py-8">
      <div className="w-full max-w-md">
        {/* Card */}
        <div className="bg-white rounded-2xl shadow-2xl p-8">
          {/* Header */}
          <div className="text-center mb-8">
            <div className="w-16 h-16 bg-green-600 rounded-xl flex items-center justify-center mx-auto mb-4">
              <span className="text-white text-2xl font-bold">EHS</span>
            </div>
            <h1 className="text-3xl font-bold text-navy mb-2">Crear Cuenta</h1>
            <p className="text-gray-600">Únete a EHS Solutions</p>
          </div>

          {/* Success message after registration with email confirmation */}
          {registrationSuccess && (
            <div className="bg-green-50 border border-green-300 rounded-xl p-6 mb-6 text-center space-y-4">
              <div className="text-5xl">✅</div>
              <h2 className="text-xl font-bold text-green-800">¡Cuenta creada con éxito!</h2>
              <p className="text-green-700 text-sm leading-relaxed">
                Hemos enviado un correo de confirmación a <strong>{successEmail}</strong>.
                Revisa tu bandeja de entrada (y la carpeta de spam) y haz clic en el enlace de confirmación para activar tu cuenta.
              </p>
              <p className="text-green-600 text-xs">
                Una vez confirmado, podrás iniciar sesión con tus credenciales.
              </p>
              <div className="pt-2">
                <Link
                  to="/login"
                  className="inline-block px-6 py-2.5 bg-green-600 text-white font-bold rounded-lg hover:bg-green-700 transition"
                >
                  Ir a Iniciar Sesión
                </Link>
              </div>
            </div>
          )}

          {/* Form - hidden after successful registration */}
          {!registrationSuccess && (
            <form onSubmit={handleSubmit} className="space-y-4">
              {/* Name Fields */}
              <div className="grid grid-cols-1 gap-3">
                <div>
                  <label className="block text-sm font-semibold text-navy mb-1">
                    Nombre(s)
                  </label>
                  <input
                    type="text"
                    name="nombres"
                    value={formData.nombres}
                    onChange={handleChange}
                    placeholder="Juan"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600 focus:ring-2 focus:ring-green-100 transition text-sm"
                  />
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-sm font-semibold text-navy mb-1">
                      Apellido Paterno
                    </label>
                    <input
                      type="text"
                      name="apellidoPaterno"
                      value={formData.apellidoPaterno}
                      onChange={handleChange}
                      placeholder="Pérez"
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600 focus:ring-2 focus:ring-green-100 transition text-sm"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-semibold text-navy mb-1">
                      Apellido Materno
                    </label>
                    <input
                      type="text"
                      name="apellidoMaterno"
                      value={formData.apellidoMaterno}
                      onChange={handleChange}
                      placeholder="García"
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600 focus:ring-2 focus:ring-green-100 transition text-sm"
                    />
                  </div>
                </div>
              </div>

              {/* Email */}
              <div>
                <label className="block text-sm font-semibold text-navy mb-1">
                  Email
                </label>
                <input
                  type="email"
                  name="email"
                  value={formData.email}
                  onChange={handleChange}
                  placeholder="tu@email.com"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600 focus:ring-2 focus:ring-green-100 transition text-sm"
                />
              </div>

              {/* Password */}
              <div>
                <label className="block text-sm font-semibold text-navy mb-1">
                  Contraseña
                </label>
                <input
                  type="password"
                  name="password"
                  value={formData.password}
                  onChange={handleChange}
                  placeholder="••••••••"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600 focus:ring-2 focus:ring-green-100 transition text-sm"
                />
              </div>

              {/* Confirm Password */}
              <div>
                <label className="block text-sm font-semibold text-navy mb-1">
                  Confirmar Contraseña
                </label>
                <input
                  type="password"
                  name="confirmPassword"
                  value={formData.confirmPassword}
                  onChange={handleChange}
                  placeholder="••••••••"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600 focus:ring-2 focus:ring-green-100 transition text-sm"
                />
              </div>

              {/* Errors */}
              {formError && (
                <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm">
                  {formError}
                </div>
              )}

              {/* Submit */}
              <button
                type="submit"
                disabled={loading}
                className="w-full py-3 bg-green-600 text-white font-bold rounded-lg hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed transition mt-6"
              >
                {loading ? 'Registrando...' : 'Registrarse'}
              </button>
            </form>
          )}

          {/* Login Link */}
          {!registrationSuccess && (
            <p className="text-center text-gray-600 mt-4">
              ¿Ya tienes cuenta?{' '}
              <Link to="/login" className="text-green-600 font-bold hover:text-green-700">
                Inicia sesión aquí
              </Link>
            </p>
          )}
        </div>
      </div>
    </div>
  );
};
