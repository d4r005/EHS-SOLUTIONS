-- ============================================
-- EHS SOLUTIONS - Tabla de órdenes de pago
-- Registra los pagos procesados por MercadoPago
-- ============================================

CREATE TABLE IF NOT EXISTS orders (
  id SERIAL PRIMARY KEY,
  student_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  course_id INTEGER NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  mercadopago_payment_id VARCHAR(100),
  amount DECIMAL(10, 2) NOT NULL,
  currency VARCHAR(10) DEFAULT 'MXN',
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'rejected', 'refunded')),
  payer_email VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(student_id, course_id)
);

-- Índice para buscar por payment_id de MercadoPago
CREATE INDEX IF NOT EXISTS idx_orders_mercadopago_payment_id ON orders(mercadopago_payment_id);

-- Políticas RLS para orders
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- El estudiante puede ver sus propias órdenes
CREATE POLICY IF NOT EXISTS "self select orders" ON public.orders
  FOR SELECT TO authenticated
  USING (student_id = public.current_user_id());

-- Admin puede ver todas las órdenes
CREATE POLICY IF NOT EXISTS "admin select orders" ON public.orders
  FOR SELECT TO authenticated
  USING (public.current_user_role() = 'admin');

-- Solo el servicio (service role) puede insertar desde el webhook
-- (el webhook usa SUPABASE_SERVICE_ROLE_KEY que bypassa RLS)
