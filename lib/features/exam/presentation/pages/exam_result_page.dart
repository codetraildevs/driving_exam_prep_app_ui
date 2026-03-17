import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../../../l10n/generated/app_localizations.dart';

// ─── Grade helper ─────────────────────────────────────────────────────────────

String _gradeFor(int score) {
  if (score >= 95) return 'A+';
  if (score >= 85) return 'A';
  if (score >= 75) return 'B';
  if (score >= 70) return 'C';
  if (score >= 60) return 'D';
  return 'F';
}

int _starsFor(int score) {
  if (score >= 90) return 5;
  if (score >= 80) return 4;
  if (score >= 70) return 3;
  if (score >= 60) return 2;
  return 1;
}

// ─── Confetti particle ────────────────────────────────────────────────────────

class _Particle {
  double x;
  double y;
  double vx;
  double vy;
  final double size;
  final Color color;
  final bool isCircle;
  double angle;
  final double spin;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.isCircle,
    required this.angle,
    required this.spin,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()..color = p.color;
      canvas.save();
      canvas.translate(p.x * size.width, p.y * size.height);
      canvas.rotate(p.angle);
      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size, paint);
      } else {
        canvas.drawRect(
            Rect.fromCenter(
                center: Offset.zero, width: p.size * 1.6, height: p.size * 0.8),
            paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => true;
}

// ─── Page ─────────────────────────────────────────────────────────────────────

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
  // ── Animations ──────────────────────────────────────────────────────────────
  late final AnimationController _ringCtrl;
  late final AnimationController _cardCtrl;
  late final AnimationController _confettiCtrl;
  late final Animation<double> _ringAnim;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<int> _counterAnim;

  // ── Confetti ─────────────────────────────────────────────────────────────
  final List<_Particle> _particles = [];
  static const _confettiColors = [
    Color(0xFFFF5252), Color(0xFFFFD740), Color(0xFF69F0AE),
    Color(0xFF40C4FF), Color(0xFFE040FB), Color(0xFFFF6D00),
    Color(0xFFFFFFFF),
  ];

  @override
  void initState() {
    super.initState();

    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _confettiCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3));

    _ringAnim = CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOutCubic);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeIn);
    _counterAnim = IntTween(begin: 0, end: widget.score).animate(
        CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOutCubic));

    // Stagger: ring starts first, card slides in at 400 ms
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      _ringCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _cardCtrl.forward();
    });

    if (widget.score >= 70) {
      _initParticles();
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _confettiCtrl.forward();
      });
      _confettiCtrl.addListener(_tickParticles);
    }
  }

  void _initParticles() {
    final rng = Random();
    for (int i = 0; i < 80; i++) {
      _particles.add(_Particle(
        x: rng.nextDouble(),
        y: -0.1 - rng.nextDouble() * 0.4,
        vx: (rng.nextDouble() - 0.5) * 0.006,
        vy: 0.004 + rng.nextDouble() * 0.006,
        size: 4 + rng.nextDouble() * 5,
        color: _confettiColors[rng.nextInt(_confettiColors.length)]
            .withValues(alpha: 0.85),
        isCircle: rng.nextBool(),
        angle: rng.nextDouble() * 2 * pi,
        spin: (rng.nextDouble() - 0.5) * 0.15,
      ));
    }
  }

  void _tickParticles() {
    setState(() {
      for (final p in _particles) {
        p.x += p.vx;
        p.y += p.vy;
        p.vy += 0.0002; // gravity
        p.angle += p.spin;
      }
    });
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _cardCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    if (seconds <= 0) return '--';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  void _shareResult(BuildContext context, AppLocalizations l10n) {
    final title = widget.examTitle.isNotEmpty ? widget.examTitle : l10n.examMockExam;
    final grade = _gradeFor(widget.score);
    final statusLabel = widget.score >= 70 ? l10n.progressPassed : l10n.progressFailedCount;
    final statusIcon = widget.score >= 70 ? '✅' : '❌';
    final text =
        '$title\n$statusIcon $statusLabel — Score: ${widget.score}% (${l10n.examGradeLabel} $grade)\n'
        '${l10n.examCorrect}: ${widget.correctAnswers}/${widget.totalQuestions} | '
        '${l10n.examTimeSpent}: ${_formatTime(widget.timeSpentSeconds)}';
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.examCopiedToClipboard),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final passed = widget.score >= 70;
    final wrong = widget.totalQuestions - widget.correctAnswers;
    final progress = widget.totalQuestions > 0
        ? widget.correctAnswers / widget.totalQuestions
        : 0.0;
    final grade = _gradeFor(widget.score);
    final stars = _starsFor(widget.score);
    final primaryColor = passed ? AppColors.success : AppColors.warning;
    final size = MediaQuery.of(context).size;
    final ringSize = min(size.width * 0.50, 200.0);

    // Gradient changes based on pass/fail
    final topGradient = passed
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF059669), Color(0xFF34D399)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD97706), Color(0xFFFB923C)],
          );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // ── Background gradient panel ──────────────────────────────────
          Container(
            height: size.height * 0.52,
            decoration: BoxDecoration(gradient: topGradient),
          ),

          // ── Confetti (pass only) ──────────────────────────────────────
          if (passed && _particles.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ConfettiPainter(_particles),
                ),
              ),
            ),

          // ── Main content ──────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── Top bar ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 22),
                        onPressed: () => context.go('/home'),
                      ),
                      Expanded(
                        child: Text(
                          widget.examTitle.isNotEmpty
                              ? widget.examTitle
                              : l10n.examMockExam,
                          style: AppTextStyles.heading5.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Share button
                      IconButton(
                        icon: const Icon(Icons.ios_share_rounded,
                            color: Colors.white, size: 22),
                        tooltip: l10n.examShareResult,
                        onPressed: () => _shareResult(context, l10n),
                      ),
                    ],
                  ),
                ),

                // ── Score ring + grade badge ───────────────────────────
                const SizedBox(height: 4),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Score ring
                    AnimatedBuilder(
                      animation: _ringAnim,
                      builder: (ctx, _) => _ScoreRing(
                        progress: progress * _ringAnim.value,
                        displayScore: _counterAnim.value,
                        passed: passed,
                        size: ringSize,
                        label: passed
                            ? l10n.progressPassed
                            : l10n.progressFailedCount,
                      ),
                    ),

                    // Grade badge (top-right of ring)
                    Positioned(
                      top: 0,
                      right: (size.width - ringSize) / 2 - 4,
                      child: _GradeBadge(grade: grade, passed: passed),
                    ),
                  ],
                ),

                // ── Stars ─────────────────────────────────────────────
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: AnimatedBuilder(
                        animation: _ringAnim,
                        builder: (ctx, _) {
                          final delay = (i * 0.15).clamp(0.0, 1.0);
                          final animVal =
                              ((_ringAnim.value - delay) / (1 - delay))
                                  .clamp(0.0, 1.0);
                          return Transform.scale(
                            scale: i < stars
                                ? 0.6 + 0.4 * animVal
                                : 1.0,
                            child: Icon(
                              i < stars
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: i < stars
                                  ? Colors.amber
                                  : Colors.white.withValues(alpha: 0.45),
                              size: 26,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  passed ? l10n.examCongratulations : l10n.examGoodEffort,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    passed ? l10n.examPassedMessage : l10n.examFailedMessage,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // ── Scrollable bottom card ─────────────────────────────
                const SizedBox(height: 18),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(28)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 24,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ── Stats grid ───────────────────────────
                              _StatsGrid(
                                correct: widget.correctAnswers,
                                wrong: wrong,
                                total: widget.totalQuestions,
                                timeStr: _formatTime(widget.timeSpentSeconds),
                                score: widget.score,
                                l10n: l10n,
                                primaryColor: primaryColor,
                                ringAnim: _ringAnim,
                              ),

                              const SizedBox(height: 16),

                              // ── Pass/fail banner ─────────────────────
                              _ResultBanner(
                                  passed: passed,
                                  primaryColor: primaryColor,
                                  l10n: l10n),

                              const SizedBox(height: 20),

                              // ── Action buttons ────────────────────────
                              _ActionButton(
                                icon: Icons.replay_rounded,
                                label: l10n.examRetakeTest,
                                color: primaryColor,
                                filled: true,
                                onTap: () => context.go('/exam'),
                              ),
                              const SizedBox(height: 10),
                              _ActionButton(
                                icon: Icons.home_rounded,
                                label: l10n.examBackHome,
                                color: primaryColor,
                                filled: false,
                                onTap: () => context.go('/home'),
                              ),
                              const SizedBox(height: 10),
                              _ActionButton(
                                icon: Icons.bar_chart_rounded,
                                label: l10n.progressTitle,
                                color: AppColors.textSecondary,
                                filled: false,
                                outlined: false,
                                onTap: () => context.go('/progress'),
                              ),
                              const SizedBox(height: 10),
                              _ActionButton(
                                icon: Icons.ios_share_rounded,
                                label: l10n.examShareResult,
                                color: AppColors.textSecondary,
                                filled: false,
                                outlined: false,
                                onTap: () => _shareResult(context, l10n),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Score ring ───────────────────────────────────────────────────────────────

class _ScoreRing extends StatelessWidget {
  final double progress;
  final int displayScore;
  final bool passed;
  final double size;
  final String label;

  const _ScoreRing({
    required this.progress,
    required this.displayScore,
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
          bgColor: Colors.white.withValues(alpha: 0.22),
          fgColor: Colors.white,
          trackColor: Colors.white.withValues(alpha: 0.1),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$displayScore%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.24,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontSize: size * 0.10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Ring painter ─────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  final Color bgColor;
  final Color fgColor;
  final Color trackColor;

  _RingPainter({
    required this.progress,
    required this.bgColor,
    required this.fgColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokeW = size.width * 0.09;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeW) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background track
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi,
      false,
      Paint()
        ..color = bgColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW,
    );

    // Progress arc
    if (progress > 0) {
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
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}

// ─── Grade badge ──────────────────────────────────────────────────────────────

class _GradeBadge extends StatelessWidget {
  final String grade;
  final bool passed;

  const _GradeBadge({required this.grade, required this.passed});

  @override
  Widget build(BuildContext context) {
    final bg = passed ? const Color(0xFFFFD700) : const Color(0xFFFF7043);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
              color: bg.withValues(alpha: 0.5),
              blurRadius: 8,
              spreadRadius: 2),
        ],
      ),
      child: Center(
        child: Text(
          grade,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ─── Stats grid ───────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final int correct;
  final int wrong;
  final int total;
  final String timeStr;
  final int score;
  final AppLocalizations l10n;
  final Color primaryColor;
  final Animation<double> ringAnim;

  const _StatsGrid({
    required this.correct,
    required this.wrong,
    required this.total,
    required this.timeStr,
    required this.score,
    required this.l10n,
    required this.primaryColor,
    required this.ringAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Three chips ────────────────────────────────────────────────
        Row(
          children: [
            _Chip(
                icon: Icons.check_circle_rounded,
                value: '$correct',
                label: l10n.examCorrect,
                color: AppColors.success),
            const SizedBox(width: 10),
            _Chip(
                icon: Icons.cancel_rounded,
                value: '$wrong',
                label: l10n.examWrong,
                color: AppColors.error),
            const SizedBox(width: 10),
            _Chip(
                icon: Icons.timer_rounded,
                value: timeStr,
                label: l10n.examTimeSpent,
                color: AppColors.primaryLight),
          ],
        ),

        const SizedBox(height: 16),

        // ── Accuracy bar ───────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.examAccuracy, style: AppTextStyles.labelMedium),
            AnimatedBuilder(
              animation: ringAnim,
              builder: (ctx, _) => Text(
                '${(score * ringAnim.value).toInt()}%',
                style: AppTextStyles.heading6.copyWith(color: primaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: ringAnim,
          builder: (ctx, _) => ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (score / 100) * ringAnim.value,
              minHeight: 10,
              backgroundColor: primaryColor.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
        ),

        // ── Threshold indicator ────────────────────────────────────────
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${l10n.examPassingScore}: 70%',
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _Chip(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style:
                    AppTextStyles.heading6.copyWith(color: color, height: 1)),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pass/fail result banner ──────────────────────────────────────────────────

class _ResultBanner extends StatelessWidget {
  final bool passed;
  final Color primaryColor;
  final AppLocalizations l10n;

  const _ResultBanner(
      {required this.passed,
      required this.primaryColor,
      required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryColor.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              passed ? Icons.emoji_events_rounded : Icons.lightbulb_outline,
              color: primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              passed ? l10n.examBadgeEarned : l10n.examNeedMorePractice,
              style: AppTextStyles.bodySmall.copyWith(color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action button ────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool filled;
  final bool outlined;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.filled,
    this.outlined = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 2,
        ),
      );
    }
    if (outlined) {
      return OutlinedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.6)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
    }
    return TextButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10),
        foregroundColor: color,
      ),
    );
  }
}
