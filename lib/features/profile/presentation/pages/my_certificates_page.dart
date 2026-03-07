import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../shared/network/api_config.dart';
import '../../../../shared/session/auth_session.dart';
import 'package:http/http.dart' as http;

const _kRequiredPassed = 18;
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
  List<dynamic> _results = [];

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
      final token = await AuthSession().getToken();
      final res = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/api/exam-results/$userId'),
            headers: {
              if (token != null) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final list = (body is List)
            ? body
            : (body['results'] ?? body['data'] ?? []);
        setState(() => _results = list as List);
      } else {
        setState(() => _error = 'HTTP ${res.statusCode}');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _boolVal(dynamic v) =>
      v == true || v == 1 || v == '1' || v == 'true';

  int get _passedCount =>
      _results.where((r) => _boolVal(r['passed'])).length;

  bool get _hasCertificate => _passedCount >= _kRequiredPassed;

  Future<void> _openIrembo() async {
    final uri = Uri.parse(_kIremboUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final gradient = AppColors.primaryGradientFor(Theme.of(context).brightness);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      l10n.certificatesTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _load,
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

  Widget _progressCard(BuildContext context, AppLocalizations l10n) {
    final pct = (_passedCount / _kRequiredPassed).clamp(0.0, 1.0);
    final passed = _passedCount;
    final needed = (_kRequiredPassed - passed).clamp(0, _kRequiredPassed);
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
                l10n.certificateProgressLabel(passed, _kRequiredPassed),
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
