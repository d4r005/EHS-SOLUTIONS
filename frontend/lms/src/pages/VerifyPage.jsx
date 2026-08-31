import { useState, useEffect } from 'react';
import { useSearchParams, Link } from 'react-router-dom';
import { verifyService } from '../services/verifyService';

export const VerifyPage = () => {
  const [searchParams] = useSearchParams();
  const folioFromUrl = searchParams.get('f');
  const [folio, setFolio] = useState(folioFromUrl || '');
  const [cert, setCert] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (folioFromUrl) {
      handleVerify(folioFromUrl);
    }
  }, [folioFromUrl]);

  const handleVerify = async (folioToVerify) => {
    if (!folioToVerify) return;
    try {
      setLoading(true);
      setError(null);
      setCert(null);
      const data = await verifyService.getCertificateByFolio(folioToVerify);
      if (data) {
        setCert(data);
      } else {
        setError('El folio ingresado no es válido o no existe en nuestros registros.');
      }
    } catch (err) {
      console.error(err);
      setError('Ocurrió un error al verificar el certificado.');
    } finally {
      setLoading(false);
    }
  };

  const onManualSubmit = (e) => {
    e.preventDefault();
    if (folio.trim()) {
      handleVerify(folio.trim());
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center">
          <div className="animate-spin text-4xl mb-4 text-navy">⌛</div>
          <p className="text-gray-600 font-semibold">Verificando autenticidad...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-100 py-12 px-4">
      <div className="max-w-md mx-auto bg-white rounded-2xl shadow-xl overflow-hidden border border-gray-200">
        <div className="bg-navy p-6 text-center text-white">
          <div className="text-3xl mb-2">🛡️</div>
          <h1 className="text-xl font-bold">Validación de Certificado</h1>
          <p className="text-blue-100 text-sm opacity-80">EHS Solutions - Registro STPS</p>
        </div>

        <div className="p-8">
          {!cert && (
            <form onSubmit={onManualSubmit} className="mb-8 space-y-4">
              <div>
                <label className="block text-sm font-bold text-gray-700 mb-2">Ingresar Folio Manualmente</label>
                <input
                  type="text"
                  value={folio}
                  onChange={(e) => setFolio(e.target.value)}
                  placeholder="Ej. EHS-DC3-2026-0001"
                  className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-navy focus:border-transparent outline-none transition"
                />
              </div>
              <button
                type="submit"
                disabled={!folio.trim()}
                className="w-full bg-green text-white font-bold py-3 rounded-xl hover:bg-green-hover transition shadow-lg disabled:opacity-50"
              >
                Validar Documento
              </button>
            </form>
          )}

          {error && (
            <div className="text-center space-y-4 p-4 bg-red-50 rounded-xl border border-red-100">
              <div className="text-red-500 text-4xl">⚠️</div>
              <h2 className="text-lg font-bold text-gray-800">No se pudo validar</h2>
              <p className="text-gray-600 text-xs leading-relaxed">{error}</p>
            </div>
          )}

          {cert && (
            <div className="space-y-6">
              <div className="text-center pb-4 border-b border-gray-100">
                <div className="text-green-600 text-5xl mb-2">✅</div>
                <h2 className="text-2xl font-bold text-navy">¡Documento Válido!</h2>
                <p className="text-xs text-gray-500 font-mono mt-1">Folio: {cert.certificate_number}</p>
              </div>

              <div className="space-y-4">
                <div>
                  <label className="block text-xs font-bold text-gray-400 uppercase tracking-wider">Estudiante</label>
                  <p className="text-lg font-semibold text-gray-800">
                    {cert.student?.first_name} {cert.student?.last_name}
                  </p>
                </div>

                <div>
                  <label className="block text-xs font-bold text-gray-400 uppercase tracking-wider">Curso</label>
                  <p className="text-md text-gray-700 leading-tight">
                    {cert.course?.title}
                  </p>
                  <p className="text-xs text-gray-500 mt-1 italic">
                    Duración: {cert.course?.duration_hours} horas
                  </p>
                </div>

                <div>
                  <label className="block text-xs font-bold text-gray-400 uppercase tracking-wider">Fecha de Emisión</label>
                  <p className="text-md text-gray-700">
                    {new Date(cert.issued_date).toLocaleDateString('es-MX', {
                      year: 'numeric', month: 'long', day: 'numeric'
                    })}
                  </p>
                </div>

                <div className="bg-green-50 border border-green-200 rounded-lg p-3">
                  <p className="text-green-800 text-xs text-center leading-relaxed">
                    Esta constancia es auténtica y forma parte de los registros oficiales de capacitación de <strong>EHS Solutions</strong>.
                  </p>
                </div>
              </div>

              <div className="pt-6 text-center">
                <Link to="/" className="inline-block px-6 py-2 border-2 border-navy text-navy font-bold rounded-lg hover:bg-navy hover:text-white transition">
                  Cerrar
                </Link>
              </div>
            </div>
          )}
        </div>
      </div>

      <p className="text-center text-gray-400 text-xs mt-8">
        &copy; {new Date().getFullYear()} EHS Solutions. Todos los derechos reservados.
      </p>
    </div>
  );
};
