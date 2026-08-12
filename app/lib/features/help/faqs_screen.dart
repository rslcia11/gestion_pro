import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/shared_widgets.dart';

class FaqsScreen extends StatelessWidget {
  const FaqsScreen({super.key});

  static const List<_FaqItem> _faqs = [
    _FaqItem(
      icon: LucideIcons.idCard,
      color: AppColors.accentPurple,
      question: '¿Qué es una tarjeta de fidelidad?',
      answer:
          'Cada tarjeta representa un negocio afiliado a Donde Siempre. Acumulas puntos en ese negocio escaneando su código QR y, cuando completas la tarjeta, ganas el premio que ese local te ofrece.',
    ),
    _FaqItem(
      icon: LucideIcons.qrCode,
      color: AppColors.accentGreen,
      question: '¿Cómo gano puntos?',
      answer:
          'Toca el botón "Escanear QR" desde tu pantalla principal y apunta la cámara al código QR del negocio. Cada escaneo válido suma 1 punto a la tarjeta de ese negocio.',
    ),
    _FaqItem(
      icon: LucideIcons.chartNoAxesColumn,
      color: AppColors.accentPink,
      question: '¿Cómo veo mi progreso?',
      answer:
          'Dentro de cada tarjeta verás una barra que muestra tu avance hacia el premio. El porcentaje indica qué tan cerca estás de canjearlo.',
    ),
    _FaqItem(
      icon: LucideIcons.gift,
      color: AppColors.accentAmber,
      question: '¿Cómo canjeo mi premio?',
      answer:
          'Cuando llenes la tarjeta acércate al local y muestra tu premio en la pestaña "Premios". El negocio aprobará el canje y se marcará como entregado.',
    ),
    _FaqItem(
      icon: LucideIcons.arrowLeftRight,
      color: AppColors.accentPurple,
      question: '¿Puedo transferir un premio a otra persona?',
      answer:
          'Sí. En la pestaña "Premios" toca "Transferir" e ingresa el correo de un amigo registrado en Donde Siempre. El premio se moverá a su cuenta.',
    ),
    _FaqItem(
      icon: LucideIcons.clock,
      color: AppColors.accentPink,
      question: '¿Por qué no puedo escanear el mismo QR dos veces seguidas?',
      answer:
          'Cada negocio define un tiempo de espera entre escaneos (cooldown). Esto evita acumulaciones automáticas. Puedes escanear en otros locales mientras tanto.',
    ),
    _FaqItem(
      icon: LucideIcons.lock,
      color: AppColors.accentGreen,
      question: '¿Cómo cambio mi contraseña?',
      answer:
          'En tu perfil toca "Cambiar contraseña". Necesitas al menos 6 caracteres. Tu correo no se puede modificar.',
    ),
    _FaqItem(
      icon: LucideIcons.trash2,
      color: AppColors.textSecondary,
      question: '¿Cómo elimino mi cuenta?',
      answer:
          'Desde tu perfil toca "Eliminar mi cuenta". La acción es irreversible: borramos todos tus datos personales conforme a privacidad.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: AppBarTitle('Preguntas frecuentes', style: AppTypography.titleBold.copyWith(fontSize: 16)),
        centerTitle: true,
        leading: IconActionButton(
          icon: LucideIcons.arrowLeft,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.pastelOf(AppColors.accentPurple),
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.fileText, size: 32, color: AppColors.accentPurple),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Manual de uso de Donde Siempre',
                    style: AppTypography.subtitleBold.copyWith(fontSize: 16, color: AppColors.accentPurple),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ..._faqs.map((faq) => _FaqCard(item: faq)),
          const SizedBox(height: 24),
          InkWell(
            onTap: () async {
              final Uri whatsappUrl = Uri.parse('https://wa.me/593995371895');
              if (await canLaunchUrl(whatsappUrl)) {
                await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
              }
            },
            borderRadius: BorderRadius.circular(AppRadii.card),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.pastelOf(AppColors.accentGreen),
                borderRadius: BorderRadius.circular(AppRadii.card),
                border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.handHeart, color: AppColors.accentGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '¿Tienes otra pregunta? Escríbenos por WhatsApp y te ayudamos en el momento.',
                      style: AppTypography.bodyMedium.copyWith(fontSize: 12, color: AppColors.accentGreen),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _FaqItem {
  final IconData icon;
  final Color color;
  final String question;
  final String answer;

  const _FaqItem({
    required this.icon,
    required this.color,
    required this.question,
    required this.answer,
  });
}

class _FaqCard extends StatelessWidget {
  final _FaqItem item;

  const _FaqCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: AppShadows.card,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Icon(item.icon, color: item.color, size: 28),
          title: Text(
            item.question,
            style: AppTypography.bodyRegular.copyWith(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item.answer,
                style: AppTypography.bodyMedium.copyWith(fontSize: 13, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
