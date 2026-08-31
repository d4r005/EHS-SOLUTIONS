import { useState, useEffect } from 'react';
import { adminService } from '../../services/adminService';
import { dc3Service } from '../../services/dc3Service';
import { constanciaService } from '../../services/constanciaService';
import { OCUPACIONES_STPS } from '../../data/ocupaciones';

export const AdminDashboard = () => {
  const [tab, setTab] = useState('reports');
  const [users, setUsers] = useState([]);
  const [courses, setCourses] = useState([]);
  const [certificates, setCertificates] = useState([]);
  const [reports, setReports] = useState(null);
  const [loading, setLoading] = useState(true);

  // Estado para gestión de inscripciones
  const [enrollments, setEnrollments] = useState([]);
  const [selectedStudent, setSelectedStudent] = useState(null);
  const [studentEnrollments, setStudentEnrollments] = useState([]);
  const [grantCourseId, setGrantCourseId] = useState('');
  const [enrollmentMsg, setEnrollmentMsg] = useState(null);

  // Estado para el Laboratorio DC-3 (pruebas)
  const [testForm, setTestForm] = useState({
    nombres: 'JESUS DARIO',
    apellidos: 'ROBLES TRUJILLO',
    curp: 'ROTJ920320HNLBRS04',
    ocupacion: '04.6 Procesos industriales',
    puesto: 'COORDINADOR EHS',
    empresa: 'SHELSER S. DE R.L. DE C.V.',
    rfc: 'CGU101126SA2',
    curso: 'Formación de Supervisores de Seguridad y Salud Ocupacional',
    horas: 8,
    categoria: 'SEGURIDAD'
  });

  useEffect(() => {
    fetchAll();
  }, []);

  const fetchAll = async () => {
    try {
      setLoading(true);
      const [u, c, r, certs, enr] = await Promise.all([
        adminService.getUsers(),
        adminService.getAllCourses(),
        adminService.getReports(),
        adminService.getAllCertificates(),
        adminService.getAllEnrollments(),
      ]);
      setUsers(u);
      setCourses(c);
      setReports(r);
      setCertificates(certs);
      setEnrollments(enr);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  // --- Handlers de inscripciones ---
  const handleSelectStudent = async (studentId) => {
    setSelectedStudent(studentId);
    setEnrollmentMsg(null);
    if (studentId) {
      try {
        const data = await adminService.getStudentEnrollments(studentId);
        setStudentEnrollments(data);
      } catch (err) {
        console.error('Error al cargar inscripciones del estudiante:', err);
        setStudentEnrollments([]);
      }
    } else {
      setStudentEnrollments([]);
    }
  };

  const handleGrantCourse = async () => {
    if (!selectedStudent || !grantCourseId) return;
    setEnrollmentMsg(null);
    try {
      await adminService.grantCourse(selectedStudent, parseInt(grantCourseId));
      const data = await adminService.getStudentEnrollments(selectedStudent);
      setStudentEnrollments(data);
      setGrantCourseId('');
      setEnrollmentMsg({ type: 'success', text: 'Curso asignado correctamente al estudiante.' });
      // Actualizar lista global
      const allEnr = await adminService.getAllEnrollments();
      setEnrollments(allEnr);
    } catch (err) {
      setEnrollmentMsg({ type: 'error', text: err.message || 'No se pudo asignar el curso.' });
    }
  };

  const handleRevokeCourse = async (enrollmentId, courseTitle) => {
    if (!window.confirm(`¿Quitar el curso "${courseTitle}" de este estudiante?`)) return;
    setEnrollmentMsg(null);
    try {
      await adminService.revokeCourse(enrollmentId);
      const data = await adminService.getStudentEnrollments(selectedStudent);
      setStudentEnrollments(data);
      setEnrollmentMsg({ type: 'success', text: 'Curso removido del estudiante.' });
      const allEnr = await adminService.getAllEnrollments();
      setEnrollments(allEnr);
    } catch (err) {
      setEnrollmentMsg({ type: 'error', text: err.message || 'No se pudo remover el curso.' });
    }
  };

  const handleDownloadDC3 = async (cert) => {
    try {
      const s = cert.student || {};
      const nombreSTPS = `${s.apellido_paterno || s.last_name || ''} ${s.apellido_materno || ''} ${s.nombres || s.first_name || ''}`.replace(/\s+/g, ' ').trim().toUpperCase();
      await dc3Service.generateAndDownload({
        nombreTrabajador: nombreSTPS,
        curp: s.curp,
        ocupacion: s.ocupacion,
        puesto: s.puesto,
        empresa: s.company_name,
        rfc: s.company_rfc,
        nombreCurso: cert.course?.title,
        duracionHoras: cert.course?.duration_hours,
        fechaInicio: cert.issued_date,
        fechaFin: cert.issued_date,
        categoria: cert.course?.category,
        folio: cert.certificate_number,
      });
    } catch (err) {
      console.error('Error al descargar DC-3:', err);
      alert('Error al generar el PDF del DC-3');
    }
  };

  const handleDownloadConstancia = async (cert) => {
    try {
      const s = cert.student || {};
      const nombreCompleto = `${s.nombres || s.first_name || ''} ${s.apellido_paterno || s.last_name || ''} ${s.apellido_materno || ''}`.replace(/\s+/g, ' ').trim();
      await constanciaService.generateAndDownload({
        nombreAlumno: nombreCompleto,
        nombreCurso: cert.course?.title,
        duracionHoras: cert.course?.duration_hours,
        fechaInicio: cert.issued_date,
        fechaFin: cert.issued_date,
        folio: cert.certificate_number,
      });
    } catch (err) {
      console.error('Error al descargar Constancia:', err);
      alert('Error al generar el PDF de la Constancia');
    }
  };

  const handleTestDC3 = async () => {
    await dc3Service.generateAndDownload({
      nombreTrabajador: `${testForm.apellidos} ${testForm.nombres}`.toUpperCase(),
      curp: testForm.curp,
      ocupacion: testForm.ocupacion,
      puesto: testForm.puesto,
      empresa: testForm.empresa,
      rfc: testForm.rfc,
      nombreCurso: testForm.curso,
      duracionHoras: testForm.horas,
      fechaInicio: new Date().toISOString(),
      fechaFin: new Date().toISOString(),
      categoria: testForm.categoria,
      folio: 'TEST-000-XYZ',
    });
  };

  const handleTestConstancia = async () => {
    await constanciaService.generateAndDownload({
      nombreAlumno: `${testForm.nombres} ${testForm.apellidos}`,
      nombreCurso: testForm.curso,
      duracionHoras: testForm.horas,
      fechaInicio: new Date().toISOString(),
      fechaFin: new Date().toISOString(),
      folio: 'TEST-000-XYZ',
    });
  };

  const handleRoleChange = async (id, role) => {
    await adminService.updateUserRole(id, role);
    setUsers(users.map((u) => (u.id === id ? { ...u, role } : u)));
  };

  const handleToggleActive = async (u) => {
    await adminService.toggleUserActive(u.id, !u.is_active);
    setUsers(users.map((x) => (x.id === u.id ? { ...x, is_active: !u.is_active } : x)));
  };

  const handleDeleteUser = async (u) => {
    if (!window.confirm(`¿BORRAR DEFINITIVAMENTE al usuario "${u.first_name || ''} ${u.last_name || ''}" (${u.email})?\n\nEsta acción no se puede deshacer y borrará todo su historial.`)) return;
    try {
      await adminService.deleteUser(u.id);
      setUsers(users.filter((x) => x.id !== u.id));
    } catch (err) {
      alert(err.message || 'No se pudo eliminar al usuario. Es posible que tenga registros vinculados (inscripciones, certificados) que impidan su borrado.');
    }
  };

  const handleTogglePublish = async (c) => {
    await adminService.togglePublish(c.id, !c.is_published);
    setCourses(courses.map((x) => (x.id === c.id ? { ...x, is_published: !c.is_published } : x)));
  };

  const handleDeleteCourse = async (c) => {
    if (!window.confirm(`¿Eliminar el curso "${c.title}"?`)) return;
    await adminService.deleteCourse(c.id);
    setCourses(courses.filter((x) => x.id !== c.id));
  };

  const tabs = [
    { id: 'reports', label: 'Reportes' },
    { id: 'users', label: 'Usuarios' },
    { id: 'enrollments', label: 'Inscripciones' },
    { id: 'courses', label: 'Cursos' },
    { id: 'certificates', label: 'Certificados' },
    { id: 'lab', label: '🧪 Laboratorio' },
  ];

  const students = users.filter((u) => u.role === 'student');
  const selectedStudentData = users.find((u) => u.id === parseInt(selectedStudent));

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-6xl mx-auto px-4">
        <h1 className="text-3xl font-bold text-navy mb-6">Panel de Administración</h1>

        <div className="flex gap-2 mb-6 border-b border-gray-200 overflow-x-auto">
          {tabs.map((t) => (
            <button
              key={t.id}
              onClick={() => setTab(t.id)}
              className={`px-5 py-3 font-semibold text-sm transition border-b-2 whitespace-nowrap ${
                tab === t.id ? 'border-green-600 text-green-600' : 'border-transparent text-gray-500 hover:text-navy'
              }`}
            >
              {t.label}
            </button>
          ))}
        </div>

        {loading ? (
          <p className="text-gray-500">Cargando...</p>
        ) : (
          <>
            {tab === 'reports' && reports && (
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                <StatBox label="Estudiantes" value={reports.totalStudents} icon="🎓" />
                <StatBox label="Instructores" value={reports.totalInstructors} icon="👩‍🏫" />
                <StatBox label="Cursos totales" value={reports.totalCourses} icon="📚" />
                <StatBox label="Cursos publicados" value={reports.publishedCourses} icon="🟢" />
                <StatBox label="Inscripciones" value={reports.totalEnrollments} icon="📝" />
                <StatBox label="Cursos completados" value={reports.completedEnrollments} icon="✅" />
                <StatBox label="Certificados emitidos" value={reports.totalCertificates} icon="🏆" />
                <StatBox label="Cursos de paga" value={reports.paidCourses} icon="💰" />
              </div>
            )}

            {tab === 'users' && (
              <div className="bg-white rounded-xl shadow-md overflow-hidden">
                <table className="w-full text-sm">
                  <thead className="bg-gray-50 text-left text-gray-500">
                    <tr>
                      <th className="px-4 py-3">Nombre</th>
                      <th className="px-4 py-3">Email</th>
                      <th className="px-4 py-3">Rol</th>
                      <th className="px-4 py-3">Estado</th>
                      <th className="px-4 py-3">Acciones</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100">
                    {users.map((u) => (
                      <tr key={u.id}>
                        <td className="px-4 py-3">
                          <div className="font-semibold text-navy">
                            {u.nombres || u.first_name} {u.apellido_paterno || u.last_name} {u.apellido_materno || ''}
                          </div>
                          <div className="text-xs text-gray-400">{u.id}</div>
                        </td>
                        <td className="px-4 py-3 text-gray-600">{u.email}</td>
                        <td className="px-4 py-3">
                          <select value={u.role} onChange={(e) => handleRoleChange(u.id, e.target.value)}
                            className="border border-gray-300 rounded-lg px-2 py-1 text-sm">
                            <option value="student">student</option>
                            <option value="instructor">instructor</option>
                            <option value="admin">admin</option>
                          </select>
                        </td>
                        <td className="px-4 py-3">
                          <span className={u.is_active ? 'text-green-600' : 'text-red-600'}>
                            {u.is_active ? 'Activo' : 'Inactivo'}
                          </span>
                        </td>
                        <td className="px-4 py-3">
                          <div className="flex gap-2">
                            <button onClick={() => handleToggleActive(u)} className="px-3 py-1 border border-gray-300 rounded-lg hover:bg-gray-50 text-xs font-semibold">
                              {u.is_active ? 'Desactivar' : 'Activar'}
                            </button>
                            <button onClick={() => handleDeleteUser(u)} className="px-3 py-1 bg-red-50 text-red-600 border border-red-200 rounded-lg hover:bg-red-100 text-xs font-semibold">
                              Eliminar
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}

            {tab === 'enrollments' && (
              <div className="space-y-6">
                {/* Selector de estudiante + otorgar curso */}
                <div className="bg-white rounded-xl shadow-md p-6">
                  <h2 className="text-xl font-bold text-navy mb-4">Gestionar cursos del estudiante</h2>
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4 items-end">
                    <div>
                      <label className="block text-xs font-bold text-gray-500 mb-1">Estudiante</label>
                      <select
                        value={selectedStudent || ''}
                        onChange={(e) => handleSelectStudent(e.target.value)}
                        className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm bg-white"
                      >
                        <option value="">Selecciona un estudiante...</option>
                        {students.map((s) => (
                          <option key={s.id} value={s.id}>{s.first_name} {s.last_name} — {s.email}</option>
                        ))}
                      </select>
                    </div>
                    <div>
                      <label className="block text-xs font-bold text-gray-500 mb-1">Curso a asignar</label>
                      <select
                        value={grantCourseId}
                        onChange={(e) => setGrantCourseId(e.target.value)}
                        disabled={!selectedStudent}
                        className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm bg-white disabled:opacity-50"
                      >
                        <option value="">Selecciona un curso...</option>
                        {courses.map((c) => (
                          <option key={c.id} value={c.id}>{c.title}</option>
                        ))}
                      </select>
                    </div>
                    <div>
                      <button
                        onClick={handleGrantCourse}
                        disabled={!selectedStudent || !grantCourseId}
                        className="w-full px-4 py-2 bg-green-600 text-white rounded-lg font-bold hover:bg-green-700 transition disabled:opacity-50 disabled:cursor-not-allowed text-sm"
                      >
                        Otorgar curso
                      </button>
                    </div>
                  </div>

                  {enrollmentMsg && (
                    <div className={`mt-4 px-4 py-2 rounded-lg text-sm ${enrollmentMsg.type === 'success' ? 'bg-green-50 text-green-700 border border-green-200' : 'bg-red-50 text-red-700 border border-red-200'}`}>
                      {enrollmentMsg.text}
                    </div>
                  )}
                </div>

                {/* Cursos actuales del estudiante seleccionado */}
                {selectedStudent && (
                  <div className="bg-white rounded-xl shadow-md p-6">
                    <h3 className="text-lg font-bold text-navy mb-4">
                      Cursos de {selectedStudentData?.first_name} {selectedStudentData?.last_name}
                    </h3>
                    {studentEnrollments.length > 0 ? (
                      <div className="space-y-3">
                        {studentEnrollments.map((enr) => (
                          <div key={enr.id} className="flex items-center justify-between border border-gray-200 rounded-lg p-4">
                            <div>
                              <p className="font-semibold text-navy">{enr.course?.title}</p>
                              <p className="text-xs text-gray-500">
                                {enr.course?.category} · {Math.round(enr.progress_percentage || 0)}% ·{' '}
                                <span className={enr.status === 'completed' ? 'text-green-600' : 'text-gray-400'}>
                                  {enr.status === 'completed' ? 'Completado' : 'En progreso'}
                                </span>
                              </p>
                            </div>
                            <button
                              onClick={() => handleRevokeCourse(enr.id, enr.course?.title)}
                              className="px-3 py-1.5 bg-red-600 text-white rounded-lg hover:bg-red-700 text-xs font-semibold transition"
                            >
                              Quitar curso
                            </button>
                          </div>
                        ))}
                      </div>
                    ) : (
                      <p className="text-gray-500 text-sm italic">Este estudiante no tiene cursos asignados.</p>
                    )}
                  </div>
                )}

                {/* Vista general de todas las inscripciones */}
                <div className="bg-white rounded-xl shadow-md overflow-hidden">
                  <h3 className="text-lg font-bold text-navy p-4 pb-2">Todas las inscripciones</h3>
                  <table className="w-full text-sm">
                    <thead className="bg-gray-50 text-left text-gray-500">
                      <tr>
                        <th className="px-4 py-3">Estudiante</th>
                        <th className="px-4 py-3">Curso</th>
                        <th className="px-4 py-3">Progreso</th>
                        <th className="px-4 py-3">Estado</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-100">
                      {enrollments.map((enr) => (
                        <tr key={enr.id}>
                          <td className="px-4 py-3">
                            <div className="font-semibold text-navy">
                              {enr.student?.nombres || enr.student?.first_name} {enr.student?.apellido_paterno || enr.student?.last_name}
                            </div>
                            <div className="text-xs text-gray-400">{enr.student?.email}</div>
                          </td>
                          <td className="px-4 py-3 text-gray-600">{enr.course?.title}</td>
                          <td className="px-4 py-3 text-gray-600">{Math.round(enr.progress_percentage || 0)}%</td>
                          <td className="px-4 py-3">
                            <span className={enr.status === 'completed' ? 'text-green-600' : 'text-gray-400'}>
                              {enr.status === 'completed' ? '✅ Completado' : '🔄 En progreso'}
                            </span>
                          </td>
                        </tr>
                      ))}
                      {!enrollments.length && (
                        <tr>
                          <td colSpan="4" className="px-4 py-8 text-center text-gray-500 italic">
                            No hay inscripciones registradas.
                          </td>
                        </tr>
                      )}
                    </tbody>
                  </table>
                </div>
              </div>
            )}

            {tab === 'courses' && (
              <div className="bg-white rounded-xl shadow-md overflow-hidden">
                <table className="w-full text-sm">
                  <thead className="bg-gray-50 text-left text-gray-500">
                    <tr>
                      <th className="px-4 py-3">Curso</th>
                      <th className="px-4 py-3">Instructor</th>
                      <th className="px-4 py-3">Precio</th>
                      <th className="px-4 py-3">Estado</th>
                      <th className="px-4 py-3">Acciones</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100">
                    {courses.map((c) => (
                      <tr key={c.id}>
                        <td className="px-4 py-3 font-semibold text-navy">{c.title}</td>
                        <td className="px-4 py-3 text-gray-600">{c.instructor_first_name} {c.instructor_last_name}</td>
                        <td className="px-4 py-3 text-gray-600">{c.price > 0 ? `$${c.price}` : 'Gratis'}</td>
                        <td className="px-4 py-3">
                          <span className={c.is_published ? 'text-green-600' : 'text-gray-400'}>
                            {c.is_published ? '🟢 Publicado' : '⚪ Borrador'}
                          </span>
                        </td>
                        <td className="px-4 py-3 flex gap-2">
                          <button onClick={() => handleTogglePublish(c)} className="px-3 py-1 border border-gray-300 rounded-lg hover:bg-gray-50 text-xs font-semibold">
                            {c.is_published ? 'Despublicar' : 'Publicar'}
                          </button>
                          <button onClick={() => handleDeleteCourse(c)} className="px-3 py-1 bg-red-600 text-white rounded-lg hover:bg-red-700 text-xs font-semibold">
                            Eliminar
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}

            {tab === 'certificates' && (
              <div className="bg-white rounded-xl shadow-md overflow-hidden">
                <table className="w-full text-sm">
                  <thead className="bg-gray-50 text-left text-gray-500">
                    <tr>
                      <th className="px-4 py-3">Estudiante</th>
                      <th className="px-4 py-3">Curso</th>
                      <th className="px-4 py-3">Fecha</th>
                      <th className="px-4 py-3">Folio</th>
                      <th className="px-4 py-3">Documentos</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100">
                    {certificates.map((cert) => (
                      <tr key={cert.id}>
                        <td className="px-4 py-3">
                          <div className="font-semibold text-navy">
                            {cert.student?.nombres || cert.student?.first_name} {cert.student?.apellido_paterno || cert.student?.last_name} {cert.student?.apellido_materno || ''}
                          </div>
                          <div className="text-xs text-gray-500">{cert.student?.curp || 'Sin CURP'}</div>
                        </td>
                        <td className="px-4 py-3 text-gray-600">{cert.course?.title}</td>
                        <td className="px-4 py-3 text-gray-600">{new Date(cert.issued_date).toLocaleDateString()}</td>
                        <td className="px-4 py-3 text-xs font-mono">{cert.certificate_number}</td>
                        <td className="px-4 py-3">
                          <div className="flex gap-2">
                            <button onClick={() => handleDownloadConstancia(cert)} className="px-2 py-1 bg-navy text-white rounded text-xs hover:bg-navy-light transition">
                              Diploma
                            </button>
                            <button onClick={() => handleDownloadDC3(cert)} className="px-2 py-1 bg-green-600 text-white rounded text-xs hover:bg-green-700 transition">
                              DC-3
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))}
                    {!certificates.length && (
                      <tr>
                        <td colSpan="5" className="px-4 py-8 text-center text-gray-500 italic">No hay certificados emitidos todavía.</td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            )}

            {tab === 'lab' && (
              <div className="bg-white rounded-xl shadow-md p-6 max-w-2xl">
                <h2 className="text-xl font-bold text-navy mb-4">Laboratorio de Documentos (Pruebas)</h2>
                <p className="text-sm text-gray-600 mb-6">Usa este formulario para generar documentos con datos ficticios y verificar la alineación de las plantillas.</p>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                  <div>
                    <label className="block text-xs font-bold text-gray-500 mb-1">Nombre(s)</label>
                    <input type="text" value={testForm.nombres} onChange={(e) => setTestForm({...testForm, nombres: e.target.value})} className="w-full border border-gray-300 rounded p-2 text-sm" />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-gray-500 mb-1">Apellidos (Paterno y Materno)</label>
                    <input type="text" value={testForm.apellidos} onChange={(e) => setTestForm({...testForm, apellidos: e.target.value})} className="w-full border border-gray-300 rounded p-2 text-sm" />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-gray-500 mb-1">CURP</label>
                    <input type="text" value={testForm.curp} onChange={(e) => setTestForm({...testForm, curp: e.target.value})} className="w-full border border-gray-300 rounded p-2 text-sm" />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-gray-500 mb-1">Ocupación (Catálogo STPS)</label>
                    <select value={testForm.ocupacion} onChange={(e) => setTestForm({...testForm, ocupacion: e.target.value})} className="w-full border border-gray-300 rounded p-2 text-sm bg-white">
                      {OCUPACIONES_STPS.map(o => (
                        <option key={o} value={o}>{o}</option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-gray-500 mb-1">Puesto</label>
                    <input type="text" value={testForm.puesto} onChange={(e) => setTestForm({...testForm, puesto: e.target.value})} className="w-full border border-gray-300 rounded p-2 text-sm" />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-gray-500 mb-1">Empresa</label>
                    <input type="text" value={testForm.empresa} onChange={(e) => setTestForm({...testForm, empresa: e.target.value})} className="w-full border border-gray-300 rounded p-2 text-sm" />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-gray-500 mb-1">RFC Empresa</label>
                    <input type="text" value={testForm.rfc} onChange={(e) => setTestForm({...testForm, rfc: e.target.value})} className="w-full border border-gray-300 rounded p-2 text-sm" />
                  </div>
                  <div className="md:col-span-2">
                    <label className="block text-xs font-bold text-gray-500 mb-1">Seleccionar Curso</label>
                    <select
                      value={testForm.curso}
                      onChange={(e) => {
                        const c = courses.find(x => x.title === e.target.value);
                        setTestForm({
                          ...testForm,
                          curso: e.target.value,
                          horas: c?.duration_hours || 8,
                          categoria: c?.category || 'SEGURIDAD'
                        });
                      }}
                      className="w-full border border-gray-300 rounded p-2 text-sm bg-white"
                    >
                      <option value="">-- Selecciona un curso --</option>
                      {courses.map(c => (
                        <option key={c.id} value={c.title}>{c.title}</option>
                      ))}
                      {!courses.length && <option disabled>No hay cursos cargados</option>}
                    </select>
                  </div>
                </div>

                <div className="flex gap-4">
                  <button onClick={handleTestConstancia} className="flex-1 py-3 bg-navy text-white rounded-lg font-bold hover:bg-navy-light transition">
                    Probar Diploma (Constancia)
                  </button>
                  <button onClick={handleTestDC3} className="flex-1 py-3 bg-green-600 text-white rounded-lg font-bold hover:bg-green-700 transition">
                    Probar Formato DC-3
                  </button>
                </div>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
};

const StatBox = ({ label, value, icon }) => (
  <div className="bg-white rounded-xl shadow-md p-5 text-center">
    <div className="text-3xl mb-2">{icon}</div>
    <p className="text-2xl font-bold text-navy">{value}</p>
    <p className="text-sm text-gray-500">{label}</p>
  </div>
);
