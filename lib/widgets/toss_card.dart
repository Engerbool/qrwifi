import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Toss-style card with subtle elevation
/// Clean white card on gray background, no glassmorphism
class TossCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusMedium),
        boxShadow: elevated ? AppTheme.cardShadow : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusMedium),
        child: Material(
          color: Colors.transparent,
          child: onTap != null
              ? InkWell(
                  onTap: onTap,
                  splashColor: AppTheme.primary.withValues(alpha: 0.08),
                  highlightColor: AppTheme.primary.withValues(alpha: 0.04),
                  child: Padding(
                    padding: padding ?? EdgeInsets.zero,
                    child: child,
                  ),
                )
              : Padding(
                  padding: padding ?? EdgeInsets.zero,
                  child: child,
                ),
        ),
      ),
    );

    return card;
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
        borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? AppTheme.radiusMedium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(children.length * 2 - 1, (index) {
            if (index.isOdd) {
              return const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16);
            }
            return children[index ~/ 2];
          }),
        ),
      ),
    );
  }
}

/// List item for TossListCard
class TossListItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppTheme.primary.withValues(alpha: 0.08),
        highlightColor: AppTheme.primary.withValues(alpha: 0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMD,
            vertical: AppTheme.spacingMD,
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: AppTheme.spacingMD),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppTheme.spacingSM),
                trailing!,
              ],
            ],
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
            child: Icon(
              icon,
              color: AppTheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
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
