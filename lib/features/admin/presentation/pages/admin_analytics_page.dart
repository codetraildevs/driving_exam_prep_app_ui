import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../shared/network/api_helper.dart';

class AdminAnalyticsPage extends StatefulWidget {
  const AdminAnalyticsPage({Key? key}) : super(key: key);

  @override
  State<AdminAnalyticsPage> createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends State<AdminAnalyticsPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;

  DateTime? _startDate;
  DateTime? _endDate;

  Map<String, dynamic> _analytics = {};

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  static const int _lowEngagementThreshold = 20;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    // Default to last 7 days
    _endDate = DateTime.now();
    _startDate = _endDate!.subtract(const Duration(days: 6));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadData();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final sdf = DateFormat('yyyy-MM-dd');
      final qStart = _startDate != null ? sdf.format(_startDate!) : '';
      final qEnd = _endDate != null ? sdf.format(_endDate!) : '';

      final result = await ApiHelper().get(
        '/api/admin/analytics',
        queryParams: {
          if (qStart.isNotEmpty) 'dateFrom': qStart,
          if (qEnd.isNotEmpty) 'dateTo': qEnd,
        },
      );

      if (result.isSuccess) {
        final data = result.data as Map<String, dynamic>?;
        if (data != null && data.containsKey('analytics')) {
          if (mounted) {
            setState(() {
              _analytics = data['analytics'] as Map<String, dynamic>;
            });
            _animController.forward(from: 0);
          }
        }
      } else {
        if (mounted) setState(() => _error = result.errorMessage);
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Network error. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                  onPrimary: AppColors.textInverse,
                ),
          ),
          child: child!,
        );
      },
    );

    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
      _loadData();
    }
  }

  int get _totalExams => _analytics['totalExams'] as int? ?? 0;
  int get _uniqueUsers => _analytics['uniqueUsers'] as int? ?? 0;
  List<dynamic> get _rawDailyStats =>
      (_analytics['dailyStats'] as List<dynamic>?) ?? [];

  bool get _isLowEngagement => _uniqueUsers < _lowEngagementThreshold;

  /// Builds the complete list of {date, count} for every day between
  /// [_startDate] and [_endDate], filling in zero for missing days.
  List<Map<String, dynamic>> get _fullDailyStats {
    if (_startDate == null || _endDate == null) return [];

    // Build a lookup map from the raw API data
    final dataMap = <String, int>{};
    for (final stat in _rawDailyStats) {
      final dateStr = stat['date'] as String;
      dataMap[dateStr] = stat['count'] as int;
    }

    // Iterate every day in the range
    final sdf = DateFormat('yyyy-MM-dd');
    final result = <Map<String, dynamic>>[];
    var current = DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
    final end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);

    while (!current.isAfter(end)) {
      final key = sdf.format(current);
      result.add({'date': key, 'count': dataMap[key] ?? 0});
      current = current.add(const Duration(days: 1));
    }
    return result;
  }

  Color get _barColor =>
      _isLowEngagement ? AppColors.warning : AppColors.primary;

  Color get _barColorLight =>
      _isLowEngagement ? AppColors.warningLight : AppColors.primaryLight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(context, innerBoxIsScrolled),
        ],
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool innerBoxIsScrolled) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverAppBar(
      expandedHeight: 150,
      pinned: true,
      floating: false,
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: const Text(
        'Analytics',
        style: TextStyle(
            color: AppColors.textInverse, fontWeight: FontWeight.bold),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.textInverse),
          onPressed: _isLoading ? null : _loadData,
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradientFor(
                isDark ? Brightness.dark : Brightness.light),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Track Tester Engagement',
                          style: TextStyle(
                              color:
                                  AppColors.textInverse.withValues(alpha: 0.8),
                              fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Daily Exam Activity',
                          style: TextStyle(
                            color: AppColors.textInverse,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.textInverse.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.analytics,
                        color: AppColors.textInverse, size: 28),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading && _analytics.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _analytics.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 56, color: AppColors.error.withValues(alpha: 0.7)),
              const SizedBox(height: 16),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDateFilter(),
              const SizedBox(height: 16),
              if (_isLowEngagement && _analytics.isNotEmpty) _buildAlertBanner(),
              const SizedBox(height: 16),
              _buildSummaryCards(),
              const SizedBox(height: 28),
              _buildChartSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.warning, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Low engagement detected — only $_uniqueUsers unique users submitted exams in this period. Consider reaching out to testers.',
              style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    final sdf = DateFormat('MMM d, yyyy');
    final dateText = _startDate != null && _endDate != null
        ? '${sdf.format(_startDate!)}  →  ${sdf.format(_endDate!)}'
        : 'Select Date Range';

    final dayCount = _startDate != null && _endDate != null
        ? _endDate!.difference(_startDate!).inDays + 1
        : 0;

    return GestureDetector(
      onTap: _pickDateRange,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
                color:
                    Theme.of(context).shadowColor.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_month,
                  color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Date Range',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(dateText,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),
            if (dayCount > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$dayCount days',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Total Exams',
            value: _totalExams.toString(),
            subtitle: 'Completed',
            icon: Icons.quiz_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Unique Users',
            value: _uniqueUsers.toString(),
            subtitle: _isLowEngagement ? '⚠ Needs attention' : 'Active testers',
            icon: Icons.people_rounded,
            color: _barColor,
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection() {
    final days = _fullDailyStats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Exams per Day', style: AppTextStyles.heading5),
            const Spacer(),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                  color: _barColor,
                  borderRadius: BorderRadius.circular(3)),
            ),
            const SizedBox(width: 6),
            Text(
              _isLowEngagement ? 'Low activity' : 'Active',
              style: TextStyle(fontSize: 11, color: _isLowEngagement ? _barColor: AppColors.primary,),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                  color:
                      Theme.of(context).shadowColor.withValues(alpha: 0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Y-axis legend + chart area
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
                child: _buildChart(days),
              ),
              const SizedBox(height: 8),
              // Bottom legend
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  days.isEmpty
                      ? 'No data for the selected period.'
                      : 'Showing ${days.length} day${days.length == 1 ? "" : "s"} · ${_rawDailyStats.length} active day${_rawDailyStats.length == 1 ? "" : "s"}',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChart(List<Map<String, dynamic>> days) {
    if (days.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bar_chart, size: 48, color: AppColors.textTertiary),
              SizedBox(height: 8),
              Text('No exam data for this period',
                  style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    int maxCount = 0;
    for (final d in days) {
      final c = d['count'] as int;
      if (c > maxCount) maxCount = c;
    }
    if (maxCount == 0) maxCount = 1;

    // Each bar column: countLabelSlot(18) + chartHeight(150) + labelHeight(36) = 204 total
    const double barColumnWidth = 36.0;
    const double countLabelSlot = 18.0; // 16px text + 2px spacer
    const double chartHeight = 180.0;   // max bar height
    const double labelHeight = 36.0;    // rotated date label
    const double totalColumnHeight = countLabelSlot + chartHeight + labelHeight; // 204

    return LayoutBuilder(builder: (context, constraints) {
      final totalWidth = math.max(
          constraints.maxWidth, days.length * barColumnWidth.toDouble());
      final needsScroll = totalWidth > constraints.maxWidth;

      final chart = SizedBox(
        width: totalWidth,
        height: totalColumnHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: days.map((day) {
            final count = day['count'] as int;
            final dateStr = day['date'] as String;
            String shortLabel = dateStr;
            try {
              final parsed = DateTime.parse(dateStr);
              shortLabel = DateFormat('d/M').format(parsed);
            } catch (_) {}

            final fraction = count / maxCount;
            // final barH = math.max(fraction * chartHeight, count > 0 ? 8.0 : 2.0);
            const availableBarHeight = chartHeight - countLabelSlot;

final barH = math.min(
  math.max(fraction * availableBarHeight, count > 0 ? 8.0 : 2.0),
  availableBarHeight,
);

            final isEmpty = count == 0;
            final barDecoration = isEmpty
                ? const BoxDecoration(
                    color: AppColors.neutral200,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(4)),
                  )
                : BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_barColorLight, _barColor],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6)),
                    boxShadow: [
                      BoxShadow(
                          color: _barColor.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2))
                    ],
                  );

            return SizedBox(
              width: barColumnWidth,
              height: totalColumnHeight,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // count label above bar — fixed 16px slot
                  SizedBox(
                    height: 16,
                    child: count > 0
                        ? Text(
                            count.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: _isLowEngagement ? _barColor: AppColors.primary,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 2),
                  // the bar — grows proportionally inside the remaining space
                  SizedBox(
                    height: barH,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutCubic,
                        decoration: barDecoration,
                      ),
                    ),
                  ),
                  // date label — fixed rotated slot
                  SizedBox(
                    height: labelHeight,
                    child: OverflowBox(
                      maxWidth: barColumnWidth * 1.5,
                      child: Center(
                        child: Transform.rotate(
                          angle: -math.pi / 4,
                          child: Text(
                            shortLabel,
                            style: TextStyle(
                              fontSize: 8,
                              color: isEmpty
                                  ? AppColors.textTertiary
                                  : AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.clip,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );

      if (needsScroll) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: chart,
        );
      }
      return chart;
    });
  }
}

// ──────────────────────────────────────────────
// Stat Card Widget
// ──────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
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
          BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: AppTextStyles.heading2
                .copyWith(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
                fontSize: 11,
                color: color.withValues(alpha: 0.75),
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
