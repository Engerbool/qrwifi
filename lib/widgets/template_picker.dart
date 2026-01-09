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
            // Category tabs
            SizedBox(
              height: 40,
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
                      HapticFeedback.lightImpact();
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
                  final isSelected = provider.selectedTemplate.id == template.id;

                  return _TemplateCard(
                    template: template,
                    isSelected: isSelected,
                    isKorean: isKorean,
                    onTap: () {
                      HapticFeedback.lightImpact();
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

class _CategoryChip extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMD,
          vertical: AppTheme.spacingSM,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: 1,
          ),
          boxShadow: isSelected ? AppTheme.cardShadow : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 16,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              isKorean ? category.nameKo : category.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 95,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppTheme.cardShadow : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium - 1),
          child: Column(
            children: [
              // Template preview
              Expanded(
                child: Container(
                  decoration: template.backgroundDecoration,
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isSelected ? 44 : 40,
                      height: isSelected ? 44 : 40,
                      decoration: BoxDecoration(
                        color: template.qrBackgroundColor,
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
                        size: isSelected ? 30 : 26,
                        color: template.qrForegroundColor,
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
                  color: isSelected ? AppTheme.primary : AppTheme.surface,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSelected)
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
                        isKorean ? template.nameKo : template.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppTheme.textPrimary,
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
    );
  }
}
