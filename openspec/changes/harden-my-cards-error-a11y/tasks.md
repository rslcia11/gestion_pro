# Tasks: Harden My Cards screen — error state, accessibility, contrast

## Phase 1: Foundation — Contrast Tokens

- [x] 1.1 RED: Write `app/test/app_colors_on_light_test.dart` asserting
      `AppColors.onLightOf()` returns the correct `*OnLight` const for
      `accentPurple`/`accentPink`/`accentAmber`/`accentGreen`, and returns
      the input unchanged for an unmapped color.
- [x] 1.2 GREEN: In `app/lib/core/theme/app_colors.dart`, add
      `accentPurpleOnLight (0xFF7E22CE)`, `accentPinkOnLight (0xFFBE185D)`,
      `accentAmberOnLight (0xFF8A6D00)`, `accentGreenOnLight (0xFF15803D)`
      with doc comments, and `static Color onLightOf(Color accent)`.
- [x] 1.3 REFACTOR: Confirm doc comments explain the 4.5:1 AA rationale and
      usage scope (text/icon on white only, not fills).

## Phase 2: Foundation — Error State Widget

- [x] 2.1 RED: Write `app/test/cards_error_state_test.dart` — pump
      `CardsErrorState` with a fake `onRetry`, assert the message text
      renders and tapping "Reintentar" invokes the callback once.
- [x] 2.2 GREEN: Add public `CardsErrorState` `StatelessWidget` to
      `app/lib/features/cards/my_cards_screen.dart` (icon, title, message,
      `PrimaryButton` retry) per design.md's interface.

## Phase 3: Core Implementation — Wire Error State Into Screen

- [x] 3.1 In `_MyCardsScreenState.build()`, insert an
      `state.error != null && state.cards.isEmpty` branch between the
      loading check and the existing `state.cards.isEmpty` check, rendering
      `CardsErrorState(onRetry: () => ref.read(myCardsProvider.notifier).refreshCards())`.
- [x] 3.2 Update the `ref.listen` SnackBar: only show it when
      `next.cards.isNotEmpty`; replace `'Error: ${next.error}'` with a static
      plain-language string (no raw exception text).

## Phase 4: Core Implementation — Accessibility

- [x] 4.1 Wrap the leading `IconActionButton` (back arrow) in
      `Semantics(label: 'Volver', button: true, ...)` and set `size: 48`.
- [x] 4.2 Wrap the avatar/edit `GestureDetector` in
      `Semantics(label: 'Editar perfil', button: true, ...)`; bump
      `UserAvatar(size: ...)` from 44 to 48.

## Phase 5: Core Implementation — Contrast Token Usage

- [x] 5.1 In `_LoyaltyCardItem`, replace the progress-percentage `Text`
      color (`accentColor`) with `AppColors.onLightOf(accentColor)`.
- [x] 5.2 Replace the `TOTAL` `_MiniStat`'s `color: accentColor` with
      `AppColors.onLightOf(accentColor)`; replace `CANJES`'s
      `AppColors.accentPink` with `AppColors.accentPinkOnLight`; replace
      `ESTADO`'s `AppColors.accentGreen` with `AppColors.accentGreenOnLight`.
- [x] 5.3 In `_RewardBanner`, replace `Color(0xFF8A6D00)` with
      `AppColors.accentAmberOnLight`.

## Phase 6: Documentation

- [x] 6.1 Update `DESIGN.md`'s Colors section: document the 4 new
      `*OnLight` tokens (hex, usage guidance, contrast rationale).

## Phase 7: Verification

- [x] 7.1 Run `flutter analyze --no-fatal-infos --no-fatal-warnings` from
      `app/` — zero new errors/warnings vs. the 3 known pre-existing infos. Confirmed clean.
- [x] 7.2 Run `flutter test` from `app/` — the 5 new/touched tests (3 in
      `app_colors_on_light_test.dart`, 2 in `cards_error_state_test.dart`) all
      pass. **3 unrelated pre-existing tests fail** (`create_business_test.dart`,
      `widget_test.dart`, `qr_management_test.dart`) — root cause: none of them
      call `Supabase.initialize()` in test setup, and the app now touches
      `Supabase.instance` at init (`AuthWrapper`/`RealtimeSyncService`) since
      today's earlier Supabase-reconnection work. This regression predates this
      change and is out of this change's scope — see verify-report.md.
