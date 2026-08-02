import 'package:flutter/material.dart';

/// Animated shimmer placeholder block used while content is loading.
class SkeletonBox extends StatefulWidget {
  final double? width;
  final double? height;
  final double radius;

  const SkeletonBox({super.key, this.width, this.height, this.radius = 12});

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  late final Animation<Alignment> _sweep = Tween<Alignment>(
    begin: const Alignment(-1.2, 0),
    end: const Alignment(1.2, 0),
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;
    final base = outline.withValues(alpha: 0.12);
    final highlight = outline.withValues(alpha: 0.28);

    return AnimatedBuilder(
      animation: _sweep,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: _sweep.value,
            end: Alignment(-_sweep.value.x, _sweep.value.y),
            colors: [base, highlight, base],
          ),
        ),
      ),
    );
  }
}

/// A grid of [SkeletonBox] cards used to mock a loading card grid
/// (exam list, signs library, etc.) without layout jumps.
class SkeletonCardGrid extends StatelessWidget {
  final int crossAxisCount;
  final int itemCount;
  final double mainAxisExtent;
  final double radius;
  final EdgeInsets padding;

  const SkeletonCardGrid({
    super.key,
    this.crossAxisCount = 2,
    this.itemCount = 6,
    this.mainAxisExtent = 100,
    this.radius = 16,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: mainAxisExtent,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => SkeletonBox(radius: radius),
    );
  }
}
