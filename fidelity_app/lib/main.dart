import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_wrapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final GlobalKey<NavigatorState> globalNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase ya inicializado o error: $e');
  }

  // Inicializar Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // NOTA: El RealtimeSyncService NO se inicializa acá. Si lo hiciéramos antes
  // del login, el canal se suscribiría con el rol anónimo y, por las políticas
  // RLS, el servidor nunca enviaría los cambios del usuario. Se inicializa
  // tras autenticarse (ver AuthWrapper) para que el canal lleve el JWT.

  runApp(const ProviderScope(child: FidelityApp()));
}

class FidelityApp extends StatelessWidget {
  const FidelityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Donde Siempre',
      theme: AppTheme.theme,
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
