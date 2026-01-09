import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/translations.dart';
import '../providers/locale_provider.dart';
import '../providers/poster_provider.dart';
import '../widgets/poster_canvas.dart';
import '../widgets/toss_button.dart';
import '../services/export_service.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final GlobalKey _posterKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleProvider>().locale.languageCode;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, lang),
            // Poster Preview
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLG,
                ),
                child: _buildPosterPreview(context),
              ),
            ),
            // Action Buttons
            _buildActionButtons(context, lang),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String lang) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMD,
        vertical: AppTheme.spacingSM,
      ),
      child: Row(
        children: [
          TossIconButton(
            icon: Icons.arrow_back_ios_rounded,
            onPressed: () => Navigator.pop(context),
            size: 40,
          ),
          const SizedBox(width: AppTheme.spacingSM),
          Expanded(
            child: Text(
              AppTranslations.get('preview', lang),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Consumer<PosterProvider>(
            builder: (context, provider, child) {
              return TossIconButton(
                icon: provider.isExporting
                    ? Icons.hourglass_top_rounded
                    : Icons.download_rounded,
                onPressed: provider.isExporting ? null : _handleExport,
                color: AppTheme.primary,
                size: 40,
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 300));
  }

  Widget _buildPosterPreview(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: PosterCanvas(
          posterKey: _posterKey,
          isPreview: true,
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 500),
        )
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildActionButtons(BuildContext context, String lang) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLG),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success indicator
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMD,
              vertical: AppTheme.spacingSM,
            ),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: AppTheme.success,
                ),
                const SizedBox(width: AppTheme.spacingSM),
                Text(
                  AppTranslations.get('poster_ready', lang),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTheme.success,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingMD),
          // Download Button
          Consumer<PosterProvider>(
            builder: (context, provider, child) {
              return TossPrimaryButton(
                text: provider.isExporting
                    ? AppTranslations.get('saving', lang)
                    : AppTranslations.get('download_poster', lang),
                icon: provider.isExporting
                    ? Icons.hourglass_top_rounded
                    : Icons.download_rounded,
                isLoading: provider.isExporting,
                onPressed: provider.isExporting ? null : _handleExport,
              );
            },
          ),
          const SizedBox(height: AppTheme.spacingSM),
          // Edit Button
          TossSecondaryButton(
            text: AppTranslations.get('edit_poster', lang),
            icon: Icons.edit_rounded,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          delay: const Duration(milliseconds: 400),
          duration: const Duration(milliseconds: 400),
        );
  }

  Future<void> _handleExport() async {
    final provider = context.read<PosterProvider>();
    provider.setExporting(true);
    provider.setExportError(null);

    try {
      final result = await ExportService.exportPoster(_posterKey);

      if (!mounted) return;

      if (result.success) {
        _showSuccess(result.message);
      } else {
        _showError(result.message);
        provider.setExportError(result.message);
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to export poster: $e');
        provider.setExportError(e.toString());
      }
    } finally {
      if (mounted) {
        provider.setExporting(false);
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSM),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        margin: const EdgeInsets.all(AppTheme.spacingMD),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSM),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        margin: const EdgeInsets.all(AppTheme.spacingMD),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
