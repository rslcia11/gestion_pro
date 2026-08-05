import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'login_screen.dart';
import '../../core/validators/app_validators.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/auth_error_translator.dart';
import '../../shared/widgets/shared_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String _selectedRole = 'client';

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  XFile? _avatarFile;

  final supabase = Supabase.instance.client;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final metadata = {
        'role': _selectedRole,
        'full_name': _fullNameController.text.trim(),
      };
      final authResponse = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: metadata,
      );

      if (authResponse.user == null) throw Exception('Error al crear usuario');

      final userId = authResponse.user!.id;

      // Subir Avatar si existe
      String? avatarUrl;
      if (_avatarFile != null) {
        try {
          final fileBytes = await _avatarFile!.readAsBytes();
          final fileExt = _avatarFile!.name.split('.').last.toLowerCase();
          final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
          final imagePath = '$userId/$fileName';

          await supabase.storage.from('avatars').uploadBinary(
            imagePath,
            fileBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );
          avatarUrl = supabase.storage.from('avatars').getPublicUrl(imagePath);
        } catch (e) {
          debugPrint('Error uploading avatar: $e');
        }
      }

      await supabase.from('profiles').upsert({
        'id': userId,
        'full_name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'avatar_url': avatarUrl,
        'role': _selectedRole,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });

      if (mounted) {
        _showSuccessToast();
        if (authResponse.session == null) {
          _showVerificationDialog();
        } else {
          // Si es cliente, cerramos la sesión para obligarlo a loguearse (como pidió el usuario)
          // y evitar que MyCardsScreen lance el diálogo de bienvenida en el fondo.
          if (_selectedRole == 'client') {
            await supabase.auth.signOut();
          }

          Future.delayed(1500.ms, () {
            if (mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          });
        }
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: const Duration(milliseconds: 2500),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.accentGreen,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentGreen.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.circleCheck, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '¡CUENTA CREADA CON ÉXITO!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack),
      ),
    );
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
        title: Text('¡Casi listo!', textAlign: TextAlign.center, style: AppTypography.titleBold),
        content: Text(
          'Te hemos enviado un correo de verificación. Por favor, confirma tu cuenta para continuar.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyRegular,
        ),
        actions: [
          PrimaryButton(
            label: 'Entendido',
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).popUntil((route) => route.isFirst);
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
      appBar: AppBar(
        title: const AppBarTitle('Únete a nosotros'),
        leading: IconActionButton(
          icon: LucideIcons.arrowLeft,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Selector de Rol
                Row(
                  children: [
                    Expanded(
                      child: _RoleSelectorCard(
                        title: 'CLIENTE',
                        icon: LucideIcons.user,
                        color: AppColors.accentAmber,
                        isSelected: _selectedRole == 'client',
                        onTap: () => setState(() => _selectedRole = 'client'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _RoleSelectorCard(
                        title: 'NEGOCIO',
                        icon: LucideIcons.store,
                        color: AppColors.accentPurple,
                        isSelected: _selectedRole == 'business',
                        onTap: () => setState(() => _selectedRole = 'business'),
                      ),
                    ),
                  ],
                ).animate().slideY(begin: 0.2).fadeIn(),

                const SizedBox(height: AppSpacing.xl),

                // Selector de Imagen (Solo para Clientes)
                if (_selectedRole == 'client')
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                        if (img != null) setState(() => _avatarFile = img);
                      },
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.pastelOf(AppColors.accentPurple),
                              shape: BoxShape.circle,
                              image: _avatarFile != null
                                  ? DecorationImage(image: FileImage(File(_avatarFile!.path)), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: _avatarFile == null
                                ? const Icon(LucideIcons.camera, size: 32, color: AppColors.accentPurple)
                                : null,
                          ),
                          if (_avatarFile != null)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: AppColors.accentPurple, shape: BoxShape.circle),
                                child: const Icon(LucideIcons.pencil, size: 14, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ).animate(delay: 100.ms).fadeIn().scale(),

                const SizedBox(height: AppSpacing.xl),

                Text('Datos personales', style: AppTypography.labelBold)
                    .animate(delay: 200.ms)
                    .fadeIn(),

                const SizedBox(height: AppSpacing.md),

                // Campos del Formulario
                Column(
                  children: [
                    AppTextField(
                      controller: _fullNameController,
                      hint: 'Nombre completo',
                      prefixIcon: LucideIcons.user,
                      validator: AppValidators.validateName,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      hint: 'Email',
                      prefixIcon: LucideIcons.mail,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                      validator: AppValidators.validateEmail,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      hint: 'Teléfono',
                      prefixIcon: LucideIcons.phone,
                      helperText: '10 dígitos (Ecuador)',
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: AppValidators.validateEcuadorPhone,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      hint: 'Contraseña segura',
                      helperText: 'Mínimo 6 caracteres',
                      prefixIcon: LucideIcons.lock,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? LucideIcons.eye : LucideIcons.eyeOff,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                      validator: AppValidators.validatePassword,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      hint: 'Confirma tu contraseña',
                      prefixIcon: LucideIcons.lock,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible ? LucideIcons.eye : LucideIcons.eyeOff,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                      ),
                      validator: (v) => AppValidators.validateConfirmPassword(v, _passwordController.text),
                    ),
                  ],
                ).animate(delay: 300.ms).slideY(begin: 0.1).fadeIn(),

                const SizedBox(height: AppSpacing.xl),

                PrimaryButton(
                  label: _selectedRole == 'business' ? 'Configurar negocio' : 'Crear mi cuenta',
                  isLoading: _isLoading,
                  onPressed: _register,
                ).animate(delay: 500.ms).scale(curve: Curves.easeOutBack).fadeIn(),

                const SizedBox(height: AppSpacing.md),

                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                  child: Text(
                    '¿Ya tienes cuenta? Inicia sesión',
                    style: AppTypography.subtitleBold.copyWith(fontSize: 15),
                  ),
                ).animate(delay: 700.ms).fadeIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleSelectorCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleSelectorCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.pastelOf(color) : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: isSelected ? color : AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTypography.labelBold.copyWith(
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
