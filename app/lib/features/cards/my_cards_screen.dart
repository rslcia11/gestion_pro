import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../scanner/scanner_screen.dart';
import 'card_history_screen.dart';
import '../profile/user_profile_screen.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/shared_widgets.dart';
import 'providers/my_cards_provider.dart';
import 'dart:async';
import '../../core/services/realtime_sync_service.dart';
import '../../core/widgets/global_celebration_dialog.dart';

class MyCardsScreen extends ConsumerStatefulWidget {
  const MyCardsScreen({super.key});

  /// Resetea el flag de sesión (recordatorio de premio) al cerrar sesión,
  /// para que el próximo usuario en el mismo proceso lo vea bien.
  static void resetSessionFlags() {
    _MyCardsScreenState._pendingRewardShown = false;
  }

  @override
  ConsumerState<MyCardsScreen> createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends ConsumerState<MyCardsScreen> {
  late ConfettiController _confettiController;
  static bool _pendingRewardShown = false;

  StreamSubscription<void>? _rewardsSub;
  StreamSubscription<void>? _scansSub;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));

    // Bind real-time event handlers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(myCardsProvider.notifier);
      notifier.onCardCompleted = _showCelebrationDialog;
      notifier.onPointEarned = _showPointEarnedAnimation;
      
      // Evitar que el diálogo salte si la pantalla está oculta detrás del RegisterScreen
      if (ModalRoute.of(context)?.isCurrent == true) {
        _checkWelcomeMessage();
      }
    });

    // Nota: los cambios de loyalty_cards ya los maneja el canal filtrado del
    // provider (que además dispara la celebración). Acá solo escuchamos rewards
    // y scans (que el provider no cubre) y todo pasa por el debounce del notifier.
    _rewardsSub = RealtimeSyncService().onRewardsChanged.listen((_) {
      if (mounted) {
        ref.read(myCardsProvider.notifier).scheduleRefresh();
      }
    });
    // Un escaneo pendiente (recién hecho) debe reordenar la tarjeta al tope en vivo,
    // aunque no cambie la fila de loyalty_cards.
    _scansSub = RealtimeSyncService().onScansChanged.listen((_) {
      if (mounted) {
        ref.read(myCardsProvider.notifier).scheduleRefresh();
      }
    });
  }

  @override
  void dispose() {
    _rewardsSub?.cancel();
    _scansSub?.cancel();
    _confettiController.dispose();
    super.dispose();
  }

  void _showPointEarnedAnimation() {
    if (!mounted) return;
    _confettiController.play();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Punto aprobado! Sumaste 1 punto ✨', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.accentGreen,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Stub: sin backend conectado — no hay señal real de "usuario nuevo",
  // así que el mensaje de bienvenida no se dispara automáticamente.
  void _checkWelcomeMessage() {}

  void _showCelebrationDialog() {
    if (!mounted) return;
    GlobalCelebrationDialog.show(
      context,
      title: '¡FELICIDADES!',
      message: '¡Felicidades! Espera o acércate al local para que aprueben tu premio.',
      iconType: 'reward',
    );
  }

  /// Si el usuario tiene un premio sin reclamar (por si borró la notificación
  /// por accidente), le mostramos un modal al reingresar a la app con un botón
  /// que lo lleva directo al premio. Solo una vez por arranque de la app.
  void _checkPendingRewards() {
    if (_pendingRewardShown || !mounted) return;
    // Si hay otro diálogo o pantalla por encima (ej. bienvenida), no lo apilamos.
    if (ModalRoute.of(context)?.isCurrent != true) return;

    final state = ref.read(myCardsProvider);
    Map<String, dynamic>? cardWithReward;
    for (final card in state.cards) {
      final rewards = (card['rewards'] as List?) ?? const [];
      // Solo 'pending': si el premio ya está entregado ('approved') no molestamos
      // al cliente con el recordatorio en cada inicio de sesión.
      final hasUnclaimed =
          rewards.any((r) => (r as Map)['status'] == 'pending');
      if (hasUnclaimed) {
        cardWithReward = card;
        break;
      }
    }

    if (cardWithReward == null) return;
    _pendingRewardShown = true;
    _showPendingRewardDialog(cardWithReward);
  }

  void _showPendingRewardDialog(Map<String, dynamic> card) {
    final business = card['businesses'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.pastelOf(AppColors.accentAmber),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.gift, color: AppColors.accentAmber, size: 44),
            ).animate().scale(duration: 450.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 16),
            Text(
              '¡Tienes un premio!',
              style: AppTypography.titleBold,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          'Tienes un premio pendiente en ${business['name']}. ¡No te olvides de reclamarlo!',
          textAlign: TextAlign.center,
          style: AppTypography.bodyRegular,
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Después',
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PrimaryButton(
                  label: 'Ver premio',
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CardHistoryScreen(
                          loyaltyCardId: card['id'],
                          businessId: business['id'],
                          businessName: business['name'],
                          initialTabIndex: 1, // pestaña PREMIOS
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Extracts first name + last name from full_name string.
  String _getDisplayName(String fullName) {
    if (fullName.isEmpty) return '';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0]} ${parts[1]}';
    return parts[0];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(myCardsProvider);
    
    // Listen to error state
    ref.listen<MyCardsState>(myCardsProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${next.error}'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }

      // Apenas terminan de cargar las tarjetas, revisamos si hay un premio
      // pendiente para avisarle al usuario con un modal (una vez por sesión).
      final justLoaded = !next.isLoading &&
          next.cards.isNotEmpty &&
          (previous == null || previous.isLoading || previous.cards.isEmpty);
      if (justLoaded) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _checkPendingRewards());
      }
    });

    final displayName = _getDisplayName(state.userName);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: AppColors.background,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              if (displayName.isNotEmpty)
                Text('Hola, $displayName', style: AppTypography.titleBold.copyWith(fontSize: 18)),
          ],
        ),
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Center(
            child: GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserProfileScreen()),
                );
                if (result == true) {
                  // Refresco silencioso (sin spinner): actualiza foto y nombre en
                  // su lugar, sin recargar toda la pantalla ni parpadear.
                  ref.read(myCardsProvider.notifier).refreshCards(silent: true);
                }
              },
              child: Stack(
                children: [
                  UserAvatar(
                    imageUrl: state.avatarUrl,
                    initials: state.userName.isNotEmpty ? state.userName[0] : '?',
                    size: 44,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.accentPurple, AppColors.accentPink],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: const Icon(
                        LucideIcons.pencil,
                        size: 10,
                        color: Colors.white,
                      ),
                    )
                        .animate(
                          onPlay: (controller) => controller.repeat(reverse: true),
                        )
                        .scale(
                          duration: const Duration(seconds: 1),
                          begin: const Offset(1, 1),
                          end: const Offset(1.15, 1.15),
                          curve: Curves.easeInOut,
                        )
                        .shimmer(
                          duration: const Duration(seconds: 3),
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: state.isLoading && state.cards.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.cards.isEmpty
            ? _buildEmptyState(theme)
            : RefreshIndicator(
                onRefresh: () => ref.read(myCardsProvider.notifier).refreshCards(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  itemCount: state.cards.length,
                  itemBuilder: (context, index) {
                    return _LoyaltyCardItem(
                      card: state.cards[index],
                      index: index,
                      sessionLastViewedAt: state.sessionLastViewedAt,
                      onTap: () {
                        final card = state.cards[index];
                        final business = card['businesses'];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CardHistoryScreen(
                              loyaltyCardId: card['id'],
                              businessId: business['id'],
                              businessName: business['name'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: state.cards.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ScannerScreen()),
                );
              },
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
              icon: const Icon(LucideIcons.scanLine),
              label: Text('Escanear QR', style: AppTypography.subtitleBold.copyWith(color: AppColors.onPrimary, fontSize: 15)),
            ).animate().scale(delay: 1.seconds, curve: Curves.elasticOut),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 3.14 / 2, // Hacia abajo
            maxBlastForce: 5, 
            minBlastForce: 2, 
            emissionFrequency: 0.05, 
            numberOfParticles: 50, 
            gravity: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.pastelOf(AppColors.accentPurple),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.creditCard, size: 72, color: AppColors.accentPurple),
            ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),
            const SizedBox(height: AppSpacing.xl),
            Text('¡Empieza tu colección!', style: AppTypography.displayBold.copyWith(fontSize: 20)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Escanea tu primer código QR en cualquier local afiliado.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: 'Escanear ahora',
              icon: LucideIcons.scanLine,
              isFullWidth: false,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ScannerScreen()),
              ),
            ).animate(delay: 400.ms).fadeIn().moveY(begin: 20, curve: Curves.easeOut),
          ],
        ),
      ),
    );
  }
}

class _LoyaltyCardItem extends StatelessWidget {
  final Map<String, dynamic> card;
  final int index;
  final VoidCallback onTap;
  final DateTime? sessionLastViewedAt;

  const _LoyaltyCardItem({
    required this.card,
    required this.index,
    required this.onTap,
    this.sessionLastViewedAt,
  });

  @override
  Widget build(BuildContext context) {
    final business = card['businesses'];
    final currentPoints = card['current_points'] as int;
    final pointsRequired = business['points_required'] as int;
    final progress = (currentPoints / pointsRequired).clamp(0.0, 1.0);

    // Premios ganados pero todavía no entregados por el local (status 'pending').
    // Apenas el local lo entrega (status 'approved') deja de mostrarse.
    // Se actualiza EN VIVO porque el realtime de rewards dispara refreshCards.
    final rewardsList = (card['rewards'] as List?) ?? const [];
    final unclaimedRewards = rewardsList
        .where((r) => (r as Map)['status'] == 'pending')
        .toList();
    final bool hasUnclaimedReward = unclaimedRewards.isNotEmpty;

    // Colores dinámicos basados en el índice para variedad
    final accents = [
      AppColors.accentPurple,
      AppColors.accentPink,
      AppColors.accentAmber,
      AppColors.accentGreen,
    ];
    final accentColor = accents[index % accents.length];

    final String? lastScanStr = card['last_scan_at'];
    bool isRecentlyUpdated = false;
    if (lastScanStr != null) {
      final lastScan = DateTime.tryParse(lastScanStr);
      if (lastScan != null) {
        if (sessionLastViewedAt != null) {
          isRecentlyUpdated = lastScan.isAfter(sessionLastViewedAt!);
        } else {
          // Si es la primera vez que abre la app en su vida, usamos la regla de 5 mins por si acaso
          final diff = DateTime.now().toUtc().difference(lastScan);
          isRecentlyUpdated = diff.inMinutes < 5;
        }
      }
    }

    return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppRadii.card),
              boxShadow: AppShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.pastelOf(accentColor),
                        borderRadius: BorderRadius.circular(AppRadii.badge),
                        image: business['logo_url'] != null
                            ? DecorationImage(
                                image: NetworkImage(business['logo_url']),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: business['logo_url'] == null
                          ? Icon(
                              AppTheme.getCategoryIcon(
                                business['business_categories']?['name'] ?? 'Otra',
                              ),
                              color: accentColor,
                              size: 32,
                            )
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  business['name'].toString(),
                                  style: AppTypography.subtitleBold.copyWith(fontSize: 18),
                                ),
                              ),
                              if (isRecentlyUpdated)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.pastelOf(AppColors.accentGreen),
                                    borderRadius: BorderRadius.circular(AppRadii.badge),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(LucideIcons.zap, color: AppColors.accentGreen, size: 12),
                                      const SizedBox(width: 4),
                                      Text(
                                        '¡Nuevo!',
                                        style: AppTypography.labelBold.copyWith(
                                          color: AppColors.accentGreen,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ).animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1.0, end: 1.05, duration: 800.ms),
                            ],
                          ),
                          if (business['reward_description'] != null)
                            Text(
                              business['reward_description']!.toString(),
                              style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                            ),
                          if (business['reward_long_description'] != null)
                            Text(
                              business['reward_long_description'].toString(),
                              style: AppTypography.caption,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Premio ganado visible en vivo en la tarjeta.
                if (hasUnclaimedReward) ...[
                  const SizedBox(height: AppSpacing.md),
                  _RewardBanner(count: unclaimedRewards.length),
                ],

                const SizedBox(height: AppSpacing.lg),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$currentPoints / $pointsRequired puntos',
                      style: AppTypography.labelBold,
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: AppTypography.labelBold.copyWith(color: accentColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 14,
                    backgroundColor: AppColors.pastelOf(accentColor),
                    valueColor: AlwaysStoppedAnimation(accentColor),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                Row(
                  children: [
                    _MiniStat(
                      icon: LucideIcons.sparkles,
                      value: (card['total_points_lifetime'] ?? 0).toString(),
                      label: 'TOTAL',
                      color: accentColor,
                    ),
                    const Spacer(),
                    _MiniStat(
                      icon: LucideIcons.gift,
                      value: (card['rewards_claimed'] ?? 0).toString(),
                      label: 'CANJES',
                      color: AppColors.accentPink,
                    ),
                    const Spacer(),
                    _MiniStat(
                      icon: LucideIcons.calendarCheck,
                      value: 'ACTIVA',
                      label: 'ESTADO',
                      color: AppColors.accentGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        .animate(delay: (index * 100).ms)
        .slideY(begin: 0.2, curve: Curves.elasticOut, duration: 800.ms)
        .fadeIn();
  }
}

class _RewardBanner extends StatelessWidget {
  final int count;

  const _RewardBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    const Color color = AppColors.accentAmber;
    final String title = count > 1 ? '¡Tienes $count premios!' : '¡Tienes un premio!';
    const String subtitle = 'Acércate al local para reclamarlo.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.pastelOf(color),
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.gift, color: color, size: 22),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.12, duration: 800.ms, curve: Curves.easeInOut),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.subtitleBold.copyWith(color: const Color(0xFF8A6D00), fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTypography.subtitleBold.copyWith(fontSize: 14)),
            Text(label, style: AppTypography.caption.copyWith(fontSize: 10, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}


