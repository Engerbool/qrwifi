import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/translations.dart';
import '../providers/locale_provider.dart';
import '../providers/poster_provider.dart';
import '../widgets/editable_element.dart';
import '../widgets/property_panel.dart';
import '../widgets/toss_button.dart';

/// Screen for editing poster element positions and styles
class CanvasEditorScreen extends StatefulWidget {
  const CanvasEditorScreen({super.key});

  @override
  State<CanvasEditorScreen> createState() => _CanvasEditorScreenState();
}

class _CanvasEditorScreenState extends State<CanvasEditorScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure elements are initialized when entering editor
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PosterProvider>();
      if (provider.elements.isEmpty) {
        provider.initializeElements();
      }
      provider.setEditorMode(true);
      // Auto-select QR code element
      provider.selectElement('qr-code');
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final lang = locale.locale.languageCode;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, lang),
            Expanded(child: _buildCanvasArea(context)),
            _buildBottomBar(context, lang),
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
            onPressed: () => _handleBack(context),
            size: 40,
          ),
          const SizedBox(width: AppTheme.spacingSM),
          Expanded(
            child: Text(
              AppTranslations.get('edit_layout', lang),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          TossIconButton(
            icon: Icons.check_rounded,
            onPressed: () => _handleDone(context),
            color: AppTheme.primary,
            size: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasArea(BuildContext context) {
    return Consumer<PosterProvider>(
      builder: (context, provider, child) {
        final size = provider.selectedSize;
        final template = provider.selectedTemplate;
        final elements = provider.sortedElements;

        return GestureDetector(
          onTap: () {
            // Deselect when tapping outside elements
            provider.deselectElement();
          },
          child: Container(
            margin: const EdgeInsets.all(AppTheme.spacingMD),
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate scale to fit canvas in available space
                  final availableWidth = constraints.maxWidth;
                  final availableHeight = constraints.maxHeight;

                  final canvasAspectRatio = size.aspectRatio;
                  final availableAspectRatio = availableWidth / availableHeight;

                  double canvasWidth, canvasHeight, scale;

                  if (canvasAspectRatio > availableAspectRatio) {
                    // Canvas is wider - fit to width
                    canvasWidth = availableWidth;
                    canvasHeight = availableWidth / canvasAspectRatio;
                    scale = canvasWidth / size.widthPx;
                  } else {
                    // Canvas is taller - fit to height
                    canvasHeight = availableHeight;
                    canvasWidth = availableHeight * canvasAspectRatio;
                    scale = canvasHeight / size.heightPx;
                  }

                  return Container(
                    width: canvasWidth,
                    height: canvasHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                      boxShadow: AppTheme.elevatedShadow,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                      child: Container(
                        decoration: template.backgroundDecoration,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: elements.map((element) {
                            final isSelected =
                                provider.selectedElement?.id == element.id;
                            return EditableElement(
                              key: ValueKey(element.id),
                              element: element,
                              canvasScale: scale,
                              isSelected: isSelected,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, String lang) {
    return Consumer<PosterProvider>(
      builder: (context, provider, child) {
        final selectedElement = provider.selectedElement;

        // Show PropertyPanel when element is selected
        if (selectedElement != null) {
          return const PropertyPanel();
        }

        // Show hint when no element selected (same height as PropertyPanel)
        return Container(
          height: 340.0,
          padding: const EdgeInsets.all(AppTheme.spacingMD),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: 48,
                  color: AppTheme.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  lang == 'ko' ? '요소를 탭하여 선택하세요' : 'Tap an element to select',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleBack(BuildContext context) {
    final provider = context.read<PosterProvider>();
    provider.setEditorMode(false);
    Navigator.pop(context);
  }

  void _handleDone(BuildContext context) {
    final provider = context.read<PosterProvider>();
    provider.setEditorMode(false);
    provider.deselectElement();
    Navigator.pop(context);
  }
}
