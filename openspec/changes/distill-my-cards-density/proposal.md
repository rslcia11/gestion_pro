# Proposal: Distill card content density in MyCardsScreen

## What

Strip noise and token drift from `_LoyaltyCardItem` (and a couple of nearby
widgets in the same file) in `app/lib/features/cards/my_cards_screen.dart`:

1. Remove the `_MiniStat` with label `ESTADO` / hardcoded value `'ACTIVA'` —
   it never varies, so it's pure visual weight with zero information. The
   mini-stat row goes from 3 items (`TOTAL` / `Spacer` / `CANJES` / `Spacer` /
   `ESTADO`) to 2 items laid out with `MainAxisAlignment.spaceBetween`.
2. Stop rendering `business['reward_long_description']` alongside
   `business['reward_description']` on the card — keep only
   `reward_description` (the short "what premio do you get" label, e.g. "Café
   Gratis"). Confirmed via grep that `reward_long_description` is not shown
   anywhere in the user-facing reward detail view
   (`card_history_screen.dart` only ever reads `reward_description`); it's
   used only in the business-owner dashboard (`dashboard_repository.dart`)
   and the business's own edit screen (`business_profile_screen.dart`),
   neither of which a cardholder sees. Removing it from the list card doesn't
   delete data or hide it from anyone who currently sees it.
3. Snap off-scale `EdgeInsets` to `AppSpacing` steps (4/8/16/24/32):
   `EdgeInsets.all(40)` → `AppSpacing.xl` (32, matching the sibling icon
   circle in `CardsErrorState` which already uses `AppSpacing.xl`),
   `EdgeInsets.all(10)` → `AppSpacing.sm` (8, nearest step).
4. Snap off-hierarchy `fontSize` overrides (24/20/17/14/12 documented in
   `DESIGN.md`) to the nearest documented step: welcome-dialog title `22`→
   default `titleBold` (20), AppBar greeting `18`→ default `titleBold` (20,
   matching `DESIGN.md`'s own stated use of Title for AppBar titles), FAB
   label `15`→`14`, business-name `18`→ default `subtitleBold` (17), "¡Nuevo!"
   badge `10`→`12`, mini-stat label `10`→ default `caption` (12).

## Why

Per the design critique
(`.impeccable/critique/2026-07-29T23-08-25Z__app-lib-features-cards-my-cards-screen-dart.md`,
finding P2): the fake "ESTADO: ACTIVA" stat competes visually with two real
stats (lifetime points, redemptions) for zero payoff; showing both reward
description fields duplicates the same idea at two lengths on a card that
already carries a logo, progress bar, and reward banner; and several
one-off spacing/font values bypass the documented `AppSpacing`/typography
scales in `DESIGN.md` without a documented reason, adding arbitrary
visual variance across an otherwise consistent design system.

## Scope

- `app/lib/features/cards/my_cards_screen.dart` only.
- No data model, repository, or provider changes — `reward_long_description`
  keeps being fetched/stored, just not rendered on this card.
- No changes to accessibility (`Semantics`, touch targets, contrast tokens)
  from the earlier `harden-my-cards-error-a11y` change, and no changes to the
  confetti/celebration mechanics.

## Out of scope

- `SizedBox(height: 12)` between the points/percent row and the progress bar:
  off-scale but out of this change's explicit ask (EdgeInsets/padding only);
  left as-is.
- `fontSize: 20` on `displayBold` (empty state / error state headings) and
  `fontSize: 14` on `subtitleBold` (reward banner title): both numerically
  match a documented step already, so not "off-hierarchy" even though the
  base style's own default differs — left as-is.
