import { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import { courseService } from '../services/courseService';
import { certificateService } from '../services/certificateService';
import { dc3Service } from '../services/dc3Service';
import { constanciaService } from '../services/constanciaService';
import { rest, authApi, SUPABASE_URL, SUPABASE_KEY } from '../services/api';
import { OCUPACIONES_STPS } from '../data/ocupaciones';

export const ProfilePage = () => {
  const { user } = useAuth();
  const [enrollments, setEnrollments] = useState([]);
  const [certificates, setCertificates] = useState([]);
  const [loading, setLoading] = useState(true);
  const [form, setForm] = useState({
    nombres: '',
    apellido_paterno: '',
    apellido_materno: '',
    phone: '',
    bio: '',
    curp: '',
    ocupacion: '',
    puesto: '',
    company_name: '',
    company_rfc: ''
  });
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState(null);
  const [pwForm, setPwForm] = useState({ password: '', confirm: '' });
  const [pwMessage, setPwMessage] = useState(null);

  useEffect(() => {
    if (user) {
      setForm((f) => ({
        ...f,
        nombres: user.nombres || user.first_name || '',
        apellido_paterno: user.apellido_paterno || '',
        apellido_materno: user.apellido_materno || '',
        phone: user.phone || '',
        bio: user.bio || '',
      }));
      fetchData();
      fetchExtraProfile();
    }
  }, [user]);

  const fetchExtraProfile = async () => {
    try {
      const { data } = await rest.get(
        `/users?id=eq.${user.id}&select=curp,ocupacion,puesto,company_name,company_rfc,nombres,apellido_paterno,apellido_materno`
      );
      if (data?.[0]) {
        setForm((f) => ({
          ...f,
          nombres: data[0].nombres || f.nombres,
          apellido_paterno: data[0].apellido_paterno || f.apellido_paterno,
          apellido_materno: data[0].apellido_materno || '',
          curp: data[0].curp || '',
          ocupacion: data[0].ocupacion || '',
          puesto: data[0].puesto || '',
          company_name: data[0].company_name || '',
          company_rfc: data[0].company_rfc || '',
        }));
      }
    } catch (err) {
      console.error('Error al cargar datos adicionales:', err);
    }
  };

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
      await rest.patch(
        `/users?id=eq.${user.id}`,
        {
          first_name: form.nombres,
          last_name: `${form.apellido_paterno} ${form.apellido_materno}`.trim(),
          nombres: form.nombres,
          apellido_paterno: form.apellido_paterno,
          apellido_materno: form.apellido_materno,
          phone: form.phone,
          bio: form.bio,
          curp: form.curp,
          ocupacion: form.ocupacion,
          puesto: form.puesto,
          company_name: form.company_name,
          company_rfc: form.company_rfc
        }
      );
      setMessage({ type: 'success', text: 'Perfil actualizado. Los cambios se reflejarán completamente al volver a iniciar sesión.' });
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
      await authApi.put('/user', { password: pwForm.password });
      setPwMessage({ type: 'success', text: 'Contraseña actualizada correctamente' });
      setPwForm({ password: '', confirm: '' });
    } catch (err) {
      setPwMessage({ type: 'error', text: err.response?.data?.msg || 'No se pudo cambiar la contraseña' });
    }
  };

  const handleDownloadConstancia = async (cert) => {
    const enrollment = enrollments.find((e) => e.course_id === cert.course_id);
    const nombreCompleto = `${form.nombres} ${form.apellido_paterno} ${form.apellido_materno}`.replace(/\s+/g, ' ').trim();
    try {
      await constanciaService.generateAndDownload({
        nombreAlumno: nombreCompleto,
        nombreCurso: cert.course?.title || 'Curso',
        duracionHoras: cert.course?.duration_hours,
        fechaInicio: enrollment?.enrollment_date,
        fechaFin: cert.issued_date,
        folio: cert.certificate_number,
      });
    } catch (err) {
      console.error('Error al generar Constancia:', err);
      certificateService.downloadCertificatePDF(
        cert,
        nombreCompleto,
        cert.course?.title || 'Curso',
        cert.course?.duration_hours
      );
    }
  };

  const handleDownloadDC3 = async (cert) => {
    const enrollment = enrollments.find((e) => e.course_id === cert.course_id);
    const nombreSTPS = `${form.apellido_paterno} ${form.apellido_materno} ${form.nombres}`.replace(/\s+/g, ' ').trim().toUpperCase();
    try {
      await dc3Service.generateAndDownload({
        nombreTrabajador: nombreSTPS,
        curp: form.curp,
        ocupacion: form.ocupacion,
        puesto: form.puesto,
        empresa: form.company_name,
        rfc: form.company_rfc,
        nombreCurso: cert.course?.title || 'Curso',
        duracionHoras: cert.course?.duration_hours,
        fechaInicio: enrollment?.enrollment_date,
        fechaFin: cert.issued_date,
        categoria: cert.course?.category,
        folio: cert.certificate_number,
      });
    } catch (err) {
      console.error('Error al generar DC-3:', err);
      alert('No se pudo generar el DC-3. Verifica que tu CURP y Ocupación estén completos en tu perfil.');
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-5xl mx-auto px-4 space-y-8">
        <h1 className="text-3xl font-bold text-navy">Mi Perfil</h1>

        {/* Datos personales */}
        <div className="bg-white rounded-xl shadow-md p-6">
          <h2 className="text-xl font-bold text-navy mb-4">Datos personales</h2>
          <form onSubmit={handleSaveProfile} className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-semibold text-navy mb-1">Nombre(s)</label>
              <input value={form.nombres} onChange={(e) => setForm({ ...form, nombres: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600" />
            </div>
            <div>
              <label className="block text-sm font-semibold text-navy mb-1">Apellido Paterno</label>
              <input value={form.apellido_paterno} onChange={(e) => setForm({ ...form, apellido_paterno: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600" />
            </div>
            <div>
              <label className="block text-sm font-semibold text-navy mb-1">Apellido Materno</label>
              <input value={form.apellido_materno} onChange={(e) => setForm({ ...form, apellido_materno: e.target.value })}
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
            <div className="md:col-span-1">
              {/* Espacio vacío para alineación si es necesario o bio */}
            </div>
            <div className="md:col-span-3">
              <label className="block text-sm font-semibold text-navy mb-1">Bio</label>
              <textarea value={form.bio} onChange={(e) => setForm({ ...form, bio: e.target.value })} rows={3}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600" />
            </div>

            <div className="md:col-span-3 pt-2 mt-2 border-t border-gray-100">
              <p className="text-sm text-gray-500 mb-3">Datos para tu constancia DC-3 (opcional, pero recomendado para tramitarla ante la STPS)</p>
            </div>
            <div>
              <label className="block text-sm font-semibold text-navy mb-1">CURP</label>
              <input value={form.curp} maxLength={18} onChange={(e) => setForm({ ...form, curp: e.target.value.toUpperCase() })}
                placeholder="18 caracteres" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600" />
            </div>
            <div>
              <label className="block text-sm font-semibold text-navy mb-1">Ocupación específica</label>
              <select value={form.ocupacion} onChange={(e) => setForm({ ...form, ocupacion: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600 bg-white">
                <option value="">Selecciona una ocupación...</option>
                {OCUPACIONES_STPS.map((occ) => (
                  <option key={occ} value={occ}>{occ}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="block text-sm font-semibold text-navy mb-1">Puesto</label>
              <input value={form.puesto} onChange={(e) => setForm({ ...form, puesto: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600" />
            </div>
            <div>
              <label className="block text-sm font-semibold text-navy mb-1">Empresa (razón social)</label>
              <input value={form.company_name} onChange={(e) => setForm({ ...form, company_name: e.target.value })}
                placeholder="Deja en blanco si eres independiente" className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600" />
            </div>
            <div>
              <label className="block text-sm font-semibold text-navy mb-1">RFC de la empresa</label>
              <input value={form.company_rfc} maxLength={13} onChange={(e) => setForm({ ...form, company_rfc: e.target.value.toUpperCase() })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600" />
            </div>

            {message && (
              <div className={`md:col-span-3 px-4 py-2 rounded-lg text-sm ${message.type === 'success' ? 'bg-green-50 text-green-700 border border-green-200' : 'bg-red-50 text-red-700 border border-red-200'}`}>
                {message.text}
              </div>
            )}
            <div className="md:col-span-3">
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
                  <div className="flex gap-2">
                    <button onClick={() => handleDownloadConstancia(cert)} className="px-3 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 text-sm font-semibold transition">
                      Constancia
                    </button>
                    <button onClick={() => handleDownloadDC3(cert)} className="px-3 py-2 border-2 border-navy text-navy rounded-lg hover:bg-navy hover:text-white text-sm font-semibold transition">
                      DC-3
                    </button>
                  </div>
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
