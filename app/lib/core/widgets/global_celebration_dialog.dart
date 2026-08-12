import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';
import '../../shared/widgets/shared_widgets.dart';

class GlobalCelebrationDialog extends StatefulWidget {
  final String title;
  final String message;
  final String iconType; // 'reward' or 'transfer'

  const GlobalCelebrationDialog({
    super.key,
    required this.title,
    required this.message,
    this.iconType = 'reward',
  });

  // Evita que se apilen varios diálogos de celebración a la vez (por ejemplo si
  // el push y el realtime disparan casi juntos). Solo se muestra uno.
  static bool _isOpen = false;

  static Future<void> show(BuildContext context, {required String title, required String message, String iconType = 'reward'}) async {
    if (_isOpen) return;
    _isOpen = true;
    try {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => GlobalCelebrationDialog(
          title: title,
          message: message,
          iconType: iconType,
        ),
      );
    } finally {
      _isOpen = false;
    }
  }

  @override
  State<GlobalCelebrationDialog> createState() => _GlobalCelebrationDialogState();
}

class _GlobalCelebrationDialogState extends State<GlobalCelebrationDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
      content: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            maxBlastForce: 100,
            minBlastForce: 80,
            gravity: 0.1,
            colors: [
              AppColors.accentPurple,
              AppColors.accentGreen,
              AppColors.accentAmber,
              AppColors.accentPink,
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.pastelOf(AppColors.accentGreen),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.iconType == 'transfer' ? LucideIcons.arrowLeftRight : LucideIcons.partyPopper,
                  size: 56,
                  color: AppColors.accentGreen,
                ),
              )
              .animate(onPlay: (c) => c.repeat())
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.2, 1.2),
                duration: 600.ms,
                curve: Curves.elasticOut,
              )
              .then()
              .scale(
                begin: const Offset(1.2, 1.2),
                end: const Offset(0.8, 0.8),
              ),
              const SizedBox(height: 32),
              Text(widget.title, style: AppTypography.titleBold, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              Text(widget.message, textAlign: TextAlign.center, style: AppTypography.bodyRegular),
              const SizedBox(height: 24),
            ],
          ),
        ],
      ),
      actions: [
        PrimaryButton(label: 'Entendido', onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}
