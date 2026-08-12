import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class StepLogoPicker extends StatefulWidget {
  final XFile? initialImage;
  final ValueChanged<XFile?> onImageSelected;

  const StepLogoPicker({
    super.key,
    this.initialImage,
    required this.onImageSelected,
  });

  @override
  State<StepLogoPicker> createState() => _StepLogoPickerState();
}

class _StepLogoPickerState extends State<StepLogoPicker> {
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imageFile = widget.initialImage;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
        widget.onImageSelected(_imageFile);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Añade el logo de tu negocio', style: AppTypography.subtitleBold, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          'Introducir logo de negocio (tu tienda o marca, no foto del dueño)',
          style: AppTypography.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Center(
          child: Stack(
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.pastelOf(AppColors.accentPurple),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 2),
                  image: _imageFile != null
                      ? DecorationImage(
                          image: kIsWeb
                              ? NetworkImage(_imageFile!.path) as ImageProvider
                              : FileImage(File(_imageFile!.path))
                                    as ImageProvider,
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imageFile == null
                    ? Icon(LucideIcons.store, size: 56, color: AppColors.accentPurple)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(LucideIcons.images),
                              title: const Text('Galería'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.gallery);
                              },
                            ),
                            ListTile(
                              leading: const Icon(LucideIcons.camera),
                              title: const Text('Cámara'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.camera);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.camera, color: AppColors.onPrimary, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
