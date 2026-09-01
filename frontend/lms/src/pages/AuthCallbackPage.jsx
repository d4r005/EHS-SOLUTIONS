import { useEffect, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

// Página a la que Supabase redirige tras confirmar el correo (ver
// AuthContext.register -> redirect_to). Supabase entrega los tokens de
// sesión en el fragmento (#) de la URL: #access_token=...&type=signup
export const AuthCallbackPage = () => {
  const { confirmSession } = useAuth();
  const navigate = useNavigate();
  const [status, setStatus] = useState('loading'); // loading | success | error
  const ran = useRef(false);

  useEffect(() => {
    if (ran.current) return;
    ran.current = true;

    const hash = window.location.hash?.startsWith('#')
      ? window.location.hash.substring(1)
      : window.location.hash;
    const params = new URLSearchParams(hash || window.location.search);

    const accessToken = params.get('access_token');
    const refreshToken = params.get('refresh_token');
    const type = params.get('type');
    const errorDescription = params.get('error_description');

    if (errorDescription) {
      setStatus('error');
      return;
    }

    if (accessToken && (type === 'signup' || type === 'invite' || !type)) {
      confirmSession(accessToken, refreshToken);
      setStatus('success');
      const timer = setTimeout(() => {
        navigate('/dashboard', { replace: true, state: { justConfirmed: true } });
      }, 1800);
      return () => clearTimeout(timer);
    }

    setStatus('error');
  }, []);

  return (
    <div className="min-h-screen bg-gradient-to-br from-navy to-navy-deep flex items-center justify-center px-4 py-8">
      <div className="w-full max-w-md bg-white rounded-2xl shadow-2xl p-8 text-center">
        {status === 'loading' && (
          <>
            <div className="animate-spin text-4xl mb-4">⏳</div>
            <h1 className="text-xl font-bold text-navy">Confirmando tu cuenta...</h1>
          </>
        )}

        {status === 'success' && (
          <div className="space-y-3">
            <div className="text-5xl">🎉</div>
            <h1 className="text-2xl font-bold text-green-700">¡Tu cuenta ya está activa!</h1>
            <p className="text-gray-600 text-sm">Correo confirmado con éxito. Te llevamos a tu Dashboard...</p>
          </div>
        )}

        {status === 'error' && (
          <div className="space-y-3">
            <div className="text-5xl">⚠️</div>
            <h1 className="text-xl font-bold text-red-700">No pudimos confirmar tu cuenta</h1>
            <p className="text-gray-600 text-sm">
              El enlace pudo haber expirado o ya fue usado. Intenta iniciar sesión o solicita un nuevo correo de confirmación.
            </p>
            <a href="/app/login" className="inline-block mt-2 px-6 py-2.5 bg-green-600 text-white font-bold rounded-lg hover:bg-green-700 transition">
              Ir a Iniciar Sesión
            </a>
          </div>
        )}
      </div>
    </div>
  );
};
