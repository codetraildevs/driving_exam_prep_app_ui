import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';

class ExamResultPage extends StatefulWidget {
  final String attemptId;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int timeSpentSeconds;
  final String examTitle;

  const ExamResultPage({
    required this.attemptId,
    this.score = 0,
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.timeSpentSeconds = 0,
    this.examTitle = '',
    Key? key,
  }) : super(key: key);

  @override
  State<ExamResultPage> createState() => _ExamResultPageState();
}

class _ExamResultPageState extends State<ExamResultPage>
    with TickerProviderStateMixin {
  late final AnimationController _ringCtrl;
  late final AnimationController _slideCtrl;
  late final Animation<double> _ringAnim;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _ringAnim = CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOutCubic);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _slideCtrl, curve: Curves.easeIn);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _ringCtrl.forward();
        _slideCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    if (seconds <= 0) return '--';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final passed = widget.score >= 70;
    final wrong = widget.totalQuestions - widget.correctAnswers;
    final progress = widget.totalQuestions > 0
        ? widget.correctAnswers / widget.totalQuestions
        : 0.0;
    final primaryColor = passed ? AppColors.success : AppColors.warning;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // ── Background gradient ──────────────────────────────────────
          Container(
            height: size.height * 0.45,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: passed
                    ? [AppColors.success, const Color(0xFF00BFA5)]
                    : [AppColors.warning, const Color(0xFFFF7043)],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ── Header ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => context.go('/home'),
                        ),
                        Expanded(
                          child: Text(
                            widget.examTitle.isNotEmpty
                                ? widget.examTitle
                                : l10n.examMockExam,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // ── Score Ring ──────────────────────────────────────
                  const SizedBox(height: 16),
                  Center(
                    child: AnimatedBuilder(
                      animation: _ringAnim,
                      builder: (ctx, _) => _ScoreRing(
                        progress: progress * _ringAnim.value,
                        score: widget.score,
                        passed: passed,
                        size: min(size.width * 0.55, 220),
                        label: passed ? l10n.progressPassed : l10n.progressFailedCount,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    passed ? l10n.examCongratulations : l10n.examGoodEffort,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    passed ? l10n.examPassedMessage : l10n.examFailedMessage,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 28),

                  // ── Stats card ──────────────────────────────────────
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // ── Stat row ──────────────────────────────
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  _StatChip(
                                    icon: Icons.check_circle_rounded,
                                    value: '${widget.correctAnswers}',
                                    label: l10n.examCorrect,
                                    color: AppColors.success,
                                  ),
                                  _vDivider(),
                                  _StatChip(
                                    icon: Icons.cancel_rounded,
                                    value: '$wrong',
                                    label: l10n.examWrong,
                                    color: AppColors.error,
                                  ),
                                  _vDivider(),
                                  _StatChip(
                                    icon: Icons.timer_rounded,
                                    value: _formatTime(widget.timeSpentSeconds),
                                    label: l10n.examTimeSpent,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),

                            const Divider(height: 1),

                            // ── Progress bar ──────────────────────────
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        l10n.examAccuracy,
                                        style: AppTextStyles.labelMedium,
                                      ),
                                      Text(
                                        '${widget.score}%',
                                        style: AppTextStyles.heading6.copyWith(
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  AnimatedBuilder(
                                    animation: _ringAnim,
                                    builder: (ctx, _) => ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: (widget.score / 100) *
                                            _ringAnim.value,
                                        minHeight: 12,
                                        backgroundColor:
                                            primaryColor.withOpacity(0.12),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                primaryColor),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ── Pass/Fail message ─────────────────────
                            Container(
                              margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: primaryColor.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    passed
                                        ? Icons.emoji_events_rounded
                                        : Icons.lightbulb_outline,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      passed
                                          ? l10n.examBadgeEarned
                                          : l10n.examNeedMorePractice,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Action buttons ──────────────────────────────────
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.replay_rounded),
                          label: Text(l10n.examRetakeTest),
                          onPressed: () {
                            context.go('/exam');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.home_rounded),
                          label: Text(l10n.examBackHome),
                          onPressed: () => context.go('/home'),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: primaryColor,
                            side: BorderSide(color: primaryColor),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          icon: const Icon(Icons.bar_chart_rounded),
                          label: Text(l10n.progressTitle),
                          onPressed: () => context.go('/progress'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 50,
        color: AppColors.neutral200,
      );
}

class _ScoreRing extends StatelessWidget {
  final double progress;
  final int score;
  final bool passed;
  final double size;
  final String label;

  const _ScoreRing({
    required this.progress,
    required this.score,
    required this.passed,
    required this.size,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: progress,
          passed: passed,
          bgColor: Colors.white.withOpacity(0.2),
          fgColor: Colors.white,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: size * 0.1,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final bool passed;
  final Color bgColor;
  final Color fgColor;

  _RingPainter({
    required this.progress,
    required this.passed,
    required this.bgColor,
    required this.fgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeW = size.width * 0.08;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: (size.width - strokeW) / 2,
    );

    // Background ring
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi,
      false,
      Paint()
        ..color = bgColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * progress,
      false,
      Paint()
        ..color = fgColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.heading6.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
