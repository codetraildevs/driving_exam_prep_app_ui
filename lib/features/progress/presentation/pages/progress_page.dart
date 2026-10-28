import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../shared/network/api_helper.dart';
import '../../../../shared/network/offline_cache.dart';
import '../../../../shared/responsive/responsive_layout.dart';
import '../../../../shared/widgets/app_page_header.dart';

class ProgressPage extends StatefulWidget {
  final Future<ApiResponse> Function(String userId)? loadResults;
  const ProgressPage({Key? key, this.loadResults}) : super(key: key);

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _refreshing = false, _saved = false;
  String? _error;
  List<dynamic> _results = [];
  late final AnimationController _animCtrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadResults();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadResults() async {
    if (!mounted || _refreshing) return;
    final l10n = AppLocalizations.of(context);
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      setState(() {
        _isLoading = false;
        _error = l10n.errorNetwork;
      });
      return;
    }
    final cache = OfflineCache();
    final key = cache.examResultsKey(auth.user.id);
    setState(() {
      _refreshing = true;
      _isLoading = _results.isEmpty;
      _error = null;
    });
    dynamic cached;
    try {
      cached = await cache.load(key);
    } catch (_) {}
    if (!mounted) return;
    if (cached is List) {
      setState(() {
        _results = cached;
        _isLoading = false;
        _saved = true;
      });
      _animCtrl.forward(from: 0);
    }
    try {
      final result =
          await (widget.loadResults?.call(auth.user.id) ??
              ApiHelper().get('/api/exam-results/${auth.user.id}'));
      if (!mounted) return;
      if (result.isSuccess) {
        await cache.save(key, result.dataList);
        final merged = await cache.load(key);
        if (!mounted) return;
        setState(() {
          _results = merged is List ? merged : result.dataList;
          _saved = false;
        });
        _animCtrl.forward(from: 0);
      } else if (cached is! List) {
        setState(() => _error = l10n.errorNetwork);
      }
    } catch (_) {
      if (mounted && cached is! List) {
        setState(() => _error = l10n.errorNetwork);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _refreshing = false;
        });
      }
    }
  }

  // ── Computed stats ──────────────────────────────────────────────────────────

  int get _total => _results.length;

  // Pending local attempts have no server flag yet; match the existing backend.
  int get _passed => _results
      .where(
        (r) => r['passed'] == null
            ? _intVal(r['score']) >= 60
            : _boolVal(r['passed']),
      )
      .length;

  int get _failed => _total - _passed;

  int get _bestScore =>
      _total == 0 ? 0 : _results.map((r) => _intVal(r['score'])).reduce(max);

  double get _avgScore => _total == 0
      ? 0
      : _results.map((r) => _intVal(r['score'])).reduce((a, b) => a + b) /
            _total;

  static bool _boolVal(dynamic v) =>
      v == true || v == 1 || v == '1' || v == 'true';

  static int _intVal(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Column(
        children: [
          // ── Gradient header ──────────────────────────────────────────
          AppPageHeader(
            title: l10n.progressTitle,
            showBack: false,
            subtitle: (!_isLoading && _error == null && _total > 0)
                ? '$_passed / $_total ${l10n.progressPassedCount}'
                : null,
            trailing: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _refreshing ? null : _loadResults,
              tooltip: l10n.commonRetry,
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _ErrorView(error: _error!, onRetry: _loadResults, l10n: l10n)
                : _total == 0
                ? _EmptyView(l10n: l10n)
                : RefreshIndicator(
                    onRefresh: _loadResults,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(
                        16,
                      ), // The scroll view below already applies 16px
                      // padding; only constrain width on desktop.
                      child: ConstrainedContent(
                        padding: EdgeInsets.zero,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_saved)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(l10n.progressSaved),
                              ),
                            // ── Summary grid ──────────────────────
                            _SummaryGrid(
                              total: _total,
                              passed: _passed,
                              failed: _failed,
                              best: _bestScore,
                              avg: _avgScore,
                              l10n: l10n,
                              anim: _anim,
                            ),
                            const SizedBox(height: 24),

                            // ── Recent exams ──────────────────────
                            Text(
                              l10n.progressRecentExams,
                              style: AppTextStyles.heading5,
                            ),
                            const SizedBox(height: 12),
                            ..._results
                                .take(20)
                                .map(
                                  (r) => _ExamResultCard(result: r, l10n: l10n),
                                ),

                            if (_results.length > 20)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  '+ ${_results.length - 20} more',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Summary grid ──────────────────────────────────────────────────────────────

class _SummaryGrid extends StatelessWidget {
  final int total;
  final int passed;
  final int failed;
  final int best;
  final double avg;
  final AppLocalizations l10n;
  final Animation<double> anim;

  const _SummaryGrid({
    required this.total,
    required this.passed,
    required this.failed,
    required this.best,
    required this.avg,
    required this.l10n,
    required this.anim,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = AppColors.primaryGradientFor(Theme.of(context).brightness);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.progressPerformanceSummary, style: AppTextStyles.heading5),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = <Widget>[
              _StatCard(
                icon: Icons.check_circle_rounded,
                value: '$passed',
                label: l10n.progressPassedCount,
                color: AppColors.success,
                anim: anim,
              ),
              _StatCard(
                icon: Icons.cancel_rounded,
                value: '$failed',
                label: l10n.progressFailedCount,
                color: AppColors.warning,
                anim: anim,
              ),
              _StatCard(
                icon: Icons.emoji_events_rounded,
                value: '$best%',
                label: l10n.progressBestScore,
                color: AppColors.primary,
                anim: anim,
                delay: 0.2,
              ),
              _StatCard(
                icon: Icons.analytics_rounded,
                value: '${avg.toStringAsFixed(0)}%',
                label: l10n.progressAverageScore,
                color: AppColors.accent,
                anim: anim,
                delay: 0.3,
              ),
            ];
            // 2x2 below the desktop breakpoint, 4-across on desktop.
            if (constraints.maxWidth >= AppBreakpoints.desktop) {
              return Row(
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: cards[i]),
                  ],
                ],
              );
            }
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: 12),
                    Expanded(child: cards[1]),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: cards[2]),
                    const SizedBox(width: 12),
                    Expanded(child: cards[3]),
                  ],
                ),
              ],
            );
          },
        ),

        // Pass-rate progress bar
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      l10n.progressPassRate,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(total > 0 ? passed / total * 100 : 0).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AnimatedBuilder(
                animation: anim,
                builder: (ctx, _) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: total > 0 ? (passed / total) * anim.value : 0,
                    minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$passed / $total ${l10n.progressPassedCount.toLowerCase()}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Animation<double> anim;
  final double delay;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.anim,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (ctx, child) {
        final start = delay;
        final end = (delay + 0.5).clamp(0.0, 1.0);
        final curvedValue = CurvedAnimation(
          parent: anim,
          curve: Interval(start, end, curve: Curves.easeOutBack),
        ).value;
        return Transform.scale(
          scale: 0.8 + 0.2 * curvedValue,
          child: Opacity(opacity: curvedValue.clamp(0.0, 1.0), child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Per-exam result card ───────────────────────────────────────────────────────

class _ExamResultCard extends StatelessWidget {
  final dynamic result;
  final AppLocalizations l10n;

  const _ExamResultCard({required this.result, required this.l10n});

  static bool _boolVal(dynamic v) =>
      v == true || v == 1 || v == '1' || v == 'true';

  static int _intVal(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final passed = result['passed'] == null
        ? _intVal(result['score']) >= 60
        : _boolVal(result['passed']);
    final score = _intVal(result['score']);
    final total = _intVal(result['totalQuestions']);
    final correct = _intVal(result['correctAnswers']);
    final rawDate = (result['completedAt'] ?? result['createdAt'] ?? '')
        .toString();
    String date = '';
    if (rawDate.isNotEmpty) {
      final dayPart = rawDate.contains('T')
          ? rawDate.split('T')[0]
          : rawDate.split(' ')[0];
      if (dayPart != '0000-00-00' && dayPart.isNotEmpty) {
        date = dayPart;
      }
    }
    final color = passed ? AppColors.success : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$score%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      passed ? l10n.progressPassed : l10n.quizFailed,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    if (date.isNotEmpty)
                      Text(
                        '• $date',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 9,
                        ),
                      ),
                  ],
                ),
                if (total > 0)
                  Text(
                    '$correct/$total ${l10n.examCorrect.toLowerCase()}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            passed
                ? Icons.check_circle_outline_rounded
                : Icons.error_outline_rounded,
            color: color.withValues(alpha: 0.4),
            size: 18,
          ),
        ],
      ),
    );
  }
}

// ── Error / empty views ───────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final AppLocalizations l10n;

  const _ErrorView({
    required this.error,
    required this.onRetry,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: AppColors.neutral400),
            const SizedBox(height: 16),
            Text(
              error,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final AppLocalizations l10n;

  const _EmptyView({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.quiz_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.progressNoExams,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/practice'),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l10n.practiceTitle),
            ),
          ],
        ),
      ),
    );
  }
}
