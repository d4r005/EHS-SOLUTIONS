import { useState } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';
import { SUPABASE_URL, SUPABASE_KEY } from '../services/api';

export const ForgotPasswordPage = () => {
  const [email, setEmail] = useState('');
  const [loading, setLoading] = useState(false);
  const [sent, setSent] = useState(false);
  const [error, setError] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    try {
      const redirectTo = `${window.location.origin}/app/reset-password`;
      await axios.post(
        `${SUPABASE_URL}/auth/v1/recover`,
        { email },
        {
          headers: {
            apikey: SUPABASE_KEY,
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${SUPABASE_KEY}`
          },
          params: { redirect_to: redirectTo }
        }
      );
      setSent(true);
    } catch (err) {
      setError('No se pudo enviar el correo. Verifica el email e intenta de nuevo.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-navy to-navy-deep flex items-center justify-center px-4">
      <div className="w-full max-w-md">
        <div className="bg-white rounded-2xl shadow-2xl p-8">
          <div className="text-center mb-8">
            <div className="w-16 h-16 bg-green-600 rounded-xl flex items-center justify-center mx-auto mb-4">
              <span className="text-white text-2xl font-bold">EHS</span>
            </div>
            <h1 className="text-2xl font-bold text-navy mb-2">Recuperar contraseña</h1>
            <p className="text-gray-600">Te enviaremos un enlace para restablecerla</p>
          </div>

          {sent ? (
            <div className="text-center">
              <div className="bg-green-50 border border-green-200 text-green-700 px-4 py-4 rounded-lg text-sm mb-6">
                Si el email existe en nuestro sistema, recibirás un correo con instrucciones para restablecer tu contraseña.
              </div>
              <Link to="/login" className="text-green-600 font-bold hover:text-green-700">Volver a iniciar sesión</Link>
            </div>
          ) : (
            <form onSubmit={handleSubmit} className="space-y-5">
              <div>
                <label className="block text-sm font-semibold text-navy mb-2">Email</label>
                <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} required
                  placeholder="tu@email.com"
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600 focus:ring-2 focus:ring-green-100 transition" />
              </div>
              {error && <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm">{error}</div>}
              <button type="submit" disabled={loading}
                className="w-full py-3 bg-green-600 text-white font-bold rounded-lg hover:bg-green-700 disabled:opacity-50 transition">
                {loading ? 'Enviando...' : 'Enviar enlace de recuperación'}
              </button>
              <p className="text-center text-gray-600">
                <Link to="/login" className="text-green-600 font-bold hover:text-green-700">Volver a iniciar sesión</Link>
              </p>
            </form>
          )}
        </div>
      </div>
    </div>
  );
};
