import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/shared_widgets.dart';

class StepCampaignData extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController rewardController;
  final TextEditingController rewardLongController;
  final TextEditingController pointsController;

  const StepCampaignData({
    super.key,
    required this.formKey,
    required this.rewardController,
    required this.rewardLongController,
    required this.pointsController,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Tu Primer Sistema de Puntos', style: AppTypography.subtitleBold),
          const SizedBox(height: 8),
          Text('¿Qué ganan tus clientes y cuántos puntos necesitan?', style: AppTypography.bodyMedium),
          const SizedBox(height: 24),

          AppTextField(
            controller: rewardController,
            label: 'Premio (ej: Café Gratis, 10% de Descuento)',
            prefixIcon: LucideIcons.gift,
            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 16),

          AppTextField(
            controller: rewardLongController,
            label: 'Descripción del premio (opcional)',
            hint: 'Detalles, condiciones, vigencia...',
            prefixIcon: LucideIcons.pencil,
          ),
          const SizedBox(height: 16),

          AppTextField(
            controller: pointsController,
            keyboardType: TextInputType.number,
            label: 'Escaneos / Puntos necesarios',
            prefixIcon: LucideIcons.star,
            helperText: 'Recomendamos entre 5 y 10 puntos.',
            validator: (v) =>
                (int.tryParse(v ?? '') ?? 0) < 1 ? 'Mínimo 1 punto' : null,
          ),
        ],
      ),
    );
  }
}
