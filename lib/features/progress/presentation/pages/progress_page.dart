import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../shared/network/api_config.dart';
import '../../../../shared/session/auth_session.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({Key? key}) : super(key: key);

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
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
    _loadResults();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadResults() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final authState = context.read<AuthBloc>().state;
      String? userId;
      if (authState is AuthAuthenticated) {
        userId = authState.user.id;
      }
      if (userId == null || userId.isEmpty) {
        setState(() => _error = 'Not authenticated');
        return;
      }
      final token = await AuthSession().getToken();
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/api/exam-results/$userId'),
            headers: {
              if (token != null) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = (data is List)
            ? data
            : (data['results'] ?? data['data'] ?? []);
        setState(() => _results = results as List);
        _animCtrl.forward(from: 0);
      } else {
        setState(() => _error = 'HTTP ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Computed stats ──────────────────────────────────────────────────────────

  int get _total => _results.length;

  int get _passed =>
      _results.where((r) => _boolVal(r['passed'])).length;

  int get _failed => _total - _passed;

  int get _bestScore => _total == 0
      ? 0
      : _results
          .map((r) => _intVal(r['score']))
          .reduce(max);

  double get _avgScore => _total == 0
      ? 0
      : _results.map((r) => _intVal(r['score'])).reduce((a, b) => a + b) /
          _total;

  double get _passRate => _total == 0 ? 0 : _passed / _total;

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
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white),
                          onPressed: () => context.go('/home'),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          onPressed: _loadResults,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        l10n.progressTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!_isLoading && _error == null && _total > 0) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _HeaderStats(
                          total: _total,
                          passed: _passed,
                          passRate: _passRate,
                          l10n: l10n,
                          anim: _anim,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _ErrorView(
                        error: _error!,
                        onRetry: _loadResults,
                        l10n: l10n,
                      )
                    : _total == 0
                        ? _EmptyView(l10n: l10n)
                        : RefreshIndicator(
                            onRefresh: _loadResults,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
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
                                  ..._results.take(20).map((r) =>
                                      _ExamResultCard(
                                          result: r, l10n: l10n)),

                                  if (_results.length > 20)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        '+ ${_results.length - 20} more',
                                        style: AppTextStyles.bodySmall
                                            .copyWith(
                                                color:
                                                    AppColors.textSecondary),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  const SizedBox(height: 32),
                                ],
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

// ── Header stats ──────────────────────────────────────────────────────────────

class _HeaderStats extends StatelessWidget {
  final int total;
  final int passed;
  final double passRate;
  final AppLocalizations l10n;
  final Animation<double> anim;

  const _HeaderStats({
    required this.total,
    required this.passed,
    required this.passRate,
    required this.l10n,
    required this.anim,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HeaderChip(
          value: '$total',
          label: l10n.progressExamsTaken,
          icon: Icons.quiz_rounded,
        ),
        const SizedBox(width: 12),
        _HeaderChip(
          value: '$passed',
          label: l10n.progressPassedCount,
          icon: Icons.check_circle_rounded,
        ),
        const SizedBox(width: 12),
        _HeaderChip(
          value: '${(passRate * 100).toInt()}%',
          label: l10n.progressPassRate,
          icon: Icons.trending_up_rounded,
        ),
      ],
    );
  }
}

class _HeaderChip extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _HeaderChip({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.progressPerformanceSummary, style: AppTextStyles.heading5),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.check_circle_rounded,
                value: '$passed',
                label: l10n.progressPassedCount,
                color: AppColors.success,
                anim: anim,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.cancel_rounded,
                value: '$failed',
                label: l10n.progressFailedCount,
                color: AppColors.warning,
                anim: anim,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.emoji_events_rounded,
                value: '$best%',
                label: l10n.progressBestScore,
                color: AppColors.primary,
                anim: anim,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.analytics_rounded,
                value: '${avg.toStringAsFixed(0)}%',
                label: l10n.progressAverageScore,
                color: AppColors.accent,
                anim: anim,
              ),
            ),
          ],
        ),

        // Pass-rate progress bar
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.progressPassRate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                    value: total > 0
                        ? (passed / total) * anim.value
                        : 0,
                    minHeight: 10,
                    backgroundColor: Colors.white.withOpacity(0.2),
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
                  color: Colors.white.withOpacity(0.8),
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

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.anim,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (ctx, child) => Transform.scale(
        scale: 0.85 + 0.15 * anim.value,
        child: child,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          border: Border.all(color: color.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
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
    final passed = _boolVal(result['passed']);
    final score = _intVal(result['score']);
    final total = _intVal(result['totalQuestions']);
    final correct = _intVal(result['correctAnswers']);
    final dateStr =
        (result['completedAt'] ?? result['createdAt'] ?? '').toString();
    final date = dateStr.isNotEmpty ? dateStr.split('T')[0] : '';
    final color = passed ? AppColors.success : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$score%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  passed ? l10n.progressPassed : l10n.quizFailed,
                  style: AppTextStyles.labelLarge.copyWith(color: color),
                ),
                if (total > 0)
                  Text(
                    '$correct/$total ${l10n.examCorrect.toLowerCase()}',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                if (date.isNotEmpty)
                  Text(
                    date,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.textTertiary),
                  ),
              ],
            ),
          ),
          Icon(
            passed
                ? Icons.check_circle_rounded
                : Icons.info_rounded,
            color: color,
            size: 22,
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

  const _ErrorView(
      {required this.error, required this.onRetry, required this.l10n});

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
            Text(error,
                style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
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
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.quiz_outlined,
                  size: 48, color: AppColors.primary),
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
