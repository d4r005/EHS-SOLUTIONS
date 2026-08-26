import { useState, useEffect } from 'react';
import { adminService } from '../../services/adminService';

export const AdminDashboard = () => {
  const [tab, setTab] = useState('reports');
  const [users, setUsers] = useState([]);
  const [courses, setCourses] = useState([]);
  const [reports, setReports] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchAll();
  }, []);

  const fetchAll = async () => {
    try {
      setLoading(true);
      const [u, c, r] = await Promise.all([
        adminService.getUsers(),
        adminService.getAllCourses(),
        adminService.getReports(),
      ]);
      setUsers(u);
      setCourses(c);
      setReports(r);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleRoleChange = async (id, role) => {
    await adminService.updateUserRole(id, role);
    setUsers(users.map((u) => (u.id === id ? { ...u, role } : u)));
  };

  const handleToggleActive = async (u) => {
    await adminService.toggleUserActive(u.id, !u.is_active);
    setUsers(users.map((x) => (x.id === u.id ? { ...x, is_active: !u.is_active } : x)));
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
    { id: 'courses', label: 'Cursos' },
  ];

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-6xl mx-auto px-4">
        <h1 className="text-3xl font-bold text-navy mb-6">Panel de Administración</h1>

        <div className="flex gap-2 mb-6 border-b border-gray-200">
          {tabs.map((t) => (
            <button
              key={t.id}
              onClick={() => setTab(t.id)}
              className={`px-5 py-3 font-semibold text-sm transition border-b-2 ${
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
                        <td className="px-4 py-3 font-semibold text-navy">{u.first_name} {u.last_name}</td>
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
                          <button onClick={() => handleToggleActive(u)} className="px-3 py-1 border border-gray-300 rounded-lg hover:bg-gray-50 text-xs font-semibold">
                            {u.is_active ? 'Desactivar' : 'Activar'}
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
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
