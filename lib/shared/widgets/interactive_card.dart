import 'package:flutter/material.dart';

/// Wraps a tappable card with web-friendly interactivity:
///  - pointer cursor on hover (desktop)
///  - hover / focus / pressed visual states exposed to the page's builder
///  - keyboard activation: Tab to focus, Enter/Space to activate
///
/// The page supplies a [builder] that renders the card using the current
/// [InteractiveCardState] (e.g. to lift the card on hover or draw a focus
/// ring), so every surface gets consistent behavior without duplicating
/// Focus/MouseRegion plumbing.
class InteractiveCard extends StatefulWidget {
  final VoidCallback? onTap;

  /// When false the card is inert: no cursor, focus, or activation.
  final bool enabled;

  final Widget Function(BuildContext context, InteractiveCardState state)
  builder;

  const InteractiveCard({
    super.key,
    this.onTap,
    this.enabled = true,
    required this.builder,
  });

  @override
  State<InteractiveCard> createState() => InteractiveCardState();
}

class InteractiveCardState extends State<InteractiveCard> {
  final FocusNode _focusNode = FocusNode();

  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  /// True while the pointer is over the card (desktop).
  bool get hovered => _hovered;

  /// True while the card has keyboard focus (Tab).
  bool get focused => _focused;

  /// True while the pointer is pressed down on the card.
  bool get pressed => _pressed;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _activate() {
    if (widget.enabled) widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final interactive = widget.enabled && widget.onTap != null;
    return FocusableActionDetector(
      focusNode: _focusNode,
      enabled: interactive,
      mouseCursor: interactive
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      onShowHoverHighlight: (v) => setState(() => _hovered = v),
      actions: {
        // Keyboard activation (Enter / Space while focused).
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            _activate();
            return null;
          },
        ),
      },
      child: GestureDetector(
        // Pointer activation + pressed feedback (mouse & touch).
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          _activate();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: widget.builder(context, this),
      ),
    );
  }
}
