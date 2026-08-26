import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { courseService } from '../services/courseService';
import { certificateService } from '../services/certificateService';
import { paymentService } from '../services/paymentService';

export const CourseDetailPage = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const { isAuthenticated, user, loading: authLoading } = useAuth();
  const [course, setCourse] = useState(null);
  const [loading, setLoading] = useState(true);
  const [enrolling, setEnrolling] = useState(false);
  const [paying, setPaying] = useState(false);
  const [downloadingCert, setDownloadingCert] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchCourse();
  }, [id]);

  useEffect(() => {
    // Tras volver de Stripe Checkout, reintenta refrescar unos segundos
    // por si el webhook todavía está procesando la inscripción
    const params = new URLSearchParams(window.location.search);
    if (params.get('payment') === 'success') {
      let attempts = 0;
      const interval = setInterval(() => {
        attempts += 1;
        fetchCourse();
        if (attempts >= 5) clearInterval(interval);
      }, 2000);
      return () => clearInterval(interval);
    }
  }, [id]);

  const fetchCourse = async () => {
    try {
      setLoading(true);
      const data = await courseService.getCourseById(id);
      setCourse(data.course);
    } catch (err) {
      setError('Error al cargar el curso');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleEnroll = async () => {
    if (!isAuthenticated) {
      navigate('/login');
      return;
    }
    try {
      setEnrolling(true);
      await courseService.enrollCourse(id);
      // Refrescar el curso para mostrar el enrollment actualizado
      fetchCourse();
    } catch (err) {
      setError(err.message || 'Error al inscribirse');
    } finally {
      setEnrolling(false);
    }
  };

  const handleBuy = async () => {
    if (!isAuthenticated) {
      navigate('/login');
      return;
    }
    try {
      setPaying(true);
      await paymentService.startCheckout(id, user);
      // startCheckout redirige a Stripe; si falla, cae al catch
    } catch (err) {
      setError(err.message || 'No se pudo iniciar el pago');
      setPaying(false);
    }
  };

  const handleDownloadCertificate = async () => {
    try {
      setDownloadingCert(true);
      const cert = await certificateService.getOrCreateCertificate(id);
      certificateService.downloadCertificatePDF(
        cert,
        `${user.first_name} ${user.last_name}`,
        course.title,
        course.duration_hours
      );
    } catch (err) {
      setError(err.message || 'No se pudo generar el certificado');
    } finally {
      setDownloadingCert(false);
    }
  };

  const handleStartLearning = () => {
    // Navegar a la primera lección del primer módulo
    const firstModule = course.modules?.[0];
    const firstLesson = firstModule?.lessons?.[0];
    if (firstLesson) {
      navigate(`/courses/${id}/lessons/${firstLesson.id}`);
    }
  };

  const isEnrolled = course?.enrollment;
  const isAdmin = ['admin', 'instructor'].includes(user?.role);
  // Admin/instructor pueden revisar el contenido (textos y videos) sin inscribirse
  const canViewContent = isEnrolled || isAdmin;

  if (loading || authLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin text-4xl">⏳</div>
          <p className="text-gray-600 mt-2">Cargando curso...</p>
        </div>
      </div>
    );
  }

  if (error || !course) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <p className="text-2xl text-gray-600 mb-4">{error || 'Curso no encontrado'}</p>
          <button onClick={() => navigate('/courses')} className="px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700">
            Volver a cursos
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Hero */}
      <div className="bg-gradient-to-br from-navy to-navy-deep text-white py-12 px-4">
        <div className="max-w-5xl mx-auto">
          <button onClick={() => navigate('/courses')} className="text-gray-300 hover:text-white mb-4 text-sm">
            ← Volver al catálogo
          </button>
          <div className="flex items-start gap-2 mb-4 flex-wrap">
            <span className="text-sm bg-green-600 px-3 py-1 rounded-full text-white">
              {course.difficulty_level === 'beginner' ? 'Principiante' : course.difficulty_level === 'intermediate' ? 'Intermedio' : 'Avanzado'}
            </span>
            {course.category && <span className="text-sm bg-white/20 px-3 py-1 rounded-full">{course.category}</span>}
          </div>
          <h1 className="text-4xl font-bold mb-3">{course.title}</h1>
          <p className="text-xl text-gray-300 mb-4">{course.short_description || course.description}</p>
          <div className="flex items-center gap-6 text-sm text-gray-300">
            <span>👤 {course.instructor_first_name} {course.instructor_last_name}</span>
            <span>⏱️ {course.duration_hours || 0} horas</span>
            <span>📦 {course.module_count} módulos</span>
            <span>📄 {course.lesson_count} lecciones</span>
            <span>{course.price > 0 ? `💰 $${course.price}` : '🆓 Gratis'}</span>
          </div>
        </div>
      </div>

      <div className="max-w-5xl mx-auto px-4 py-8">
        {/* Action bar */}
        <div className="bg-white rounded-xl shadow-md p-6 mb-8 flex items-center justify-between flex-wrap gap-4">
          {isAdmin ? (
            <>
              <div className="bg-navy/5 px-4 py-2 rounded-lg border border-navy/10">
                <p className="text-navy font-bold flex items-center gap-2">
                  <span className="text-xl">🛡️</span> Modo Revisión: {user?.role}
                </p>
                <p className="text-xs text-gray-500">Tienes acceso total al contenido para evaluación.</p>
              </div>
              <button onClick={handleStartLearning} className="px-6 py-3 bg-navy text-white rounded-lg hover:bg-navy-light font-bold transition shadow-sm">
                Revisar contenido
              </button>
            </>
          ) : isEnrolled ? (
            <>
              <div>
                <p className="text-sm text-gray-600">Tu progreso</p>
                <div className="flex items-center gap-3 mt-1">
                  <div className="w-48 h-3 bg-gray-200 rounded-full overflow-hidden">
                    <div className="h-full bg-green-600 transition-all" style={{ width: `${course.enrollment.progress_percentage || 0}%` }} />
                  </div>
                  <span className="font-semibold text-navy">{Math.round(course.enrollment.progress_percentage || 0)}%</span>
                </div>
              </div>
              <div className="flex gap-3">
                {course.enrollment.progress_percentage >= 100 && (
                  <button onClick={handleDownloadCertificate} disabled={downloadingCert} className="px-6 py-3 bg-navy text-white rounded-lg hover:bg-navy-light font-semibold transition disabled:opacity-50">
                    {downloadingCert ? 'Generando...' : '🏆 Descargar certificado'}
                  </button>
                )}
                <button onClick={handleStartLearning} className="px-6 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 font-semibold transition">
                  {course.enrollment.progress_percentage > 0 ? 'Continuar Aprendiendo' : 'Comenzar Curso'}
                </button>
              </div>
            </>
          ) : course.price > 0 ? (
            <>
              <p className="text-gray-600">Compra este curso para acceder a todo el contenido</p>
              <button onClick={handleBuy} disabled={paying} className="px-6 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 font-semibold transition disabled:opacity-50">
                {paying ? 'Redirigiendo...' : isAuthenticated ? `Comprar por $${course.price} MXN` : 'Inicia sesión para comprar'}
              </button>
            </>
          ) : (
            <>
              <p className="text-gray-600">Inscríbete para acceder a todo el contenido</p>
              <button onClick={handleEnroll} disabled={enrolling} className="px-6 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 font-semibold transition disabled:opacity-50">
                {enrolling ? 'Inscribiendo...' : isAuthenticated ? 'Inscribirme' : 'Inicia sesión para inscribirte'}
              </button>
            </>
          )}
        </div>

        {/* Descripción completa */}
        <div className="bg-white rounded-xl shadow-md p-6 mb-8">
          <h2 className="text-2xl font-bold text-navy mb-4">Sobre el curso</h2>
          <p className="text-gray-700 leading-relaxed">{course.description}</p>
        </div>

        {/* Contenido del curso */}
        <div className="bg-white rounded-xl shadow-md p-6">
          <h2 className="text-2xl font-bold text-navy mb-6">Contenido del curso</h2>
          {course.modules?.length > 0 ? (
            <div className="space-y-4">
              {course.modules.map((module, idx) => (
                <div key={module.id} className="border border-gray-200 rounded-lg overflow-hidden">
                  <div className="bg-gray-50 px-5 py-3 flex items-center justify-between">
                    <h3 className="font-bold text-navy">Módulo {idx + 1}: {module.title}</h3>
                    <span className="text-sm text-gray-500">{module.lessons?.length || 0} lecciones</span>
                  </div>
                  {module.lessons?.length > 0 && (
                    <div className="divide-y divide-gray-100">
                      {module.lessons.map((lesson) => {
                        const hasQuiz = lesson.quizzes && lesson.quizzes.length > 0;
                        return (
                          <div
                            key={lesson.id}
                            onClick={() => canViewContent && navigate(`/courses/${id}/lessons/${lesson.id}`)}
                            className={`px-5 py-4 flex items-center justify-between group ${canViewContent ? 'hover:bg-gray-50 cursor-pointer' : 'opacity-70'}`}
                          >
                            <div className="flex items-center gap-4">
                              <span className="text-gray-400 group-hover:text-green-600 transition">
                                {lesson.content_type === 'video' ? '🎥' : lesson.content_type === 'document' ? '📄' : '📝'}
                              </span>
                              <div>
                                <p className="text-gray-700 font-medium group-hover:text-navy transition">{lesson.title}</p>
                                {hasQuiz && (
                                  <span className="inline-flex items-center gap-1 mt-1 px-2 py-0.5 bg-navy text-white text-[10px] font-bold rounded uppercase tracking-wider">
                                    📋 Examen Final
                                  </span>
                                )}
                              </div>
                            </div>
                            <span className="text-xs text-gray-400 font-medium">{lesson.duration_minutes || 0} min</span>
                          </div>
                        );
                      })}
                    </div>
                  )}
                </div>
              ))}
            </div>
          ) : (
            <p className="text-gray-500 text-center py-8">El contenido del curso se está preparando</p>
          )}
        </div>
      </div>
    </div>
  );
};
