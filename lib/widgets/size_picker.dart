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
                    HapticFeedback.lightImpact();
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

class _SizeCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.08)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppTheme.cardShadow : null,
        ),
        child: Column(
          children: [
            // Size preview icon (fixed height container for alignment)
            SizedBox(
              height: 44,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: size.isLandscape ? 48 : 32,
                  height: size.isLandscape ? 28 : 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary.withValues(alpha: 0.15)
                        : AppTheme.border.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : AppTheme.textTertiary,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.qr_code_2_rounded,
                    size: size.isLandscape ? 16 : 20,
                    color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingSM),

            // Size name
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected)
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
                    isKorean ? size.nameKo : size.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? AppTheme.primary : AppTheme.textPrimary,
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
              '${size.widthMm.toInt()}x${size.heightMm.toInt()}mm',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
