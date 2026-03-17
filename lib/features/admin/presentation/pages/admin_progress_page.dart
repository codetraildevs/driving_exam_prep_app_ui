import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/network/api_helper.dart';
import '../../../../shared/widgets/app_page_header.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class AdminProgressPage extends StatefulWidget {
  const AdminProgressPage({Key? key}) : super(key: key);

  @override
  State<AdminProgressPage> createState() => _AdminProgressPageState();
}

class _AdminProgressPageState extends State<AdminProgressPage> {
  bool _isLoading = true;
  List<dynamic> _results = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await ApiHelper().get('/api/exam-results');
      if (result.isSuccess) {
        setState(() {
          _results = result.dataList;
        });
      } else if (result.statusCode == 401) {
        if (!mounted) return;
        context.read<AuthBloc>().add(const SignOutEvent());
        context.go('/login');
      } else {
        setState(() => _error = result.detailedError);
      }
    } catch (e) {
      setState(() => _error = AppLocalizations.of(context).errorUnexpected(e.toString()));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  double get _averageScore {
    if (_results.isEmpty) return 0;
    double total = 0;
    for (final r in _results) {
      final score = (r['score'] ?? r['percentage'] ?? 0) as num;
      total += score.toDouble();
    }
    return total / _results.length;
  }

  List<dynamic> get _topPerformers {
    final sorted = List.from(_results);
    sorted.sort((a, b) {
      final aScore = (a['score'] ?? a['percentage'] ?? 0) as num;
      final bScore = (b['score'] ?? b['percentage'] ?? 0) as num;
      return bScore.compareTo(aScore);
    });
    return sorted.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Column(
        children: [
          AppPageHeader(
            title: l10n.adminProgress,
            showBack: false,
            trailing: IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.textInverse),
              onPressed: _loadResults,
              tooltip: 'Refresh',
            ),
          ),
          Expanded(
            child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(_error!, style: AppTextStyles.bodyMedium),
                      ElevatedButton(onPressed: _loadResults, child: Text(l10n.commonRetry)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadResults,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Summary stats
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: l10n.progressTotalAttempts,
                                value: '${_results.length}',
                                icon: Icons.quiz,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                title: l10n.progressAverageScore,
                                value: '${_averageScore.toInt()}%',
                                icon: Icons.bar_chart,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Top performers
                        Text(
                          l10n.adminProgress,
                          style: AppTextStyles.heading5,
                        ),
                        const SizedBox(height: 12),
                        ..._topPerformers.asMap().entries.map((entry) {
                          final i = entry.key;
                          final r = entry.value as Map;
                          final name = (r['userName'] ?? r['user_name'] ?? r['name'] ?? 'Unknown').toString();
                          final score = (r['score'] ?? r['percentage'] ?? 0) as num;
                          final examTitle = (r['examTitle'] ?? r['exam_title'] ?? '').toString();
                          final date = (r['createdAt'] ?? r['created_at'] ?? '').toString().split('T')[0];
                          final passed = score >= 70;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: i < 3
                                    ? AppColors.warning.withValues(alpha: 0.2)
                                    : AppColors.neutral200,
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    color: i < 3 ? AppColors.warning : AppColors.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(name, style: AppTextStyles.heading6),
                              subtitle: Text(
                                examTitle.isNotEmpty ? '$examTitle • $date' : date,
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: passed
                                      ? AppColors.success.withValues(alpha: 0.15)
                                      : AppColors.warning.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${score.toInt()}%',
                                  style: TextStyle(
                                    color: passed ? AppColors.success : AppColors.warning,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Theme.of(context).shadowColor.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.heading4.copyWith(color: color)),
          Text(title, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
