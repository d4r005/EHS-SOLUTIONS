import { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { courseService } from '../services/courseService';

export const DashboardPage = () => {
  const { user, isAuthenticated } = useAuth();
  const [courses, setCourses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState({
    totalCourses: 0,
    completedCourses: 0,
    inProgressCourses: 0,
    hoursLearned: 0,
  });

  useEffect(() => {
    if (isAuthenticated && user) {
      fetchMyCourses();
    }
  }, [isAuthenticated, user]);

  const fetchMyCourses = async () => {
    try {
      setLoading(true);
      const data = await courseService.getMyCourses();
      setCourses(data.enrollments || []);

      // Calcular estadísticas
      const completed = data.enrollments?.filter(c => c.progress_percentage === 100).length || 0;
      const inProgress = data.enrollments?.filter(c => c.progress_percentage < 100).length || 0;

      setStats({
        totalCourses: data.enrollments?.length || 0,
        completedCourses: completed,
        inProgressCourses: inProgress,
        hoursLearned: Math.floor(Math.random() * 50) + 10, // Demo
      });
    } catch (error) {
      console.error('Error fetching courses:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-7xl mx-auto px-4">
        {/* Welcome Section */}
        <div className="mb-8">
          <h1 className="text-4xl font-bold text-navy mb-2">
            Bienvenido, {user?.first_name}! 👋
          </h1>
          <p className="text-gray-600">Aquí está tu progreso de aprendizaje</p>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
          <StatCard
            icon="📚"
            label="Cursos Totales"
            value={stats.totalCourses}
            color="blue"
          />
          <StatCard
            icon="✅"
            label="Completados"
            value={stats.completedCourses}
            color="green"
          />
          <StatCard
            icon="🔄"
            label="En Progreso"
            value={stats.inProgressCourses}
            color="yellow"
          />
          <StatCard
            icon="⏱️"
            label="Horas Estudiadas"
            value={stats.hoursLearned}
            color="purple"
          />
        </div>

        {/* Courses Section */}
        <div className="bg-white rounded-xl shadow-md p-6 mb-8">
          <h2 className="text-2xl font-bold text-navy mb-6">Mis Cursos</h2>

          {loading ? (
            <div className="text-center py-12">
              <div className="animate-spin text-4xl">⏳</div>
              <p className="text-gray-600 mt-2">Cargando cursos...</p>
            </div>
          ) : courses.length > 0 ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {courses.map((enrollment) => (
                <CourseCard key={enrollment.id} enrollment={enrollment} />
              ))}
            </div>
          ) : (
            <div className="text-center py-12">
              <p className="text-gray-600 mb-4">No estás inscrito en ningún curso todavía</p>
              <a
                href="/courses"
                className="inline-block px-6 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 transition"
              >
                Explorar Cursos
              </a>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

const StatCard = ({ icon, label, value, color }) => {
  const colorMap = {
    blue: 'bg-blue-50 border-blue-200',
    green: 'bg-green-50 border-green-200',
    yellow: 'bg-yellow-50 border-yellow-200',
    purple: 'bg-purple-50 border-purple-200',
  };

  return (
    <div className={`${colorMap[color]} border rounded-lg p-4`}>
      <div className="text-4xl mb-2">{icon}</div>
      <p className="text-sm text-gray-600">{label}</p>
      <p className="text-3xl font-bold text-navy">{value}</p>
    </div>
  );
};

const CourseCard = ({ enrollment }) => {
  const navigate = useNavigate();
  const { user } = useAuth();

  // Usar los datos del curso que vienen del JOIN en courseService.getMyCourses
  const courseTitle = enrollment.title || enrollment.course?.title || `Curso #${enrollment.course_id}`;
  const thumbnail = enrollment.thumbnail_url || enrollment.course?.thumbnail_url;
  const category = enrollment.category || enrollment.course?.category || 'Capacitación';

  const isAdmin = ['admin', 'instructor'].includes(user?.role);

  return (
    <div className="bg-white border border-gray-200 rounded-lg overflow-hidden hover:shadow-lg transition">
      {/* Thumbnail */}
      <div className="h-32 bg-gradient-to-br from-navy to-navy-deep relative">
        {thumbnail ? (
          <img src={thumbnail} alt={courseTitle} className="w-full h-full object-cover" />
        ) : (
          <div className="absolute inset-0 flex items-center justify-center">
            <span className="text-4xl">📚</span>
          </div>
        )}
      </div>

      {/* Content */}
      <div className="p-4">
        <h3 className="font-bold text-navy mb-1 line-clamp-1" title={courseTitle}>
          {courseTitle}
        </h3>
        <p className="text-xs text-gray-500 uppercase font-bold mb-4">
          {category}
        </p>

        {/* Progress Bar */}
        <div className="mb-5">
          <div className="flex justify-between items-center mb-1">
            <span className="text-xs font-semibold text-navy">
              {isAdmin ? 'Estado: Modo Revisión' : 'Tu progreso'}
            </span>
            {!isAdmin && <span className="text-xs text-gray-600">{Math.round(enrollment.progress_percentage)}%</span>}
          </div>
          <div className="w-full h-2.5 bg-gray-100 rounded-full overflow-hidden">
            <div
              className={`h-full ${isAdmin ? 'bg-navy' : 'bg-green-600'} transition-all duration-1000`}
              style={{ width: `${isAdmin ? 100 : enrollment.progress_percentage}%` }}
            ></div>
          </div>
        </div>

        {/* Action */}
        <Link
          to={`/courses/${enrollment.course_id}`}
          className={`block w-full py-3 ${isAdmin ? 'bg-navy hover:bg-navy-light' : 'bg-green-600 hover:bg-green-700'} text-white rounded-lg transition text-sm font-bold shadow-sm text-center`}
        >
          {isAdmin ? '🛡️ Revisar Curso' : 'Continuar Aprendiendo'}
        </Link>
      </div>
    </div>
  );
};
