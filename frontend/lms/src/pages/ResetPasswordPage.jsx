import { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import axios from 'axios';

const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL || 'https://tsqlpjliqslgzookdqvg.supabase.co';
const SUPABASE_KEY = import.meta.env.VITE_SUPABASE_KEY;

// Supabase redirige con el token en el hash: #access_token=...&type=recovery
function getAccessTokenFromHash() {
  const hash = window.location.hash.replace('#', '');
  const params = new URLSearchParams(hash);
  return params.get('access_token');
}

export const ResetPasswordPage = () => {
  const navigate = useNavigate();
  const [accessToken, setAccessToken] = useState(null);
  const [password, setPassword] = useState('');
  const [confirm, setConfirm] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(false);

  useEffect(() => {
    const token = getAccessTokenFromHash();
    if (token) setAccessToken(token);
    else setError('Enlace inválido o expirado. Solicita uno nuevo.');
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError(null);
    if (password.length < 6) {
      setError('La contraseña debe tener al menos 6 caracteres');
      return;
    }
    if (password !== confirm) {
      setError('Las contraseñas no coinciden');
      return;
    }
    try {
      setLoading(true);
      await axios.put(
        `${SUPABASE_URL}/auth/v1/user`,
        { password },
        { headers: { apikey: SUPABASE_KEY, Authorization: `Bearer ${accessToken}`, 'Content-Type': 'application/json' } }
      );
      setSuccess(true);
      setTimeout(() => navigate('/login'), 2500);
    } catch (err) {
      setError('No se pudo actualizar la contraseña. El enlace puede haber expirado.');
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
            <h1 className="text-2xl font-bold text-navy mb-2">Nueva contraseña</h1>
          </div>

          {success ? (
            <div className="bg-green-50 border border-green-200 text-green-700 px-4 py-4 rounded-lg text-sm text-center">
              Contraseña actualizada correctamente. Redirigiendo al inicio de sesión...
            </div>
          ) : (
            <form onSubmit={handleSubmit} className="space-y-5">
              <div>
                <label className="block text-sm font-semibold text-navy mb-2">Nueva contraseña</label>
                <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} required
                  disabled={!accessToken}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600 focus:ring-2 focus:ring-green-100 transition" />
              </div>
              <div>
                <label className="block text-sm font-semibold text-navy mb-2">Confirmar contraseña</label>
                <input type="password" value={confirm} onChange={(e) => setConfirm(e.target.value)} required
                  disabled={!accessToken}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600 focus:ring-2 focus:ring-green-100 transition" />
              </div>
              {error && <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm">{error}</div>}
              <button type="submit" disabled={loading || !accessToken}
                className="w-full py-3 bg-green-600 text-white font-bold rounded-lg hover:bg-green-700 disabled:opacity-50 transition">
                {loading ? 'Actualizando...' : 'Actualizar contraseña'}
              </button>
              <p className="text-center text-gray-600">
                <Link to="/forgot-password" className="text-green-600 font-bold hover:text-green-700">Solicitar nuevo enlace</Link>
              </p>
            </form>
          )}
        </div>
      </div>
    </div>
  );
};
