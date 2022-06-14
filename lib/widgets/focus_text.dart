import 'package:flutter/material.dart';

/// A widget that displays [text] inside a [Focus] widget.
class FocusText extends StatelessWidget {
  /// Create an instance.
  const FocusText({
    required this.text,
    this.autofocus = false,
    super.key,
  });

  /// The text to show.
  final String text;

  /// Whether or not this widget should be autofocused.
  final bool autofocus;

  /// Build the widget.
  @override
  Widget build(final BuildContext context) => Focus(
        autofocus: autofocus,
        child: Text(text),
      );
}
