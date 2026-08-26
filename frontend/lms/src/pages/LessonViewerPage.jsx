import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { courseService } from '../services/courseService';

export const LessonViewerPage = () => {
  const { id: courseId, lessonId } = useParams();
  const navigate = useNavigate();
  const [modules, setModules] = useState([]);
  const [currentLesson, setCurrentLesson] = useState(null);
  const [loading, setLoading] = useState(true);
  const [completing, setCompleting] = useState(false);
  const [allLessons, setAllLessons] = useState([]);
  const [currentLessonIndex, setCurrentLessonIndex] = useState(-1);

  useEffect(() => {
    fetchData();
  }, [courseId, lessonId]);

  const fetchData = async () => {
    try {
      setLoading(true);
      const [modulesData, lessonData] = await Promise.all([
        courseService.getModules(courseId),
        courseService.getLessonById(lessonId),
      ]);

      const modulesList = modulesData.modules || [];
      setModules(modulesList);

      // Aplanar todas las lecciones en orden para navegación
      const flat = [];
      modulesList.forEach((m) => {
        m.lessons?.forEach((l) => flat.push({ ...l, moduleId: m.id, moduleTitle: m.title }));
      });
      setAllLessons(flat);

      const idx = flat.findIndex((l) => l.id === parseInt(lessonId));
      setCurrentLessonIndex(idx);

      setCurrentLesson(lessonData.lesson);
    } catch (err) {
      console.error('Error loading lesson:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleComplete = async () => {
    try {
      setCompleting(true);
      await courseService.completeLesson(lessonId);
      // Refrescar para mostrar progreso actualizado
      const lessonData = await courseService.getLessonById(lessonId);
      setCurrentLesson(lessonData.lesson);
      goToNextLesson();
    } catch (err) {
      console.error('Error completing lesson:', err);
    } finally {
      setCompleting(false);
    }
  };

  const goToNextLesson = () => {
    if (currentLessonIndex >= 0 && currentLessonIndex < allLessons.length - 1) {
      const next = allLessons[currentLessonIndex + 1];
      navigate(`/courses/${courseId}/lessons/${next.id}`);
    }
  };

  const goToPrevLesson = () => {
    if (currentLessonIndex > 0) {
      const prev = allLessons[currentLessonIndex - 1];
      navigate(`/courses/${courseId}/lessons/${prev.id}`);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin text-4xl">⏳</div>
      </div>
    );
  }

  if (!currentLesson) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <p className="text-xl text-gray-600 mb-4">Lección no encontrada</p>
          <button onClick={() => navigate(`/courses/${courseId}`)} className="px-6 py-2 bg-green text-white rounded-lg hover:bg-green-hover">
            Volver al curso
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 py-6">
        {/* Top bar */}
        <div className="flex items-center justify-between mb-6">
          <button onClick={() => navigate(`/courses/${courseId}`)} className="text-gray-600 hover:text-navy text-sm font-medium">
            ← Volver al curso
          </button>
          <div className="text-sm text-gray-500">
            Lección {currentLessonIndex + 1} de {allLessons.length}
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Contenido principal */}
          <div className="lg:col-span-2">
            <div className="bg-white rounded-xl shadow-md p-6">
              <h1 className="text-2xl font-bold text-navy mb-3">{currentLesson.title}</h1>
              {currentLesson.description && <p className="text-gray-600 mb-6">{currentLesson.description}</p>}

              {/* Contenido según tipo */}
              {currentLesson.content_type === 'video' && currentLesson.video_url ? (
                <div className="mb-6">
                  <video src={currentLesson.video_url} controls className="w-full rounded-lg" />
                </div>
              ) : currentLesson.content_type === 'document' && currentLesson.document_url ? (
                <div className="mb-6">
                  <iframe src={currentLesson.document_url} className="w-full h-[600px] rounded-lg border" title="Documento" />
                </div>
              ) : currentLesson.content_url ? (
                <div className="mb-6">
                  <iframe src={currentLesson.content_url} className="w-full h-[600px] rounded-lg border" title="Contenido" />
                </div>
              ) : (
                <div className="mb-6 bg-gray-100 rounded-lg p-8 text-center">
                  <span className="text-4xl block mb-2">📝</span>
                  <p className="text-gray-500">Esta lección no tiene contenido multimedia todavía</p>
                </div>
              )}

              {/* Botón completar */}
              <button
                onClick={handleComplete}
                disabled={completing}
                className="w-full py-3 bg-green text-white rounded-lg hover:bg-green-hover font-semibold transition disabled:opacity-50 mb-4"
              >
                {completing ? 'Marcando...' : '✓ Marcar como completada'}
              </button>

              {/* Navegación */}
              <div className="flex justify-between gap-4">
                <button
                  onClick={goToPrevLesson}
                  disabled={currentLessonIndex <= 0}
                  className="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition"
                >
                  ← Anterior
                </button>
                <button
                  onClick={goToNextLesson}
                  disabled={currentLessonIndex >= allLessons.length - 1}
                  className="px-4 py-2 bg-navy text-white rounded-lg hover:bg-navy-light disabled:opacity-50 disabled:cursor-not-allowed transition"
                >
                  Siguiente →
                </button>
              </div>
            </div>
          </div>

          {/* Sidebar - Lista de lecciones */}
          <div className="lg:col-span-1">
            <div className="bg-white rounded-xl shadow-md p-5 sticky top-6">
              <h3 className="font-bold text-navy mb-4">Contenido del curso</h3>
              <div className="space-y-3 max-h-[600px] overflow-y-auto">
                {modules.map((module, mIdx) => (
                  <div key={module.id}>
                    <p className="text-sm font-semibold text-gray-500 mb-1">
                      Módulo {mIdx + 1}: {module.title}
                    </p>
                    {module.lessons?.map((lesson) => {
                      const isActive = lesson.id === parseInt(lessonId);
                      return (
                        <button
                          key={lesson.id}
                          onClick={() => navigate(`/courses/${courseId}/lessons/${lesson.id}`)}
                          className={`w-full text-left px-3 py-2 rounded-lg text-sm transition ${
                            isActive
                              ? 'bg-green text-white font-semibold'
                              : 'hover:bg-gray-50 text-gray-700'
                          }`}
                        >
                          <span className="mr-2">
                            {lesson.content_type === 'video' ? '🎥' : lesson.content_type === 'document' ? '📄' : '📝'}
                          </span>
                          {lesson.title}
                        </button>
                      );
                    })}
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
