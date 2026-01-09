import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../config/translations.dart';
import '../providers/locale_provider.dart';
import '../providers/poster_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/toss_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final lang = locale.locale.languageCode;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context, locale)
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 300)),
                const SizedBox(height: AppTheme.spacingXL),
                // Create card
                _buildCreateCard(context, lang)
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 400),
                    )
                    .slideY(
                      begin: 0.1,
                      end: 0,
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                    ),
                const SizedBox(height: AppTheme.spacingXL),
                // Info card
                _buildInfoCard(context, lang)
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 400),
                      duration: const Duration(milliseconds: 400),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LocaleProvider locale) {
    final themeProvider = context.watch<ThemeProvider>();

    return Row(
      children: [
        const Spacer(),
        // Locale toggle
        _buildLocaleToggle(context, locale),
        const SizedBox(width: AppTheme.spacingSM),
        // Dark mode toggle
        _buildThemeToggle(context, themeProvider),
      ],
    );
  }

  Widget _buildLocaleToggle(BuildContext context, LocaleProvider locale) {
    return GestureDetector(
      onTap: () => locale.toggleLocale(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Text(
          locale.isKorean ? '한국어' : 'EN',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, ThemeProvider themeProvider) {
    final platformBrightness = MediaQuery.of(context).platformBrightness;
    // Use actual theme brightness, not just ThemeMode setting
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => themeProvider.toggleTheme(platformBrightness),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          shape: BoxShape.circle,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Icon(
          isDark
              ? Icons.light_mode_rounded
              : Icons.dark_mode_rounded,
          color: AppTheme.textSecondary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildCreateCard(BuildContext context, String lang) {
    return TossCard(
      onTap: () => _navigateToEditor(context),
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(
              Icons.wifi_rounded,
              color: AppTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTranslations.get('create_new', lang).replaceAll('\n', ' '),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppTranslations.get('create_description', lang),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_rounded,
            color: AppTheme.primary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String lang) {
    return TossListCard(
      children: [
        _buildInfoItem(context, '1', AppTranslations.get('info1', lang)),
        _buildInfoItem(context, '2', AppTranslations.get('info2', lang)),
        _buildInfoItem(context, '3', AppTranslations.get('info3', lang)),
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMD,
        vertical: AppTheme.spacingSM + 4,
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingMD),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToEditor(BuildContext context) {
    context.read<PosterProvider>().reset();
    Navigator.pushNamed(context, AppRoutes.editor);
  }
}
