import 'package:flutter/material.dart';
import '../theme/neon_theme.dart';

/// Thin wrapper around ElevatedButton with a neon glow container.
class NeonButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final effectiveColor = enabled ? color : color.withAlpha(80);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: enabled
            ? [NeonTheme.neonGlow(color, blur: 8, spread: 1)]
            : [],
      ),
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveColor.withAlpha(30),
          foregroundColor: effectiveColor,
          disabledBackgroundColor: color.withAlpha(10),
          disabledForegroundColor: color.withAlpha(60),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: effectiveColor.withAlpha(120)),
          ),
          textStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 22),
              const SizedBox(width: 10),
            ],
            Text(text),
          ],
        ),
      ),
    );
  }
}
