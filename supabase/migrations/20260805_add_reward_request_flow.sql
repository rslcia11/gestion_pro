-- Flujo "Solicitar premio": el cliente pasa su premio de 'pending' a 'requested',
-- lo que dispara la notificación real al dueño del negocio (ver
-- supabase/functions/push-notification/index.ts, handleRewards). Solo puede
-- solicitar el dueño actual del premio, y solo si todavía está en 'pending'.
--
-- Requiere que 20260805_add_requested_reward_status.sql ya haya sido aplicada
-- (y su transacción confirmada) antes de correr este archivo.
BEGIN;

CREATE OR REPLACE FUNCTION public.request_reward(p_reward_id uuid)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $function$
DECLARE
  v_user_id uuid;
  v_status public.reward_status;
BEGIN
  SELECT user_id, status
  INTO v_user_id, v_status
  FROM public.rewards
  WHERE id = p_reward_id
  FOR UPDATE;

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'REWARD_NOT_FOUND';
  END IF;

  IF v_user_id != auth.uid() THEN
    RAISE EXCEPTION 'REWARD_NOT_OWNED';
  END IF;

  IF v_status != 'pending'::public.reward_status THEN
    RAISE EXCEPTION 'REWARD_NOT_PENDING';
  END IF;

  UPDATE public.rewards
  SET status = 'requested'::public.reward_status
  WHERE id = p_reward_id;

  RETURN true;
END;
$function$;

-- Ahora se puede transferir un premio en 'pending' (antes de solicitarlo) además
-- de 'approved' (como ya funcionaba). Una vez solicitado ('requested') ya no se
-- puede transferir: el dueño del negocio ya fue notificado y puede estar
-- preparándolo.
CREATE OR REPLACE FUNCTION public.transfer_reward(
  p_reward_id UUID,
  p_user_id UUID,
  p_loyalty_card_id UUID
) RETURNS BOOLEAN AS $transfer_reward$
DECLARE
  v_from_user_id UUID;
  v_business_id UUID;
  v_status public.reward_status;
  v_recipient_role public.user_role;
  v_card_user_id UUID;
  v_card_business_id UUID;
BEGIN
  SELECT user_id, business_id, status
  INTO v_from_user_id, v_business_id, v_status
  FROM public.rewards
  WHERE id = p_reward_id
  FOR UPDATE;

  IF v_from_user_id IS NULL THEN
    RAISE EXCEPTION 'REWARD_NOT_FOUND';
  END IF;

  IF v_from_user_id != auth.uid() THEN
    RAISE EXCEPTION 'REWARD_NOT_OWNED';
  END IF;

  IF v_status NOT IN ('pending'::public.reward_status, 'approved'::public.reward_status) THEN
    RAISE EXCEPTION 'REWARD_NOT_TRANSFERABLE';
  END IF;

  IF p_user_id = v_from_user_id THEN
    RAISE EXCEPTION 'CANNOT_TRANSFER_TO_SELF';
  END IF;

  SELECT role
  INTO v_recipient_role
  FROM public.profiles
  WHERE id = p_user_id;

  IF v_recipient_role IS NULL THEN
    RAISE EXCEPTION 'RECIPIENT_NOT_FOUND';
  END IF;

  IF v_recipient_role != 'client'::public.user_role THEN
    RAISE EXCEPTION 'RECIPIENT_NOT_CLIENT';
  END IF;

  SELECT user_id, business_id
  INTO v_card_user_id, v_card_business_id
  FROM public.loyalty_cards
  WHERE id = p_loyalty_card_id;

  IF v_card_user_id IS NULL THEN
    RAISE EXCEPTION 'LOYALTY_CARD_NOT_FOUND';
  END IF;

  IF v_card_user_id != p_user_id OR v_card_business_id != v_business_id THEN
    RAISE EXCEPTION 'LOYALTY_CARD_MISMATCH';
  END IF;

  UPDATE public.rewards
  SET user_id = p_user_id,
      loyalty_card_id = p_loyalty_card_id
  WHERE id = p_reward_id;

  INSERT INTO public.reward_transfer_history (
    reward_id,
    from_user_id,
    to_user_id,
    business_id,
    transferred_at
  ) VALUES (
    p_reward_id,
    v_from_user_id,
    p_user_id,
    v_business_id,
    NOW()
  );

  RETURN TRUE;
END;
$transfer_reward$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

COMMIT;
