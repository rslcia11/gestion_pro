import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'register_screen.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/auth_error_translator.dart';
import '../../shared/widgets/shared_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null && mounted) {
        // AuthWrapper automáticamente detectará el inicio de sesión y cambiará de pantalla.
        // No hacemos pushReplacement para no recargar el sistema.
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AuthErrorTranslator.translate(e)),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        );
      }
    } finally {
      if (mounted && supabase.auth.currentUser == null) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetPassword(String email) async {
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Revisa tu correo para recuperar la contraseña.'),
            backgroundColor: AppColors.accentGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AuthErrorTranslator.translate(e)),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showRecoveryDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
        title: Text('Recuperar contraseña', style: AppTypography.titleBold),
        content: AppTextField(
          controller: emailController,
          hint: 'Correo electrónico',
          prefixIcon: LucideIcons.mail,
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          SecondaryButton(
            label: 'Cancelar',
            isFullWidth: false,
            onPressed: () => Navigator.pop(context),
          ),
          PrimaryButton(
            label: 'Enviar',
            isFullWidth: false,
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                _resetPassword(emailController.text);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // Sin rebote: el contenido entra en pantalla, pero seguimos
            // permitiendo scroll si el teclado achica el espacio.
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppRadii.badge),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(LucideIcons.zap, color: AppColors.onPrimary, size: 32),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text('Donde Siempre', style: AppTypography.displayBold),
                    ],
                  ).animate().scale(duration: AppTheme.animDurationSlow, curve: AppTheme.animCurveElastic).fadeIn(),

                  const SizedBox(height: AppSpacing.xl),

                  // Formulario
                  Column(
                    children: [
                      AppTextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        hint: 'Tu email',
                        prefixIcon: LucideIcons.mail,
                        validator: (value) =>
                            (value == null || value.isEmpty) ? 'Ingresa tu email' : null,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        hint: 'Tu contraseña',
                        prefixIcon: LucideIcons.lock,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? LucideIcons.eye : LucideIcons.eyeOff,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                        validator: (value) =>
                            (value == null || value.isEmpty) ? 'Ingresa tu contraseña' : null,
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Mínimo 6 caracteres', style: AppTypography.caption),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showRecoveryDialog,
                          child: Text(
                            '¿Olvidaste tu contraseña?',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.accentPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .slideY(begin: 0.15, duration: AppTheme.animDurationSlow, curve: AppTheme.animCurveStandard, delay: 200.ms)
                      .fadeIn(delay: 200.ms),

                  const SizedBox(height: AppSpacing.lg),

                  PrimaryButton(
                    label: 'Iniciar Sesión',
                    isLoading: _isLoading,
                    onPressed: _login,
                  )
                      .animate()
                      .scale(duration: 400.ms, curve: Curves.easeOutBack, delay: 500.ms)
                      .fadeIn(delay: 500.ms),

                  const SizedBox(height: AppSpacing.lg),

                  // Registro
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: Text(
                      '¿No tienes cuenta? Regístrate',
                      style: AppTypography.subtitleBold.copyWith(fontSize: 15),
                    ),
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
