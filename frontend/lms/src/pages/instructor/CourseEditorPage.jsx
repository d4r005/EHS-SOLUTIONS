import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import axios from 'axios';
import { quizService } from '../../services/quizService';

const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL || 'https://tsqlpjliqslgzookdqvg.supabase.co';
const SUPABASE_KEY = import.meta.env.VITE_SUPABASE_KEY;

const rest = axios.create({ baseURL: `${SUPABASE_URL}/rest/v1`, headers: { apikey: SUPABASE_KEY, 'Content-Type': 'application/json' } });
rest.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

export const CourseEditorPage = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [course, setCourse] = useState(null);
  const [modules, setModules] = useState([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [newModuleTitle, setNewModuleTitle] = useState('');
  const [expandedModule, setExpandedModule] = useState(null);
  const [quizByLesson, setQuizByLesson] = useState({});

  useEffect(() => {
    fetchData();
  }, [id]);

  const fetchData = async () => {
    try {
      setLoading(true);
      const [{ data: courses }, { data: mods }] = await Promise.all([
        rest.get(`/courses?id=eq.${id}&select=*`),
        rest.get(`/modules?course_id=eq.${id}&select=*,lessons(*)&order=order_index`),
      ]);
      setCourse(courses[0]);
      const sortedModules = (mods || []).map((m) => ({
        ...m,
        lessons: (m.lessons || []).sort((a, b) => a.order_index - b.order_index),
      }));
      setModules(sortedModules);

      // cargar quizzes existentes por lección
      const quizMap = {};
      for (const m of sortedModules) {
        for (const l of m.lessons) {
          const q = await quizService.getQuizByLesson(l.id);
          if (q) quizMap[l.id] = q;
        }
      }
      setQuizByLesson(quizMap);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleSaveCourse = async (e) => {
    e.preventDefault();
    setSaving(true);
    try {
      await rest.patch(`/courses?id=eq.${id}`, {
        title: course.title,
        description: course.description,
        short_description: course.short_description,
        category: course.category,
        thumbnail_url: course.thumbnail_url,
        price: parseFloat(course.price) || 0,
        duration_hours: parseInt(course.duration_hours) || 0,
        difficulty_level: course.difficulty_level,
      });
    } catch (err) {
      console.error(err);
    } finally {
      setSaving(false);
    }
  };

  const handleAddModule = async (e) => {
    e.preventDefault();
    if (!newModuleTitle.trim()) return;
    const { data } = await rest.post('/modules', {
      course_id: parseInt(id),
      title: newModuleTitle,
      order_index: modules.length + 1,
    });
    setModules([...modules, { ...data[0], lessons: [] }]);
    setNewModuleTitle('');
  };

  const handleDeleteModule = async (moduleId) => {
    if (!window.confirm('¿Eliminar este módulo y todas sus lecciones?')) return;
    await rest.delete(`/modules?id=eq.${moduleId}`);
    setModules(modules.filter((m) => m.id !== moduleId));
  };

  const handleAddLesson = async (moduleId) => {
    const title = window.prompt('Título de la lección:');
    if (!title) return;
    const module = modules.find((m) => m.id === moduleId);
    const { data } = await rest.post('/lessons', {
      module_id: moduleId,
      title,
      content_type: 'text',
      order_index: (module.lessons?.length || 0) + 1,
      is_required: true,
    });
    setModules(modules.map((m) => (m.id === moduleId ? { ...m, lessons: [...(m.lessons || []), data[0]] } : m)));
  };

  const handleUpdateLesson = async (moduleId, lesson, field, value) => {
    const updated = { ...lesson, [field]: value };
    setModules(modules.map((m) =>
      m.id === moduleId ? { ...m, lessons: m.lessons.map((l) => (l.id === lesson.id ? updated : l)) } : m
    ));
  };

  const handleSaveLesson = async (lesson) => {
    await rest.patch(`/lessons?id=eq.${lesson.id}`, {
      title: lesson.title,
      description: lesson.description,
      content: lesson.content,
      video_url: lesson.video_url,
      content_type: lesson.video_url && lesson.content ? 'mixed' : lesson.video_url ? 'video' : 'text',
      duration_minutes: parseInt(lesson.duration_minutes) || 0,
    });
  };

  const handleDeleteLesson = async (moduleId, lessonId) => {
    if (!window.confirm('¿Eliminar esta lección?')) return;
    await rest.delete(`/lessons?id=eq.${lessonId}`);
    setModules(modules.map((m) => (m.id === moduleId ? { ...m, lessons: m.lessons.filter((l) => l.id !== lessonId) } : m)));
  };

  const handleAddQuiz = async (lessonId) => {
    const title = window.prompt('Título del examen:', 'Examen de la lección');
    if (!title) return;
    const quiz = await quizService.createQuiz({ lesson_id: lessonId, title, passing_score: 70, is_active: true });
    setQuizByLesson({ ...quizByLesson, [lessonId]: quiz });
  };

  const handleAddQuestion = async (quiz) => {
    const question_text = window.prompt('Texto de la pregunta:');
    if (!question_text) return;
    const option_a = window.prompt('Opción A:');
    const option_b = window.prompt('Opción B:');
    const option_c = window.prompt('Opción C (opcional):') || null;
    const option_d = window.prompt('Opción D (opcional):') || null;
    const correct_answer = (window.prompt('¿Cuál es la respuesta correcta? (a/b/c/d):') || 'a').toLowerCase();
    await quizService.createQuestion({
      quiz_id: quiz.id, question_text, option_a, option_b, option_c, option_d, correct_answer, order_index: 1,
    });
    alert('Pregunta agregada');
  };

  if (loading || !course) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin text-4xl">⏳</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-5xl mx-auto px-4 space-y-8">
        <button onClick={() => navigate(-1)} className="text-gray-600 hover:text-navy text-sm font-medium">← Volver</button>

        {/* Datos del curso */}
        <div className="bg-white rounded-xl shadow-md p-6">
          <h2 className="text-xl font-bold text-navy mb-4">Datos del curso</h2>
          <form onSubmit={handleSaveCourse} className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="md:col-span-2">
              <label className="block text-sm font-semibold text-navy mb-1">Título</label>
              <input value={course.title || ''} onChange={(e) => setCourse({ ...course, title: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600" />
            </div>
            <div className="md:col-span-2">
              <label className="block text-sm font-semibold text-navy mb-1">Descripción corta</label>
              <input value={course.short_description || ''} onChange={(e) => setCourse({ ...course, short_description: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600" />
            </div>
            <div className="md:col-span-2">
              <label className="block text-sm font-semibold text-navy mb-1">Descripción completa</label>
              <textarea rows={3} value={course.description || ''} onChange={(e) => setCourse({ ...course, description: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600" />
            </div>
            <div>
              <label className="block text-sm font-semibold text-navy mb-1">Categoría</label>
              <input value={course.category || ''} onChange={(e) => setCourse({ ...course, category: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600" />
            </div>
            <div>
              <label className="block text-sm font-semibold text-navy mb-1">Nivel</label>
              <select value={course.difficulty_level || 'beginner'} onChange={(e) => setCourse({ ...course, difficulty_level: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600">
                <option value="beginner">Principiante</option>
                <option value="intermediate">Intermedio</option>
                <option value="advanced">Avanzado</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-semibold text-navy mb-1">Precio (MXN, 0 = gratis)</label>
              <input type="number" step="0.01" value={course.price || 0} onChange={(e) => setCourse({ ...course, price: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600" />
            </div>
            <div>
              <label className="block text-sm font-semibold text-navy mb-1">Duración (horas)</label>
              <input type="number" value={course.duration_hours || 0} onChange={(e) => setCourse({ ...course, duration_hours: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600" />
            </div>
            <div className="md:col-span-2">
              <label className="block text-sm font-semibold text-navy mb-1">URL de imagen (thumbnail)</label>
              <input value={course.thumbnail_url || ''} onChange={(e) => setCourse({ ...course, thumbnail_url: e.target.value })}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600" />
            </div>
            <div className="md:col-span-2">
              <button type="submit" disabled={saving} className="px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 font-semibold transition disabled:opacity-50">
                {saving ? 'Guardando...' : 'Guardar cambios'}
              </button>
            </div>
          </form>
        </div>

        {/* Módulos y lecciones */}
        <div className="bg-white rounded-xl shadow-md p-6">
          <h2 className="text-xl font-bold text-navy mb-4">Módulos y lecciones</h2>

          <form onSubmit={handleAddModule} className="flex gap-3 mb-6">
            <input value={newModuleTitle} onChange={(e) => setNewModuleTitle(e.target.value)} placeholder="Título del nuevo módulo"
              className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:border-green-600" />
            <button type="submit" className="px-4 py-2 bg-navy text-white rounded-lg hover:bg-navy-light font-semibold transition">+ Módulo</button>
          </form>

          <div className="space-y-4">
            {modules.map((m) => (
              <div key={m.id} className="border border-gray-200 rounded-lg">
                <div className="bg-gray-50 px-4 py-3 flex items-center justify-between cursor-pointer" onClick={() => setExpandedModule(expandedModule === m.id ? null : m.id)}>
                  <p className="font-bold text-navy">{m.title} ({m.lessons?.length || 0} lecciones)</p>
                  <div className="flex gap-2">
                    <button onClick={(e) => { e.stopPropagation(); handleAddLesson(m.id); }} className="px-3 py-1 bg-green-600 text-white rounded-lg hover:bg-green-700 text-sm">+ Lección</button>
                    <button onClick={(e) => { e.stopPropagation(); handleDeleteModule(m.id); }} className="px-3 py-1 bg-red-600 text-white rounded-lg hover:bg-red-700 text-sm">Eliminar</button>
                  </div>
                </div>

                {expandedModule === m.id && (
                  <div className="p-4 space-y-4">
                    {(m.lessons || []).map((l) => (
                      <div key={l.id} className="border border-gray-100 rounded-lg p-4 bg-gray-50/50">
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-3 mb-2">
                          <input value={l.title || ''} onChange={(e) => handleUpdateLesson(m.id, l, 'title', e.target.value)}
                            placeholder="Título" className="px-3 py-2 border border-gray-300 rounded-lg text-sm" />
                          <input value={l.video_url || ''} onChange={(e) => handleUpdateLesson(m.id, l, 'video_url', e.target.value)}
                            placeholder="URL de YouTube (opcional)" className="px-3 py-2 border border-gray-300 rounded-lg text-sm" />
                        </div>
                        <textarea value={l.content || ''} onChange={(e) => handleUpdateLesson(m.id, l, 'content', e.target.value)}
                          placeholder="Contenido de texto de la lección" rows={3}
                          className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm mb-2" />
                        <div className="flex items-center gap-2 flex-wrap">
                          <input type="number" value={l.duration_minutes || 0} onChange={(e) => handleUpdateLesson(m.id, l, 'duration_minutes', e.target.value)}
                            placeholder="Min" className="w-20 px-3 py-2 border border-gray-300 rounded-lg text-sm" />
                          <button onClick={() => handleSaveLesson(l)} className="px-3 py-1.5 bg-green-600 text-white rounded-lg hover:bg-green-700 text-sm">Guardar</button>
                          <button onClick={() => handleDeleteLesson(m.id, l.id)} className="px-3 py-1.5 bg-red-600 text-white rounded-lg hover:bg-red-700 text-sm">Eliminar</button>
                          {quizByLesson[l.id] ? (
                            <button onClick={() => handleAddQuestion(quizByLesson[l.id])} className="px-3 py-1.5 border border-navy text-navy rounded-lg hover:bg-navy hover:text-white text-sm transition">
                              + Pregunta al examen
                            </button>
                          ) : (
                            <button onClick={() => handleAddQuiz(l.id)} className="px-3 py-1.5 border border-navy text-navy rounded-lg hover:bg-navy hover:text-white text-sm transition">
                              + Crear examen
                            </button>
                          )}
                        </div>
                      </div>
                    ))}
                    {!m.lessons?.length && <p className="text-sm text-gray-500">Sin lecciones todavía</p>}
                  </div>
                )}
              </div>
            ))}
            {!modules.length && <p className="text-gray-500">Todavía no hay módulos. Agrega el primero arriba.</p>}
          </div>
        </div>
      </div>
    </div>
  );
};
