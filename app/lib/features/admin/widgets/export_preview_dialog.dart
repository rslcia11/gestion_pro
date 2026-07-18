import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/services/export_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/shared_widgets.dart';

class ExportPreviewDialog extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final ExportEntity entity;
  final ExportService exportService;

  const ExportPreviewDialog({
    super.key,
    required this.data,
    required this.entity,
    required this.exportService,
  });

  Future<void> _export(BuildContext context) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.accentPurple))),
      );

      final csvContent = await exportService.generateCsv(data, entity);
      if (!context.mounted) return;
      Navigator.of(context).pop();

      final filename =
          'export_${entity.name}_${DateTime.now().millisecondsSinceEpoch}.csv';
      await exportService.shareCsv(csvContent, filename);
      if (!context.mounted) return;
      Navigator.of(context).pop();
    } on ExportException catch (e) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
          title: Text('Error', style: AppTypography.titleBold),
          content: Text(e.message, style: AppTypography.bodyRegular),
          actions: [
            PrimaryButton(label: 'OK', onPressed: () => Navigator.pop(context)),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rowCount = data.length;
    final isOverLimit = rowCount > 5000;

    return AlertDialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
      title: Text('Exportar a CSV', style: AppTypography.titleBold),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Se exportarán $rowCount registros (según los filtros activos).',
            style: AppTypography.bodyRegular,
          ),
          if (isOverLimit) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.pastelOf(AppColors.error),
                borderRadius: BorderRadius.circular(AppRadii.badge),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.circleAlert, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Límite excedido\n\nMáximo permitido es 5000 filas.\nAjusta los filtros.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        SecondaryButton(label: 'Cancelar', onPressed: () => Navigator.pop(context)),
        if (!isOverLimit)
          PrimaryButton(label: 'Exportar', icon: LucideIcons.download, onPressed: () => _export(context)),
      ],
    );
  }
}
