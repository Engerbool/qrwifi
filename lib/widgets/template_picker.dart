import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/poster_template.dart';
import '../providers/locale_provider.dart';
import '../providers/poster_provider.dart';

class TemplatePicker extends StatefulWidget {
  const TemplatePicker({super.key});

  @override
  State<TemplatePicker> createState() => _TemplatePickerState();
}

class _TemplatePickerState extends State<TemplatePicker> {
  TemplateCategory _selectedCategory = TemplateCategory.basic;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final isKorean = locale.isKorean;

    return Consumer<PosterProvider>(
      builder: (context, provider, child) {
        final templates = PosterTemplates.getByCategory(_selectedCategory);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category tabs (48dp minimum for accessibility)
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: PosterTemplates.categories.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: AppTheme.spacingSM),
                itemBuilder: (context, index) {
                  final category = PosterTemplates.categories[index];
                  final isSelected = _selectedCategory == category.category;

                  return _CategoryChip(
                    category: category,
                    isSelected: isSelected,
                    isKorean: isKorean,
                    onTap: () {
                      if (!kIsWeb) HapticFeedback.lightImpact();
                      setState(() {
                        _selectedCategory = category.category;
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppTheme.spacingMD),

            // Templates in selected category
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: templates.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: AppTheme.spacingSM),
                itemBuilder: (context, index) {
                  final template = templates[index];
                  final isSelected =
                      provider.selectedTemplate.id == template.id;

                  return _TemplateCard(
                    template: template,
                    isSelected: isSelected,
                    isKorean: isKorean,
                    onTap: () {
                      if (!kIsWeb) HapticFeedback.lightImpact();
                      provider.setTemplate(template);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CategoryChip extends StatefulWidget {
  final CategoryInfo category;
  final bool isSelected;
  final bool isKorean;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.isKorean,
    required this.onTap,
  });

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip> {
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
            horizontal: AppTheme.spacingMD,
            vertical: AppTheme.spacingSM + 4,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.primary
                : _isHovered
                    ? AppTheme.primary.withValues(alpha: 0.1)
                    : AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            border: Border.all(
              color: widget.isSelected
                  ? AppTheme.primary
                  : _isHovered
                      ? AppTheme.primary.withValues(alpha: 0.5)
                      : AppTheme.border,
              width: 1,
            ),
            boxShadow: widget.isSelected ? AppTheme.cardShadow : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.category.icon,
                size: 16,
                color: widget.isSelected
                    ? Colors.white
                    : _isHovered
                        ? AppTheme.primary
                        : AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                widget.isKorean ? widget.category.nameKo : widget.category.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: widget.isSelected
                      ? Colors.white
                      : _isHovered
                          ? AppTheme.primary
                          : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateCard extends StatefulWidget {
  final PosterTemplate template;
  final bool isSelected;
  final bool isKorean;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.isSelected,
    required this.isKorean,
    required this.onTap,
  });

  @override
  State<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<_TemplateCard> {
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
          width: 95,
          transform: _isHovered && !widget.isSelected
              ? (Matrix4.identity()..scale(1.03))
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium - 1),
            child: Column(
              children: [
                // Template preview
                Expanded(
                  child: Container(
                    decoration: widget.template.backgroundDecoration,
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: widget.isSelected || _isHovered ? 44 : 40,
                        height: widget.isSelected || _isHovered ? 44 : 40,
                        decoration: BoxDecoration(
                          color: widget.template.qrBackgroundColor,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.qr_code_2_rounded,
                          size: widget.isSelected || _isHovered ? 30 : 26,
                          color: widget.template.qrForegroundColor,
                        ),
                      ),
                    ),
                  ),
                ),
                // Template name
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? AppTheme.primary
                        : _isHovered
                            ? AppTheme.primary.withValues(alpha: 0.1)
                            : AppTheme.surface,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isSelected)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.check_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      Flexible(
                        child: Text(
                          widget.isKorean ? widget.template.nameKo : widget.template.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: widget.isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: widget.isSelected
                                ? Colors.white
                                : _isHovered
                                    ? AppTheme.primary
                                    : AppTheme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
