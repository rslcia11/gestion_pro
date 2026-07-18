import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../../core/validators/app_validators.dart';
import '../help/faqs_screen.dart';
import '../auth/providers/auth_provider.dart';
import 'providers/user_profile_provider.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  XFile? _newAvatarFile;

  @override
  void initState() {
    super.initState();
    final state = ref.read(userProfileProvider);
    _fullNameController = TextEditingController(text: state.fullName);
    _phoneController = TextEditingController(text: state.phone);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      setState(() => _newAvatarFile = image);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    
    final success = await ref.read(userProfileProvider.notifier).saveProfile(
      fullName: _fullNameController.text,
      phone: _phoneController.text,
      newAvatarFile: _newAvatarFile,
    );

    if (mounted) {
      if (success) {
        await _showSavedAnimation();
        if (mounted) Navigator.pop(context, true);
      } else {
        final error = ref.read(userProfileProvider).error;
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error'), backgroundColor: AppColors.accentPink),
          );
        }
      }
    }
  }

  /// Muestra una animación de éxito (check que escala) tras guardar el perfil.
  /// Se autocierra a los ~1.4s y recién ahí volvemos a la pantalla anterior.
  Future<void> _showSavedAnimation() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (dialogCtx) {
        final navigator = Navigator.of(dialogCtx);
        Future.delayed(const Duration(milliseconds: 1400), () {
          if (navigator.canPop()) navigator.pop();
        });
        return Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 36),
            margin: const EdgeInsets.symmetric(horizontal: 48),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(color: AppColors.accentGreen, shape: BoxShape.circle),
                  child: const Icon(LucideIcons.circleCheck, color: Colors.white, size: 44),
                )
                    .animate()
                    .scale(duration: 450.ms, curve: Curves.easeOutBack)
                    .then()
                    .shimmer(duration: 600.ms, color: Colors.white70),
                const SizedBox(height: 20),
                Text('¡Perfil actualizado!', textAlign: TextAlign.center, style: AppTypography.titleBold)
                    .animate()
                    .fadeIn(delay: 200.ms),
              ],
            ),
          ).animate().fadeIn(duration: 250.ms).scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOut),
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final confirmController = TextEditingController();
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
          title: Text('¿Eliminar mi cuenta?', style: AppTypography.titleBold),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Esta acción es irreversible y cumplimos con borrar todos tus datos personales.',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Escribe "ELIMINAR" para confirmar:', style: AppTypography.labelBold),
              const SizedBox(height: 8),
              AppTextField(controller: confirmController, hint: 'ELIMINAR'),
            ],
          ),
          actions: [
            SecondaryButton(label: 'Cancelar', onPressed: () => Navigator.pop(context, false)),
            PrimaryButton(
              label: 'Eliminar definitivamente',
              isDestructive: true,
              onPressed: () {
                if (confirmController.text.trim().toUpperCase() == 'ELIMINAR') Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final success = await ref.read(userProfileProvider.notifier).deleteAccount();
    if (mounted) {
      if (success) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        final error = ref.read(userProfileProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: AppColors.accentPink),
        );
      }
    }
  }

  Future<void> _changePassword() async {
    final newPwdController = TextEditingController();
    final confirmPwdController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isVisible = false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
          title: Text('Cambiar Contraseña', style: AppTypography.titleBold.copyWith(fontSize: 16), textAlign: TextAlign.center),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: newPwdController,
                  obscureText: !isVisible,
                  label: 'Nueva contraseña',
                  helperText: 'Mínimo 6 caracteres',
                  prefixIcon: LucideIcons.lock,
                  suffixIcon: IconButton(
                    icon: Icon(isVisible ? LucideIcons.eye : LucideIcons.eyeOff, color: AppColors.textSecondary),
                    onPressed: () => setLocalState(() => isVisible = !isVisible),
                  ),
                  validator: AppValidators.validatePassword,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: confirmPwdController,
                  obscureText: !isVisible,
                  label: 'Confirmar contraseña',
                  prefixIcon: LucideIcons.lock,
                  validator: (v) => AppValidators.validateConfirmPassword(v, newPwdController.text),
                ),
              ],
            ),
          ),
          actions: [
            SecondaryButton(label: 'Cancelar', onPressed: () => Navigator.pop(ctx, false)),
            PrimaryButton(
              label: 'Guardar',
              onPressed: () {
                if (formKey.currentState!.validate()) Navigator.pop(ctx, true);
              },
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    final success = await ref.read(userProfileProvider.notifier).changePassword(newPwdController.text);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contraseña actualizada'), backgroundColor: AppColors.accentGreen),
        );
      } else {
        final error = ref.read(userProfileProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error'), backgroundColor: AppColors.accentPink),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
        title: Text('¿Cerrar sesión?', textAlign: TextAlign.center, style: AppTypography.titleBold),
        content: Text('¿Estás seguro que deseas salir de tu cuenta?', textAlign: TextAlign.center, style: AppTypography.bodyRegular),
        actions: [
          SecondaryButton(label: 'Cancelar', onPressed: () => Navigator.pop(ctx, false)),
          PrimaryButton(label: 'Cerrar Sesión', onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    );

    if (confirm != true) return;

    await ref.read(authStateProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<UserProfileState>(userProfileProvider, (previous, next) {
      if (previous?.fullName != next.fullName && next.fullName.isNotEmpty) {
        _fullNameController.text = next.fullName;
      }
      if (previous?.phone != next.phone && next.phone.isNotEmpty) {
        _phoneController.text = next.phone;
      }
    });

    final state = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Mi Perfil', style: AppTypography.titleBold.copyWith(fontSize: 16)),
        centerTitle: true,
        actions: [
          IconActionButton(
            icon: LucideIcons.circleCheck,
            backgroundColor: AppColors.pastelOf(AppColors.accentGreen),
            iconColor: AppColors.accentGreen,
            onPressed: state.isLoading ? null : _saveChanges,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: state.isLoading && state.fullName.isEmpty
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.accentPurple)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            UserAvatar(
                              imageUrl: _newAvatarFile != null ? null : state.avatarUrl,
                              initials: state.fullName.isNotEmpty ? state.fullName[0] : '?',
                              size: 120,
                              backgroundColor: AppColors.accentPurple,
                            ),
                            if (_newAvatarFile != null)
                              Positioned.fill(
                                child: ClipOval(
                                  child: Image.file(File(_newAvatarFile!.path), fit: BoxFit.cover),
                                ),
                              ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                child: const Icon(LucideIcons.camera, color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppTextField(
                      controller: _fullNameController,
                      label: 'Nombre completo',
                      prefixIcon: LucideIcons.user,
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      controller: _phoneController,
                      label: 'Teléfono',
                      prefixIcon: LucideIcons.phone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildEmailReadOnly(state.email ?? ''),
                    const SizedBox(height: AppSpacing.xl),

                    // ACCIONES DE CUENTA
                    _ProfileAction(
                      icon: LucideIcons.lock,
                      label: 'Cambiar contraseña',
                      color: AppColors.accentPurple,
                      onTap: _changePassword,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ProfileAction(
                      icon: LucideIcons.circleHelp,
                      label: 'Preguntas frecuentes',
                      color: AppColors.accentAmber,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FaqsScreen()),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ProfileAction(
                      icon: LucideIcons.logOut,
                      label: 'Cerrar sesión',
                      color: AppColors.textSecondary,
                      onTap: _logout,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    TextButton.icon(
                      onPressed: _deleteAccount,
                      icon: const Icon(LucideIcons.trash2, color: AppColors.border),
                      label: Text('Eliminar mi cuenta', style: AppTypography.labelBold.copyWith(color: AppColors.border)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmailReadOnly(String email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Correo registrado', style: AppTypography.labelBold.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.mail, size: 20, color: AppColors.border),
              const SizedBox(width: 12),
              Expanded(
                child: Text(email, style: AppTypography.subtitleBold.copyWith(fontSize: 15, color: AppColors.textSecondary)),
              ),
              const Icon(LucideIcons.lock, size: 16, color: AppColors.border),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ProfileAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Text(label, style: AppTypography.subtitleBold.copyWith(color: color, fontSize: 14)),
              ),
              const Icon(LucideIcons.chevronRight, color: AppColors.border),
            ],
          ),
        ),
      ),
    );
  }
}



