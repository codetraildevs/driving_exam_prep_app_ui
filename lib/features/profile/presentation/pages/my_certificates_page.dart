import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../shared/network/api_helper.dart';
import '../../../../shared/network/offline_cache.dart';

/// Total unique exams available in the app.
const _kTotalExams = 20;

/// Pass percentage (18/20 = 90%).
const _kPassPercent = 90;

/// Number of unique exams the user must pass to earn the certificate.
const _kRequiredPassed = 18;

/// Minimum correct answers out of 20 to pass.
const _kPassCorrect = 18;

const _kIremboUrl =
    'https://irembo.gov.rw/user/citizen/service/rnp/registration_for_driving_license_test_provisional_computer_based';

class MyCertificatesPage extends StatefulWidget {
  const MyCertificatesPage({Key? key}) : super(key: key);

  @override
  State<MyCertificatesPage> createState() => _MyCertificatesPageState();
}

class _MyCertificatesPageState extends State<MyCertificatesPage> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _rawResults = [];
  bool _fromCache = false;

  /// Map of examId → latest result (deduplicated, latest attempt wins).
  Map<String, Map<String, dynamic>> _uniqueExams = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
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
      if (userId == null) {
        setState(() => _error = 'Not authenticated');
        return;
      }

      final cache = OfflineCache();
      final cacheKey = cache.examResultsKey(userId);

      // Try network first
      final result = await ApiHelper().get('/api/exam-results/$userId');
      if (result.isSuccess) {
        final list = result.dataList;
        await cache.save(cacheKey, list);
        setState(() {
          _rawResults = list;
          _fromCache = false;
        });
      } else if (result.statusCode == 401) {
        if (!mounted) return;
        context.read<AuthBloc>().add(const SignOutEvent());
        context.go('/login');
        return;
      } else {
        // Fallback to cache
        final cached = await cache.load(cacheKey);
        if (cached is List) {
          setState(() {
            _rawResults = cached;
            _fromCache = true;
          });
        } else {
          setState(() => _error = result.errorMessage);
        }
      }
    } catch (e) {
      // Network error → try cache
      try {
        final authState = context.read<AuthBloc>().state;
        final userId =
            authState is AuthAuthenticated ? authState.user.id : null;
        if (userId != null) {
          final cache = OfflineCache();
          final cached = await cache.load(cache.examResultsKey(userId));
          if (cached is List) {
            setState(() {
              _rawResults = cached;
              _fromCache = true;
            });
          } else {
            setState(() => _error = e.toString());
          }
        } else {
          setState(() => _error = e.toString());
        }
      } catch (_) {
        setState(() => _error = e.toString());
      }
    } finally {
      _buildUniqueExams();
      setState(() => _isLoading = false);
    }
  }

  /// Deduplicate results: for each examId keep only the latest attempt.
  void _buildUniqueExams() {
    final map = <String, Map<String, dynamic>>{};
    // Results come sorted by createdAt DESC from the API,
    // so the first occurrence of each examId is the latest.
    for (final r in _rawResults) {
      if (r is! Map<String, dynamic>) continue;
      final examId = (r['examId'] ?? '').toString();
      if (examId.isEmpty) continue;
      if (!map.containsKey(examId)) {
        map[examId] = r;
      }
    }
    _uniqueExams = map;
  }

  int _intVal(dynamic v) =>
      v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

  /// Whether a result counts as "passed" using the 90% (18/20) rule.
  bool _isPassed(Map<String, dynamic> r) {
    final score = _intVal(r['score']);
    return score >= _kPassPercent;
  }

  int get _passedCount =>
      _uniqueExams.values.where((r) => _isPassed(r)).length;

  bool get _hasCertificate => _passedCount >= _kRequiredPassed;

  Future<void> _openIrembo() async {
    final uri = Uri.parse(_kIremboUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Ordered list of all 20 exam IDs ──────────────────────────────────
  static const _allExamIds = [
    '177', '1', '2', '3', '4', '5', '6', '7', '8', '9',
    '10', '11', '12', '13', '14', '15', '16', '17', '18', '19',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gradient = AppColors.primaryGradientFor(Theme.of(context).brightness);
    final topPadding = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Column(
          children: [
            // ── Full-bleed header (covers status bar) ──────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(8, topPadding + 4, 8, 20),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: AppColors.textInverse),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      l10n.certificatesTitle,
                      style: AppTextStyles.heading5.copyWith(
                        color: AppColors.textInverse,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh,
                        color: AppColors.textInverse),
                    onPressed: _load,
                  ),
                ],
              ),
            ),

            // ── Offline banner ─────────────────────────────────────────
            if (_fromCache)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.orange.shade700,
                child: Row(
                  children: [
                    const Icon(Icons.cloud_off, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.offlineBanner,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Body ───────────────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _errorView(l10n)
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _progressCard(context, l10n),
                                const SizedBox(height: 16),
                                _passMarkCard(context, l10n),
                                const SizedBox(height: 16),
                                _examGrid(context, l10n),
                                const SizedBox(height: 20),
                                if (_hasCertificate) ...[
                                  _certificateCard(context, l10n),
                                  const SizedBox(height: 16),
                                  _iremboCard(context, l10n),
                                ],
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Pass‑mark info card ────────────────────────────────────────────
  Widget _passMarkCard(BuildContext context, AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: cs.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.certificatePassMark(_kPassCorrect, 20, _kPassPercent),
              style: AppTextStyles.bodySmall
                  .copyWith(color: cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  // ── Exam status grid (20 tiles) ───────────────────────────────────
  Widget _examGrid(BuildContext context, AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    final screenW = MediaQuery.of(context).size.width;
    // Responsive: 5 cols on wide, 4 on normal
    final crossCount = screenW >= 600 ? 5 : 4;
    final availableW = screenW - 32 - 32; // page padding + container padding
    final spacing = 10.0;
    final tileSize =
        ((availableW - spacing * (crossCount - 1)) / crossCount)
            .clamp(44.0, 64.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with count badge
          Row(
            children: [
              Icon(Icons.grid_view_rounded, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.certificateUniqueExamsPassed(
                      _passedCount, _kTotalExams),
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // Circular badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _passedCount > 0
                      ? const LinearGradient(
                          colors: [AppColors.success, Color(0xFF43A047)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: _passedCount == 0
                      ? cs.surfaceContainerHighest
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$_passedCount',
                    style: TextStyle(
                      color: _passedCount > 0
                          ? Colors.white
                          : cs.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Grid
          Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: List.generate(_allExamIds.length, (i) {
              final eid = _allExamIds[i];
              final result = _uniqueExams[eid];
              final attempted = result != null;
              final passed = attempted && _isPassed(result);
              final score = attempted ? _intVal(result['score']) : 0;

              // Gradient backgrounds for passed/failed
              Decoration decoration;
              Color fg;
              IconData? icon;
              if (passed) {
                decoration = BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                );
                fg = Colors.white;
                icon = Icons.check_circle_rounded;
              } else if (attempted) {
                decoration = BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.error,
                      cs.error.withValues(alpha: 0.75),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                );
                fg = Colors.white;
                icon = Icons.cancel_rounded;
              } else {
                decoration = BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.3),
                  ),
                );
                fg = cs.onSurfaceVariant;
                icon = null;
              }

              return Tooltip(
                message: l10n.certificateExamStatus(i + 1),
                child: Container(
                  width: tileSize,
                  height: tileSize,
                  decoration: decoration,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null)
                        Icon(icon, color: fg, size: tileSize * 0.3),
                      Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: fg,
                          fontSize: tileSize * 0.22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (attempted)
                        Text(
                          '$score%',
                          style: TextStyle(
                            color: fg.withValues(alpha: 0.85),
                            fontSize: tileSize * 0.17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _legendDot(AppColors.success, l10n.progressPassedCount),
              _legendDot(cs.error, l10n.progressFailedCount),
              _legendDot(
                  cs.surfaceContainerHighest, l10n.certificateNotAttempted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }

  Widget _progressCard(BuildContext context, AppLocalizations l10n) {
    final pct = (_passedCount / _kTotalExams).clamp(0.0, 1.0);
    final passed = _passedCount;
    final needed = (_kTotalExams - passed).clamp(0, _kTotalExams);
    final color = _hasCertificate
        ? AppColors.success
        : Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _hasCertificate
                      ? Icons.workspace_premium_rounded
                      : Icons.pending_actions_rounded,
                  color: color,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hasCertificate
                          ? l10n.certificateReadyTitle
                          : l10n.certificatesAchievements,
                      style: AppTextStyles.heading6,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _hasCertificate
                          ? l10n.certificateReadySubtitle(passed)
                          : l10n.certificateExamsNeeded(needed),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.certificateProgressLabel(passed, _kTotalExams),
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.textSecondary),
              ),
              Text(
                '${(pct * 100).toInt()}%',
                style: AppTextStyles.labelMedium
                    .copyWith(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 12,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _certificateCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF283593)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.workspace_premium_rounded,
                  color: Color(0xFFFFD700), size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.certificatesTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.certificateReadySubtitle(_passedCount),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 18),
              const SizedBox(width: 6),
              Text(
                '$_passedCount ${l10n.progressPassedCount}',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.certificatesEarned,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iremboCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.06),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.link_rounded, color: AppColors.success, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.certificateIremboDesc,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.open_in_new_rounded),
              label: Text(l10n.certificateIremboLink),
              onPressed: _openIrembo,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorView(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: AppColors.neutral400),
            const SizedBox(height: 16),
            Text(_error!, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
