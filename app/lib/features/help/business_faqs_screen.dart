import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_typography.dart';

class BusinessFaqsScreen extends StatelessWidget {
  const BusinessFaqsScreen({super.key});

  static const List<_FaqItem> _faqs = [
    _FaqItem(
      icon: LucideIcons.store,
      color: AppColors.accentPurple,
      question: '¿Cómo activo mi negocio?',
      answer:
          'Al crear tu negocio, te enviamos a WhatsApp el mensaje de activación. Un administrador de Donde Siempre revisará tu solicitud y activará tu cuenta. Una vez activo, tu código QR estará disponible para que tus clientes lo escaneen.',
    ),
    _FaqItem(
      icon: LucideIcons.qrCode,
      color: AppColors.accentGreen,
      question: '¿Cómo comparto mi código QR?',
      answer:
          'En tu dashboard, entra a la pestaña QR. Desde ahí puedes guardar la imagen directamente en la galería de tu teléfono o exportar un PDF listo para imprimir. También puedes compartirlo por WhatsApp, redes sociales o cualquier app.',
    ),
    _FaqItem(
      icon: LucideIcons.zap,
      color: AppColors.accentPink,
      question: '¿Cómo funciona el sistema de puntos?',
      answer:
          'Cada cliente escanea tu QR y el escaneo queda en "Pendientes". Tú apruebas el escaneo y el cliente recibe 1 punto. Cuando acumula los puntos necesarios (que tú configuras en tu perfil), se genera automáticamente un premio que debes entregar.',
    ),
    _FaqItem(
      icon: LucideIcons.circlePlus,
      color: AppColors.accentAmber,
      question: '¿Puedo darle puntos manualmente a un cliente?',
      answer:
          'Sí. En la pestaña Clientes, toca los tres puntos al lado del nombre del cliente y elige "Puntos". Puedes asignar los puntos que quieras. Esta acción crea un registro automáticamente como si hubiera sido un escaneo.',
    ),
    _FaqItem(
      icon: LucideIcons.lock,
      color: AppColors.accentPink,
      question: '¿Por qué no puedo darle puntos a un cliente?',
      answer:
          'Si un cliente ya tiene un premio pendiente en tu negocio, no se pueden agregar más puntos hasta que ese premio sea entregado y aprobado. El botón aparecerá bloqueado con el mensaje "Premio pendiente".',
    ),
    _FaqItem(
      icon: LucideIcons.gift,
      color: AppColors.accentGreen,
      question: '¿Cómo entrego un premio?',
      answer:
          'Cuando un cliente alcanza los puntos necesarios, aparecerá en tu pestaña Premios. Al entregar el premio físicamente al cliente, toca "Entregar" en la app para marcarlo como completado. Así se reinicia el contador del cliente.',
    ),
    _FaqItem(
      icon: LucideIcons.hourglass,
      color: AppColors.accentPurple,
      question: '¿Qué pasa si rechazo un escaneo?',
      answer:
          'El cliente no recibe el punto y el escaneo queda marcado como rechazado. Usa esto cuando el cliente no realizó una compra real o si el escaneo fue inválido.',
    ),
    _FaqItem(
      icon: LucideIcons.clock,
      color: AppColors.textSecondary,
      question: '¿Qué es el tiempo de espera entre escaneos (cooldown)?',
      answer:
          'Es el tiempo mínimo que debe pasar entre dos escaneos del mismo cliente. Lo configuras en tu perfil. Evita que alguien escanee repetidamente sin realizar una compra real. El valor por defecto es 4 horas.',
    ),
    _FaqItem(
      icon: LucideIcons.chartNoAxesColumn,
      color: AppColors.accentGreen,
      question: '¿Cómo veo las estadísticas de mi negocio?',
      answer:
          'En el dashboard principal ves tarjetas con el resumen: total de clientes activos, escaneos del mes, premios entregados y más. Para el historial completo de escaneos y premios, usa la sección Historial.',
    ),
    _FaqItem(
      icon: LucideIcons.users,
      color: AppColors.accentPurple,
      question: '¿Cómo veo el progreso de mis clientes?',
      answer:
          'En la pestaña Clientes, cada tarjeta muestra tres datos: puntos actuales vs puntos requeridos para el premio (en morado), total de escaneos históricos y cantidad de premios ya ganados.',
    ),
    _FaqItem(
      icon: LucideIcons.pencil,
      color: AppColors.accentPink,
      question: '¿Puedo cambiar la cantidad de puntos necesarios?',
      answer:
          'Sí. Desde tu perfil (ícono de lápiz en el dashboard) puedes modificar los puntos requeridos, la descripción del premio y otros datos de tu campaña. Los cambios aplican para nuevos clientes y para el conteo actual.',
    ),
    _FaqItem(
      icon: LucideIcons.trash2,
      color: AppColors.textSecondary,
      question: '¿Cómo elimino mi cuenta de negocio?',
      answer:
          'Desde tu perfil, al final de la página encontrarás "Eliminar mi cuenta". Deberás escribir la palabra ELIMINAR para confirmar. Esta acción es irreversible y borra todos los datos de tu negocio.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Preguntas frecuentes', style: AppTypography.titleBold.copyWith(fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Header banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accentPurple.withValues(alpha: 0.12),
                  AppColors.accentPink.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadii.card),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.store,
                  size: 32,
                  color: AppColors.accentPurple,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Guía para dueños',
                        style: AppTypography.subtitleBold.copyWith(fontSize: 15, color: AppColors.accentPurple),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Todo lo que necesitas saber para gestionar tu programa de fidelidad.',
                        style: AppTypography.bodyMedium.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ..._faqs.map((faq) => _FaqCard(item: faq)),
          const SizedBox(height: 24),
          // Footer contact
          InkWell(
            onTap: () async {
              final Uri whatsappUrl = Uri.parse('https://wa.me/593995371895');
              if (await canLaunchUrl(whatsappUrl)) {
                await launchUrl(whatsappUrl);
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
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.pastelOf(item.color),
              borderRadius: BorderRadius.circular(AppRadii.badge),
            ),
            child: Icon(item.icon, color: item.color, size: 22),
          ),
          title: Text(
            item.question,
            style: AppTypography.bodyRegular.copyWith(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item.answer,
                style: AppTypography.bodyMedium.copyWith(fontSize: 13, height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
