# Tasks: distill-my-cards-density

- [x] Re-read the current `app/lib/features/cards/my_cards_screen.dart` (not
      the critique snapshot) and confirm the ESTADO mini-stat, both reward
      description fields, and the flagged spacing/font values still exist as
      described.
- [x] Grep `reward_long_description` usage across the app to decide which
      reward field is redundant on this card — confirmed the user-facing
      reward detail (`card_history_screen.dart`) only reads
      `reward_description`; `reward_long_description` is business-owner-only
      (`dashboard_repository.dart`, `business_profile_screen.dart`).
- [x] Remove the `ESTADO`/`'ACTIVA'` `_MiniStat` and change the mini-stat
      `Row` from 3-items-with-`Spacer()` to 2 items with
      `MainAxisAlignment.spaceBetween`.
- [x] Remove the `reward_long_description` `Text` from the card, keep
      `reward_description`.
- [x] Snap `EdgeInsets.all(40)` (empty-state icon circle) to `AppSpacing.xl`.
- [x] Snap `EdgeInsets.all(10)` (`_RewardBanner` icon circle) to
      `AppSpacing.sm`.
- [x] Snap off-hierarchy `fontSize` overrides to the nearest documented step:
      welcome dialog title (22), AppBar greeting (18), FAB label (15),
      business name (18), "¡Nuevo!" badge (10), mini-stat label (10).
- [x] Sanity-check no overflow/wrap regressions from the font-size changes
      (all changes hold size steady or shrink slightly; `AppBarTitle` already
      supports 2-line wrap; business name `Row` stays `Expanded`).
- [x] Run `flutter analyze --no-fatal-infos --no-fatal-warnings` from `app/`
      — 3 pre-existing infos only (`business_profile_screen.dart:309`,
      `user_profile_repository.dart:4`, `main.dart:27`), no new issues.
- [x] Run `flutter test` from `app/` — all 8 tests passing (3
      `app_colors_on_light_test.dart`, 2 `cards_error_state_test.dart`, 1 each
      `create_business_test.dart`, `qr_management_test.dart`,
      `widget_test.dart`), no regressions.
