import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Tarjeta 3D infantil (mirror de .kid-card de la web):
/// blanca, radius 24, borde 4px y sombra dura sólida que se "hunde" al presionar.
class KidCard extends StatefulWidget {
  final Widget child;
  final Color? accentColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double shadowOffset;
  final Color? backgroundColor;

  const KidCard({
    super.key,
    required this.child,
    this.accentColor,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.shadowOffset = 6,
    this.backgroundColor,
  });

  @override
  State<KidCard> createState() => _KidCardState();
}

class _KidCardState extends State<KidCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor;
    final borderColor = accent != null
        ? accent.withValues(alpha: 0.35)
        : AppColors.border;
    final shadowColor = accent ?? const Color(0xFFCBD5E1);
    final offset = _pressed ? 2.0 : widget.shadowOffset;

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(
          0, _pressed ? widget.shadowOffset - 2 : 0, 0),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.kidCard),
        border: Border.all(color: borderColor, width: 4),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: Offset(0, offset),
            blurRadius: 0,
          ),
        ],
      ),
      child: widget.child,
    );

    if (widget.onTap == null) return card;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: card,
    );
  }
}

/// Botón 3D con sombra dura (mirror de los botones de acción de la web).
class KidButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final IconData? icon;
  final bool expanded;
  final bool loading;

  const KidButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primary,
    this.icon,
    this.expanded = false,
    this.loading = false,
  });

  @override
  State<KidButton> createState() => _KidButtonState();
}

class _KidButtonState extends State<KidButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;
    final color = enabled ? widget.color : AppColors.textLight;
    final shadow = darken(color, 0.32);

    final content = Row(
      mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.loading)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
                strokeWidth: 2.5, color: Colors.white),
          )
        else if (widget.icon != null)
          Icon(widget.icon, color: Colors.white, size: 20),
        if (widget.icon != null || widget.loading) const SizedBox(width: 8),
        Flexible(
          child: Text(
            widget.label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: enabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, _pressed ? 3 : 0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: darken(color, 0.15), width: 2),
          boxShadow: [
            BoxShadow(
              color: shadow,
              offset: Offset(0, _pressed ? 1 : 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: content,
      ),
    );
  }
}

/// Botón secundario (Volver / Cancelar), estilo .btn-back de la web.
class KidBackButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData icon;

  const KidBackButton({
    super.key,
    this.label = 'Volver',
    required this.onPressed,
    this.icon = Icons.arrow_back,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: AppColors.textMuted),
      label: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
      ),
    );
  }
}
