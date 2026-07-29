# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Users

Three roles share one app, treated as equally important surfaces (no role is secondary):

- **Client**: a consumer of local businesses (cafés, shops) who wants their loyalty stamps digitized. Scans a QR at checkout to accumulate points, views their cards and pending/claimed rewards, edits their profile.
- **Business**: the owner/staff of a local shop who wants to run a rewards program without a POS or expensive system. Generates QR codes, approves scans, awards manual points, views métricas for their own local(es).
- **Admin**: operates the platform itself. Global dashboard, CSV export of all users/businesses, activates/deactivates locales.

## Product Purpose

Donde Siempre digitizes the physical cardboard loyalty/stamp card that local businesses already hand out. Clients accumulate points by scanning a QR code at the business; once a business's configured point threshold is reached, a reward is generated automatically. Success means a client never needs a paper card, and a business can run a points program without adopting new hardware or a paid system.

## Positioning

The mechanism a competitor can't copy honestly: it replaces an artifact the business and client already use and understand (the stamp card) instead of introducing a new loyalty concept, app-specific currency, or gamification layer. Frictionless digitization of an existing local-commerce ritual is the core claim, not a novel rewards mechanic.

## Operating Context

- **Scan-to-points loop**: client scans a business's QR; a cooldown (default 4h) between successful scans per client/business pair prevents abuse; the business can alternatively award "manual points" from their dashboard (recorded as an approved-scan for audit trail).
- **Reward cycle**: each business sets its own `points_required`. Reaching it auto-creates a pending reward, resets points to 0, and increments the client's claimed-rewards history. A client with a pending reward is locked from earning further points at that business until the reward is marked redeemed.
- **Push notifications**: Firebase Cloud Messaging notifies a client when a reward is generated or a point is approved.
- **Admin oversight**: CSV export of users/businesses and the ability to activate/deactivate a business's local(es).
- Full historical rule detail lives in `docs/business_rules.md` (documents the original Supabase implementation of these rules).

## Capabilities and Constraints

- **Current build state**: the Flutter app (`/app`) is front-end only. Every `repository`/`provider` in `lib/features/*/data` and `lib/features/*/providers` is stubbed — reads return empty values immediately, writes are no-ops — so the UI compiles and navigates through its designed empty states without any backend. This is deliberate: screens and providers are decoupled behind these interfaces so a future backend swap shouldn't require UI changes (see `docs/architecture.md`).
- **No real auth today**: `AuthWrapper` always shows a role-selection screen (client/negocio/admin) with no login. `login_screen.dart`/`register_screen.dart` exist as designed UI but aren't wired into the navigable flow.
- **Backend history**: `/supabase` (PostgreSQL + PL/pgSQL triggers/RPCs) is the original backend and encodes the business rules above, but the app no longer calls it — kept purely as reference for whatever backend gets connected next.
- **Active external service**: Firebase Cloud Messaging is the only backend-adjacent service currently live.
- **Terminology**: "tarjeta"/card = a client's loyalty relationship with one business; "local"/negocio = a single business location; "canje"/claim = redeeming a pending reward.
- Architecture pattern is feature-first (`lib/features/<domain>`), with shared design-system and utility code under `lib/core` and `lib/shared/widgets`.

## Brand Commitments

- Product name: **Donde Siempre**.
- Existing logo asset: `app/assets/images/logo_blanco.png`.
- An implemented, Figma-derived design system already exists in code (`lib/core/theme/*`: colors, typography — Poppins/Inter, radii, shadows, spacing) — noted as evidence of an incumbent visual world, not specified here; `/impeccable document` is the path to record it formally.

## Evidence on Hand

- `docs/business_rules.md` — full reward-cycle, cooldown, and roles/permissions rules (reference implementation, historical).
- `docs/architecture.md` — frontend architecture and current stub state.
- `docs/database.md`, `docs/setup.md` — historical backend schema and setup/deploy guide.
- No customer testimonials, case studies, pricing, or usage metrics are on hand — do not fabricate these.

## Product Principles

1. Digitize the stamp card, don't reinvent it — every new flow should map back to something a client or shop owner already understands from the physical ritual.
2. All three roles (client, business, admin) are first-class; no surface is designed as an afterthought to another.
3. Anti-fraud mechanics (scan cooldown, pending-reward lock) are core product behavior, not edge cases — they must stay visible and understandable to the client, not hidden as background rules.
4. UI and providers stay decoupled from data source — any new feature's data layer should be replaceable without touching its screens, consistent with the current stub-repository pattern.

## Accessibility & Inclusion

No product-specific accessibility requirement has been established yet.
