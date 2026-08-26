import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';
import axios from 'axios';

const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL || 'https://tsqlpjliqslgzookdqvg.supabase.co';
const SUPABASE_KEY = import.meta.env.VITE_SUPABASE_KEY;

const rest = axios.create({ baseURL: `${SUPABASE_URL}/rest/v1`, headers: { apikey: SUPABASE_KEY, 'Content-Type': 'application/json' } });
rest.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

export const InstructorDashboard = () => {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [courses, setCourses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [creating, setCreating] = useState(false);
  const [newTitle, setNewTitle] = useState('');

  useEffect(() => {
    fetchCourses();
  }, []);

  const fetchCourses = async () => {
    try {
      setLoading(true);
      const isAdmin = user.role === 'admin';
      const query = isAdmin
        ? '/courses?select=*,enrollments(id,progress_percentage)&order=created_at.desc'
        : `/courses?instructor_id=eq.${user.id}&select=*,enrollments(id,progress_percentage)&order=created_at.desc`;
      const { data } = await rest.get(query);
      setCourses(data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleCreate = async (e) => {
    e.preventDefault();
    if (!newTitle.trim()) return;
    try {
      setCreating(true);
      const { data } = await rest.post('/courses', {
        title: newTitle,
        instructor_id: user.id,
        is_published: false,
        price: 0,
      });
      setNewTitle('');
      navigate(`/instructor/courses/${data[0].id}`);
    } catch (err) {
      console.error(err);
    } finally {
      setCreating(false);
    }
  };

  const handleTogglePublish = async (course) => {
    await rest.patch(`/courses?id=eq.${course.id}`, { is_published: !course.is_published });
    fetchCourses();
  };

  const handleDelete = async (course) => {
    if (!window.confirm(`¿Eliminar el curso "${course.title}"? Esta acción no se puede deshacer.`)) return;
    await rest.delete(`/courses?id=eq.${course.id}`);
    fetchCourses();
  };

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-6xl mx-auto px-4">
        <div className="flex items-center justify-between mb-6 flex-wrap gap-4">
          <h1 className="text-3xl font-bold text-navy">Panel de Instructor</h1>
        </div>

        {/* Crear curso */}
        <div className="bg-white rounded-xl shadow-md p-6 mb-8">
          <h2 className="text-lg font-bold text-navy mb-3">Crear nuevo curso</h2>
          <form onSubmit={handleCreate} className="flex gap-3 flex-wrap">
            <input
              value={newTitle}
              onChange={(e) => setNewTitle(e.target.value)}
              placeholder="Título del curso"
              className="flex-1 min-w-[240px] px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600"
            />
            <button type="submit" disabled={creating} className="px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 font-semibold transition disabled:opacity-50">
              {creating ? 'Creando...' : 'Crear curso'}
            </button>
          </form>
        </div>

        {/* Lista de cursos */}
        <div className="bg-white rounded-xl shadow-md p-6">
          <h2 className="text-lg font-bold text-navy mb-4">Mis cursos</h2>
          {loading ? (
            <p className="text-gray-500">Cargando...</p>
          ) : courses.length ? (
            <div className="space-y-3">
              {courses.map((c) => {
                const enrolled = c.enrollments?.length || 0;
                const avgProgress = enrolled
                  ? Math.round(c.enrollments.reduce((s, e) => s + (e.progress_percentage || 0), 0) / enrolled)
                  : 0;
                return (
                  <div key={c.id} className="border border-gray-200 rounded-lg p-4 flex items-center justify-between flex-wrap gap-3">
                    <div>
                      <p className="font-bold text-navy">{c.title}</p>
                      <p className="text-sm text-gray-500">
                        {c.is_published ? '🟢 Publicado' : '⚪ Borrador'} · {enrolled} inscritos · {avgProgress}% progreso promedio · ${c.price || 0}
                      </p>
                    </div>
                    <div className="flex gap-2 flex-wrap">
                      <button onClick={() => navigate(`/instructor/courses/${c.id}`)} className="px-4 py-2 bg-navy text-white rounded-lg hover:bg-navy-light text-sm font-semibold transition">
                        Editar
                      </button>
                      <button onClick={() => handleTogglePublish(c)} className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 text-sm font-semibold transition">
                        {c.is_published ? 'Despublicar' : 'Publicar'}
                      </button>
                      <button onClick={() => handleDelete(c)} className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 text-sm font-semibold transition">
                        Eliminar
                      </button>
                    </div>
                  </div>
                );
              })}
            </div>
          ) : (
            <p className="text-gray-500">Todavía no tienes cursos creados</p>
          )}
        </div>
      </div>
    </div>
  );
};
