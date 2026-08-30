import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { courseService } from '../services/courseService';

export const CoursesPage = () => {
  const navigate = useNavigate();
  const [courses, setCourses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [category, setCategory] = useState('');
  const [difficulty, setDifficulty] = useState('');

  const categories = ['Seguridad Industrial', 'Salud Ocupacional', 'Medio Ambiente', 'Primeros Auxilios', 'General'];
  const difficulties = [
    { value: 'beginner', label: 'Principiante' },
    { value: 'intermediate', label: 'Intermedio' },
    { value: 'advanced', label: 'Avanzado' },
  ];

  useEffect(() => {
    fetchCourses();
  }, [search, category, difficulty]);

  const fetchCourses = async () => {
    try {
      setLoading(true);
      const filters = {};
      if (search) filters.search = search;
      if (category) filters.category = category;
      if (difficulty) filters.difficulty_level = difficulty;
      const data = await courseService.getCourses(filters);
      setCourses(data.courses || []);
    } catch (error) {
      console.error('Error fetching courses:', error);
    } finally {
      setLoading(false);
    }
  };

  const difficultyBadge = (level) => {
    const colors = {
      beginner: 'bg-green-100 text-green-700',
      intermediate: 'bg-yellow-100 text-yellow-700',
      advanced: 'bg-red-100 text-red-700',
    };
    const labels = { beginner: 'Principiante', intermediate: 'Intermedio', advanced: 'Avanzado' };
    return colors[level] || colors.beginner;
  };

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-7xl mx-auto px-4">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-navy mb-2">Catálogo de Cursos (Mejorado v2)</h1>
          <p className="text-gray-600">Explora nuestros cursos de capacitación EHS</p>
        </div>

        {/* Filtros */}
        <div className="bg-white rounded-xl shadow-md p-6 mb-8">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <input
              type="text"
              placeholder="Buscar cursos..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
            />
            <select
              value={category}
              onChange={(e) => setCategory(e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
            >
              <option value="">Todas las categorías</option>
              {categories.map((c) => <option key={c} value={c}>{c}</option>)}
            </select>
            <select
              value={difficulty}
              onChange={(e) => setDifficulty(e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500"
            >
              <option value="">Todos los niveles</option>
              {difficulties.map((d) => <option key={d.value} value={d.value}>{d.label}</option>)}
            </select>
          </div>
        </div>

        {/* Grid de cursos */}
        {loading ? (
          <div className="text-center py-16">
            <div className="animate-spin text-4xl">⏳</div>
            <p className="text-gray-600 mt-2">Cargando cursos...</p>
          </div>
        ) : courses.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {courses.map((course) => (
              <div
                key={course.id}
                onClick={() => navigate(`/courses/${course.id}`)}
                className="bg-white border border-gray-200 rounded-lg overflow-hidden hover:shadow-lg transition cursor-pointer"
              >
                <div className="h-40 bg-gradient-to-br from-navy to-navy-deep flex items-center justify-center overflow-hidden">
                  {course.thumbnail_url ? (
                    <img src={course.thumbnail_url} alt={course.title} className="w-full h-full object-cover" />
                  ) : (
                    <span className="text-5xl">📚</span>
                  )}
                </div>
                <div className="p-5">
                  <div className="flex justify-between items-start mb-2">
                    <span className={`text-xs font-semibold px-2 py-1 rounded-full ${difficultyBadge(course.difficulty_level)}`}>
                      {course.difficulty_level === 'beginner' ? 'Principiante' : course.difficulty_level === 'intermediate' ? 'Intermedio' : 'Avanzado'}
                    </span>
                    {course.price > 0 ? (
                      <span className="text-lg font-bold text-green-600">${course.price}</span>
                    ) : (
                      <span className="text-sm font-semibold text-green-600">Gratis</span>
                    )}
                  </div>
                  <h3 className="text-lg font-bold text-navy mb-2">{course.title}</h3>
                  <p className="text-sm text-gray-600 mb-3 line-clamp-2">{course.short_description || course.description}</p>
                  <div className="flex items-center justify-between text-xs text-gray-500">
                    <span>👤 {course.first_name} {course.last_name}</span>
                    <span>⏱️ {course.duration_hours || 0}h</span>
                  </div>
                  <div className="mt-3 text-xs text-gray-400">
                    📦 {course.module_count || 0} módulos · 📄 {course.lesson_count || 0} lecciones
                  </div>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="text-center py-16 bg-white rounded-xl shadow-md">
            <p className="text-6xl mb-4">🔍</p>
            <p className="text-gray-600 text-lg">No se encontraron cursos con esos filtros</p>
          </div>
        )}
      </div>
    </div>
  );
};
