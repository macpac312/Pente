import 'package:flutter/material.dart';
import '../theme/neon_theme.dart';
import '../utils/constants.dart';

class NeonStone extends StatefulWidget {
  final StoneType type;
  final Color player1Color;
  final Color player2Color;
  final double size;
  final bool isLastMove;
  final bool isWinningStone;
  final bool isCaptured;
  final bool isHinted;
  final int? moveNumber;
  final bool showMoveNumber;
  final bool animate;

  const NeonStone({
    super.key,
    required this.type,
    this.player1Color = NeonTheme.neonCyan,
    this.player2Color = NeonTheme.neonPink,
    this.size = 28,
    this.isLastMove = false,
    this.isWinningStone = false,
    this.isCaptured = false,
    this.isHinted = false,
    this.moveNumber,
    this.showMoveNumber = false,
    this.animate = true,
  });

  @override
  State<NeonStone> createState() => _NeonStoneState();
}

class _NeonStoneState extends State<NeonStone>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == StoneType.none) {
      if (widget.isHinted) {
        return _buildHintIndicator();
      }
      return const SizedBox.shrink();
    }

    final color = widget.type == StoneType.player1
        ? widget.player1Color
        : widget.player2Color;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.animate ? _scaleAnimation.value : 1.0,
          child: _buildStone(color),
        );
      },
    );
  }

  Widget _buildStone(Color color) {
    final glowIntensity = widget.isWinningStone ? 1.5 : 1.0;
    final double extraGlow = widget.isLastMove ? 0.3 : 0.0;

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.9),
            color.withOpacity(0.6),
            color.withOpacity(0.3),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          // Inner glow
          BoxShadow(
            color: color.withOpacity(0.8 * glowIntensity),
            blurRadius: 6 * glowIntensity,
            spreadRadius: 1,
          ),
          // Outer glow
          BoxShadow(
            color: color.withOpacity((0.4 + extraGlow) * glowIntensity),
            blurRadius: 12 * glowIntensity,
            spreadRadius: 2,
          ),
          // Ambient glow
          if (widget.isWinningStone || widget.isLastMove)
            BoxShadow(
              color: color.withOpacity(0.2 * glowIntensity),
              blurRadius: 24,
              spreadRadius: 4,
            ),
        ],
      ),
      child: Center(
        child: Container(
          width: widget.size * 0.6,
          height: widget.size * 0.6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.15),
          ),
          child: widget.showMoveNumber && widget.moveNumber != null
              ? Center(
                  child: Text(
                    '${widget.moveNumber}',
                    style: TextStyle(
                      fontSize: widget.size * 0.28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.9),
                      fontFamily: NeonTheme.fontFamily,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildHintIndicator() {
    return Container(
      width: widget.size * 0.5,
      height: widget.size * 0.5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: NeonTheme.neonGreen.withOpacity(0.3),
        border: Border.all(
          color: NeonTheme.neonGreen.withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: NeonTheme.neonGreen.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class CapturedStoneAnimation extends StatefulWidget {
  final Color color;
  final double size;
  final VoidCallback? onComplete;

  const CapturedStoneAnimation({
    super.key,
    required this.color,
    this.size = 28,
    this.onComplete,
  });

  @override
  State<CapturedStoneAnimation> createState() => _CapturedStoneAnimationState();
}

class _CapturedStoneAnimationState extends State<CapturedStoneAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward().then((_) => widget.onComplete?.call());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 1.0 - _controller.value,
          child: Transform.scale(
            scale: 1.0 + _controller.value * 0.5,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(0.5),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.6),
                    blurRadius: 16 + _controller.value * 16,
                    spreadRadius: _controller.value * 8,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
