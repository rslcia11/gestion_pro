import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'login_screen.dart';
import '../../core/validators/app_validators.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Stub: sin backend conectado — pendiente de integrar nueva DB.
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Backend no conectado.'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Únete a nosotros'),
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
