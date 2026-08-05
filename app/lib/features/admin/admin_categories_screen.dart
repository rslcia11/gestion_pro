import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/shared_widgets.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final response = await supabase
          .from('business_categories')
          .select()
          .order('name');
      if (mounted) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar categorías: $e'),
            backgroundColor: AppColors.accentPink,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addCategory(String name) async {
    try {
      await supabase.from('business_categories').insert({'name': name});
      _loadCategories();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppColors.accentPink,
          ),
        );
      }
    }
  }

  Future<void> _deleteCategory(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
        title: Text('Eliminar Categoría', style: AppTypography.titleBold),
        content: Text(
          '¿Estás seguro de eliminar esta categoría? Esto podría afectar a los negocios que la tengan asignada si no hay restricciones en la base de datos.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: SecondaryButton(label: 'Cancelar', onPressed: () => Navigator.pop(context, false)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PrimaryButton(
                  label: 'Eliminar',
                  isDestructive: true,
                  onPressed: () => Navigator.pop(context, true),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await supabase.from('business_categories').delete().eq('id', id);
      _loadCategories();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar (probablemente en uso): $e'),
            backgroundColor: AppColors.accentPink,
          ),
        );
      }
    }
  }

  void _showAddDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
        title: Text('Nueva Categoría', style: AppTypography.titleBold),
        content: AppTextField(
          controller: controller,
          label: 'Nombre de la categoría',
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: SecondaryButton(label: 'Cancelar', onPressed: () => Navigator.pop(context)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PrimaryButton(
                  label: 'Guardar',
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      Navigator.pop(context);
                      _addCategory(controller.text.trim());
                    }
                  },
                ),
              ),
            ],
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
        title: const AppBarTitle('Gestión de Categorías'),
        leading: IconActionButton(
          icon: LucideIcons.arrowLeft,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
        icon: const Icon(LucideIcons.plus),
        label: Text('Nueva categoría', style: AppTypography.subtitleBold.copyWith(color: AppColors.onPrimary, fontSize: 15)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.accentPurple),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    boxShadow: AppShadows.card,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.pastelOf(AppColors.accentPurple),
                          borderRadius: BorderRadius.circular(AppRadii.badge),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(LucideIcons.layers, color: AppColors.accentPurple, size: 24),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          category['name'].toString(),
                          style: AppTypography.subtitleBold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconActionButton(
                        icon: LucideIcons.trash2,
                        backgroundColor: AppColors.pastelOf(AppColors.accentPink),
                        iconColor: AppColors.accentPink,
                        onPressed: () => _deleteCategory(category['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
