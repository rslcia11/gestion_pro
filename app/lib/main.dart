import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_brightness.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/providers/theme_mode_provider.dart';
import 'features/auth/auth_wrapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase (push notifications) — independiente del backend de datos.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase ya inicializado o error: $e');
  }

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: AppRoot()));
}

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final effectiveBrightness = mode == ThemeMode.system
        ? MediaQuery.platformBrightnessOf(context)
        : (mode == ThemeMode.dark ? Brightness.dark : Brightness.light);

    if (AppBrightness.current != effectiveBrightness) {
      AppBrightness.current = effectiveBrightness;
      // Los ~700 call-sites directos de AppColors.x (fuera de ThemeData) no
      // dependen de ningún InheritedWidget, así que no son reactivos por sí
      // solos. reassembleApplication() fuerza que TODO build() se vuelva a
      // ejecutar (igual que hot reload) sin destruir State ni el stack de
      // Navigator — a diferencia de remontar con una Key, que tira toda la
      // navegación. Se agenda post-frame para no reentrar en medio del build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.reassembleApplication();
      });
    }

    return MaterialApp(
      title: 'Donde Siempre',
      theme: AppTheme.theme,
      darkTheme: AppTheme.darkTheme,
      themeMode: mode,
      debugShowCheckedModeBanner: false,
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      navigatorKey: globalNavigatorKey,
      home: const AuthWrapper(),
    );
  }
}
