import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';

/// Toss-style primary button (Blue background, white text)
class TossPrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const TossPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  });

  @override
  State<TossPrimaryButton> createState() => _TossPrimaryButtonState();
}

class _TossPrimaryButtonState extends State<TossPrimaryButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => _setPressed(true) : null,
        onTapUp: isEnabled ? (_) => _setPressed(false) : null,
        onTapCancel: isEnabled ? () => _setPressed(false) : null,
        onTap: isEnabled
            ? () {
                if (!kIsWeb) HapticFeedback.lightImpact();
                widget.onPressed?.call();
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
          transformAlignment: Alignment.center,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 100),
            opacity: _isPressed ? 0.7 : (isEnabled ? 1.0 : 0.5),
            child: Container(
              width: widget.fullWidth ? double.infinity : null,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLG,
                vertical: AppTheme.spacingMD,
              ),
              decoration: BoxDecoration(
                color: _isHovered && isEnabled
                    ? AppTheme.primary.withValues(alpha: 0.9)
                    : AppTheme.primary,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                boxShadow: _isHovered && isEnabled
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: widget.fullWidth
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading) ...[
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ] else ...[
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: Colors.white, size: 20),
                      const SizedBox(width: AppTheme.spacingSM),
                    ],
                    Text(
                      widget.text,
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: Colors.white),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _setPressed(bool value) {
    setState(() => _isPressed = value);
  }
}

/// Toss-style secondary button (White background, border)
class TossSecondaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const TossSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  });

  @override
  State<TossSecondaryButton> createState() => _TossSecondaryButtonState();
}

class _TossSecondaryButtonState extends State<TossSecondaryButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => _setPressed(true) : null,
        onTapUp: isEnabled ? (_) => _setPressed(false) : null,
        onTapCancel: isEnabled ? () => _setPressed(false) : null,
        onTap: isEnabled
            ? () {
                if (!kIsWeb) HapticFeedback.lightImpact();
                widget.onPressed?.call();
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
          transformAlignment: Alignment.center,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 100),
            opacity: _isPressed ? 0.7 : (isEnabled ? 1.0 : 0.5),
            child: Container(
              width: widget.fullWidth ? double.infinity : null,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLG,
                vertical: AppTheme.spacingMD,
              ),
              decoration: BoxDecoration(
                color: _isHovered && isEnabled
                    ? AppTheme.background
                    : AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(
                  color: _isHovered && isEnabled
                      ? AppTheme.primary
                      : AppTheme.border,
                ),
                boxShadow: _isHovered && isEnabled ? AppTheme.cardShadow : null,
              ),
              child: Row(
                mainAxisSize: widget.fullWidth
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading) ...[
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ] else ...[
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: AppTheme.textPrimary, size: 20),
                      const SizedBox(width: AppTheme.spacingSM),
                    ],
                    Text(
                      widget.text,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _setPressed(bool value) {
    setState(() => _isPressed = value);
  }
}

/// Toss-style text button (No background)
class TossTextButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  const TossTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.color,
  });

  @override
  State<TossTextButton> createState() => _TossTextButtonState();
}

class _TossTextButtonState extends State<TossTextButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppTheme.primary;
    final isEnabled = widget.onPressed != null;

    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => _setPressed(true) : null,
        onTapUp: isEnabled ? (_) => _setPressed(false) : null,
        onTapCancel: isEnabled ? () => _setPressed(false) : null,
        onTap: isEnabled
            ? () {
                if (!kIsWeb) HapticFeedback.lightImpact();
                widget.onPressed?.call();
              }
            : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: _isPressed ? 0.5 : (isEnabled ? 1.0 : 0.4),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSM,
              vertical: AppTheme.spacingXS,
            ),
            decoration: BoxDecoration(
              color: _isHovered && isEnabled
                  ? color.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: color, size: 18),
                  const SizedBox(width: AppTheme.spacingXS),
                ],
                Text(
                  widget.text,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    decoration: _isHovered ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _setPressed(bool value) {
    setState(() => _isPressed = value);
  }
}

/// Toss-style icon button
class TossIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final String? tooltip;

  const TossIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 24,
    this.tooltip,
  });

  @override
  State<TossIconButton> createState() => _TossIconButtonState();
}

class _TossIconButtonState extends State<TossIconButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppTheme.textPrimary;
    final isEnabled = widget.onPressed != null;

    Widget button = MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => _setPressed(true) : null,
        onTapUp: isEnabled ? (_) => _setPressed(false) : null,
        onTapCancel: isEnabled ? () => _setPressed(false) : null,
        onTap: isEnabled
            ? () {
                if (!kIsWeb) HapticFeedback.lightImpact();
                widget.onPressed?.call();
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.all(AppTheme.spacingSM),
          decoration: BoxDecoration(
            color: _isHovered && isEnabled
                ? AppTheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 100),
            opacity: _isPressed ? 0.5 : (isEnabled ? 1.0 : 0.4),
            child: Icon(widget.icon, color: color, size: widget.size),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        triggerMode: kIsWeb ? TooltipTriggerMode.tap : TooltipTriggerMode.longPress,
        child: button,
      );
    }

    return button;
  }

  void _setPressed(bool value) {
    setState(() => _isPressed = value);
  }
}

/// Segmented control (Toss style pill selector)
class TossSegmentedControl<T> extends StatefulWidget {
  final List<T> items;
  final T selectedItem;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;

  const TossSegmentedControl({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  State<TossSegmentedControl<T>> createState() => _TossSegmentedControlState<T>();
}

class _TossSegmentedControlState<T> extends State<TossSegmentedControl<T>> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = item == widget.selectedItem;
          final isHovered = _hoveredIndex == index && !isSelected;

          return Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _hoveredIndex = index),
              onExit: (_) => setState(() => _hoveredIndex = null),
              child: GestureDetector(
                onTap: () {
                  if (!kIsWeb) HapticFeedback.lightImpact();
                  widget.onChanged(item);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingSM,
                    horizontal: AppTheme.spacingMD,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary
                        : isHovered
                            ? AppTheme.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall - 2),
                  ),
                  child: Text(
                    widget.labelBuilder(item),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
