---
target: app/lib/features/cards/my_cards_screen.dart
total_score: 20
max_score: 40
na_heuristics: 
p0_count: 1
p1_count: 3
timestamp: 2026-07-29T23-08-25Z
slug: app-lib-features-cards-my-cards-screen-dart
---
Method: dual-agent (A: a1dce6090cceeb1a5 · B: ae71c30f6fc8c1107)

## Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 2 | Fetch error and "genuinely zero cards" render as the same empty state; error only surfaces as a transient SnackBar (my_cards_screen.dart:274-280) that vanishes in seconds. |
| 2 | Match System / Real World | 3 | Plain, warm Spanish copy; loyalty-card metaphor reads naturally. |
| 3 | User Control and Freedom | 3 | Pending-reward and welcome dialogs have clear dismiss/cancel paths (:222-253). |
| 4 | Consistency and Standards | 1 | Leading back arrow (:305-308) on the client's true root screen (auth_wrapper.dart:165-167 confirms there's nothing to pop to) — `maybePop()` silently no-ops. |
| 5 | Error Prevention | 3 | Nothing destructive on this screen; minor gap only (no debounce on card tap). |
| 6 | Recognition Rather Than Recall | 3 | Actions/labels visible, mini-stats are text-labeled. |
| 7 | Flexibility and Efficiency | 1 | No search/filter/sort for a client with many businesses; single linear list. |
| 8 | Aesthetic and Minimalist Design | 2 | Hardcoded "ESTADO: ACTIVA" stat (:677-683) is dead content at equal visual weight to real stats; both `reward_description` and `reward_long_description` render unconditionally. |
| 9 | Error Recovery | 1 | Raw `Error: ${next.error}` shown verbatim (:276) — no plain-language message, no retry action. |
| 10 | Help and Documentation | 1 | No help/support entry point on this screen. |
| **Total** | | **20/40** | **Acceptable (bottom edge, close to Poor)** |

## Design Specificity Verdict

**Partially specific.** The feedback loop is genuinely authored for this product: confetti + celebration dialog on card completion, the "¡Punto aprobado! ✨" snackbar, and the pulsing "¡Nuevo!" badge are built specifically around the scan→approve→point loop from PRODUCT.md — real product character.

The static card composition is category-interchangeable: logo chip, progress bar, three icon-label mini-stats — the shape of any generic loyalty-app template. DESIGN.md's north star ("el pasaporte de sellos del barrio, digitalizado") isn't visually cited anywhere in the card — no stamp, passport, or ink-texture motif, just a standard rounded white card with a pastel icon. Accent color is assigned by list index, not business identity (my_cards_screen.dart:510-516), undercutting DESIGN.md's framing of pastel accents as a semantic system — here it's decoration that can visibly shift for the same business across refreshes.

**Deterministic scan**: No web detector applies (native Flutter, no DOM/CSS) — Assessment B ran an equivalent grep/static pass instead. Findings: radii are 100% compliant with DESIGN.md's token scale (every `BorderRadius.circular` call uses `AppRadii.*`); colors are 100% token-routed except one undocumented hardcoded hex (`0xFF8A6D00` at :730, a manually-darkened amber with no entry in DESIGN.md); spacing has real drift — several off-scale literals (`EdgeInsets.all(40)`, `EdgeInsets.all(10)`) that match no step in the `xs/sm/md/lg/xl` scale, plus multiple correct-value-but-not-token-referenced literals. Both assessments independently and exactly agreed on one finding: `IconActionButton` defaults to 40×40px (icon_action_button.dart:13), below both platform touch-target minimums — strong signal, not a one-off judgment call.

**Visual overlays**: not applicable — no browser/live-render pipeline exists for a native Flutter screen; this is a source-level critique.

## Overall Impression

The emotional peak (celebration on completing a card) is well-built and specific to the product. But the entry experience for a returning user on a flaky connection — which PRODUCT.md documents as a real, recurring risk given the self-hosted backend's dynamic IP — is the single biggest gap: errors, near-invisible touch targets, and zero accessibility labels all cluster around the same "we designed for the happy path only" blind spot.

## What's Working

1. Real-time celebration stack (confetti, dialog, snackbar, animated badge) is bespoke and correctly weighted around the product's actual differentiator moment.
2. Pending-reward reminder on relaunch is a thoughtful, non-obvious safety net against lost rewards.
3. Radius token discipline is perfect — zero stray radius literals anywhere in the file.

## Priority Issues

**[P0] Error state is indistinguishable from "zero cards"**
Why it matters: PRODUCT.md documents the backend as genuinely unreliable (manually reconfigured EC2 IP on every restart). A client hitting a timeout sees the same "¡Empieza tu colección!" screen as a brand-new user, or a bare spinner — no persistent in-body error/retry affordance, only a SnackBar that vanishes. They may believe their scans never registered and re-scan repeatedly, or contact support confused about a working account.
Fix: give the cards state a distinct error state, rendered as its own screen (retry button, plain-language message), separate from the true empty state.
Suggested command: `/impeccable harden`

**[P1] Icon-only controls fail accessibility — confirmed by both assessments independently**
Why it matters: zero `Semantics`/`semanticLabel`/`Tooltip` usage anywhere in the file or its composed widgets (grep-confirmed). The leading back button (:305-308) defaults to 40×40 (icon_action_button.dart:13) — below iOS's 44pt and Android's 48dp minimums — and has no accessible label. The avatar-edit pencil tap target (:313-368) is borderline (~44×44, meets iOS, fails Android) and is also unlabeled. A screen-reader user hears a jumble of concatenated text on the card itself instead of "Business X, 5 of 10 points, 50%."
Fix: wrap icon-only controls in `Semantics(label: ...)`, and raise the default/override size on interactive AppBar actions to ≥44/48.
Suggested command: `/impeccable harden`

**[P1] Accent-color text fails WCAG AA contrast on white, and the one existing fix bypasses the token system**
Why it matters: the progress percentage and mini-stat icon/value render full-saturation accent color directly on white — amber ≈2.1:1, green ≈3.3:1, both fail the 4.5:1 AA floor for this text size. Notably, `_RewardBanner` already solves this exact problem by manually darkening amber to `#8A6D00` (:730) — but that fix is a hardcoded, undocumented hex with no entry in DESIGN.md, not a reusable token. The correct fix exists in the file and simply wasn't generalized.
Fix: add a contrast-safe darkened variant per accent to DESIGN.md's token set, and reuse it everywhere an accent sits as text/icon on a light surface.
Suggested command: `/impeccable harden`

**[P1] Dead back arrow on the client's true root screen**
Why it matters: `auth_wrapper.dart:165-167` routes authenticated clients directly to this screen — there is nothing to pop to. The visible, tappable arrow trains users to distrust the app's chrome the first time it silently no-ops.
Fix: remove the leading back arrow on this screen, or replace with a non-actionable identity element if the AppBar needs visual balance.
Suggested command: `/impeccable clarify`

**[P2] Card content density and token drift**
Why it matters: the hardcoded "ESTADO: ACTIVA" mini-stat (:677-683) never varies — pure noise at equal visual weight to real stats (chunking check fails: ~8+ discrete pieces per card). Both `reward_description` and `reward_long_description` render simultaneously. Separately, several spacing values (`EdgeInsets.all(40)`, `EdgeInsets.all(10)`) match no step in the documented `xs/sm/md/lg/xl` scale, and several font-size overrides (22, 18, 15, 10) bypass the documented type hierarchy (24/20/17/14/12) with one-off in-between values.
Fix: drop the ESTADO stat or replace with a real signal; collapse the two description fields; snap stray spacing/font-size literals to the nearest documented step (or add the step to DESIGN.md if it's genuinely needed twice or more).
Suggested command: `/impeccable distill`

## Persona Red Flags

**Casey (Distracted Mobile)**: FAB sits correctly in the thumb zone, but a timed-out fetch on 3G leaves her staring at "¡Empieza tu colección!" — wrong message, no retry, no indication anything failed beyond a SnackBar she likely missed switching apps.

**Jordan (Confused First-Timer)**: taps the top-left back arrow expecting habitual "back" behavior; nothing happens — no error, no navigation, no feedback beyond a ripple. Will likely tap again, assume the app is frozen.

**Sam (Accessibility)**: progress-percentage and mini-stat text fail contrast at the exact spot conveying core-loop progress — the thing she most needs to read. The card's `GestureDetector` carries no `Semantics` label, so a screen reader announces a jumble of concatenated text nodes instead of a coherent "Business X, 5 of 10 points, 50%" announcement.

## Minor Observations

- Accent color assigned by list index, not business identity — can visibly shift for the same business across refreshes since cards reorder by recent activity.
- No debounce guard on card tap; rapid double-tap could push `CardHistoryScreen` twice.
- `pointsRequired == 0` silently clamps progress to 100% rather than flagging a misconfigured business.
- `ConfettiWidget` sits outside `SafeArea` (:373 wraps only `Scaffold.body`) and top-aligns at the literal viewport edge — low-impact since it's decorative, but a real edge-to-edge/status-bar overlap risk on notched devices.
- `AppBottomNavBar` exists in the design system but is unused anywhere in the app — worth confirming a single-screen-plus-push IA is the intended long-term shape for the client experience.

## Questions to Consider

- PRODUCT.md calls reward transfer a first-class differentiator, not an afterthought — so why is there zero visible entry point for it on the home screen itself, only reachable by digging into card history?
- Is a back arrow the right chrome for the one screen a client can never actually leave? What would this AppBar look like designed as a home screen rather than inherited from a detail-screen pattern?
- If the backend really does go down periodically (as PRODUCT.md documents), shouldn't that be a first-class designed state on this screen, rather than a generic try/catch that collapses into the empty state?
