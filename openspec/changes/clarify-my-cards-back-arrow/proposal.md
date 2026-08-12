# Proposal: Remove dead back arrow from MyCardsScreen

## What

Remove the back-arrow `IconButton` from `MyCardsScreen`'s `AppBar.leading`. Don't
replace it with anything — just delete `leading` and let `AppBar` fall back to
its default (no leading widget, since `Navigator.canPop(context)` is false here).

## Why

`auth_wrapper.dart` routes authenticated clients (`AuthClient` state) straight to
`const MyCardsScreen()` with no wrapping route push — it is the true root screen
for that user type, with nothing to pop to. The back arrow's `onPressed` called
`Navigator.of(context).maybePop()`, which silently no-ops on this screen. Per
`impeccable/reference/clarify.md`'s "Actions and navigation" guidance, a control
that visibly invites a gesture but does nothing trains users to distrust the
app's chrome. Confirmed independently by reading `auth_wrapper.dart`: `AuthClient`
maps 1:1 to `MyCardsScreen()`, no other route sits above it.

Note: a prior change (`harden-my-cards-error-a11y`) already fixed this same
element's accessibility properties (`Semantics(label: 'Volver')`, 48px touch
target) but explicitly deferred the "should this exist at all" question to this
change.

## Scope

- `app/lib/features/cards/my_cards_screen.dart` — remove the `leading:` entry
  from the `AppBar` in `build()`.
- No layout compensation needed: `admin_dashboard_screen.dart` (another true-root
  screen, `AuthAdmin` -> `AdminDashboardScreen()`) already establishes the
  convention of a titled `AppBar` with no `leading` and no extra left padding —
  this change follows that existing precedent for consistency.
- No new test added: no existing test mounts the full `MyCardsScreen` (its
  `AppBar`/back-button included) — the file's own comments note it can't be
  mounted in a widget test without a fake backend/repository. Forcing one just
  for this removal wasn't warranted; `CardsErrorState` (the one piece of this
  screen that IS unit-tested) is unaffected.

## Out of scope

- Any other AppBar in the app (business/admin screens keep their own
  leading/back behavior as-is).
