import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Toss-style card with subtle elevation and hover effects
/// Clean white card on gray background, no glassmorphism
class TossCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? borderRadius;
  final bool elevated;

  const TossCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius,
    this.elevated = true,
  });

  @override
  State<TossCard> createState() => _TossCardState();
}

class _TossCardState extends State<TossCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hasOnTap = widget.onTap != null;
    final radius = widget.borderRadius ?? AppTheme.radiusMedium;

    return MouseRegion(
      cursor: hasOnTap ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: hasOnTap ? (_) => setState(() => _isHovered = true) : null,
      onExit: hasOnTap ? (_) => setState(() => _isHovered = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: widget.margin,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(radius),
          border: _isHovered && hasOnTap
              ? Border.all(color: AppTheme.primary.withValues(alpha: 0.3))
              : null,
          boxShadow: _isHovered && hasOnTap
              ? AppTheme.elevatedShadow
              : (widget.elevated ? AppTheme.cardShadow : null),
        ),
        transform: _isHovered && hasOnTap
            ? (Matrix4.identity()..translate(0.0, -2.0))
            : Matrix4.identity(),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Material(
            color: Colors.transparent,
            child: hasOnTap
                ? InkWell(
                    onTap: widget.onTap,
                    splashColor: AppTheme.primary.withValues(alpha: 0.08),
                    highlightColor: AppTheme.primary.withValues(alpha: 0.04),
                    child: Padding(
                      padding: widget.padding ?? EdgeInsets.zero,
                      child: widget.child,
                    ),
                  )
                : Padding(
                    padding: widget.padding ?? EdgeInsets.zero,
                    child: widget.child,
                  ),
          ),
        ),
      ),
    );
  }
}

/// List item card - for items in a list with dividers
class TossListCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;

  const TossListCard({
    super.key,
    required this.children,
    this.margin,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppTheme.radiusMedium,
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppTheme.radiusMedium,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(children.length * 2 - 1, (index) {
            if (index.isOdd) {
              return const Divider(
                height: 1,
                thickness: 1,
                indent: 16,
                endIndent: 16,
              );
            }
            return children[index ~/ 2];
          }),
        ),
      ),
    );
  }
}

/// List item for TossListCard with hover support
class TossListItem extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  const TossListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  @override
  State<TossListItem> createState() => _TossListItemState();
}

class _TossListItemState extends State<TossListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hasOnTap = widget.onTap != null;

    return MouseRegion(
      cursor: hasOnTap ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: hasOnTap ? (_) => setState(() => _isHovered = true) : null,
      onExit: hasOnTap ? (_) => setState(() => _isHovered = false) : null,
      child: Material(
        color: _isHovered ? AppTheme.primary.withValues(alpha: 0.04) : Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          splashColor: AppTheme.primary.withValues(alpha: 0.08),
          highlightColor: AppTheme.primary.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMD,
              vertical: AppTheme.spacingMD,
            ),
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: AppTheme.spacingMD),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.title, style: Theme.of(context).textTheme.titleSmall),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.trailing != null) ...[
                  const SizedBox(width: AppTheme.spacingSM),
                  widget.trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Action card with icon, title, description, and arrow
class TossActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  const TossActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TossCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppTheme.spacingLG),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: AppTheme.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(description, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingSM),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppTheme.primary,
          ),
        ],
      ),
    );
  }
}
