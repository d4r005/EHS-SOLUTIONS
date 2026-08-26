import { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import { courseService } from '../services/courseService';
import { certificateService } from '../services/certificateService';
import axios from 'axios';

const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL || 'https://tsqlpjliqslgzookdqvg.supabase.co';
const SUPABASE_KEY = import.meta.env.VITE_SUPABASE_KEY;

export const ProfilePage = () => {
  const { user, token } = useAuth();
  const [enrollments, setEnrollments] = useState([]);
  const [certificates, setCertificates] = useState([]);
  const [loading, setLoading] = useState(true);
  const [form, setForm] = useState({ first_name: '', last_name: '', phone: '', bio: '' });
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState(null);
  const [pwForm, setPwForm] = useState({ password: '', confirm: '' });
  const [pwMessage, setPwMessage] = useState(null);

  useEffect(() => {
    if (user) {
      setForm({
        first_name: user.first_name || '',
        last_name: user.last_name || '',
        phone: user.phone || '',
        bio: user.bio || '',
      });
      fetchData();
    }
  }, [user]);

  const fetchData = async () => {
    try {
      setLoading(true);
      const [coursesData, certs] = await Promise.all([
        courseService.getMyCourses(),
        certificateService.getMyCertificates(),
      ]);
      setEnrollments(coursesData.enrollments || []);
      setCertificates(certs || []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleSaveProfile = async (e) => {
    e.preventDefault();
    setSaving(true);
    setMessage(null);
    try {
      await axios.patch(
        `${SUPABASE_URL}/rest/v1/users?id=eq.${user.id}`,
        { first_name: form.first_name, last_name: form.last_name, phone: form.phone, bio: form.bio },
        { headers: { apikey: SUPABASE_KEY, Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' } }
      );
      setMessage({ type: 'success', text: 'Perfil actualizado. Los cambios se reflejarán al volver a iniciar sesión.' });
    } catch (err) {
      setMessage({ type: 'error', text: 'No se pudo actualizar el perfil' });
    } finally {
      setSaving(false);
    }
  };

  const handleChangePassword = async (e) => {
    e.preventDefault();
    setPwMessage(null);
    if (pwForm.password.length < 6) {
      setPwMessage({ type: 'error', text: 'La contraseña debe tener al menos 6 caracteres' });
      return;
    }
    if (pwForm.password !== pwForm.confirm) {
      setPwMessage({ type: 'error', text: 'Las contraseñas no coinciden' });
      return;
    }
    try {
      await axios.put(
        `${SUPABASE_URL}/auth/v1/user`,
        { password: pwForm.password },
        { headers: { apikey: SUPABASE_KEY, Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' } }
      );
      setPwMessage({ type: 'success', text: 'Contraseña actualizada correctamente' });
      setPwForm({ password: '', confirm: '' });
    } catch (err) {
      setPwMessage({ type: 'error', text: err.response?.data?.msg || 'No se pudo cambiar la contraseña' });
    }
  };

  const handleDownloadCertificate = async (cert) => {
    certificateService.downloadCertificatePDF(
      cert,
      `${user.first_name} ${user.last_name}`,
      cert.course?.title || 'Curso',
      cert.course?.duration_hours
    );
  };

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-5xl mx-auto px-4 space-y-8">
        <h1 className="text-3xl font-bold text-navy">Mi Perfil</h1>

        {/* Datos personales */}
        <div className="bg-white rounded-xl shadow-md p-6">
          <h2 className="text-xl font-bold text-navy mb-4">Datos personales</h2>
          <form onSubmit={handleSaveProfile} className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-semibold text-navy mb-1">Nombre</label>
              <input value={form.first_name} onChange={(e) => setForm({ ...form, first_name: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600" />
            </div>
            <div>
              <label className="block text-sm font-semibold text-navy mb-1">Apellido</label>
              <input value={form.last_name} onChange={(e) => setForm({ ...form, last_name: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600" />
            </div>
            <div>
              <label className="block text-sm font-semibold text-navy mb-1">Teléfono</label>
              <input value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600" />
            </div>
            <div>
              <label className="block text-sm font-semibold text-navy mb-1">Email</label>
              <input value={user?.email} disabled className="w-full px-4 py-2 border border-gray-200 rounded-lg bg-gray-100 text-gray-500" />
            </div>
            <div className="md:col-span-2">
              <label className="block text-sm font-semibold text-navy mb-1">Bio</label>
              <textarea value={form.bio} onChange={(e) => setForm({ ...form, bio: e.target.value })} rows={3}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600" />
            </div>
            {message && (
              <div className={`md:col-span-2 px-4 py-2 rounded-lg text-sm ${message.type === 'success' ? 'bg-green-50 text-green-700 border border-green-200' : 'bg-red-50 text-red-700 border border-red-200'}`}>
                {message.text}
              </div>
            )}
            <div className="md:col-span-2">
              <button type="submit" disabled={saving} className="px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 font-semibold transition disabled:opacity-50">
                {saving ? 'Guardando...' : 'Guardar cambios'}
              </button>
            </div>
          </form>
        </div>

        {/* Cambiar contraseña */}
        <div className="bg-white rounded-xl shadow-md p-6">
          <h2 className="text-xl font-bold text-navy mb-4">Cambiar contraseña</h2>
          <form onSubmit={handleChangePassword} className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <input type="password" placeholder="Nueva contraseña" value={pwForm.password}
              onChange={(e) => setPwForm({ ...pwForm, password: e.target.value })}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600" />
            <input type="password" placeholder="Confirmar contraseña" value={pwForm.confirm}
              onChange={(e) => setPwForm({ ...pwForm, confirm: e.target.value })}
              className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600" />
            {pwMessage && (
              <div className={`md:col-span-2 px-4 py-2 rounded-lg text-sm ${pwMessage.type === 'success' ? 'bg-green-50 text-green-700 border border-green-200' : 'bg-red-50 text-red-700 border border-red-200'}`}>
                {pwMessage.text}
              </div>
            )}
            <div className="md:col-span-2">
              <button type="submit" className="px-6 py-2 bg-navy text-white rounded-lg hover:bg-navy-light font-semibold transition">
                Actualizar contraseña
              </button>
            </div>
          </form>
        </div>

        {/* Historial de cursos */}
        <div className="bg-white rounded-xl shadow-md p-6">
          <h2 className="text-xl font-bold text-navy mb-4">Historial de cursos</h2>
          {loading ? (
            <p className="text-gray-500">Cargando...</p>
          ) : enrollments.length ? (
            <div className="divide-y divide-gray-100">
              {enrollments.map((e) => (
                <div key={e.id} className="py-3 flex items-center justify-between">
                  <div>
                    <p className="font-semibold text-navy">{e.title}</p>
                    <p className="text-sm text-gray-500">{e.status} · {Math.round(e.progress_percentage)}%</p>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-gray-500">Todavía no te has inscrito a ningún curso</p>
          )}
        </div>

        {/* Certificados */}
        <div className="bg-white rounded-xl shadow-md p-6">
          <h2 className="text-xl font-bold text-navy mb-4">Mis certificados</h2>
          {certificates.length ? (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {certificates.map((cert) => (
                <div key={cert.id} className="border border-gray-200 rounded-lg p-4 flex items-center justify-between">
                  <div>
                    <p className="font-semibold text-navy">{cert.course?.title}</p>
                    <p className="text-xs text-gray-500">Folio: {cert.certificate_number}</p>
                  </div>
                  <button onClick={() => handleDownloadCertificate(cert)} className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 text-sm font-semibold transition">
                    Descargar PDF
                  </button>
                </div>
              ))}
            </div>
          ) : (
            <p className="text-gray-500">Aún no tienes certificados. Completa un curso al 100% para obtener el tuyo.</p>
          )}
        </div>
      </div>
    </div>
  );
};
