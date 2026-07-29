import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../qr_management/qr_management_screen.dart';
import '../rewards/rewards_management_screen.dart';
import '../profile/business_profile_screen.dart';
import '../create_business_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/shared_widgets.dart';

import 'providers/dashboard_provider.dart';
import 'widgets/dashboard_animated_toast.dart';
import 'widgets/tabs/tab_customers.dart';
import 'widgets/tabs/tab_pending_scans.dart';
import 'widgets/tabs/tab_statistics.dart';
import '../../auth/providers/auth_provider.dart';

class BusinessDashboardScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const BusinessDashboardScreen({super.key, this.initialIndex = 0});

  /// Canal para que servicios externos (ej. el push de notificaciones) pidan
  /// que el dashboard raíz —que ya está vivo— salte a una pestaña concreta.
  static final ValueNotifier<int?> tabRequest = ValueNotifier<int?>(null);

  /// Pide que el dashboard activo se mueva a la pestaña [index].
  static void goToTab(int index) => tabRequest.value = index;

  @override
  ConsumerState<BusinessDashboardScreen> createState() => _BusinessDashboardScreenState();
}

class _BusinessDashboardScreenState extends ConsumerState<BusinessDashboardScreen> with WidgetsBindingObserver, TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _tabController = TabController(length: 5, vsync: this, initialIndex: widget.initialIndex);
    BusinessDashboardScreen.tabRequest.addListener(_onTabRequest);

    // El provider ya carga en su build() y se suscribe al realtime con canales
    // filtrados por business_id. Acá solo refrescamos si quedó viejo (ej. al
    // volver de una notificación push) y resolvemos la pestaña pedida.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).reloadIfStale();
      _checkWelcomeMessage();
      _onTabRequest();
    });
  }

  void _onTabRequest() {
    final requested = BusinessDashboardScreen.tabRequest.value;
    if (requested == null) return;
    if (mounted && requested >= 0 && requested < _tabController.length) {
      _tabController.animateTo(requested);
    }
    BusinessDashboardScreen.tabRequest.value = null; // consumido
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    BusinessDashboardScreen.tabRequest.removeListener(_onTabRequest);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Al volver del background refrescamos solo si los datos quedaron viejos,
      // evitando una recarga completa en cada resume.
      if (mounted) {
        ref.read(dashboardProvider.notifier).reloadIfStale();
      }
    }
  }

  // Stub: sin backend conectado — no hay señal real de "negocio recién
  // activado", así que el mensaje de bienvenida no se dispara automáticamente.
  void _checkWelcomeMessage() {}

  Future<void> _pickAndUploadLogo(Map<String, dynamic> business) async {
    final ImagePicker picker = ImagePicker();

    final source = await showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 5, width: 40, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 32),
            Text('Foto de perfil', style: AppTypography.titleBold.copyWith(fontSize: 16)),
            const SizedBox(height: 32),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.pastelOf(AppColors.accentPurple), shape: BoxShape.circle),
                child: const Icon(LucideIcons.images, color: AppColors.accentPurple),
              ),
              title: Text('Elegir de galería', style: AppTypography.subtitleBold.copyWith(fontSize: 14)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.pastelOf(AppColors.accentAmber), shape: BoxShape.circle),
                child: const Icon(LucideIcons.camera, color: AppColors.accentAmber),
              ),
              title: Text('Tomar foto', style: AppTypography.subtitleBold.copyWith(fontSize: 14)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            if (business['logo_url'] != null) ...[
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.pastelOf(AppColors.error), shape: BoxShape.circle),
                  child: const Icon(LucideIcons.trash2, color: AppColors.error),
                ),
                title: Text('Eliminar foto', style: AppTypography.subtitleBold.copyWith(fontSize: 14, color: AppColors.error)),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );

    if (source == null) return;

    if (source == 'delete') {
      if (mounted) {
        DashboardAnimatedToast.show(context, 'Foto eliminada exitosamente', AppColors.accentGreen, LucideIcons.circleCheck);
      }
      return;
    }

    final XFile? pickedFile = await picker.pickImage(
      source: source as ImageSource,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (pickedFile == null || !mounted) return;

    DashboardAnimatedToast.show(context, 'Logo actualizado exitosamente', AppColors.accentGreen, LucideIcons.circleCheck);
  }

  void _showPendingRewardOverlay() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: AppColors.surfaceCard, borderRadius: BorderRadius.circular(AppRadii.card)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppColors.pastelOf(AppColors.accentAmber), shape: BoxShape.circle),
                child: const Icon(LucideIcons.trophy, size: 48, color: AppColors.accentAmber),
              ),
              const SizedBox(height: 20),
              Text('¡Premio pendiente!', style: AppTypography.titleBold, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                'Este cliente ya ganó un premio. No podés agregar más puntos hasta que lo retires y lo marques como entregado.',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              PrimaryButton(label: 'Entendido', onPressed: () => Navigator.pop(ctx)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardProvider);

    ref.listen<DashboardState>(dashboardProvider, (previous, next) {
      if (next.toastMessage != null && next.toastMessage != previous?.toastMessage) {
        if (next.toastMessage == 'ERROR_PENDING_REWARD') {
          _showPendingRewardOverlay();
        } else {
          DashboardAnimatedToast.show(
            context,
            next.toastMessage!,
            next.toastIsError ? AppColors.error : AppColors.accentGreen,
            next.toastIsError ? LucideIcons.circleAlert : LucideIcons.circleCheck,
          );
        }
      }
    });

    if (state.isLoading && state.business == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.accentPurple)),
        ),
      );
    }

    final business = state.business;

    if (business == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Mi Negocio')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(48),
                  decoration: BoxDecoration(color: AppColors.pastelOf(AppColors.accentPurple), shape: BoxShape.circle),
                  child: const Icon(LucideIcons.store, size: 72, color: AppColors.accentPurple),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Sin negocio', style: AppTypography.displayBold.copyWith(fontSize: 22), textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Registra tu local para empezar a fidelizar a tus clientes con puntos y premios.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: 'Registrar mi local',
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateBusinessScreen()));
                    ref.read(dashboardProvider.notifier).loadData();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    String ownerDisplayName = '';
    if (state.ownerName.isNotEmpty) {
      final parts = state.ownerName.trim().split(RegExp(r'\s+'));
      ownerDisplayName = parts.length >= 2 ? '${parts[0]} ${parts[1]}' : parts[0];
    }

    return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          toolbarHeight: 90,
          leadingWidth: 90,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BusinessProfileScreen(business: business, ownerName: state.ownerName)),
                );
                if (result == true) {
                  // Recarga silenciosa: evita el parpadeo de reconstruir todo el dashboard.
                  ref.read(dashboardProvider.notifier).loadData(silent: true);
                }
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Hero(
                    tag: 'business_logo',
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.pastelOf(AppColors.textSecondary),
                      backgroundImage: business['logo_url'] != null ? NetworkImage(business['logo_url']) : null,
                      child: business['logo_url'] == null
                          ? const Icon(LucideIcons.store, color: AppColors.textSecondary, size: 26)
                          : null,
                    ),
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: GestureDetector(
                      onTap: () => _pickAndUploadLogo(business),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.accentPurple, AppColors.accentPink], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(LucideIcons.pencil, size: 14, color: Colors.white),
                      ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(duration: const Duration(seconds: 1), begin: const Offset(1, 1), end: const Offset(1.15, 1.15), curve: Curves.easeInOut).shimmer(duration: const Duration(seconds: 3), color: Colors.white.withValues(alpha: 0.5)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ownerDisplayName.isNotEmpty)
                Text('Hola, $ownerDisplayName', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600)),
              Text(
                business['name'].toString(),
                style: AppTypography.titleBold.copyWith(fontSize: 18),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.accentGreen, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('${state.customers.length} clientes activos', style: AppTypography.caption.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          actions: [
            IconActionButton(
              icon: LucideIcons.logOut,
              tooltip: 'Cerrar sesión',
              onPressed: () async {
                await ref.read(authStateProvider.notifier).logout();
              },
            ),
            const SizedBox(width: 8),
          ],
          bottom: TabBar(
            controller: _tabController,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            labelStyle: AppTypography.labelBold.copyWith(fontSize: 11),
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            isScrollable: true,
            tabs: [
              const Tab(text: 'Clientes'),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Pendientes'),
                    if (state.pendingScans.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      CounterBadge(count: state.pendingScans.length, color: AppColors.accentPink),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Premios'),
                    if (state.pendingRewards.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      CounterBadge(count: state.pendingRewards.length, color: AppColors.accentPurple),
                    ],
                  ],
                ),
              ),
              const Tab(text: 'Métricas'),
              const Tab(text: 'QR Codes'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: [
              const TabCustomers(),
              const TabPendingScans(),
              RewardsManagementScreen(businessId: business['id']),
              const TabStatistics(),
              QRManagementScreen(businessId: business['id']),
            ],
          ),
        ),
    );
  }
}
