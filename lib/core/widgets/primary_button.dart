import 'package:flutter/material.dart';

/// The one primary action of a view (spec T7 › G2): 48 high, radius 8,
/// accent-primary fill. Full width by default; [expand] false hugs content
/// (e.g. a FAB).
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expand;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final style = FilledButton.styleFrom(
      minimumSize: expand ? const Size.fromHeight(48) : const Size(0, 48),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

    if (loading) {
      return FilledButton(
        style: style,
        onPressed: null,
        child: const SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (icon != null) {
      return FilledButton.icon(
        style: style,
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
      );
    }
    return FilledButton(style: style, onPressed: onPressed, child: Text(label));
  }
}
