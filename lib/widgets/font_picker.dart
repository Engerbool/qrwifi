import 'package:flutter/foundation.dart' show kIsWeb;
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
  final TextStyle Function({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  })
  getStyle;

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
                child: _FontCard(
                  font: font,
                  isSelected: isSelected,
                  onTap: () {
                    if (!kIsWeb) HapticFeedback.lightImpact();
                    provider.setFont(font.id);
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

class _FontCard extends StatefulWidget {
  final FontOption font;
  final bool isSelected;
  final VoidCallback onTap;

  const _FontCard({
    required this.font,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_FontCard> createState() => _FontCardState();
}

class _FontCardState extends State<_FontCard> {
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
          // Minimum 48dp height for accessibility
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacingSM + 4,
            horizontal: AppTheme.spacingXS,
          ),
          transform: _isHovered && !widget.isSelected
              ? (Matrix4.identity()..translate(0.0, -2.0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.primary.withValues(alpha: 0.1)
                : _isHovered
                    ? AppTheme.primary.withValues(alpha: 0.05)
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '가나',
                style: widget.font.getStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: widget.isSelected || _isHovered
                      ? AppTheme.primary
                      : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.font.name,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: widget.isSelected
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: widget.isSelected || _isHovered
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
    );
  }
}
