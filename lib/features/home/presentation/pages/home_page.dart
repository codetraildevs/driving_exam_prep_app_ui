import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../config/app_config.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/locale/language_selector_page.dart';
import '../../../../shared/locale/locale_notifier.dart';
import '../../../../shared/subscription/subscription_notifier.dart';
import '../../../../shared/widgets/app_menu_button.dart';
import '../../../../shared/widgets/interactive_card.dart';
import '../../../../shared/widgets/whatsapp_groups_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/models/dashboard_notices.dart';

const _indigo = AppColors.primary;

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with WidgetsBindingObserver {
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _clock = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() {});
      unawaited(_refresh());
    }
  }

  Future<void> _refresh() async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;
    ref.invalidate(dashboardNoticesProvider(auth.user.id));
    await ref.read(subscriptionProvider.notifier).refreshStatus(auth.user.id);
  }

  Future<void> _language() async {
    final locale = await showLanguageSelectorDialog(context);
    if (!mounted || locale == null) return;
    await ref.read(localeProvider.notifier).setLocale(locale);
    unawaited(syncLanguageToBackend(locale.languageCode));
  }

  void _message(String text) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _comingSoon(String title) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) {
      final l10n = AppLocalizations.of(context);
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.construction_rounded, size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 20),
            Text(l10n.dashboardComingSoon, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(l10n.dashboardUnderDevelopment, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(onPressed: () => Navigator.pop(context), child: Text(MaterialLocalizations.of(context).backButtonTooltip)),
          ]),
        )),
      );
    }));
  }

  Future<void> _share(BuildContext cardContext) async {
    final l10n = AppLocalizations.of(context);
    final box = cardContext.findRenderObject() as RenderBox?;
    try {
      final result = await SharePlus.instance.share(ShareParams(
        text: '${l10n.homeShareAppMessage} ${AppConfig.playStoreUrl}',
        sharePositionOrigin: box != null && box.hasSize ? box.localToGlobal(Offset.zero) & box.size : null,
      ));
      if (result.status != ShareResultStatus.unavailable) return;
    } catch (_) { /* Offer an explicit copy action if sharing is unsupported. */ }
    if (!mounted) return;
    await showDialog<void>(context: context, builder: (ctx) => AlertDialog(
      title: Text(l10n.dashboardShare),
      content: const SelectableText(AppConfig.playStoreUrl),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.commonCancel)),
        FilledButton.icon(icon: const Icon(Icons.copy_outlined), label: Text(l10n.dashboardCopyLink), onPressed: () async {
          try {
            await Clipboard.setData(const ClipboardData(text: AppConfig.playStoreUrl));
            if (ctx.mounted) Navigator.pop(ctx);
            _message(l10n.dashboardLinkCopied);
          } catch (_) { _message(l10n.dashboardOpenFailed); }
        }),
      ],
    ));
  }

  Future<void> _notices(String userId) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _NoticesSheet(userId: userId),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthBloc>().state;
    final user = auth is AuthAuthenticated ? auth.user : null;
    final locale = ref.watch(localeProvider).effectiveLocale;
    final notices = user == null ? null : ref.watch(dashboardNoticesProvider(user.id));
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppColors.primaryLight : AppColors.primary;
    final surface = dark ? Theme.of(context).colorScheme.surface : Colors.white;
    final background = Theme.of(context).scaffoldBackgroundColor;
    final items = <_Shortcut>[
      _Shortcut('practice', Icons.fact_check_outlined, l10n.homePractices, l10n.homePracticesSubtitle, (_) => context.push('/practice')),
      _Shortcut('whatsapp', Icons.chat_outlined, l10n.dashboardWhatsapp, l10n.joinGroupSubtitle, (_) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const WhatsappGroupsPage()))),
      _Shortcut('gazette', Icons.menu_book_outlined, l10n.dashboardGazette, '', (_) => _comingSoon(l10n.dashboardGazette)),
      _Shortcut('irembo', Icons.account_balance_outlined, 'Irembo', '', (_) => _comingSoon('Irembo')),
      _Shortcut('progress', Icons.insights_rounded, l10n.homeProgress, '', (_) => context.push('/progress')),
      _Shortcut('share', Icons.share_outlined, l10n.dashboardShare, '', _share),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
              child: Center(child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradientFor(Theme.of(context).brightness),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                    ),
                    child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(flex: 5, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const AppMenuButton(),
                      Text(l10n.dashboardWelcome, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
                      const SizedBox(height: 6),
                      Text(user?.name.trim().isNotEmpty == true ? user!.name : l10n.dashboardProfileUnavailable,
                        style: TextStyle(fontSize: 21, height: 1.25, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 5),
                      if (user != null && user.phoneNumber.isNotEmpty)
                        Text(user.phoneNumber, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.85))),
                    ])),
                    const SizedBox(width: 12),
                    Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      _HeaderControl(icon: Icons.translate, label: l10n.settingsLanguage.toUpperCase(),
                        value: LocaleNotifier.localeNames[locale.languageCode] ?? locale.languageCode,
                        ink: Colors.white, surface: Colors.white.withValues(alpha: 0.12), onTap: _language),
                      const SizedBox(height: 8),
                      _HeaderControl(icon: Icons.notifications_none_rounded, label: l10n.dashboardNotices,
                        unread: notices?.asData?.value.unreadCount ?? 0, ink: Colors.white, surface: Colors.white.withValues(alpha: 0.12),
                        onTap: user == null ? null : () => _notices(user.id)),
                    ])),
                  ]),
                  ),
                  const SizedBox(height: 18),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _SubscriptionBanner(ink: ink, surface: surface)),
                  const SizedBox(height: 18),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: LayoutBuilder(builder: (context, constraints) {
                    final cardWidth = (constraints.maxWidth - 12) / 2;
                    final labelStyle = TextStyle(fontSize: 13, height: 1.25, fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface);
                    final detailStyle = TextStyle(fontSize: 11, height: 1.35, color: ink.withValues(alpha: 0.85));
                    double height = 130;
                    for (final item in items) {
                      double measure(String text, TextStyle style) {
                        if (text.isEmpty) return 0;
                        final painter = TextPainter(text: TextSpan(text: text, style: DefaultTextStyle.of(context).style.merge(style)),
                          textDirection: Directionality.of(context), textScaler: MediaQuery.textScalerOf(context))
                          ..layout(maxWidth: math.max(1.0, cardWidth - 30));
                        final result = painter.height;
                        painter.dispose();
                        return result;
                      }
                      height = math.max(height, 94 + measure(item.title, labelStyle) +
                        (item.subtitle.isEmpty ? 0 : 6 + measure(item.subtitle, detailStyle)));
                    }
                    return GridView.builder(
                      key: const ValueKey('dashboard-shortcuts'),
                      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: EdgeInsets.zero,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,
                        mainAxisSpacing: 12, crossAxisSpacing: 12, mainAxisExtent: height),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final imageAsset = switch (item.id) {
                          'practice' => 'assets/images/practices_image.webp',
                          'whatsapp' => 'assets/images/whatsapp_logo.webp',
                          _ => null,
                        };
                        final cardColor = switch (item.id) {
                          'whatsapp' => AppColors.accent,
                          'progress' => AppColors.success,
                          'share' => AppColors.primaryLight,
                          _ => AppColors.primary,
                        };
                        return Semantics(button: true, label: [item.title, item.subtitle].where((s) => s.isNotEmpty).join('. '),
                          onTap: () => item.onTap(context),
                          child: ExcludeSemantics(child: InteractiveCard(
                            key: ValueKey('shortcut-${item.id}'), onTap: () => item.onTap(context),
                            builder: (context, state) => AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(16),
                                border: state.focused ? Border.all(color: cardColor, width: 2) : null,
                                boxShadow: [BoxShadow(color: cardColor.withValues(alpha: state.hovered ? 0.18 : 0.08), blurRadius: state.hovered ? 18 : 10, offset: const Offset(0, 4))]),
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Container(
                                  width: 42, height: 42,
                                  decoration: BoxDecoration(color: cardColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12)),
                                  clipBehavior: Clip.antiAlias,
                                  child: imageAsset == null ? Icon(item.icon, size: 22, color: cardColor) :
                                    Image.asset(imageAsset, width: 42, height: 42, fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Icon(item.icon, size: 22, color: cardColor)),
                                ),
                                const SizedBox(height: 10),
                                Text(item.title, textAlign: TextAlign.center, style: labelStyle),
                                if (item.subtitle.isNotEmpty) ...[
                                  const SizedBox(height: 6), Text(item.subtitle, textAlign: TextAlign.center, style: detailStyle),
                                ],
                              ]),
                            ),
                          )),
                        );
                      },
                    );
                  })),
                ]),
              )),
            ),
          ),
        ),
      ),
    );
  }
}

class _Shortcut {
  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final void Function(BuildContext) onTap;
  const _Shortcut(this.id, this.icon, this.title, this.subtitle, this.onTap);
}

class _HeaderControl extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final int unread;
  final Color ink;
  final Color surface;
  final VoidCallback? onTap;
  const _HeaderControl({required this.icon, required this.label, this.value, this.unread = 0,
    required this.ink, required this.surface, required this.onTap});

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(foregroundColor: ink, backgroundColor: surface,
      minimumSize: const Size(48, 48), padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      side: BorderSide(color: ink.withValues(alpha: 0.5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Badge(isLabelVisible: unread > 0, label: Text('$unread'),
          child: Icon(icon, size: 17)),
        const SizedBox(width: 6),
        Flexible(child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
      ]),
      if (value != null) ...[const SizedBox(height: 4), Text(value!, textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))],
    ]),
  );
}

class _SubscriptionBanner extends ConsumerWidget {
  final Color ink;
  final Color surface;
  const _SubscriptionBanner({required this.ink, required this.surface});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sub = ref.watch(subscriptionProvider);
    final now = DateTime.now();
    final expiry = sub.expiresAt;
    final expired = expiry != null && !expiry.isAfter(now);
    final active = sub.hasActiveAccess && !expired;
    final days = active && expiry != null ? (expiry.difference(now).inSeconds / Duration.secondsPerDay).ceil().clamp(0, 99999).toInt() : null;
    final loading = !sub.hasLoaded && !sub.hasError;
    final noAccess = sub.hasLoaded && !active && !expired;
    final colors = Theme.of(context).colorScheme;
    final badgeColor = active ? ink : colors.secondaryContainer;
    final badgeTextColor = active
        ? (Theme.of(context).brightness == Brightness.dark ? _indigo : Colors.white)
        : colors.onSecondaryContainer;
    final title = loading ? l10n.dashboardLoading : sub.hasError && !sub.hasLoaded ? l10n.dashboardSubscriptionUnavailable :
      active ? days != null ? l10n.homeAccessActive(days) : l10n.subscriptionAccessActive :
      expired ? l10n.dashboardExpired : l10n.dashboardRequestExamAccess;
    final tier = sub.paymentTier;
    final duration = switch (tier) {
      '1_MONTH' => l10n.subscriptionMonth1,
      '3_MONTH' || '3_MONTHS' => l10n.subscriptionMonth3,
      '6_MONTH' || '6_MONTHS' => l10n.subscriptionMonth6,
      _ => l10n.dashboardDurationUnavailable,
    };
    final detail = noAccess ? l10n.dashboardExamsLocked : l10n.dashboardDuration(duration);
    return Semantics(button: true, label: '$title. $detail',
      child: Material(color: surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: ink, width: 1.2)), clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: () => context.push('/subscription'),
          child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
            Container(width: 70, height: 70, alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: badgeColor, border: Border.all(color: badgeColor, width: 2)),
              child: loading ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: badgeTextColor, strokeWidth: 2)) :
                Padding(padding: const EdgeInsets.all(8), child: FittedBox(fit: BoxFit.scaleDown,
                  child: Text(days != null ? l10n.subscriptionDays(days) : expired ? l10n.subscriptionDays(0) : '—',
                    textAlign: TextAlign.center, style: TextStyle(color: badgeTextColor, fontSize: 14, fontWeight: FontWeight.w800)))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(color: ink, fontSize: 14, height: 1.35, fontWeight: FontWeight.w700)),
              const SizedBox(height: 5),
              Text(detail, style: TextStyle(color: ink.withValues(alpha: 0.8), fontSize: 12)),
              if (sub.hasError && sub.hasLoaded) Text(l10n.dashboardCached, style: TextStyle(color: ink, fontSize: 11)),
              if (sub.isLoading && sub.hasLoaded) const Padding(padding: EdgeInsets.only(top: 6), child: LinearProgressIndicator(minHeight: 2)),
            ])),
          ])),
        ),
      ),
    );
  }
}

class _NoticesSheet extends ConsumerWidget {
  final String userId;
  const _NoticesSheet({required this.userId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notices = ref.watch(dashboardNoticesProvider(userId));
    return SizedBox(height: MediaQuery.sizeOf(context).height * 0.65,
      child: Column(children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: [
          Expanded(child: Text(l10n.dashboardNotices, style: Theme.of(context).textTheme.titleLarge)),
          IconButton(tooltip: l10n.commonRetry, onPressed: () => ref.invalidate(dashboardNoticesProvider(userId)), icon: const Icon(Icons.refresh)),
          IconButton(tooltip: MaterialLocalizations.of(context).closeButtonTooltip, onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        ])),
        Expanded(child: notices.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(l10n.dashboardNoticesUnavailable, textAlign: TextAlign.center))),
          data: (data) => data.items.isEmpty ? Center(child: Text(l10n.dashboardNoNotices)) :
            ListView.separated(padding: const EdgeInsets.all(20), itemCount: data.items.length,
              separatorBuilder: (_, __) => const Divider(), itemBuilder: (context, index) {
                final item = data.items[index];
                return ListTile(leading: Icon(item.unread ? Icons.mark_email_unread_outlined : Icons.drafts_outlined),
                  title: Text(item.title), subtitle: item.body.isEmpty ? null : Text(item.body));
              }),
        )),
      ]),
    );
  }
}
