# Tasks: clarify-my-cards-back-arrow

- [x] Read `auth_wrapper.dart` and independently confirm `MyCardsScreen` is the
      unconditional destination for `AuthClient`, with no wrapping route pushed
      onto it from elsewhere.
- [x] Read the current state of `my_cards_screen.dart`'s `AppBar` (it changed
      since the critique snapshot — `harden-my-cards-error-a11y` already added
      `Semantics(label: 'Volver')` + 48px sizing to the same arrow).
- [x] Remove the `leading:` entry (the `Semantics` + `IconActionButton` calling
      `Navigator.of(context).maybePop()`) from `MyCardsScreen`'s `AppBar`.
- [x] Evaluate whether the title needs left-padding compensation now that
      `leading` is gone — checked `admin_dashboard_screen.dart` as precedent
      (another true-root screen with a titled, leading-less `AppBar`); no
      compensation applied, consistent with that existing convention.
- [x] Check `app/test/widget_test.dart` and `app/test/cards_error_state_test.dart`
      for coverage of this AppBar/back-button; confirmed neither mounts the
      full `MyCardsScreen`, so no test needed forcing — none added.
- [x] Run `flutter analyze --no-fatal-infos --no-fatal-warnings` from `app/` —
      3 pre-existing infos only, no new issues.
- [x] Run `flutter test` from `app/` — all 8 tests passing, no regressions.
