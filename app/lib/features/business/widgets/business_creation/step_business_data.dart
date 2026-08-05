import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../location_picker_map.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radii.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/shared_widgets.dart';
import '../../../../core/models/business_category.dart';

class StepBusinessData extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final BusinessCategory? selectedCategory;
  final List<BusinessCategory> categories;
  final ValueChanged<BusinessCategory> onCategoryChanged;

  // Location
  final double? latitude;
  final double? longitude;
  final String address;
  final Function(double, double, String) onLocationSelected;

  final GlobalKey<FormFieldState<String>> nameFieldKey;
  final GlobalKey<FormFieldState<String>> categoryFieldKey;

  const StepBusinessData({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.selectedCategory,
    required this.categories,
    required this.onCategoryChanged,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.onLocationSelected,
    required this.nameFieldKey,
    required this.categoryFieldKey,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Datos del Negocio', style: AppTypography.subtitleBold),
          const SizedBox(height: 8),
          Text('¿Cómo reconocerán los clientes a tu local?', style: AppTypography.bodyMedium),
          const SizedBox(height: 24),

          AppTextField(
            fieldKey: nameFieldKey,
            controller: nameController,
            label: 'Nombre del negocio',
            prefixIcon: LucideIcons.store,
            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
          ),
          const SizedBox(height: 16),

          Autocomplete<BusinessCategory>(
            initialValue: TextEditingValue(text: selectedCategory?.name.toUpperCase() ?? ''),
            displayStringForOption: (BusinessCategory option) => option.name.toUpperCase(),
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return categories;
              }
              return categories.where((BusinessCategory option) {
                return option.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
              });
            },
            onSelected: (BusinessCategory selection) {
              onCategoryChanged(selection);
            },
            fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
              return TextFormField(
                key: categoryFieldKey,
                controller: textEditingController,
                focusNode: focusNode,
                style: AppTypography.bodyRegular,
                decoration: InputDecoration(
                  labelText: 'Categoría (Busca o selecciona)',
                  labelStyle: AppTypography.bodyMedium,
                  filled: true,
                  fillColor: AppColors.background,
                  prefixIcon: const Icon(LucideIcons.layers, size: 20, color: AppColors.textSecondary),
                  suffixIcon: const Icon(LucideIcons.chevronDown, color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    borderSide: const BorderSide(color: AppColors.textPrimary, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    borderSide: const BorderSide(color: AppColors.textPrimary, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
                validator: (String? value) {
                  if (categories.isEmpty) {
                    return 'No hay categorías disponibles en este momento. Intentá de nuevo más tarde.';
                  }
                  if (selectedCategory == null || value == null || value.isEmpty) {
                    return 'Selecciona una categoría válida de la lista';
                  }
                  return null;
                },
              );
            },
            optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<BusinessCategory> onSelected, Iterable<BusinessCategory> options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 8.0,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 250),
                    // We let it size based on the parent's constraints mostly, but give it a max width
                    width: MediaQuery.of(context).size.width - 48,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final BusinessCategory option = options.elementAt(index);
                        return ListTile(
                          title: Text(option.name.toUpperCase(), style: AppTypography.labelBold),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          if (categories.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.circleAlert, size: 16, color: AppColors.accentAmber),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'No hay categorías disponibles en este momento.',
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          AppTextField(
            controller: descriptionController,
            label: 'Descripción (Opcional)',
            prefixIcon: LucideIcons.pencil,
          ),
          const SizedBox(height: 24),

          Text('Ubicación Exacta *', style: AppTypography.subtitleBold.copyWith(fontSize: 16)),
          const SizedBox(height: 8),
          Text('Mueve el marcador o toca el mapa para ubicarte.', style: AppTypography.caption),
          const SizedBox(height: 12),

          LocationPickerMap(
            initialLatitude: latitude,
            initialLongitude: longitude,
            initialAddress: address,
            onLocationSelected: onLocationSelected,
          ),

          if (address.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.pastelOf(AppColors.accentGreen),
                  borderRadius: BorderRadius.circular(AppRadii.badge),
                  border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.circleCheck, color: AppColors.accentGreen, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(address, style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
