import 'package:flutter/material.dart';

/// Hand-rolled shimmer sweep (no `shimmer` package — only ~3 call sites need
/// this, not worth a new dependency for). A soft highlight band slides left
/// to right across a muted base fill, looping continuously.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({super.key, this.width, this.height, this.borderRadius = 4});

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final base = onSurface.withValues(alpha: 0.06);
    final highlight = onSurface.withValues(alpha: 0.14);

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final dx = (_controller.value * 4) - 2; // sweeps roughly -2..2
            return ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (bounds) => LinearGradient(
                colors: [base, highlight, base],
                stops: const [0.35, 0.5, 0.65],
                begin: Alignment(-1 + dx, 0),
                end: Alignment(1 + dx, 0),
              ).createShader(bounds),
              child: Container(color: base),
            );
          },
        ),
      ),
    );
  }
}
