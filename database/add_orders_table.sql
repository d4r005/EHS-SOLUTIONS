-- ============================================
-- EHS SOLUTIONS - Tabla de órdenes de pago (Stripe)
-- Registra los pagos procesados por Stripe Checkout
-- ============================================

-- Si la tabla ya existe con columnas de MercadoPago, renombramos las columnas
DO $$
BEGIN
  -- Renombrar mercadopago_payment_id a stripe_payment_intent si existe
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'orders' AND column_name = 'mercadopago_payment_id'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'orders' AND column_name = 'stripe_payment_intent'
  ) THEN
    ALTER TABLE public.orders RENAME COLUMN mercadopago_payment_id TO stripe_payment_intent;
  END IF;
END $$;

-- Si la tabla no existe, crearla con columnas de Stripe
CREATE TABLE IF NOT EXISTS orders (
  id SERIAL PRIMARY KEY,
  student_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  course_id INTEGER NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  stripe_payment_intent VARCHAR(200),
  stripe_session_id VARCHAR(200),
  amount DECIMAL(10, 2) NOT NULL,
  currency VARCHAR(10) DEFAULT 'MXN',
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'rejected', 'refunded')),
  payer_email VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(student_id, course_id)
);

-- Agregar stripe_session_id si la tabla ya existía sin esa columna
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS stripe_session_id VARCHAR(200);
ALTER TABLE public.orders ADD COLUMN IF NOT EXISTS stripe_payment_intent VARCHAR(200);

CREATE INDEX IF NOT EXISTS idx_orders_stripe_payment_intent ON orders(stripe_payment_intent);
CREATE INDEX IF NOT EXISTS idx_orders_stripe_session_id ON orders(stripe_session_id);

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "self select orders" ON public.orders;
CREATE POLICY "self select orders" ON public.orders
  FOR SELECT TO authenticated USING (student_id = public.current_user_id());

DROP POLICY IF EXISTS "admin select orders" ON public.orders;
CREATE POLICY "admin select orders" ON public.orders
  FOR SELECT TO authenticated USING (public.current_user_role() = 'admin');
