-- Agrega el estado intermedio 'requested' al flujo de premios:
-- pending (meta alcanzada) -> requested (cliente solicitó el retiro) -> approved/rejected.
-- Debe aplicarse en su propia transacción: Postgres no permite usar un valor de
-- enum recién agregado dentro de la misma transacción que lo crea.
ALTER TYPE public.reward_status ADD VALUE IF NOT EXISTS 'requested' AFTER 'pending';
