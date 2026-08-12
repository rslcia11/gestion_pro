import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/validators/app_validators.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class StepPersonalData extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final GlobalKey<FormFieldState<String>> fullNameFieldKey;
  final GlobalKey<FormFieldState<String>> phoneFieldKey;

  const StepPersonalData({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.phoneController,
    required this.fullNameFieldKey,
    required this.phoneFieldKey,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Tus Datos', style: AppTypography.subtitleBold),
          const SizedBox(height: 8),
          Text('Verifica o actualiza tu información de contacto.', style: AppTypography.bodyMedium),
          const SizedBox(height: 24),

          AppTextField(
            fieldKey: fullNameFieldKey,
            controller: fullNameController,
            label: 'Nombre completo',
            prefixIcon: LucideIcons.user,
            validator: AppValidators.validateName,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          AppTextField(
            fieldKey: phoneFieldKey,
            controller: phoneController,
            keyboardType: TextInputType.phone,
            label: 'Teléfono',
            prefixIcon: LucideIcons.phone,
            helperText: '10 dígitos (formato Ecuador)',
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: AppValidators.validateEcuadorPhone,
          ),
        ],
      ),
    );
  }
}
