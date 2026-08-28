import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { quizService } from '../services/quizService';
import { courseService } from '../services/courseService';

export const QuizPage = () => {
  const { id: courseId, quizId } = useParams();
  const navigate = useNavigate();
  const [quiz, setQuiz] = useState(null);
  const [questions, setQuestions] = useState([]);
  const [answers, setAnswers] = useState({});
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [result, setResult] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchQuiz();
  }, [quizId]);

  const fetchQuiz = async () => {
    try {
      setLoading(true);
      setError(null);

      console.log("Intentando cargar Quiz ID:", quizId);

      const [quizData, existing, qs] = await Promise.all([
        quizService.getQuizById(quizId),
        quizService.getMyResult(quizId).catch(() => null), // No fallar si no hay resultado previo
        quizService.getQuestionsForTaking(quizId)
      ]);

      console.log("Datos recibidos de Supabase:", { quizData, qs });

      if (!quizData) {
        setError(`Examen #${quizId} no encontrado. Verifique que la tabla 'quizzes' tenga permisos de lectura pública (RLS).`);
        return;
      }

      if (!qs || qs.length === 0) {
        setError(`El examen "${quizData.title}" fue encontrado, pero no tiene preguntas vinculadas.`);
        return;
      }

      setQuiz(quizData);
      setQuestions(qs);

      if (existing) {
        setResult({
          score: existing.score,
          total: existing.total_questions,
          correct: existing.correct_answers,
          passed: existing.score >= (quizData.passing_score || 70),
          alreadyTaken: true,
        });
      }
    } catch (err) {
      console.error("Error crítico en QuizPage:", err);
      setError('Error al conectar con la base de datos de exámenes.');
    } finally {
      setLoading(false);
    }
  };

  const handleAnswer = (questionId, option) => {
    setAnswers((prev) => ({ ...prev, [questionId]: option }));
  };

  const handleSubmit = async () => {
    if (Object.keys(answers).length < questions.length) {
      setError('Responde todas las preguntas antes de enviar');
      return;
    }
    try {
      setSubmitting(true);
      setError(null);
      const res = await quizService.submitQuiz(quiz, answers);

      // Si aprobó, marcar la lección como completada automáticamente
      if (res.passed) {
        try {
          await courseService.completeLesson(quiz.lesson_id);
        } catch (err) {
          console.error("Error al marcar lección como completada tras examen:", err);
        }
      }

      setResult(res);
    } catch (err) {
      setError(err.message || 'Error al enviar el examen');
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin text-4xl">⏳</div>
      </div>
    );
  }

  if (!quiz) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <p className="text-xl text-gray-600 mb-4">Examen no encontrado</p>
          <button onClick={() => navigate(`/courses/${courseId}`)} className="px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700">
            Volver al curso
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-3xl mx-auto px-4">
        <button onClick={() => navigate(`/courses/${courseId}`)} className="text-gray-600 hover:text-navy text-sm font-medium mb-4">
          ← Volver al curso
        </button>

        <div className="bg-white rounded-xl shadow-md p-6 mb-6">
          <h1 className="text-2xl font-bold text-navy mb-1">{quiz.title}</h1>
          {quiz.description && <p className="text-gray-600 mb-2">{quiz.description}</p>}
          <p className="text-sm text-gray-500">
            {questions.length} preguntas · Puntaje mínimo para aprobar: {quiz.passing_score || 70}%
          </p>
        </div>

        {result ? (
          <div className="bg-white rounded-xl shadow-md p-8 text-center">
            <div className="text-5xl mb-3">{result.passed ? '🎉' : '📋'}</div>
            <h2 className="text-2xl font-bold text-navy mb-2">
              {result.passed ? '¡Aprobado!' : 'No aprobado todavía'}
            </h2>
            <p className="text-gray-600 mb-4">
              Obtuviste {result.correct} de {result.total} respuestas correctas ({result.score}%)
            </p>
            {result.alreadyTaken && (
              <p className="text-sm text-gray-500 mb-4">Ya habías presentado este examen anteriormente.</p>
            )}

            <div className="flex flex-col sm:flex-row gap-3 justify-center">
              {!result.passed && (
                <button
                  onClick={() => {
                    setResult(null);
                    setAnswers({});
                  }}
                  className="px-6 py-3 bg-navy text-white rounded-lg hover:bg-navy-light font-semibold transition"
                >
                  🔄 Reintentar examen
                </button>
              )}
              <button
                onClick={() => navigate(`/courses/${courseId}`)}
                className="px-6 py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 font-semibold transition"
              >
                Volver al curso
              </button>
            </div>
          </div>
        ) : (
          <div className="space-y-5">
            {questions.map((q, idx) => (
              <div key={q.id} className="bg-white rounded-xl shadow-md p-6">
                <p className="font-semibold text-navy mb-4">
                  {idx + 1}. {q.question_text}
                </p>
                <div className="space-y-2">
                  {['a', 'b', 'c', 'd'].map((opt) => {
                    const text = q[`option_${opt}`];
                    if (!text) return null;
                    const selected = answers[q.id] === opt;
                    return (
                      <button
                        key={opt}
                        onClick={() => handleAnswer(q.id, opt)}
                        className={`w-full text-left px-4 py-3 rounded-lg border transition ${
                          selected ? 'border-green-600 bg-green-50 text-navy font-semibold' : 'border-gray-200 hover:bg-gray-50 text-gray-700'
                        }`}
                      >
                        <span className="uppercase font-bold mr-2">{opt})</span> {text}
                      </button>
                    );
                  })}
                </div>
              </div>
            ))}

            {error && (
              <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm">{error}</div>
            )}

            <button
              onClick={handleSubmit}
              disabled={submitting}
              className="w-full py-3 bg-green-600 text-white rounded-lg hover:bg-green-700 font-semibold transition disabled:opacity-50"
            >
              {submitting ? 'Enviando...' : 'Enviar Examen'}
            </button>
          </div>
        )}
      </div>
    </div>
  );
};
