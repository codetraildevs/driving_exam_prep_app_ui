import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

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
        backgroundColor: AppColors.background,
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
                        color: AppColors.textPrimary,
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
// COMPACT HEADER — shorter, gradient, with greeting and notification bell
// ──────────────────────────────────────────────────────────────────────���──────

class _CompactHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final String userName;

  const _CompactHeader({required this.l10n, required this.userName});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding + 12, 12, 18),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
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
                    color: AppColors.textInverse.withOpacity(0.85),
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
                    color: AppColors.textInverse.withOpacity(0.75),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Right: notification + avatar
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: AppColors.textInverse, size: 26),
                onPressed: () {},
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
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
    const int daysLeft = 175;
    const int totalDays = 180;
    const progress = daysLeft / totalDays;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular progress
          SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.grey.withOpacity(0.12),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
                Center(
                  child: Icon(Icons.check, color: Colors.green, size: 18),
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
                  l10n.homeAccessActive(daysLeft),
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.homePaymentTier('6 MONTHS'),
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
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              l10n.homeContinueLearning,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
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
        onTap: () => context.push('/exam'),
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
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: item.color.withOpacity(0.08),
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
                      color: item.color.withOpacity(0.12),
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