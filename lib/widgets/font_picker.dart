import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/poster_provider.dart';

/// Font option for poster text
class FontOption {
  final String id;
  final String name;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) getStyle;

  const FontOption({
    required this.id,
    required this.name,
    required this.getStyle,
  });
}

class FontPicker extends StatelessWidget {
  const FontPicker({super.key});

  static final List<FontOption> fontOptions = [
    FontOption(
      id: 'noto',
      name: 'Noto Sans',
      getStyle: ({double? fontSize, FontWeight? fontWeight, Color? color}) =>
          GoogleFonts.notoSansKr(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          ),
    ),
    FontOption(
      id: 'gowun',
      name: 'Gowun Batang',
      getStyle: ({double? fontSize, FontWeight? fontWeight, Color? color}) =>
          GoogleFonts.gowunBatang(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          ),
    ),
    FontOption(
      id: 'gaegu',
      name: 'Gaegu',
      getStyle: ({double? fontSize, FontWeight? fontWeight, Color? color}) =>
          GoogleFonts.gaegu(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          ),
    ),
    FontOption(
      id: 'diphylleia',
      name: 'Diphylleia',
      getStyle: ({double? fontSize, FontWeight? fontWeight, Color? color}) =>
          GoogleFonts.diphylleia(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          ),
    ),
  ];

  static TextStyle getStyleById(
    String id, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    final font = fontOptions.firstWhere(
      (f) => f.id == id,
      orElse: () => fontOptions.first,
    );
    return font.getStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PosterProvider>(
      builder: (context, provider, child) {
        return Row(
          children: fontOptions.map((font) {
            final isSelected = provider.selectedFont == font.id;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    provider.setFont(font.id);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingSM,
                      horizontal: AppTheme.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary.withValues(alpha: 0.1)
                          : AppTheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : AppTheme.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '가나',
                          style: font.getStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          font.name,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? AppTheme.primary
                                : AppTheme.textTertiary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
