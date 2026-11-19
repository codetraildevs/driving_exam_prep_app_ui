import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../data/referral_repository.dart';

class ReferralOverview extends StatefulWidget {
  final ReferralRepository? repository;

  /// Called with the summary each time the referral data loads, so the host
  /// page can surface values such as the user's code in its header.
  final ValueChanged<ReferralSummary>? onLoaded;

  const ReferralOverview({super.key, this.repository, this.onLoaded});

  @override
  State<ReferralOverview> createState() => _ReferralOverviewState();
}

class _ReferralOverviewState extends State<ReferralOverview> {
  late final ReferralRepository _repository =
      widget.repository ?? ReferralRepository();

  ReferralSummary? _summary;
  bool _loading = true;
  bool _failed = false;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final summary = await _repository.load();
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _loading = false;
      });
      widget.onLoaded?.call(summary);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    final summary = _summary;
    if (summary == null || summary.nextOffset == null || _loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      final next = await _repository.load(offset: summary.nextOffset!);
      if (!mounted) return;
      setState(() => _summary = summary.append(next));
    } catch (_) {
      if (mounted) _message(AppLocalizations.of(context).referralLoadError);
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  String _inviteLink(AppLocalizations l10n, Locale locale, String link) {
    final separator = link.contains('?') ? '&' : '?';
    return '$link${separator}lang=${locale.languageCode}';
  }

  Future<void> _copy(String link) async {
    try {
      await Clipboard.setData(ClipboardData(text: link));
    } catch (_) {
      if (mounted) _message(AppLocalizations.of(context).commonError);
    }
  }

  Future<void> _invite(AppLocalizations l10n, String link) async {
    final box = context.findRenderObject();
    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          text: '${l10n.referralInviteMessage} $link',
          sharePositionOrigin: box is RenderBox && box.hasSize
              ? box.localToGlobal(Offset.zero) & box.size
              : null,
        ),
      );
      if (result.status != ShareResultStatus.unavailable) return;
    } catch (_) {
      /* Fall back to the copy action below. */
    }
    if (mounted) _message(l10n.referralShareUnavailable);
  }

  void _message(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final summary = _summary;

    if (_loading && summary == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_failed && summary == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.referralLoadError,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
      );
    }
    if (summary == null) return const SizedBox.shrink();

    final locale = Localizations.localeOf(context);
    final link = _inviteLink(l10n, locale, summary.link);

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Text(
            l10n.referralHeading,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(l10n.referralDescription, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.referralYourCode,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  summary.code,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: () => _copy(link),
                      icon: const Icon(Icons.copy_rounded),
                      label: Text(l10n.referralCopy),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _invite(l10n, link),
                      icon: const Icon(Icons.group_add_outlined),
                      label: Text(l10n.referralInvite),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Stat(
                  label: l10n.referralTotal,
                  value: summary.total,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Stat(
                  label: l10n.referralConfirmed,
                  value: summary.confirmed,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Stat(
                  label: l10n.referralPending,
                  value: summary.pending,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Card(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.referralRewardsDisabled,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.referralHistory,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (summary.history.isEmpty)
            _Card(
              child: Text(
                l10n.referralEmpty,
                style: theme.textTheme.bodySmall,
              ),
            )
          else
            for (final entry in summary.history) _HistoryTile(entry: entry),
          if (summary.nextOffset != null) ...[
            const SizedBox(height: 12),
            Center(
              child: _loadingMore
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : OutlinedButton(
                      onPressed: _loadMore,
                      child: Text(l10n.referralMore),
                    ),
            ),
          ],
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: child,
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final Map<String, dynamic> entry;
  const _HistoryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final status = (entry['status'] ?? '').toString();
    final confirmed = status.toLowerCase() == 'confirmed';
    final color = confirmed ? AppColors.success : AppColors.accent;
    final raw = (entry['createdAt'] ?? '').toString();
    final date = raw.length >= 10 ? raw.substring(0, 10) : raw;
    return _Card(
      child: Row(
        children: [
          Icon(
            confirmed
                ? Icons.check_circle_outline_rounded
                : Icons.hourglass_empty_rounded,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              confirmed ? l10n.referralConfirmed : l10n.referralPending,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          if (date.isNotEmpty)
            Text(date, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
