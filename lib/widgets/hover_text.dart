import 'package:flutter/material.dart';

/// A simple Text replacement that changes color on mouse hover.
class HoverText extends StatefulWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const HoverText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  State<HoverText> createState() => _HoverTextState();
}

class _HoverTextState extends State<HoverText> {
  bool _hovering = false;

  void _onEnter(PointerEvent _) => setState(() => _hovering = true);
  void _onExit(PointerEvent _) => setState(() => _hovering = false);

  @override
  Widget build(BuildContext context) {
  final theme = Theme.of(context).textTheme;
  final themeColor = (theme.bodyMedium ?? theme.bodyLarge ?? theme.titleMedium)?.color ?? Colors.blue;
    final baseStyle = widget.style ?? const TextStyle();
    final color = _hovering ? Colors.white : (baseStyle.color ?? themeColor);

    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: Text(
        widget.data,
        style: baseStyle.copyWith(color: color),
        textAlign: widget.textAlign,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
      ),
    );
  }
}
