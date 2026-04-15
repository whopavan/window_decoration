import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class ButtonState {
  const ButtonState({
    required this.enabled,
    required this.hovered,
    required this.pressed,
  });

  final bool enabled;
  final bool hovered;
  final bool pressed;
}

typedef ButtonBuilder =
    Widget Function(BuildContext context, ButtonState state, Widget? child);

class Button extends StatefulWidget {
  const Button({
    super.key,
    required this.builder,
    this.onPressed,
    this.focusNode,
  });

  final ButtonBuilder builder;
  final VoidCallback? onPressed;
  final FocusNode? focusNode;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  bool _hovered = false;
  bool _pressed = false;
  bool _inside = false;

  bool get _enabled => widget.onPressed != null;

  void _setHovered(bool v) {
    if (_hovered != v) setState(() => _hovered = v);
  }

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  void _onEnter(PointerEnterEvent _) {
    _inside = true;
    _setHovered(true);
  }

  void _onExit(PointerExitEvent _) {
    _inside = false;
    _setHovered(false);
    _setPressed(false);
  }

  void _onTapDown(TapDownDetails _) {
    if (!_enabled) return;
    _setPressed(true);
  }

  void _onTapUp(TapUpDetails _) {
    if (!_enabled) {
      _setPressed(false);
      return;
    }
    final wasPressed = _pressed;
    _setPressed(false);
    if (wasPressed && _inside) {
      widget.onPressed?.call();
    }
  }

  void _onTapCancel() {
    _setPressed(false);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Focus(
          focusNode: widget.focusNode,
          canRequestFocus: false,
          child: widget.builder(
            context,
            ButtonState(
              enabled: _enabled,
              hovered: _hovered,
              pressed: _pressed && _inside,
            ),
            null,
          ),
        ),
      ),
    );
  }
}
