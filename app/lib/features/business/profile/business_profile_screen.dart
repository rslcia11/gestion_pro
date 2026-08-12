import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/shared_widgets.dart';
import '../../../core/models/business_category.dart';
import '../../auth/providers/auth_provider.dart';
import '../../help/business_faqs_screen.dart';
import '../widgets/location_picker_map.dart';

class BusinessProfileScreen extends StatefulWidget {
  final Map<String, dynamic> business;
  final String ownerName;

  const BusinessProfileScreen({
    super.key,
    required this.business,
    required this.ownerName,
  });

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final supabase = Supabase.instance.client;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  // Profile Controllers
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;

  // Business Controllers
  late TextEditingController _businessNameController;
  late TextEditingController _businessDescriptionController;
  late TextEditingController _rewardDescriptionController;
  late TextEditingController _rewardLongDescriptionController;
  late TextEditingController _pointsRequiredController;

  String? _logoUrl;
  XFile? _newLogoFile;

  BusinessCategory? _selectedCategory;
  List<BusinessCategory> _categories = [];

  double? _latitude;
  double? _longitude;
  String? _address;

  @override
  void initState() {
    super.initState();
    _logoUrl = widget.business['logo_url'];
    _fullNameController = TextEditingController(text: widget.ownerName);
    _phoneController = TextEditingController(text: ''); // We'll fetch this

    _businessNameController = TextEditingController(
      text: widget.business['name'],
    );
    _businessDescriptionController = TextEditingController(
      text: widget.business['description'] ?? '',
    );
    _rewardDescriptionController = TextEditingController(
      text: widget.business['reward_description'] ?? '',
    );
    _rewardLongDescriptionController = TextEditingController(
      text: widget.business['reward_long_description'] ?? '',
    );
    _pointsRequiredController = TextEditingController(
      text: widget.business['points_required']?.toString() ?? '10',
    );

    _latitude = widget.business['latitude'];
    _longitude = widget.business['longitude'];
    _address = widget.business['address'];

    _loadProfileData();
    _loadCategories();
  }

  Future<void> _loadProfileData() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final profile = await supabase
          .from('profiles')
          .select('phone')
          .eq('id', userId)
          .single();

      if (mounted) {
        setState(() {
          _phoneController.text = profile['phone'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading profile phone: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      final response = await supabase
          .from('business_categories')
          .select()
          .order('name');

      if (mounted) {
        setState(() {
          _categories = (response as List)
              .map((c) => BusinessCategory.fromJson(c))
              .toList();

          final categoryId = widget.business['category_id'];
          if (categoryId != null) {
            try {
              _selectedCategory = _categories.firstWhere(
                (c) => c.id == categoryId,
              );
            } catch (_) {}
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _businessNameController.dispose();
    _businessDescriptionController.dispose();
    _rewardDescriptionController.dispose();
    _rewardLongDescriptionController.dispose();
    _pointsRequiredController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() => _newLogoFile = image);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser!.id;
      final businessId = widget.business['id'];

      // 1. Upload Logo if changed
      String? finalLogoUrl = _logoUrl;
      if (_newLogoFile != null) {
        final fileBytes = await _newLogoFile!.readAsBytes();
        final fileExt = _newLogoFile!.name.split('.').last.toLowerCase();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final imagePath = '$userId/$fileName';

        await supabase.storage
            .from('business-logos')
            .uploadBinary(
              imagePath,
              fileBytes,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
              ),
            );
        final rawUrl = supabase.storage
            .from('business-logos')
            .getPublicUrl(imagePath);
        finalLogoUrl = '$rawUrl?v=${DateTime.now().millisecondsSinceEpoch}';
      }

      // 2. Update Profile
      await supabase
          .from('profiles')
          .update({
            'full_name': _fullNameController.text.trim(),
            'phone': _phoneController.text.trim(),
          })
          .eq('id', userId);

      // 3. Update Business
      await supabase
          .from('businesses')
          .update({
            'name': _businessNameController.text.trim(),
            'description': _businessDescriptionController.text.trim(),
            'logo_url': finalLogoUrl,
            'category_id': _selectedCategory?.id,
            'address': _address,
            'latitude': _latitude,
            'longitude': _longitude,
            'reward_description': _rewardDescriptionController.text.trim(),
            'reward_long_description': _rewardLongDescriptionController.text
                .trim(),
            'points_required': int.parse(_pointsRequiredController.text),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', businessId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado exitosamente'),
            backgroundColor: AppColors.accentGreen,
          ),
        );
        Navigator.pop(context, true); // Indicate success to refresh parent
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.accentPink,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final confirmController = TextEditingController();
        return AlertDialog(
          backgroundColor: AppColors.surfaceCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          title: Text('¿Eliminar cuenta?', style: AppTypography.titleBold),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Esta acción es irreversible. Se borrarán todos tus datos, negocios, premios y puntos acumulados.',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Escribe "ELIMINAR" para confirmar:', style: AppTypography.labelBold),
              const SizedBox(height: 8),
              AppTextField(controller: confirmController, hint: 'ELIMINAR'),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Cancelar',
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PrimaryButton(
                    label: 'Eliminar definitivamente',
                    isDestructive: true,
                    onPressed: () {
                      if (confirmController.text.trim().toUpperCase() == 'ELIMINAR') {
                        Navigator.pop(context, true);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser!.id;

      // Intentamos llamar a la Edge Function (recomendado para GDPR completo)
      try {
        await supabase.functions.invoke(
          'hyper-action',
          headers: {
            'Authorization':
                'Bearer ${supabase.auth.currentSession?.accessToken}',
          },
        );
      } catch (e) {
        debugPrint('Edge Function failed, using RPC fallback: $e');
        // Fallback: Si no has desplegado la Edge Function, al menos limpiamos los datos públicos
        await supabase.rpc(
          'delete_user_data',
          params: {'user_id_param': userId},
        );
      }

      await ProviderScope.containerOf(context).read(authStateProvider.notifier).logout();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: AppColors.accentPink,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 80,
        title: AppBarTitle('Editar Perfil', style: AppTypography.titleBold.copyWith(fontSize: 16)),
        centerTitle: true,
        leading: IconActionButton(
          icon: LucideIcons.arrowLeft,
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconActionButton(
            icon: LucideIcons.circleCheck,
            backgroundColor: AppColors.pastelOf(AppColors.accentGreen),
            iconColor: AppColors.accentGreen,
            onPressed: _isLoading ? null : _saveChanges,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.accentPurple)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Logo
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Hero(
                              tag: 'business_logo',
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: _newLogoFile != null
                                      ? DecorationImage(
                                          image: FileImage(
                                            File(_newLogoFile!.path),
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : (_logoUrl != null
                                            ? DecorationImage(
                                                image: NetworkImage(_logoUrl!),
                                                fit: BoxFit.cover,
                                              )
                                            : null),
                                ),
                                child:
                                    (_logoUrl == null && _newLogoFile == null)
                                    ? const Icon(LucideIcons.store, size: 44, color: AppColors.border)
                                    : null,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(LucideIcons.camera, color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // SECTION: DATOS PERSONALES
                    _buildSectionHeader('Datos Personales', LucideIcons.user),
                    _buildTextField(
                      _fullNameController,
                      'Nombre completo',
                      LucideIcons.idCard,
                    ),
                    _buildTextField(
                      _phoneController,
                      'WhatsApp / Celular',
                      LucideIcons.phone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // SECTION: DATOS DEL NEGOCIO
                    _buildSectionHeader('Datos del Negocio', LucideIcons.store),
                    _buildTextField(
                      _businessNameController,
                      'Nombre del negocio',
                      LucideIcons.building2,
                    ),
                    _buildTextField(
                      _businessDescriptionController,
                      'Descripción breve',
                      LucideIcons.fileText,
                      maxLines: 2,
                      isRequired: false,
                    ),

                    const SizedBox(height: AppSpacing.md),
                    // Category Dropdown
                    Text('Categoría', style: AppTypography.labelBold.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    if (_categories.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
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
                    Autocomplete<BusinessCategory>(
                      initialValue: TextEditingValue(text: _selectedCategory?.name.toUpperCase() ?? ''),
                      displayStringForOption: (BusinessCategory option) => option.name.toUpperCase(),
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        final query = textEditingValue.text.trim();
                        if (query.isEmpty || query.toUpperCase() == _selectedCategory?.name.trim().toUpperCase()) {
                          return _categories;
                        }
                        return _categories.where((BusinessCategory option) {
                          return option.name.toLowerCase().contains(query.toLowerCase());
                        });
                      },
                      onSelected: (BusinessCategory selection) {
                        setState(() => _selectedCategory = selection);
                      },
                      fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          style: AppTypography.bodyRegular,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(LucideIcons.layers, size: 20, color: AppColors.textSecondary),
                            suffixIcon: const Icon(LucideIcons.chevronDown, color: AppColors.textSecondary),
                            filled: true,
                            fillColor: AppColors.background,
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
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          validator: (String? value) {
                            if (_categories.isEmpty) {
                              return 'No hay categorías disponibles en este momento. Intentá de nuevo más tarde.';
                            }
                            if (_selectedCategory == null || value == null || value.isEmpty) {
                              return 'Selecciona una categoría válida';
                            }
                            return null;
                          },
                        );
                      },
                      optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<BusinessCategory> onSelected, Iterable<BusinessCategory> options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Material(
                                elevation: 8.0,
                                shadowColor: Colors.black26,
                                color: AppColors.surfaceCard,
                                borderRadius: BorderRadius.circular(AppRadii.card),
                                clipBehavior: Clip.antiAlias,
                                child: Container(
                                  width: constraints.maxWidth,
                                  constraints: const BoxConstraints(maxHeight: 280),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(AppRadii.card),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: options.isEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text('No se encontraron categorías', style: AppTypography.bodyMedium),
                                        )
                                      : ListView.separated(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          shrinkWrap: true,
                                          itemCount: options.length,
                                          separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
                                          itemBuilder: (BuildContext context, int index) {
                                            final BusinessCategory option = options.elementAt(index);
                                            final isSelected = _selectedCategory?.id == option.id;
                                            return ListTile(
                                              dense: true,
                                              tileColor: isSelected ? AppColors.primary.withValues(alpha: 0.08) : null,
                                              leading: Icon(
                                                LucideIcons.layers,
                                                size: 18,
                                                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                              ),
                                              title: Text(
                                                option.name.toUpperCase(),
                                                style: AppTypography.labelBold.copyWith(
                                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                                ),
                                              ),
                                              onTap: () => onSelected(option),
                                            );
                                          },
                                        ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),
                    // Location Picker
                    Text('Ubicación', style: AppTypography.labelBold.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        double? tempLat = _latitude;
                        double? tempLng = _longitude;
                        String? tempAddr = _address;

                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              appBar: AppBar(
                                title: const AppBarTitle('Seleccionar Ubicación'),
                                leading: IconActionButton(
                                  icon: LucideIcons.arrowLeft,
                                  onPressed: () => Navigator.pop(context),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(
                                      'Confirmar',
                                      style: AppTypography.labelBold.copyWith(color: AppColors.accentPurple),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                              body: LocationPickerMap(
                                initialLatitude: _latitude,
                                initialLongitude: _longitude,
                                initialAddress: _address,
                                onLocationSelected: (lat, lng, addr) {
                                  tempLat = lat;
                                  tempLng = lng;
                                  tempAddr = addr;
                                },
                              ),
                            ),
                          ),
                        );

                        setState(() {
                          _latitude = tempLat;
                          _longitude = tempLng;
                          _address = tempAddr;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(AppRadii.card),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.mapPin, color: AppColors.accentPink),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _address ?? 'Seleccionar en el mapa',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: _address == null ? AppColors.border : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(LucideIcons.chevronRight, color: AppColors.border),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // SECTION: CAMPAÑA DE PUNTOS
                    _buildSectionHeader('Campaña de Puntos', LucideIcons.sparkles),
                    _buildTextField(
                      _rewardDescriptionController,
                      '¿Qué premio entregas?',
                      LucideIcons.gift,
                    ),
                    _buildTextField(
                      _rewardLongDescriptionController,
                      'Descripción del premio',
                      LucideIcons.fileText,
                      maxLines: 2,
                      isRequired: false,
                    ),
                    _buildTextField(
                      _pointsRequiredController,
                      'Puntos necesarios',
                      LucideIcons.hash,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 40),

                    // FAQ
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BusinessFaqsScreen(),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.pastelOf(AppColors.accentPurple),
                          borderRadius: BorderRadius.circular(AppRadii.card),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.accentPurple.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppRadii.badge),
                              ),
                              child: const Icon(LucideIcons.circleHelp, color: AppColors.accentPurple, size: 22),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Preguntas Frecuentes', style: AppTypography.subtitleBold.copyWith(fontSize: 14)),
                                  const SizedBox(height: 2),
                                  Text('Guía completa para gestionar tu negocio', style: AppTypography.caption),
                                ],
                              ),
                            ),
                            const Icon(LucideIcons.chevronRight, color: AppColors.accentPurple),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // DELETE ACCOUNT
                    Center(
                      child: TextButton.icon(
                        onPressed: _deleteAccount,
                        icon: const Icon(LucideIcons.trash2, color: AppColors.border),
                        label: Text('Eliminar mi cuenta', style: AppTypography.labelBold.copyWith(color: AppColors.border)),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.accentPurple),
          const SizedBox(width: 12),
          Text(title, style: AppTypography.subtitleBold.copyWith(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = true,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: AppTextField(
        controller: controller,
        label: label,
        prefixIcon: icon,
        keyboardType: keyboardType,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Campo requerido';
          }
          return null;
        },
      ),
    );
  }
}
