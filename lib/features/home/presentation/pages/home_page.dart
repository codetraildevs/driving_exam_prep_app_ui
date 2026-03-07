import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../../shared/subscription/subscription_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userName = context.select<AuthBloc, String>((bloc) {
      final state = bloc.state;
      if (state is AuthAuthenticated && state.user.name.trim().isNotEmpty) {
        return state.user.name.trim();
      }
      return 'Driver';
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Column(
          children: [
            _CompactHeader(l10n: l10n, userName: userName),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CompactAccessCard(l10n: l10n),
                    const SizedBox(height: 20),
                    Text(
                   l10n.homeServices,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ResponsiveServicesGrid(l10n: l10n),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPACT HEADER — shorter, gradient, with greeting and optional right icon
// ─────────────────────────────────────────────────────────────────────────────

/// The type of icon shown in the right section of [_CompactHeader].
enum CompactHeaderIconType {
  /// Notification bell with optional badge.
  notification,
  /// Refresh/reload icon.
  refresh,
  /// No icon (empty right section).
  none,
}

class _CompactHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final String userName;

  /// Type of icon to show on the right. Defaults to [CompactHeaderIconType.notification].
  final CompactHeaderIconType iconType;

  /// Action to perform when the right icon is tapped.
  final VoidCallback? onIconTap;

  /// Whether to show a badge dot on the notification icon.
  final bool showBadge;

  const _CompactHeader({
    required this.l10n,
    required this.userName,
    this.iconType = CompactHeaderIconType.notification,
    this.onIconTap,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 12, 12, 18),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradientFor(Theme.of(context).brightness),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          // Left: greeting block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.homeWelcomeBack,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textInverse.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.homeGreeting(userName),
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textInverse,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.homeContinueMessage,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textInverse.withValues(alpha: 0.75),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Right: optional icon
          if (iconType != CompactHeaderIconType.none)
            Stack(
              children: [
                IconButton(
                  icon: Icon(
                    iconType == CompactHeaderIconType.refresh
                        ? Icons.refresh_rounded
                        : Icons.notifications_outlined,
                    color: AppColors.textInverse,
                    size: 26,
                  ),
                  onPressed: onIconTap,
                ),
                if (showBadge && iconType == CompactHeaderIconType.notification)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPACT ACCESS CARD — single row with progress indicator, no wasted space
// ─────────────────────────────────────────────────────────────────────────────

class _CompactAccessCard extends StatelessWidget {
  final AppLocalizations l10n;

  const _CompactAccessCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionProvider>();
    final hasAccess = sub.hasActiveAccess;
    final expiresAt = sub.expiresAt;

    // Compute days left for progress ring.
    int daysLeft = 0;
    int totalDays = 180;
    if (hasAccess && expiresAt != null) {
      // Clamp to a large value to avoid overflow — display handles "999+ days" gracefully.
      daysLeft = expiresAt.difference(DateTime.now()).inDays.clamp(0, 9999);
      // Guess total days from tier label if available.
      final tier = sub.paymentTier ?? '';
      if (tier.contains('1_MONTH')) totalDays = 30;
      else if (tier.contains('3_MONTH')) totalDays = 90;
      else totalDays = 180;
    }
    final progress = hasAccess && totalDays > 0
        ? (daysLeft / totalDays).clamp(0.0, 1.0)
        : 0.0;

    final tierLabel = () {
      final t = sub.paymentTier ?? '';
      if (t.contains('1_MONTH')) return '1 MONTH';
      if (t.contains('3_MONTH')) return '3 MONTHS';
      if (t.contains('6_MONTH')) return '6 MONTHS';
      return t.isEmpty ? '' : t;
    }();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasAccess ? null : () => context.push('/subscription'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasAccess
                ? AppColors.success.withValues(alpha: 0.3)
                : AppColors.primary.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular indicator
            SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: hasAccess ? progress : 0.0,
                    strokeWidth: 4,
                    backgroundColor:
                        Theme.of(context).colorScheme.outline.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      hasAccess
                          ? AppColors.success
                          : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  Center(
                    child: Icon(
                      hasAccess ? Icons.check : Icons.lock_outline,
                      color: hasAccess
                          ? AppColors.success
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasAccess
                        ? l10n.homeAccessActive(daysLeft)
                        : l10n.subscriptionTitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasAccess && tierLabel.isNotEmpty
                        ? l10n.homePaymentTier(tierLabel)
                        : l10n.subscriptionSubtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // CTA chip
            FilledButton(
              onPressed: () {
                if (hasAccess) {
                  context.push('/practice');
                } else {
                  context.push('/subscription');
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor:
                    hasAccess ? AppColors.primary : AppColors.accent,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                hasAccess ? l10n.homeContinueLearning : l10n.subscriptionRequestAccess,
                style: const TextStyle(fontSize: 12, color: AppColors.textInverse),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESPONSIVE SERVICES GRID — adapts columns + card height to screen width
// ─────────────────────────────────────────────────────────────────────────────

class _ResponsiveServicesGrid extends StatelessWidget {
  final AppLocalizations l10n;

  const _ResponsiveServicesGrid({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // 2 columns on phones, 3 on tablets, 4 on wide
    final crossAxisCount = width >= 900 ? 4 : (width >= 600 ? 3 : 2);
    // Smaller card height for compact look
    final cardHeight = width >= 600 ? 120.0 : 110.0;

    final services = _buildServiceList(context, l10n);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: cardHeight,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return _AnimatedServiceCard(
          item: services[index],
          index: index,
        );
      },
    );
  }

  List<_ServiceItem> _buildServiceList(
      BuildContext context, AppLocalizations l10n) {
    return [
      _ServiceItem(
        icon: Icons.traffic_rounded,
        title: l10n.homePractices,
        subtitle: l10n.homePracticesSubtitle,
        color: AppColors.primary,
        onTap: () => context.push('/practice'),
      ),
      _ServiceItem(
        icon: Icons.menu_book_rounded,
        title: l10n.homeCourses,
        subtitle: l10n.homeCoursesSubtitle,
        color: AppColors.accent,
        onTap: () => context.push('/courses'),
      ),
      _ServiceItem(
        icon: Icons.assignment_rounded,
        title: l10n.homeMockExams,
        subtitle: l10n.homeMockExamsSubtitle,
        color: AppColors.warning,
        onTap: () => context.push('/practice'),
      ),
      _ServiceItem(
        icon: Icons.show_chart_rounded,
        title: l10n.homeProgress,
        subtitle: l10n.homeProgressSubtitle,
        color: AppColors.success,
        onTap: () => context.push('/progress'),
      ),
      _ServiceItem(
        icon: Icons.share_rounded,
        title: l10n.homeShareApp,
        subtitle: l10n.homeShareAppSubtitle,
        color: AppColors.primaryLight,
        onTap: () {},
      ),
    ];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATED SERVICE CARD — compact, staggered entrance, subtle press effect
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedServiceCard extends StatefulWidget {
  final _ServiceItem item;
  final int index;

  const _AnimatedServiceCard({required this.item, required this.index});

  @override
  State<_AnimatedServiceCard> createState() => _AnimatedServiceCardState();
}

class _AnimatedServiceCardState extends State<_AnimatedServiceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Stagger entrance by index
    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) {
            setState(() => _pressed = false);
            item.onTap();
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 120),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: item.color.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon — smaller, tighter
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, color: item.color, size: 22),
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    item.title,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),

                  // Subtitle — shows context, keeps card useful
                  Text(
                    item.subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SERVICE ITEM MODEL
// ─────────────────────────────────────────────────────────────────────────────

class _ServiceItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  _ServiceItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}