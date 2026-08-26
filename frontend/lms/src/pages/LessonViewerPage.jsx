import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { courseService } from '../services/courseService';
import { quizService } from '../services/quizService';
import { emailService } from '../services/emailService';
import { certificateService } from '../services/certificateService';
import { useAuth } from '../context/AuthContext';

// Extrae el video ID de diferentes formatos de URL de YouTube
function getYouTubeId(url) {
  if (!url) return null;
  const patterns = [
    /(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([a-zA-Z0-9_-]{11})/,
  ];
  for (const p of patterns) {
    const match = url.match(p);
    if (match) return match[1];
  }
  return null;
}

// Renderiza texto con párrafos
function renderContent(text) {
  if (!text) return null;
  const paragraphs = text.split('\n\n').filter(p => p.trim());
  return paragraphs.map((para, i) => {
    // Si la línea es toda mayúscula, la tratamos como un subtítulo
    const isHeading = para === para.toUpperCase() && para.length < 120 && !para.includes('.');
    if (isHeading) {
      return <h3 key={i} className="text-lg font-bold text-navy mt-5 mb-2">{para}</h3>;
    }
    return <p key={i} className="text-gray-700 leading-relaxed mb-3">{para}</p>;
  });
}

export const LessonViewerPage = () => {
  const { id: courseId, lessonId } = useParams();
  const navigate = useNavigate();
  const [modules, setModules] = useState([]);
  const [currentLesson, setCurrentLesson] = useState(null);
  const [loading, setLoading] = useState(true);
  const [completing, setCompleting] = useState(false);
  const [allLessons, setAllLessons] = useState([]);
  const [currentLessonIndex, setCurrentLessonIndex] = useState(-1);
  const [quiz, setQuiz] = useState(null);
  const { user } = useAuth();

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

      const flat = [];
      modulesList.forEach((m) => {
        m.lessons?.forEach((l) => flat.push({ ...l, moduleId: m.id, moduleTitle: m.title }));
      });
      setAllLessons(flat);

      const idx = flat.findIndex((l) => l.id === parseInt(lessonId));
      setCurrentLessonIndex(idx);

      setCurrentLesson(lessonData.lesson);

      const associatedQuiz = await quizService.getQuizByLesson(lessonId);
      setQuiz(associatedQuiz);
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
      const lessonData = await courseService.getLessonById(lessonId);
      setCurrentLesson(lessonData.lesson);

      // Revisar si el curso llegó a 100% para notificar y ofrecer certificado
      const progress = await courseService.getCourseProgress(courseId);
      if (progress?.percentage >= 100 && user) {
        emailService.sendCourseCompletedEmail(user.email, user.first_name, allLessons[0]?.moduleTitle || 'tu curso');
        try {
          const cert = await certificateService.getOrCreateCertificate(courseId);
          emailService.sendCertificateReadyEmail(user.email, user.first_name, allLessons[0]?.moduleTitle || 'tu curso', cert.certificate_number);
        } catch (e) {
          // el certificado se puede generar después desde el perfil
        }
      }

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
          <button onClick={() => navigate(`/courses/${courseId}`)} className="px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700">
            Volver al curso
          </button>
        </div>
      </div>
    );
  }

  const ytId = getYouTubeId(currentLesson.video_url);

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
              {currentLesson.description && <p className="text-gray-500 mb-4 italic">{currentLesson.description}</p>}

              {/* Video de YouTube */}
              {ytId && (
                <div className="mb-6">
                  <div className="relative w-full" style={{ paddingBottom: '56.25%' }}>
                    <iframe
                      className="absolute top-0 left-0 w-full h-full rounded-lg"
                      src={`https://www.youtube.com/embed/${ytId}`}
                      title={currentLesson.title}
                      frameBorder="0"
                      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                      allowFullScreen
                    />
                  </div>
                </div>
              )}

              {/* Video directo (no YouTube) */}
              {!ytId && currentLesson.content_type === 'video' && currentLesson.video_url && (
                <div className="mb-6">
                  <video src={currentLesson.video_url} controls className="w-full rounded-lg" />
                </div>
              )}

              {/* Documento */}
              {currentLesson.content_type === 'document' && currentLesson.document_url && (
                <div className="mb-6">
                  <iframe src={currentLesson.document_url} className="w-full h-[600px] rounded-lg border" title="Documento" />
                </div>
              )}

              {/* Contenido de texto */}
              {currentLesson.content && (
                <div className="prose prose-lg max-w-none mb-6">
                  {renderContent(currentLesson.content)}
                </div>
              )}

              {/* Placeholder si no hay contenido */}
              {!ytId && !currentLesson.content && !currentLesson.content_url && !currentLesson.document_url && (
                <div className="mb-6 bg-gray-100 rounded-lg p-8 text-center">
                  <span className="text-4xl block mb-2">📝</span>
                  <p className="text-gray-500">Esta lección no tiene contenido todavía</p>
                </div>
              )}

              {/* Botón de examen si la lección tiene uno */}
              {quiz && (
                <button
                  onClick={() => navigate(`/courses/${courseId}/quiz/${quiz.id}`)}
                  className="w-full py-3 border-2 border-navy text-navy rounded-lg hover:bg-navy hover:text-white font-semibold transition mb-3"
                >
                  📋 Tomar examen: {quiz.title}
                </button>
              )}

              {/* Botón completar */}
              <button
                onClick={handleComplete}
                disabled={completing}
                className="w-full py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 font-semibold transition disabled:opacity-50 mb-4"
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
                              ? 'bg-green-600 text-white font-semibold'
                              : 'hover:bg-gray-50 text-gray-700'
                          }`}
                        >
                          <span className="mr-2">
                            {lesson.content_type === 'video' ? '🎥' : lesson.content_type === 'document' ? '📄' : lesson.content_type === 'mixed' ? '📚' : '📝'}
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
