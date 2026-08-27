import { rest } from './api';

export const quizService = {
  // Obtener un quiz por ID (con seguridad)
  getQuizById: async (quizId) => {
    try {
      const { data } = await rest.get(`/quizzes?id=eq.${quizId}&select=*`);
      return data[0] || null;
    } catch (error) {
      throw error.response?.data || error;
    }
  },

  // Obtener el quiz asociado a una lección (si existe)
  getQuizByLesson: async (lessonId) => {
    try {
      const { data } = await rest.get(`/quizzes?lesson_id=eq.${lessonId}&is_active=eq.true&select=*`);
      return data[0] || null;
    } catch (error) {
      return null;
    }
  },

  // Preguntas del quiz SIN la respuesta correcta (para presentarlas al alumno)
  getQuestionsForTaking: async (quizId) => {
    const { data } = await rest.get(
      `/quiz_questions?quiz_id=eq.${quizId}&select=id,quiz_id,question_text,option_a,option_b,option_c,option_d,order_index&order=order_index`
    );
    return data;
  },

  // Preguntas completas (con correct_answer y explanation) para calificar tras enviar
  getQuestionsWithAnswers: async (quizId) => {
    const { data } = await rest.get(`/quiz_questions?quiz_id=eq.${quizId}&select=*&order=order_index`);
    return data;
  },

  // Resultado previo del alumno en este quiz (si ya lo tomó)
  getMyResult: async (quizId) => {
    const userId = localStorage.getItem('userId');
    if (!userId || userId === '0') return null;
    const { data } = await rest.get(`/quiz_results?student_id=eq.${userId}&quiz_id=eq.${quizId}&select=*`);
    return data[0] || null;
  },

  // Enviar respuestas, calificar client-side y guardar resultado
  submitQuiz: async (quiz, answers) => {
    const userId = parseInt(localStorage.getItem('userId'));
    if (!userId) throw { message: 'No autenticado' };

    const questions = await quizService.getQuestionsWithAnswers(quiz.id);
    let correct = 0;
    const gradedAnswers = {};
    questions.forEach((q) => {
      const given = answers[q.id];
      const isCorrect = given === q.correct_answer;
      if (isCorrect) correct += 1;
      gradedAnswers[q.id] = { given, correct: q.correct_answer, is_correct: isCorrect };
    });

    const total = questions.length;
    const score = total > 0 ? Math.round((correct / total) * 10000) / 100 : 0;
    const passed = score >= (quiz.passing_score || 70);

    const payload = {
      student_id: userId,
      quiz_id: quiz.id,
      score,
      total_questions: total,
      correct_answers: correct,
      answers: gradedAnswers,
      completed_at: new Date().toISOString(),
    };

    await rest.post('/quiz_results', payload, {
      headers: { Prefer: 'resolution=merge-duplicates' },
      params: { on_conflict: 'student_id,quiz_id' },
    });

    return { score, total, correct, passed, questions, gradedAnswers };
  },

  // --- Gestión (instructor/admin) ---
  createQuiz: async (quiz) => {
    const { data } = await rest.post('/quizzes', quiz);
    return data[0];
  },
  updateQuiz: async (id, quiz) => {
    await rest.patch(`/quizzes?id=eq.${id}`, quiz);
  },
  deleteQuiz: async (id) => {
    await rest.delete(`/quizzes?id=eq.${id}`);
  },
  createQuestion: async (question) => {
    const { data } = await rest.post('/quiz_questions', question);
    return data[0];
  },
  updateQuestion: async (id, question) => {
    await rest.patch(`/quiz_questions?id=eq.${id}`, question);
  },
  deleteQuestion: async (id) => {
    await rest.delete(`/quiz_questions?id=eq.${id}`);
  },
};
