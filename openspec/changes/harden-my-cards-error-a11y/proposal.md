# Proposal: Harden My Cards screen — error state, accessibility, contrast

## Intent

`app/lib/features/cards/my_cards_screen.dart` is the client's home/loyalty-wallet
screen (root screen, no back destination). An impeccable critique
(`.impeccable/critique/2026-07-29T23-08-25Z__app-lib-features-cards-my-cards-screen-dart.md`)
scored it 20/40 and flagged one P0 and two in-scope P1s, all rooted in the same
gap: the screen was built for the happy path only. PRODUCT.md documents the
self-hosted backend (EC2, dynamic IP) as genuinely unreliable, so a fetch error
is a real, recurring case — not an edge case.

## Scope

### In Scope
- Distinct, persistent error state for the cards list (message + retry),
  separate from the true "zero cards" empty state (P0).
- `Semantics` labels + ≥44/48px touch targets on the two icon-only AppBar
  controls on this screen: leading back button, avatar-edit pencil (P1).
- Contrast-safe "on-light" accent color tokens in `AppColors`, documented in
  `DESIGN.md`, replacing the ad-hoc `0xFF8A6D00` hex and the raw accent colors
  used as text/icon directly on white within this screen (P1).

### Out of Scope
- Removing the dead back arrow (separate P1 finding, not selected for this
  change).
- P2 findings (ESTADO dead stat, spacing/font-size drift).
- Changing `IconActionButton`'s shared default size (14+ call sites rely on
  40×40; verified via grep — changing the default is a separate, riskier
  change).
- Card-level `Semantics` grouping for screen-reader announcement of the whole
  loyalty card (noted as a good follow-up, not an icon-only control).

## Capabilities

### New Capabilities
- `cards-error-state`: distinct persistent error UI for the cards list, with
  retry, replacing the current fall-through to empty-state/spinner.
- `cards-icon-control-accessibility`: semantic labels and minimum touch
  targets for icon-only AppBar controls on My Cards.
- `accent-contrast-tokens`: WCAG AA-safe darkened accent color tokens in the
  design system, documented and used wherever an accent renders as text/icon
  on a white surface in this screen.

### Modified Capabilities
None — no existing `openspec/specs/` domains cover this screen yet.

## Approach

Add a small presentational `CardsErrorState` widget shown when
`state.error != null && state.cards.isEmpty`, wired to `refreshCards()`.
Wrap the two icon-only AppBar controls in `Semantics` and bump their size to
48×48. Add `accent*OnLight` consts + an `AppColors.onLightOf()` lookup to
`app_colors.dart`, document them in `DESIGN.md`, and swap every accent-as-text
usage in the screen to go through them.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `app/lib/features/cards/my_cards_screen.dart` | Modified | Error state branch, Semantics + sizing on icon controls, contrast token usage |
| `app/lib/core/theme/app_colors.dart` | Modified | New `onLightOf()` + 4 `*OnLight` consts |
| `DESIGN.md` | Modified | Document new contrast-safe tokens |
| `app/test/cards_error_state_test.dart` | New | Widget test for the error state |
| `app/test/app_colors_on_light_test.dart` | New | Unit test for `onLightOf()` |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Darkened accent hues drift from brand palette | Low | Reused existing `#8A6D00` amber fix as-is; picked well-known Tailwind "-700" shades for the others, computed to clear 4.5:1 with margin |
| Full-screen widget test infeasible (Supabase/Riverpod deps in `initState`) | Medium | Test the extracted `CardsErrorState` widget and `onLightOf()` in isolation instead of the whole screen; documented as a deliberate scope limit |
| Retry loop if backend stays down | Low | Retry reuses existing `refreshCards()` — no new retry/backoff logic introduced |

## Rollback Plan

Revert the diff to `my_cards_screen.dart` and `app_colors.dart`; delete the
two new test files. No data migration, no provider/state-shape changes.

## Dependencies

None.

## Success Criteria

- [ ] A fetch error with zero cards shows a distinct error UI (not the empty
      state or a bare spinner), with a working retry button.
- [ ] Leading back button and avatar-edit control both expose a `Semantics`
      label and are ≥48×48.
- [ ] No accent color renders as text/icon directly on white in this screen
      below 4.5:1 contrast; `0xFF8A6D00` hardcode is gone.
- [ ] `flutter analyze --no-fatal-infos --no-fatal-warnings` and
      `flutter test` pass with no new issues.
