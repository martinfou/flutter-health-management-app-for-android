import 'package:flutter/material.dart';
import 'package:health_app/core/constants/ui_constants.dart';

/// Button variant types
enum ButtonVariant {
  /// Primary button with filled background
  primary,

  /// Secondary button with outlined border
  secondary,

  /// Text button with no border or background
  text,
}

/// Reusable custom button widget with variants
/// 
/// Supports primary, secondary, and text button styles.
/// Meets WCAG 2.1 AA accessibility requirements (48x48dp minimum touch target).
class CustomButton extends StatelessWidget {
  /// Button label text
  final String label;

  /// Button press callback
  final VoidCallback? onPressed;

  /// Button variant (primary, secondary, or text)
  final ButtonVariant variant;

  /// Whether button is in loading state
  final bool isLoading;

  /// Optional icon to display before label
  final IconData? icon;

  /// Button width (null for intrinsic width)
  final double? width;

  /// Button height (default: 48dp minimum)
  final double? height;

  /// Creates a custom button
  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null && !isLoading;

    // Determine button style based on variant
    final buttonStyle = _getButtonStyle(context, isEnabled);

    Widget buttonContent;
    if (isLoading) {
      buttonContent = SizedBox(
        width: UIConstants.iconSizeMd,
        height: UIConstants.iconSizeMd,
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == ButtonVariant.primary
                ? Colors.white
                : theme.colorScheme.primary,
          ),
        ),
      );
    } else {
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: UIConstants.iconSizeSm),
            SizedBox(width: UIConstants.spacingXs),
          ],
          Text(label),
        ],
      );
    }

    final button = Semantics(
      label: label,
      button: true,
      enabled: isEnabled,
      child: SizedBox(
        width: width,
        height: height ?? UIConstants.minTouchTarget,
        child: _buildButton(context, buttonStyle, buttonContent, isEnabled),
      ),
    );

    return button;
  }

  ButtonStyle _getButtonStyle(BuildContext context, bool isEnabled) {
    final theme = Theme.of(context);

    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          foregroundColor: isEnabled
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface.withValues(alpha: 0.38),
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.buttonPadding,
            vertical: UIConstants.spacingSm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
          ),
          elevation: isEnabled ? UIConstants.elevationMedium : 0,
        );

      case ButtonVariant.secondary:
        return OutlinedButton.styleFrom(
          foregroundColor: isEnabled
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.38),
          side: BorderSide(
            color: isEnabled
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.12),
            width: 1.0,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.buttonPadding,
            vertical: UIConstants.spacingSm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.borderRadiusMd),
          ),
        );

      case ButtonVariant.text:
        return TextButton.styleFrom(
          foregroundColor: isEnabled
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.38),
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacingMd,
            vertical: UIConstants.spacingSm,
          ),
        );
    }
  }

  Widget _buildButton(
    BuildContext context,
    ButtonStyle style,
    Widget content,
    bool isEnabled,
  ) {
    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: style,
          child: content,
        );

      case ButtonVariant.secondary:
        return OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: style,
          child: content,
        );

      case ButtonVariant.text:
        return TextButton(
          onPressed: isEnabled ? onPressed : null,
          style: style,
          child: content,
        );
    }
  }
}

