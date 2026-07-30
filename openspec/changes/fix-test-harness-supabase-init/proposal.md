# Fix test harness: Supabase init in widget tests

## What

`flutter test` had 3 failing tests (`create_business_test.dart`,
`widget_test.dart`, `qr_management_test.dart`), all crashing with
`You must initialize the supabase instance before calling Supabase.instance`.
None of these files called `Supabase.initialize(...)` before pumping a widget
tree that reaches `Supabase.instance` — directly (screens read
`Supabase.instance.client` as a field), or transitively via `AuthWrapper`
constructing the `RealtimeSyncService()` singleton, whose constructor also
reads `Supabase.instance.client`.

Added a shared test helper, `app/test/support/supabase_test_setup.dart`
(`initializeTestSupabase()`), that mocks `SharedPreferences` and calls
`Supabase.initialize(url: 'http://localhost:54321', publishableKey: ...,
debug: false)`. All three files now call it from `setUpAll`. Also fixed
`widget_test.dart`'s stale assertion, which still expected a removed
"design preview" role-picker screen — it now asserts the current
unauthenticated entry point, `LoginScreen` (by type and its
"Iniciar Sesión" button text).

## Why

The app was reconnected to a real self-hosted Supabase backend (an EC2
instance with a dynamic IP) earlier in this work session; these three test
files predate that reconnection and were never updated. Separately, an even
earlier session removed the app's old design-preview/role-picker entry point
in favor of real login (`AuthWrapper` → `LoginScreen` when unauthenticated),
which `widget_test.dart` never caught up to either.

Verified empirically (not assumed) that `Supabase.initialize()` completes
without throwing even without real network reachability: reading
`supabase_flutter` 2.15.4's source
(`supabase_flutter-2.15.4/lib/src/supabase.dart`) confirms `_isInitialized` is
set synchronously in `_init()`, and the post-init session-recovery call
(`recoverSession()`) is wrapped in a `CancelableOperation` that is *not*
awaited by `initialize()` — so a network failure there never propagates to
the caller. A single shared helper (vs. triplicating the boilerplate) keeps
the three files consistent and makes future backend-config changes a
one-file edit.

## Scope

Test-infrastructure only. No production code changed. No new production
dependencies.
