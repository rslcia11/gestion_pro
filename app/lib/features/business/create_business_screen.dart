import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'widgets/business_creation/step_logo_picker.dart';
import 'widgets/business_creation/step_personal_data.dart';
import 'widgets/business_creation/step_business_data.dart';
import 'widgets/business_creation/step_campaign_data.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../../core/models/business_category.dart';
import '../auth/providers/auth_provider.dart';

import 'providers/create_business_provider.dart';
import 'data/business_repository.dart';
import '../../core/providers/supabase_provider.dart';
import '../profile/data/profile_repository.dart';

class CreateBusinessScreen extends ConsumerStatefulWidget {
  const CreateBusinessScreen({super.key});

  @override
  ConsumerState<CreateBusinessScreen> createState() => _CreateBusinessScreenState();
}

class _CreateBusinessScreenState extends ConsumerState<CreateBusinessScreen> {
  int _currentStep = 0;

  // Form keys for steps
  final _personalFormKey = GlobalKey<FormState>();
  final _businessFormKey = GlobalKey<FormState>();
  final _campaignFormKey = GlobalKey<FormState>();

  // Field keys: permiten ubicar y scrollear hasta el primer campo que falla
  // su validación (en vez de dejar al usuario buscando el error a ciegas).
  final _fullNameFieldKey = GlobalKey<FormFieldState<String>>();
  final _phoneFieldKey = GlobalKey<FormFieldState<String>>();
  final _businessNameFieldKey = GlobalKey<FormFieldState<String>>();
  final _categoryFieldKey = GlobalKey<FormFieldState<String>>();
  final _rewardFieldKey = GlobalKey<FormFieldState<String>>();
  final _pointsFieldKey = GlobalKey<FormFieldState<String>>();

  // Controllers & Data
  XFile? _logoFile;
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  final _businessNameController = TextEditingController();
  final _businessDescriptionController = TextEditingController();
  BusinessCategory? _selectedCategory;
  List<BusinessCategory> _categories = [];
  double? _selectedLatitude;
  double? _selectedLongitude;
  String _selectedAddress = '';

  final _rewardDescriptionController = TextEditingController();
  final _rewardLongDescriptionController = TextEditingController();
  final _pointsRequiredController = TextEditingController(text: '10');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingProfileData();
      _loadCategories();
    });
  }

  Future<void> _loadCategories() async {
    try {
      final repo = ref.read(businessRepositoryProvider);
      final categories = await repo.getCategories();
      if (mounted) {
        setState(() {
          _categories = categories;
          if (_categories.isNotEmpty) {
            _selectedCategory = _categories.first;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _loadExistingProfileData() async {
    final user = ref.read(supabaseClientProvider).auth.currentUser;
    if (user != null) {
      try {
        final repo = ref.read(profileRepositoryProvider);
        final profile = await repo.getProfile(user.id);
        if (profile != null && mounted) {
          setState(() {
            _fullNameController.text = profile['full_name'] ?? '';
            _phoneController.text = profile['phone'] ?? '';
          });
        }
      } catch (e) {
        debugPrint('Error loading profile: $e');
      }
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

  void _nextStep() {
    bool canContinue = false;

    if (_currentStep == 0) {
      canContinue = true;
    } else if (_currentStep == 1) {
      if (_personalFormKey.currentState!.validate()) {
        canContinue = true;
      } else {
        _showValidationError();
        _scrollToFirstError([_fullNameFieldKey, _phoneFieldKey]);
      }
    } else if (_currentStep == 2) {
      if (_businessFormKey.currentState!.validate()) {
        if (_selectedLatitude == null || _selectedLongitude == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Debes seleccionar la ubicación en el mapa'),
              backgroundColor: AppColors.accentPink,
            ),
          );
        } else {
          canContinue = true;
        }
      } else {
        _showValidationError();
        _scrollToFirstError([_businessNameFieldKey, _categoryFieldKey]);
      }
    } else if (_currentStep == 3) {
      if (_campaignFormKey.currentState!.validate()) {
        _submitBusiness();
        return;
      } else {
        _showValidationError();
        _scrollToFirstError([_rewardFieldKey, _pointsFieldKey]);
      }
    }

    if (canContinue && _currentStep < 3) {
      setState(() => _currentStep += 1);
    }
  }

  void _showValidationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Revisá los campos marcados en rojo antes de continuar'),
        backgroundColor: AppColors.accentPink,
      ),
    );
  }

  /// Lleva el scroll hasta el primer campo de [keys] que quedó con error
  /// tras la validación, en vez de dejar el mensaje fuera de la vista.
  void _scrollToFirstError(List<GlobalKey<FormFieldState<String>>> keys) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final key in keys) {
        final fieldContext = key.currentContext;
        if (fieldContext != null && (key.currentState?.hasError ?? false)) {
          Scrollable.ensureVisible(
            fieldContext,
            alignment: 0.2,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          return;
        }
      }
    });
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  void _submitBusiness() {
    final pointsText = _pointsRequiredController.text.trim();
    final pointsRequired = int.tryParse(pointsText) ?? 10;

    ref.read(createBusinessProvider.notifier).submitBusiness(
      fullName: _fullNameController.text,
      phone: _phoneController.text,
      logoFile: _logoFile,
      businessName: _businessNameController.text,
      businessDescription: _businessDescriptionController.text,
      address: _selectedAddress,
      latitude: _selectedLatitude,
      longitude: _selectedLongitude,
      categoryId: _selectedCategory?.id.toString(),
      rewardDescription: _rewardDescriptionController.text,
      rewardLongDescription: _rewardLongDescriptionController.text,
      pointsRequired: pointsRequired,
    );
  }

  void _showSuccessDialog() {
    final String waMessage = 'Hola, he creado mi negocio y quiero fidelizar a mis clientes ya';
    final String waUrl = 'https://wa.me/593995371895?text=${Uri.encodeComponent(waMessage)}';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        title: Text('¡Todo listo!', style: AppTypography.titleBold, textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tu negocio fue creado exitosamente.\n\nPara activarlo en la plataforma, comunícate con nosotros por WhatsApp o correo:',
              textAlign: TextAlign.center,
              style: AppTypography.bodyRegular,
            ),
            const SizedBox(height: 24),
            SecondaryButton(
              label: 'Enviar Correo',
              icon: LucideIcons.mail,
              onPressed: () => launchUrl(Uri.parse('mailto:${AppTheme.supportEmail}')),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.03, duration: 1.2.seconds, curve: Curves.easeInOut),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Contactar por WhatsApp',
              icon: LucideIcons.phone,
              onPressed: () => launchUrl(Uri.parse(waUrl)),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.03, duration: 1.2.seconds, delay: 600.ms, curve: Curves.easeInOut),
          ],
        ),
        actions: [
          SecondaryButton(
            label: 'Entendido',
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authStateProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final createBusinessState = ref.watch(createBusinessProvider);

    ref.listen<CreateBusinessState>(createBusinessProvider, (previous, next) {
      if (next.error != null && (previous?.error != next.error)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear negocio: ${next.error}'),
            backgroundColor: AppColors.accentPink,
          ),
        );
      } else if (next.isSuccess && (previous?.isSuccess != next.isSuccess)) {
        _showSuccessDialog();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const AppBarTitle('Configurar Negocio'),
        leading: Navigator.canPop(context)
            ? IconActionButton(
                icon: LucideIcons.arrowLeft,
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: createBusinessState.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.accentPurple),
              ),
            )
          : Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: _nextStep,
              onStepCancel: _previousStep,
              physics: const ScrollPhysics(),
              controlsBuilder: (context, details) {
                final isLastStep = _currentStep == 3;
                return Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          label: isLastStep ? 'Finalizar y Crear' : 'Siguiente',
                          onPressed: details.onStepContinue,
                        ),
                      ),
                      if (_currentStep > 0) ...[
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: details.onStepCancel,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                          ),
                          child: const Text('Atrás'),
                        ),
                      ],
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  title: const Text('Logo de la Tienda'),
                  subtitle: const Text('Imagen principal de tu negocio'),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0
                      ? StepState.complete
                      : StepState.indexed,
                  content: StepLogoPicker(
                    initialImage: _logoFile,
                    onImageSelected: (file) => setState(() => _logoFile = file),
                  ),
                ),
                Step(
                  title: const Text('Datos Personales'),
                  subtitle: const Text('Información de contacto'),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1
                      ? StepState.complete
                      : StepState.indexed,
                  content: StepPersonalData(
                    formKey: _personalFormKey,
                    fullNameController: _fullNameController,
                    phoneController: _phoneController,
                    fullNameFieldKey: _fullNameFieldKey,
                    phoneFieldKey: _phoneFieldKey,
                  ),
                ),
                Step(
                  title: const Text('Datos del Negocio'),
                  subtitle: const Text('Nombre, categoría y ubicación'),
                  isActive: _currentStep >= 2,
                  state: _currentStep > 2
                      ? StepState.complete
                      : StepState.indexed,
                  content: StepBusinessData(
                    formKey: _businessFormKey,
                    nameController: _businessNameController,
                    descriptionController: _businessDescriptionController,
                    selectedCategory: _selectedCategory,
                    categories: _categories,
                    onCategoryChanged: (cat) =>
                        setState(() => _selectedCategory = cat),
                    latitude: _selectedLatitude,
                    longitude: _selectedLongitude,
                    address: _selectedAddress,
                    onLocationSelected: (lat, lng, address) {
                      setState(() {
                        _selectedLatitude = lat;
                        _selectedLongitude = lng;
                        _selectedAddress = address;
                      });
                    },
                    nameFieldKey: _businessNameFieldKey,
                    categoryFieldKey: _categoryFieldKey,
                  ),
                ),
                Step(
                  title: const Text('Datos de Campaña'),
                  subtitle: const Text('Premio principal y puntos'),
                  isActive: _currentStep >= 3,
                  state: _currentStep == 3
                      ? StepState.editing
                      : StepState.indexed,
                  content: StepCampaignData(
                    formKey: _campaignFormKey,
                    rewardController: _rewardDescriptionController,
                    rewardLongController: _rewardLongDescriptionController,
                    pointsController: _pointsRequiredController,
                    rewardFieldKey: _rewardFieldKey,
                    pointsFieldKey: _pointsFieldKey,
                  ),
                ),
              ],
            ),
    );
  }
}
