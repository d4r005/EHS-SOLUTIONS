// ============================================
// EHS Solutions - Supabase Edge Function
// API principal: maneja auth, cursos, módulos, lecciones e inscripciones
// ============================================

import { createClient } from "npm:@supabase/supabase-js@2";
import { hash as bcryptHash, compare as bcryptCompare } from "npm:bcryptjs@2.4.3";
import { SignJWT, jwtVerify } from "npm:jose@5.9.6";

// --- Config ---
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const JWT_SECRET = new TextEncoder().encode(
  Deno.env.get("JWT_SECRET") || Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
);
const JWT_EXPIRE = "7d";

// --- Supabase client (service role, bypassa RLS) ---
const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY, {
  auth: { persistSession: false },
});

// --- CORS ---
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, PATCH, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

// --- Helpers ---
const json = (data: unknown, status = 200) =>
  new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json", ...corsHeaders },
  });

// --- JWT ---
async function signToken(payload: Record<string, unknown>) {
  return await new SignJWT(payload)
    .setProtectedHeader({ alg: "HS256" })
    .setExpirationTime(JWT_EXPIRE)
    .sign(JWT_SECRET);
}

async function verifyToken(token: string) {
  try {
    const { payload } = await jwtVerify(token, JWT_SECRET);
    return payload as { id: number; email: string; role: string };
  } catch {
    return null;
  }
}

async function getUser(req: Request) {
  const auth = req.headers.get("authorization");
  if (!auth) return null;
  const token = auth.replace("Bearer ", "");
  return await verifyToken(token);
}

// --- Router ---
function matchRoute(method: string, path: string, pattern: string) {
  // pattern like "GET /courses/:id/progress"
  const [pMethod, pPath] = pattern.split(" ");
  if (method !== pMethod) return null;
  const pParts = pPath.split("/");
  const rParts = path.split("/");
  if (pParts.length !== rParts.length) return null;
  const params: Record<string, string> = {};
  for (let i = 0; i < pParts.length; i++) {
    if (pParts[i].startsWith(":")) {
      params[pParts[i].slice(1)] = rParts[i];
    } else if (pParts[i] !== rParts[i]) {
      return null;
    }
  }
  return params;
}

// ============================================
// HANDLERS
// ============================================

// --- AUTH ---
async function handleAuthRegister(req: Request) {
  const { first_name, last_name, email, password, role = "student" } = await req.json();
  if (!first_name || !last_name || !email || !password)
    return json({ success: false, message: "Todos los campos son requeridos" }, 400);

  const { data: existing } = await supabase
    .from("users").select("id").eq("email", email).maybeSingle();
  if (existing)
    return json({ success: false, message: "El email ya está registrado" }, 409);

  const hashedPassword = bcryptHash(password, 10);
  const { data: user, error } = await supabase
    .from("users").insert({
      first_name, last_name, email, password: hashedPassword, role, is_active: true,
    }).select("id, first_name, last_name, email, role").single();
  if (error) return json({ success: false, message: "Error al registrar" }, 500);

  const token = await signToken({ id: user.id, email: user.email, role: user.role });
  return json({ success: true, message: "Registrado exitosamente", token, user }, 201);
}

async function handleAuthLogin(req: Request) {
  const { email, password } = await req.json();
  if (!email || !password)
    return json({ success: false, message: "Email y contraseña requeridos" }, 400);

  const { data: user } = await supabase
    .from("users").select("*").eq("email", email).maybeSingle();
  if (!user)
    return json({ success: false, message: "Email o contraseña incorrectos" }, 401);

  const valid = bcryptCompare(password, user.password);
  if (!valid)
    return json({ success: false, message: "Email o contraseña incorrectos" }, 401);

  const token = await signToken({ id: user.id, email: user.email, role: user.role });
  return json({
    success: true, token,
    user: { id: user.id, first_name: user.first_name, last_name: user.last_name, email: user.email, role: user.role },
  });
}

async function handleAuthProfile(user: { id: number }) {
  const { data } = await supabase
    .from("users").select("id, first_name, last_name, email, role, bio, avatar_url, phone, created_at")
    .eq("id", user.id).maybeSingle();
  if (!data) return json({ success: false, message: "Usuario no encontrado" }, 404);
  return json({ success: true, user: data });
}

// --- COURSES ---
async function handleGetCourses(url: URL) {
  const category = url.searchParams.get("category");
  const difficulty = url.searchParams.get("difficulty_level");
  const search = url.searchParams.get("search");

  let query = supabase
    .from("courses").select(`
      *,
      instructor:users!instructor_id(first_name, last_name),
      modules(id)
    `).eq("is_published", true);

  if (category) query = query.eq("category", category);
  if (difficulty) query = query.eq("difficulty_level", difficulty);
  if (search) query = query.or(`title.ilike.%${search}%,description.ilike.%${search}%`);

  const { data: courses, error } = await query.order("created_at", { ascending: false });
  if (error) return json({ success: false, message: "Error al obtener cursos" }, 500);

  // Contar lecciones por curso
  const result = await Promise.all((courses || []).map(async (c: any) => {
    const { count: lessonCount } = await supabase
      .from("lessons").select("id", { count: "exact", head: true })
      .eq("module.course_id", c.id);
    return {
      ...c,
      instructor_first_name: c.instructor?.first_name,
      instructor_last_name: c.instructor?.last_name,
      module_count: c.modules?.length || 0,
      lesson_count: lessonCount || 0,
      instructor: undefined,
      modules: undefined,
    };
  }));

  return json({ success: true, courses: result });
}

async function handleGetCourseById(id: string, user: { id: number } | null) {
  const { data: course, error } = await supabase
    .from("courses").select(`
      *,
      instructor:users!instructor_id(first_name, last_name)
    `).eq("id", id).maybeSingle();

  if (!course) return json({ success: false, message: "Curso no encontrado" }, 404);

  const { data: modules } = await supabase
    .from("modules").select(`
      *,
      lessons(*)
    `).eq("course_id", id).order("order_index");

  // Ordenar lecciones dentro de cada módulo
  const modulesWithSortedLessons = (modules || []).map((m: any) => ({
    ...m,
    lessons: (m.lessons || []).sort((a: any, b: any) => a.order_index - b.order_index),
  }));

  let enrollment = null;
  if (user) {
    const { data: enr } = await supabase
      .from("enrollments").select("*")
      .eq("student_id", user.id).eq("course_id", id).maybeSingle();
    enrollment = enr;
  }

  return json({
    success: true,
    course: {
      ...course,
      instructor_first_name: course.instructor?.first_name,
      instructor_last_name: course.instructor?.last_name,
      module_count: modulesWithSortedLessons.length,
      lesson_count: modulesWithSortedLessons.reduce((sum: number, m: any) => sum + (m.lessons?.length || 0), 0),
      modules: modulesWithSortedLessons,
      enrollment,
    },
  });
}

async function handleCreateCourse(req: Request, user: { id: number; role: string }) {
  const body = await req.json();
  if (!body.title) return json({ success: false, message: "El título es requerido" }, 400);

  const { data: course, error } = await supabase.from("courses").insert({
    title: body.title,
    description: body.description,
    short_description: body.short_description,
    instructor_id: user.id,
    category: body.category,
    thumbnail_url: body.thumbnail_url,
    price: body.price || 0,
    duration_hours: body.duration_hours,
    difficulty_level: body.difficulty_level,
    is_published: body.is_published || false,
  }).select("*").single();

  if (error) return json({ success: false, message: "Error al crear curso" }, 500);
  return json({ success: true, course }, 201);
}

async function handleUpdateCourse(id: string, req: Request, user: { id: number; role: string }) {
  const body = await req.json();

  if (user.role === "instructor") {
    const { data: owner } = await supabase
      .from("courses").select("instructor_id").eq("id", id).maybeSingle();
    if (!owner) return json({ success: false, message: "Curso no encontrado" }, 404);
    if (owner.instructor_id !== user.id) return json({ success: false, message: "No tienes permiso" }, 403);
  }

  const { data: course, error } = await supabase.from("courses").update({
    title: body.title,
    description: body.description,
    short_description: body.short_description,
    category: body.category,
    thumbnail_url: body.thumbnail_url,
    price: body.price,
    duration_hours: body.duration_hours,
    difficulty_level: body.difficulty_level,
    is_published: body.is_published,
  }).eq("id", id).select("*").maybeSingle();

  if (!course) return json({ success: false, message: "Curso no encontrado" }, 404);
  if (error) return json({ success: false, message: "Error al actualizar" }, 500);
  return json({ success: true, course });
}

async function handleDeleteCourse(id: string, user: { id: number; role: string }) {
  if (user.role === "instructor") {
    const { data: owner } = await supabase
      .from("courses").select("instructor_id").eq("id", id).maybeSingle();
    if (!owner) return json({ success: false, message: "Curso no encontrado" }, 404);
    if (owner.instructor_id !== user.id) return json({ success: false, message: "No tienes permiso" }, 403);
  }

  const { error } = await supabase.from("courses").delete().eq("id", id);
  if (error) return json({ success: false, message: "Error al eliminar" }, 500);
  return json({ success: true, message: "Curso eliminado" });
}

async function handleCourseProgress(courseId: string, user: { id: number }) {
  const { data: enrollment } = await supabase
    .from("enrollments").select("*")
    .eq("student_id", user.id).eq("course_id", courseId).maybeSingle();
  if (!enrollment) return json({ success: false, message: "No estás inscrito" }, 404);

  // Contar lecciones totales del curso
  const { data: modules } = await supabase
    .from("modules").select("id").eq("course_id", courseId);
  const moduleIds = (modules || []).map((m: any) => m.id);

  const { count: total } = await supabase
    .from("lessons").select("id", { count: "exact", head: true })
    .in("module_id", moduleIds);

  const { count: completed } = await supabase
    .from("lesson_progress").select("id", { count: "exact", head: true })
    .eq("student_id", user.id).eq("is_completed", true)
    .in("lesson_id", (await supabase.from("lessons").select("id").in("module_id", moduleIds)).data?.map((l: any) => l.id) || []);

  const pct = total && total > 0 ? Math.round((completed! / total) * 100) : 0;

  return json({
    success: true,
    progress: { enrollment, total_lessons: total, completed_lessons: completed, percentage: pct },
  });
}

// --- MODULES ---
async function handleGetModules(url: URL) {
  const courseId = url.searchParams.get("course_id");

  let query = supabase.from("modules").select("*, lessons(*)");
  if (courseId) query = query.eq("course_id", courseId);
  query = query.order("order_index");

  const { data: modules, error } = await query;
  if (error) return json({ success: false, message: "Error al obtener módulos" }, 500);

  const sorted = (modules || []).map((m: any) => ({
    ...m,
    lessons: (m.lessons || []).sort((a: any, b: any) => a.order_index - b.order_index),
  }));

  return json({ success: true, modules: sorted });
}

async function handleCreateModule(req: Request) {
  const { course_id, title, description, order_index } = await req.json();
  if (!course_id || !title) return json({ success: false, message: "course_id y title requeridos" }, 400);

  const { data: module, error } = await supabase.from("modules").insert({
    course_id, title, description, order_index: order_index || 0,
  }).select("*").single();
  if (error) return json({ success: false, message: "Error al crear módulo" }, 500);
  return json({ success: true, module }, 201);
}

async function handleUpdateModule(id: string, req: Request) {
  const body = await req.json();
  const updateData: Record<string, unknown> = {};
  if (body.title !== undefined) updateData.title = body.title;
  if (body.description !== undefined) updateData.description = body.description;
  if (body.order_index !== undefined) updateData.order_index = body.order_index;

  const { data: module, error } = await supabase.from("modules")
    .update(updateData).eq("id", id).select("*").maybeSingle();
  if (!module) return json({ success: false, message: "Módulo no encontrado" }, 404);
  if (error) return json({ success: false, message: "Error al actualizar" }, 500);
  return json({ success: true, module });
}

async function handleDeleteModule(id: string) {
  const { error } = await supabase.from("modules").delete().eq("id", id);
  if (error) return json({ success: false, message: "Error al eliminar" }, 500);
  return json({ success: true, message: "Módulo eliminado" });
}

// --- LESSONS ---
async function handleGetLessons(url: URL) {
  const moduleId = url.searchParams.get("module_id");
  if (!moduleId) return json({ success: false, message: "module_id requerido" }, 400);

  const { data: lessons, error } = await supabase
    .from("lessons").select("*").eq("module_id", moduleId).order("order_index");
  if (error) return json({ success: false, message: "Error al obtener lecciones" }, 500);
  return json({ success: true, lessons });
}

async function handleGetLessonById(id: string, user: { id: number } | null) {
  const { data: lesson } = await supabase.from("lessons").select("*").eq("id", id).maybeSingle();
  if (!lesson) return json({ success: false, message: "Lección no encontrada" }, 404);

  let progress = null;
  if (user) {
    const { data: p } = await supabase
      .from("lesson_progress").select("*")
      .eq("student_id", user.id).eq("lesson_id", id).maybeSingle();
    progress = p;
  }
  return json({ success: true, lesson, progress });
}

async function handleCreateLesson(req: Request) {
  const body = await req.json();
  if (!body.module_id || !body.title) return json({ success: false, message: "module_id y title requeridos" }, 400);

  const { data: lesson, error } = await supabase.from("lessons").insert({
    module_id: body.module_id, title: body.title, description: body.description,
    content_type: body.content_type || "text", content_url: body.content_url,
    video_url: body.video_url, document_url: body.document_url,
    duration_minutes: body.duration_minutes, order_index: body.order_index || 0,
    is_required: body.is_required !== false,
  }).select("*").single();
  if (error) return json({ success: false, message: "Error al crear lección" }, 500);
  return json({ success: true, lesson }, 201);
}

async function handleUpdateLesson(id: string, req: Request) {
  const body = await req.json();
  const updateData: Record<string, unknown> = {};
  for (const key of ["title", "description", "content_type", "content_url", "video_url", "document_url", "duration_minutes", "order_index", "is_required"]) {
    if (body[key] !== undefined) updateData[key] = body[key];
  }

  const { data: lesson, error } = await supabase.from("lessons")
    .update(updateData).eq("id", id).select("*").maybeSingle();
  if (!lesson) return json({ success: false, message: "Lección no encontrada" }, 404);
  if (error) return json({ success: false, message: "Error al actualizar" }, 500);
  return json({ success: true, lesson });
}

async function handleDeleteLesson(id: string) {
  const { error } = await supabase.from("lessons").delete().eq("id", id);
  if (error) return json({ success: false, message: "Error al eliminar" }, 500);
  return json({ success: true, message: "Lección eliminada" });
}

async function handleCompleteLesson(id: string, user: { id: number }) {
  const { data: lesson } = await supabase.from("lessons").select("*").eq("id", id).maybeSingle();
  if (!lesson) return json({ success: false, message: "Lección no encontrada" }, 404);

  // Upsert lesson_progress
  const { data: progress, error: progressErr } = await supabase
    .from("lesson_progress").upsert({
      student_id: user.id, lesson_id: id, is_completed: true,
      completion_date: new Date().toISOString(), time_spent_minutes: 0,
    }, { onConflict: "student_id,lesson_id" }).select("*").single();
  if (progressErr) return json({ success: false, message: "Error al marcar lección" }, 500);

  // Actualizar progreso de inscripción
  const { data: moduleData } = await supabase
    .from("modules").select("course_id").eq("id", lesson.module_id).maybeSingle();
  if (moduleData) {
    const courseId = moduleData.course_id;
    const { data: modules } = await supabase.from("modules").select("id").eq("course_id", courseId);
    const moduleIds = (modules || []).map((m: any) => m.id);

    const { data: allLessons } = await supabase.from("lessons").select("id").in("module_id", moduleIds);
    const lessonIds = (allLessons || []).map((l: any) => l.id);

    const { count: total } = await supabase.from("lessons").select("id", { count: "exact", head: true }).in("module_id", moduleIds);
    const { count: completed } = await supabase.from("lesson_progress").select("id", { count: "exact", head: true })
      .eq("student_id", user.id).eq("is_completed", true).in("lesson_id", lessonIds);

    const pct = total && total > 0 ? Math.round((completed! / total) * 10000) / 100 : 0;
    const status = pct === 100 ? "completed" : "in_progress";

    await supabase.from("enrollments").update({
      progress_percentage: pct, status,
      completion_date: pct === 100 ? new Date().toISOString() : null,
    }).eq("student_id", user.id).eq("course_id", courseId);
  }

  return json({ success: true, message: "Lección completada", progress });
}

// --- ENROLLMENTS ---
async function handleEnroll(req: Request, user: { id: number }) {
  const { course_id } = await req.json();
  if (!course_id) return json({ success: false, message: "course_id requerido" }, 400);

  const { data: course } = await supabase
    .from("courses").select("id, is_published").eq("id", course_id).eq("is_published", true).maybeSingle();
  if (!course) return json({ success: false, message: "Curso no encontrado" }, 404);

  const { data: existing } = await supabase
    .from("enrollments").select("id")
    .eq("student_id", user.id).eq("course_id", course_id).maybeSingle();
  if (existing) return json({ success: false, message: "Ya estás inscrito" }, 409);

  const { data: enrollment, error } = await supabase.from("enrollments").insert({
    student_id: user.id, course_id, status: "enrolled", progress_percentage: 0,
  }).select("*").single();
  if (error) return json({ success: false, message: "Error al inscribirse" }, 500);
  return json({ success: true, message: "Inscripción exitosa", enrollment }, 201);
}

async function handleGetEnrollments(user: { id: number }) {
  const { data: enrollments, error } = await supabase
    .from("enrollments").select(`
      *,
      course:courses(id, title, short_description, thumbnail_url, category, difficulty_level, duration_hours),
      instructor:courses!inner(instructor:users!instructor_id(first_name, last_name))
    `).eq("student_id", user.id).order("enrollment_date", { ascending: false });

  if (error) return json({ success: false, message: "Error al obtener inscripciones" }, 500);

  const result = (enrollments || []).map((e: any) => ({
    ...e,
    title: e.course?.title,
    short_description: e.course?.short_description,
    thumbnail_url: e.course?.thumbnail_url,
    category: e.course?.category,
    difficulty_level: e.course?.difficulty_level,
    duration_hours: e.course?.duration_hours,
    instructor_first_name: e.instructor?.[0]?.instructor?.first_name,
    instructor_last_name: e.instructor?.[0]?.instructor?.last_name,
  }));

  return json({ success: true, enrollments: result });
}

async function handleGetEnrollment(id: string, user: { id: number }) {
  const { data: enrollment } = await supabase
    .from("enrollments").select(`
      *,
      course:courses(title, description, short_description),
      instructor:courses!inner(instructor:users!instructor_id(first_name, last_name))
    `).eq("id", id).eq("student_id", user.id).maybeSingle();
  if (!enrollment) return json({ success: false, message: "Inscripción no encontrada" }, 404);
  return json({ success: true, enrollment });
}

// ============================================
// MAIN ROUTER
// ============================================
Deno.serve(async (req: Request) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const url = new URL(req.url);
  // Extraer path después de /functions/v1/api
  const fullPath = url.pathname;
  const apiPrefix = "/functions/v1/api";
  let path = fullPath.startsWith(apiPrefix) ? fullPath.slice(apiPrefix.length) : fullPath;
  path = path.replace(/^\/+/, ""); // quitar slashes iniciales
  if (!path) path = "";

  // Health check
  if (path === "health" || path === "") {
    return json({ success: true, message: "EHS Solutions API en línea", timestamp: new Date().toISOString() });
  }

  try {
    // --- Rutas públicas ---
    let params: Record<string, string> | null;

    // AUTH
    if ((params = matchRoute(req.method, path, "POST auth/register"))) return await handleAuthRegister(req);
    if ((params = matchRoute(req.method, path, "POST auth/login"))) return await handleAuthLogin(req);

    // COURSES (público: listar y ver)
    if ((params = matchRoute(req.method, path, "GET courses"))) return await handleGetCourses(url);
    if ((params = matchRoute(req.method, path, "GET courses/:id"))) return await handleGetCourseById(params.id, await getUser(req));

    // MODULES (público: listar)
    if ((params = matchRoute(req.method, path, "GET modules"))) return await handleGetModules(url);

    // LESSONS (público: listar y ver)
    if ((params = matchRoute(req.method, path, "GET lessons"))) return await handleGetLessons(url);
    if ((params = matchRoute(req.method, path, "GET lessons/:id"))) return await handleGetLessonById(params.id, await getUser(req));

    // --- Rutas que requieren auth ---
    const user = await getUser(req);

    if ((params = matchRoute(req.method, path, "GET auth/profile"))) {
      if (!user) return json({ success: false, message: "No autorizado" }, 401);
      return await handleAuthProfile(user);
    }

    if ((params = matchRoute(req.method, path, "POST courses"))) {
      if (!user || (user.role !== "instructor" && user.role !== "admin")) return json({ success: false, message: "No autorizado" }, 403);
      return await handleCreateCourse(req, user);
    }
    if ((params = matchRoute(req.method, path, "PUT courses/:id"))) {
      if (!user || (user.role !== "instructor" && user.role !== "admin")) return json({ success: false, message: "No autorizado" }, 403);
      return await handleUpdateCourse(params.id, req, user);
    }
    if ((params = matchRoute(req.method, path, "DELETE courses/:id"))) {
      if (!user || (user.role !== "instructor" && user.role !== "admin")) return json({ success: false, message: "No autorizado" }, 403);
      return await handleDeleteCourse(params.id, user);
    }
    if ((params = matchRoute(req.method, path, "GET courses/:id/progress"))) {
      if (!user) return json({ success: false, message: "No autorizado" }, 401);
      return await handleCourseProgress(params.id, user);
    }

    // MODULES (auth)
    if ((params = matchRoute(req.method, path, "POST modules"))) {
      if (!user) return json({ success: false, message: "No autorizado" }, 401);
      return await handleCreateModule(req);
    }
    if ((params = matchRoute(req.method, path, "PUT modules/:id"))) {
      if (!user) return json({ success: false, message: "No autorizado" }, 401);
      return await handleUpdateModule(params.id, req);
    }
    if ((params = matchRoute(req.method, path, "DELETE modules/:id"))) {
      if (!user) return json({ success: false, message: "No autorizado" }, 401);
      return await handleDeleteModule(params.id);
    }

    // LESSONS (auth)
    if ((params = matchRoute(req.method, path, "POST lessons"))) {
      if (!user) return json({ success: false, message: "No autorizado" }, 401);
      return await handleCreateLesson(req);
    }
    if ((params = matchRoute(req.method, path, "PUT lessons/:id"))) {
      if (!user) return json({ success: false, message: "No autorizado" }, 401);
      return await handleUpdateLesson(params.id, req);
    }
    if ((params = matchRoute(req.method, path, "DELETE lessons/:id"))) {
      if (!user) return json({ success: false, message: "No autorizado" }, 401);
      return await handleDeleteLesson(params.id);
    }
    if ((params = matchRoute(req.method, path, "PATCH lessons/:id/complete"))) {
      if (!user) return json({ success: false, message: "No autorizado" }, 401);
      return await handleCompleteLesson(params.id, user);
    }

    // ENROLLMENTS (auth)
    if ((params = matchRoute(req.method, path, "POST enrollments"))) {
      if (!user) return json({ success: false, message: "No autorizado" }, 401);
      return await handleEnroll(req, user);
    }
    if ((params = matchRoute(req.method, path, "GET enrollments"))) {
      if (!user) return json({ success: false, message: "No autorizado" }, 401);
      return await handleGetEnrollments(user);
    }
    if ((params = matchRoute(req.method, path, "GET enrollments/:id"))) {
      if (!user) return json({ success: false, message: "No autorizado" }, 401);
      return await handleGetEnrollment(params.id, user);
    }

    return json({ success: false, message: "Endpoint no encontrado" }, 404);
  } catch (err) {
    console.error("API Error:", err);
    return json({ success: false, message: "Error interno del servidor" }, 500);
  }
});
