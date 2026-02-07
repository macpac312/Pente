import 'package:flutter/material.dart';
import '../theme/neon_theme.dart';

class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final IconData? icon;
  final double width;
  final double height;
  final double fontSize;
  final bool enabled;

  const NeonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = NeonTheme.neonCyan,
    this.icon,
    this.width = double.infinity,
    this.height = 56,
    this.fontSize = 16,
    this.enabled = true,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.enabled ? widget.color : widget.color.withOpacity(0.3);

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            if (widget.enabled) widget.onPressed();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: _isPressed
                  ? color.withOpacity(0.2)
                  : NeonTheme.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(_isPressed ? 0.9 : 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(
                      _isPressed ? 0.5 : _glowAnimation.value * 0.4),
                  blurRadius: _isPressed ? 16 : 10,
                  spreadRadius: _isPressed ? 2 : 0,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: color, size: 22),
                  const SizedBox(width: 10),
                ],
                Text(
                  widget.text,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.bold,
                    color: color,
                    shadows: NeonTheme.neonTextShadow(color, intensity: 0.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class NeonIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final double size;
  final String? tooltip;

  const NeonIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color = NeonTheme.neonCyan,
    this.size = 24,
    this.tooltip,
  });

  @override
  State<NeonIconButton> createState() => _NeonIconButtonState();
}

class _NeonIconButtonState extends State<NeonIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Tooltip(
        message: widget.tooltip ?? '',
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isPressed
                ? widget.color.withOpacity(0.15)
                : Colors.transparent,
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 12,
                    ),
                  ]
                : [],
          ),
          child: Icon(
            widget.icon,
            color: widget.color,
            size: widget.size,
            shadows: [
              Shadow(
                color: widget.color.withOpacity(0.6),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
