# Design: Harden My Cards screen — error state, accessibility, contrast

## Technical Approach

Three independent, additive changes inside `my_cards_screen.dart` plus one
new lookup in `app_colors.dart`. No provider/state-shape changes — `MyCardsState`
already has `isLoading`, `cards`, `error`; we only change how the widget tree
branches on that existing state, and add `Semantics`/`size` to two existing
widgets, and swap color references.

## Architecture Decisions

### Decision: Error state as a public, isolated StatelessWidget

**Choice**: `CardsErrorState` — a public `StatelessWidget` in
`my_cards_screen.dart` (`message`, `onRetry`).
**Alternatives considered**: (a) private `_ErrorState` matching the file's
`_buildEmptyState` pattern; (b) a new file under `shared/widgets/`.
**Rationale**: Must be public (no leading `_`) so `app/test/` can import and
pump it directly — the full `MyCardsScreen` can't be widget-tested cheaply
(its `initState` calls `Supabase.instance.client.auth.currentUser` and reads
Riverpod providers backed by real repositories; no fake/mock repository
exists in this codebase today). Keeping it in the same file (not a new
shared file) matches the existing `_buildEmptyState`/`_LoyaltyCardItem`
locality — it's specific to this screen's copy and icon choice, not a
reusable cross-screen component yet.

### Decision: Branch order in `body:` — loading → error → empty → list

**Choice**: Insert the error check between the loading check and the
existing empty check: `isLoading&&empty → error&&empty → empty → list`.
**Alternatives considered**: Checking error first (before loading) — rejected
because a retry sets `isLoading: true, error: null` momentarily is not
guaranteed to clear `error` before the next frame reads it; checking loading
first preserves current first-load spinner behavior exactly.
**Rationale**: `MyCardsNotifier._loadInitialData`/`refreshCards` both clear
`error` when a non-silent load starts, so the four branches are mutually
exclusive in practice; ordering only matters for the transient frame where
`isLoading` flips.

### Decision: Suppress the error SnackBar when cards are already loaded is NOT changed — instead scope it to `cards.isEmpty` case removed from SnackBar

**Choice**: Keep the `ref.listen` SnackBar for background-refresh failures
(`cards.isNotEmpty`), replace its literal `Error: ${next.error}` text with a
static plain-language string, and skip showing it when `cards.isEmpty` (the
persistent `CardsErrorState` already covers that case — showing both would be
redundant/noisy).
**Alternatives considered**: Removing the SnackBar entirely — rejected, it's
still useful signal when the user already has data on screen and a
background sync silently fails.
**Rationale**: Matches spec's "Background refresh errors do not duplicate
messaging" requirement without inventing new state.

### Decision: `AppColors.onLightOf()` lookup + named consts, not a computed HSL darken function

**Choice**: Four named `const Color` fields (`accentPurpleOnLight`,
`accentPinkOnLight`, `accentAmberOnLight`, `accentGreenOnLight`) plus a small
`static Color onLightOf(Color accent)` switch-style lookup.
**Alternatives considered**: A runtime HSL-lightness-reduction function
(`Color darkenForContrast(Color c, {double targetRatio})`).
**Rationale**: `app_colors.dart`'s only existing derivation function is
`pastelOf()` (a fixed 12%-alpha rule, not a contrast-solver). A computed
darkener adds real algorithmic surface (HSL conversion, iterative contrast
search) for a palette of exactly 4 accents used as text-on-white in the whole
app today — not proportionate. Named consts are auditable at a glance and
match the file's existing style. `onLightOf()` exists only so call sites
that already hold a rotating `accentColor` variable (not a compile-time
constant) don't need a manual switch at each usage.

### Decision: Reuse existing `#8A6D00` for amber, pick Tailwind "-700" family for the other three

**Choice**: `accentAmberOnLight = 0xFF8A6D00` (already shipped in
`_RewardBanner`, computed contrast 4.92:1). `accentPurpleOnLight = 0xFF7E22CE`
(6.98:1), `accentPinkOnLight = 0xFFBE185D` (6.04:1),
`accentGreenOnLight = 0xFF15803D` (5.02:1) — all Tailwind "700" shades of the
same hue family as the existing accents.
**Alternatives considered**: A generic single darkening formula applied
uniformly — produces less predictable/brand-consistent results than picking
from an established scale already adjacent to the existing hex values.
**Rationale**: Every value clears 4.5:1 with real margin (not a
knife's-edge pass), and reusing a known color-scale family keeps the palette
coherent instead of inventing arbitrary one-off hexes. Purple's original
(`#9333EA`, ~5.39:1) and pink's original (`#DB2777`, ~4.60:1) already pass
AA technically, but pink's margin is thin enough (and rounding-sensitive)
that giving it the same darkened treatment as amber/green removes the risk
of an under-tested edge case.

### Decision: Touch targets fixed via local `size:` override, not shared default change

**Choice**: `IconActionButton(..., size: 48)` at this screen's leading slot;
avatar bumped from 44 to 48 via `UserAvatar(size: 48)`.
**Alternatives considered**: Changing `IconActionButton`'s default from 40 to
48/44.
**Rationale**: grep confirms 14+ call sites across admin/business/scanner/etc.
rely on the 40×40 default in dense layouts (icon rows, list actions); a
blanket default change is a separate, wider-blast-radius change requiring its
own review. Explicitly out of scope per proposal.

## File Changes

| File | Action | Description |
|------|--------|--------------|
| `app/lib/features/cards/my_cards_screen.dart` | Modify | Add `CardsErrorState` widget + body branch; wrap leading/avatar controls in `Semantics` + size 48; replace SnackBar text; route accent-as-text usages through `AppColors.onLightOf()`/`accentAmberOnLight` |
| `app/lib/core/theme/app_colors.dart` | Modify | Add 4 `*OnLight` consts + `onLightOf()` |
| `DESIGN.md` | Modify | Document new tokens in Colors section |
| `app/test/cards_error_state_test.dart` | Create | Widget test for `CardsErrorState` (renders message, retry invokes callback) |
| `app/test/app_colors_on_light_test.dart` | Create | Unit test for `onLightOf()` mapping + fallback |

## Interfaces / Contracts

```dart
class CardsErrorState extends StatelessWidget {
  const CardsErrorState({
    super.key,
    required this.onRetry,
    this.message = 'No pudimos cargar tus tarjetas. Revisá tu conexión e intentá de nuevo.',
  });
  final VoidCallback onRetry;
  final String message;
}

// app_colors.dart
static const Color accentPurpleOnLight = Color(0xFF7E22CE);
static const Color accentPinkOnLight   = Color(0xFFBE185D);
static const Color accentAmberOnLight  = Color(0xFF8A6D00);
static const Color accentGreenOnLight  = Color(0xFF15803D);
static Color onLightOf(Color accent) { ... } // falls back to `accent` if unmapped
```

## Testing Strategy

| Layer | What to Test | Approach |
|-------|--------------|----------|
| Unit | `AppColors.onLightOf()` mapping + unmapped fallback | Plain `flutter_test` unit test, no widget pump |
| Widget | `CardsErrorState` renders message + retry tap fires callback | `testWidgets` pumping the widget in isolation (`MaterialApp` wrapper only) |
| Widget (skipped, documented) | Full `MyCardsScreen` error/Semantics/size behavior | Not automated — blocked by `Supabase.instance` + real-repository Riverpod providers with no fake in this codebase; verified via `flutter analyze` + manual code review instead |

No integration/E2E layer exists in this project (confirmed in `openspec/config.yaml`).

## Migration / Rollout

No migration required. Pure UI/token change, no data or API contract change.

## Open Questions

None — proposal and specs fully resolve the approach.
