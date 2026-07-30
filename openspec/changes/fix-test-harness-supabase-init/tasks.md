# Tasks

- [x] Read `app/lib/main.dart` and `app/lib/core/config/supabase_config.dart`
      to see how the real app initializes Supabase.
- [x] Check `app/test/` for an existing shared test helper (none existed).
- [x] Read all three failing test files plus `AuthWrapper`,
      `RealtimeSyncService`, `LoginScreen`, `QRManagementScreen`,
      `auth_provider.dart` to trace exactly where each hits
      `Supabase.instance`.
- [x] Confirm `supabase_flutter` version pinned (`2.15.4` via
      `pubspec.lock`) and read its `Supabase.initialize()` source in the pub
      cache to verify session-recovery failures can't crash `initialize()`
      itself (no try/catch paper-over needed).
- [x] Create `app/test/support/supabase_test_setup.dart` with
      `initializeTestSupabase()` (mocks `SharedPreferences`, calls
      `Supabase.initialize` against a local dummy URL/key).
- [x] Update `app/test/create_business_test.dart` to use the shared helper.
- [x] Update `app/test/qr_management_test.dart` to use the shared helper
      (assertions on "Sin códigos QR" / FAB were already correct once the
      init crash is gone — no change needed there).
- [x] Update `app/test/widget_test.dart`: use the shared helper, replace the
      stale design-preview-screen assertion with an assertion on the current
      entry point (`LoginScreen`, by type + "Iniciar Sesión" text).
- [x] Run `flutter test` from `app/` — iterate until green.
- [x] Run `flutter analyze --no-fatal-infos --no-fatal-warnings` — caught a
      4th (self-introduced) issue: the new helper used the deprecated
      `anonKey` param; switched to `publishableKey` to keep the analyzer gate
      at exactly the 3 known pre-existing infos.
- [x] Re-run both `flutter test` and `flutter analyze` to confirm final
      green state.
- [x] Write `proposal.md` and `tasks.md` under
      `openspec/changes/fix-test-harness-supabase-init/`.
