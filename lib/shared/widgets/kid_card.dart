import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/palette.dart';
import '../../app/theme.dart';

/// Tarjeta 3D infantil (mirror de .kid-card de la web).
/// Presupuesto de profundidad: la sombra dura y el borde de 4px se reservan
/// para lo pulsable (`onTap != null`). Lo estático se pinta con borde fino
/// y sombra difusa mínima, para que solo lo que se toca grite.
class KidCard extends StatefulWidget {
  final Widget child;
  final Color? accentColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double shadowOffset;
  final Color? backgroundColor;

  /// Etiqueta para lectores de pantalla. Si es null y hay `onTap`, TalkBack
  /// solo anuncia "botón" sin contexto — mejor pasarla siempre que se pueda.
  final String? semanticLabel;

  const KidCard({
    super.key,
    required this.child,
    this.accentColor,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.shadowOffset = 6,
    this.backgroundColor,
    this.semanticLabel,
  });

  @override
  State<KidCard> createState() => _KidCardState();
}

class _KidCardState extends State<KidCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final pulsable = widget.onTap != null;
    final accent =
        widget.accentColor == null ? null : adaptBrand(context, widget.accentColor!);
    final borderColor =
        accent != null ? accent.withValues(alpha: 0.35) : palette.border;
    final shadowColor = accent ?? palette.shadowNeutral;
    final offset = _pressed ? 2.0 : widget.shadowOffset;

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(
          0, _pressed ? widget.shadowOffset - 2 : 0, 0),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? palette.surface,
        borderRadius: BorderRadius.circular(AppRadius.kidCard),
        border: Border.all(
          color: borderColor,
          width: pulsable ? 4 : 1.5,
        ),
        boxShadow: [
          if (pulsable)
            BoxShadow(
              color: shadowColor,
              offset: Offset(0, offset),
              blurRadius: 0,
            )
          else
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.28),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
        ],
      ),
      child: widget.child,
    );

    if (!pulsable) return card;

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap!();
        },
        child: card,
      ),
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
    final color = enabled
        ? adaptBrand(context, widget.color)
        : context.palette.textLight;
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

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: enabled
            ? () {
                HapticFeedback.selectionClick();
                widget.onPressed!();
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.translationValues(0, _pressed ? 3 : 0, 0),
          constraints: const BoxConstraints(minHeight: 48),
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
    final palette = context.palette;
    return OutlinedButton.icon(
      onPressed: onPressed == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onPressed!();
            },
      icon: Icon(icon, size: 18, color: palette.textMuted),
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          color: palette.textMuted,
        ),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: palette.surface,
        side: BorderSide(color: palette.border),
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
      ),
    );
  }
}
