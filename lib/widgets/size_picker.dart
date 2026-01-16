import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../config/theme.dart';
import '../providers/locale_provider.dart';
import '../providers/poster_provider.dart';

class SizePicker extends StatelessWidget {
  const SizePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final isKorean = context.watch<LocaleProvider>().isKorean;

    return Consumer<PosterProvider>(
      builder: (context, provider, child) {
        return Row(
          children: PosterSizes.all.map((size) {
            final isSelected = provider.selectedSize.id == size.id;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: size == PosterSizes.all.first ? 0 : 6,
                  right: size == PosterSizes.all.last ? 0 : 6,
                ),
                child: _SizeCard(
                  size: size,
                  isSelected: isSelected,
                  isKorean: isKorean,
                  onTap: () {
                    if (!kIsWeb) HapticFeedback.lightImpact();
                    provider.setSize(size);
                  },
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _SizeCard extends StatefulWidget {
  final PosterSize size;
  final bool isSelected;
  final bool isKorean;
  final VoidCallback onTap;

  const _SizeCard({
    required this.size,
    required this.isSelected,
    required this.isKorean,
    required this.onTap,
  });

  @override
  State<_SizeCard> createState() => _SizeCardState();
}

class _SizeCardState extends State<_SizeCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppTheme.spacingMD),
          transform: _isHovered && !widget.isSelected
              ? (Matrix4.identity()..translate(0.0, -2.0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.primary.withValues(alpha: 0.08)
                : _isHovered
                    ? AppTheme.primary.withValues(alpha: 0.04)
                    : AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: widget.isSelected
                  ? AppTheme.primary
                  : _isHovered
                      ? AppTheme.primary.withValues(alpha: 0.5)
                      : AppTheme.border,
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: widget.isSelected || _isHovered
                ? AppTheme.cardShadow
                : null,
          ),
          child: Column(
            children: [
              // Size preview icon (fixed height container for alignment)
              SizedBox(
                height: 44,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: widget.size.isLandscape ? 48 : 32,
                    height: widget.size.isLandscape ? 28 : 44,
                    decoration: BoxDecoration(
                      color: widget.isSelected || _isHovered
                          ? AppTheme.primary.withValues(alpha: 0.15)
                          : AppTheme.border.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: widget.isSelected || _isHovered
                            ? AppTheme.primary
                            : AppTheme.textTertiary,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.qr_code_2_rounded,
                      size: widget.size.isLandscape ? 16 : 20,
                      color: widget.isSelected || _isHovered
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingSM),

              // Size name
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isSelected)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: AppTheme.primary,
                      ),
                    ),
                  Flexible(
                    child: Text(
                      widget.isKorean ? widget.size.nameKo : widget.size.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: widget.isSelected || _isHovered
                            ? AppTheme.primary
                            : AppTheme.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),

              // Dimensions
              Text(
                '${widget.size.widthMm.toInt()}x${widget.size.heightMm.toInt()}mm',
                style: TextStyle(fontSize: 11, color: AppTheme.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
