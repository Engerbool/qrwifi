import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../models/poster_element.dart';
import '../providers/poster_provider.dart';
import '../providers/locale_provider.dart';
import '../config/translations.dart';
import '../config/theme.dart';
import 'font_picker.dart';

/// Property panel for editing selected element properties
class PropertyPanel extends StatefulWidget {
  const PropertyPanel({super.key});

  @override
  State<PropertyPanel> createState() => _PropertyPanelState();
}

class _PropertyPanelState extends State<PropertyPanel> {
  final TextEditingController _xController = TextEditingController();
  final TextEditingController _yController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _fontSizeController = TextEditingController();

  final FocusNode _xFocusNode = FocusNode();
  final FocusNode _yFocusNode = FocusNode();
  final FocusNode _widthFocusNode = FocusNode();
  final FocusNode _heightFocusNode = FocusNode();
  final FocusNode _fontSizeFocusNode = FocusNode();

  String? _currentElementId;

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _fontSizeController.dispose();
    _xFocusNode.dispose();
    _yFocusNode.dispose();
    _widthFocusNode.dispose();
    _heightFocusNode.dispose();
    _fontSizeFocusNode.dispose();
    super.dispose();
  }

  void _updateControllersFromElement(PosterElement element) {
    // Always update if element changed
    if (_currentElementId != element.id) {
      _currentElementId = element.id;
      _xController.text = element.x.round().toString();
      _yController.text = element.y.round().toString();
      _widthController.text = element.width.round().toString();
      _heightController.text = element.height.round().toString();
      _fontSizeController.text = (element.fontSize ?? 24).round().toString();
    } else {
      // Update only if field is not focused (user not typing)
      if (!_xFocusNode.hasFocus) {
        _xController.text = element.x.round().toString();
      }
      if (!_yFocusNode.hasFocus) {
        _yController.text = element.y.round().toString();
      }
      if (!_widthFocusNode.hasFocus) {
        _widthController.text = element.width.round().toString();
      }
      if (!_heightFocusNode.hasFocus) {
        _heightController.text = element.height.round().toString();
      }
      if (!_fontSizeFocusNode.hasFocus) {
        _fontSizeController.text = (element.fontSize ?? 24).round().toString();
      }
    }
  }

  void _onXChanged(PosterProvider provider, String elementId) {
    final value = double.tryParse(_xController.text);
    if (value != null) {
      final clampedValue = value < 0 ? 0.0 : value;
      provider.updateElementPosition(
        elementId,
        clampedValue,
        provider.getElementById(elementId)?.y ?? 0,
      );
    }
  }

  void _onYChanged(PosterProvider provider, String elementId) {
    final value = double.tryParse(_yController.text);
    if (value != null) {
      final clampedValue = value < 0 ? 0.0 : value;
      provider.updateElementPosition(
        elementId,
        provider.getElementById(elementId)?.x ?? 0,
        clampedValue,
      );
    }
  }

  void _onWidthChanged(PosterProvider provider, String elementId) {
    final value = double.tryParse(_widthController.text);
    if (value != null) {
      provider.updateElementSize(
        elementId,
        value,
        provider.getElementById(elementId)?.height ?? 50,
      );
    }
  }

  void _onHeightChanged(PosterProvider provider, String elementId) {
    final value = double.tryParse(_heightController.text);
    if (value != null) {
      provider.updateElementSize(
        elementId,
        provider.getElementById(elementId)?.width ?? 50,
        value,
      );
    }
  }

  void _onFontSizeChanged(PosterProvider provider, String elementId) {
    final value = double.tryParse(_fontSizeController.text);
    if (value != null && value > 0) {
      provider.updateElementStyle(elementId, fontSize: value);
    }
  }

  /// Preset colors organized by hue with brightness variations
  /// Each row: light → medium → dark variants
  static const List<Color> _presetColors = [
    // Grayscale row
    Colors.white,
    Color(0xFFE5E8EB), // Light gray
    Color(0xFFB0B8C1), // Medium gray
    Color(0xFF8B95A1), // Dark gray
    Color(0xFF4E5968), // Darker gray
    Color(0xFF191F28), // Almost black
    Colors.black,

    // Red row
    Color(0xFFFFE5E7), // Light red
    Color(0xFFFFB3B8), // Light-medium red
    Color(0xFFFF6B6B), // Medium red
    Color(0xFFF04452), // Toss red
    Color(0xFFDC2626), // Dark red
    Color(0xFFB91C1C), // Darker red
    Color(0xFF7F1D1D), // Darkest red

    // Orange row
    Color(0xFFFFF3E0), // Light orange
    Color(0xFFFFCC80), // Light-medium orange
    Color(0xFFFFB74D), // Medium orange
    Color(0xFFFF9500), // Toss orange
    Color(0xFFF57C00), // Dark orange
    Color(0xFFE65100), // Darker orange
    Color(0xFFBF360C), // Darkest orange

    // Yellow row
    Color(0xFFFFFDE7), // Light yellow
    Color(0xFFFFF59D), // Light-medium yellow
    Color(0xFFFFEE58), // Medium yellow
    Color(0xFFFFB800), // Toss yellow
    Color(0xFFFFA000), // Dark yellow
    Color(0xFFFF8F00), // Darker yellow
    Color(0xFFFF6F00), // Darkest yellow

    // Green row
    Color(0xFFE8F5E9), // Light green
    Color(0xFFA5D6A7), // Light-medium green
    Color(0xFF66BB6A), // Medium green
    Color(0xFF00C471), // Toss green
    Color(0xFF388E3C), // Dark green
    Color(0xFF2E7D32), // Darker green
    Color(0xFF1B5E20), // Darkest green

    // Blue row
    Color(0xFFE3F2FD), // Light blue
    Color(0xFF90CAF9), // Light-medium blue
    Color(0xFF64B5F6), // Medium blue
    Color(0xFF3182F6), // Toss blue
    Color(0xFF1976D2), // Dark blue
    Color(0xFF1565C0), // Darker blue
    Color(0xFF0D47A1), // Darkest blue

    // Purple row
    Color(0xFFF3E5F5), // Light purple
    Color(0xFFCE93D8), // Light-medium purple
    Color(0xFFBA68C8), // Medium purple
    Color(0xFF7C3AED), // Vivid purple
    Color(0xFF7B1FA2), // Dark purple
    Color(0xFF6A1B9A), // Darker purple
    Color(0xFF4A148C), // Darkest purple

    // Pink row
    Color(0xFFFCE4EC), // Light pink
    Color(0xFFF48FB1), // Light-medium pink
    Color(0xFFEC407A), // Medium pink
    Color(0xFFE91E63), // Vivid pink
    Color(0xFFC2185B), // Dark pink
    Color(0xFFAD1457), // Darker pink
    Color(0xFF880E4F), // Darkest pink
  ];

  void _showColorPicker(
    BuildContext context,
    Color currentColor,
    ValueChanged<Color> onColorChanged,
  ) {
    final lang = context.read<LocaleProvider>().locale.languageCode;

    showDialog(
      context: context,
      builder: (dialogContext) => _ColorPickerDialog(
        currentColor: currentColor,
        presetColors: _presetColors,
        onColorChanged: onColorChanged,
        lang: lang,
      ),
    );
  }

  String _getElementTypeName(ElementType type, String lang) {
    switch (type) {
      case ElementType.qrCode:
        return AppTranslations.get('qr_code', lang);
      case ElementType.title:
        return AppTranslations.get('title', lang);
      case ElementType.message:
        return AppTranslations.get('message', lang);
      case ElementType.ssidPassword:
        return 'SSID/Password';
      case ElementType.signature:
        return AppTranslations.get('signature', lang);
      case ElementType.wifiIcon:
        return 'WiFi Icon';
    }
  }

  bool _isTextElement(ElementType type) {
    return type == ElementType.title ||
        type == ElementType.message ||
        type == ElementType.ssidPassword ||
        type == ElementType.signature;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PosterProvider, LocaleProvider>(
      builder: (context, provider, localeProvider, child) {
        final selectedElement = provider.selectedElement;
        final lang = localeProvider.locale.languageCode;

        if (selectedElement == null) {
          return const SizedBox.shrink();
        }

        _updateControllersFromElement(selectedElement);

        // Fixed height based on tallest element type (text elements with font picker)
        // This prevents canvas resize when switching between elements
        const panelHeight = 340.0;

        return Container(
          key: const Key('property-panel-content'),
          height: panelHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with element type
              _buildHeader(selectedElement, lang),
              const SizedBox(height: 10),

              // Position and Size in one row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(AppTranslations.get('position', lang)),
                        const SizedBox(height: 6),
                        _buildPositionInputs(provider, selectedElement.id),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(AppTranslations.get('size', lang)),
                        const SizedBox(height: 6),
                        _buildSizeInputs(provider, selectedElement.id),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Color section
              _buildColorSection(provider, selectedElement, lang),

              // Font section (only for text elements) or empty space
              if (_isTextElement(selectedElement.type)) ...[
                const SizedBox(height: 10),
                _buildFontSection(provider, selectedElement, lang),
              ],

              // Spacer takes remaining space for non-text elements
              const Spacer(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(PosterElement element, String lang) {
    return Row(
      children: [
        Container(
          key: const Key('property-element-type'),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getElementTypeName(element.type, lang),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Reset button
        GestureDetector(
          key: const Key('property-reset-button'),
          onTap: () {
            final provider = context.read<PosterProvider>();
            provider.resetElement(element.id);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh_rounded, size: 14, color: AppTheme.error),
                const SizedBox(width: 4),
                Text(
                  lang == 'ko' ? '초기화' : 'Reset',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.error,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: () {
            context.read<PosterProvider>().deselectElement();
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
      ),
    );
  }

  Widget _buildPositionInputs(PosterProvider provider, String elementId) {
    return Row(
      children: [
        Expanded(
          child: _buildNumberInput(
            key: const Key('property-input-x'),
            label: 'X',
            controller: _xController,
            focusNode: _xFocusNode,
            onSubmitted: (_) => _onXChanged(provider, elementId),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNumberInput(
            key: const Key('property-input-y'),
            label: 'Y',
            controller: _yController,
            focusNode: _yFocusNode,
            onSubmitted: (_) => _onYChanged(provider, elementId),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeInputs(PosterProvider provider, String elementId) {
    return Row(
      children: [
        Expanded(
          child: _buildNumberInput(
            key: const Key('property-input-width'),
            label: 'W',
            controller: _widthController,
            focusNode: _widthFocusNode,
            onSubmitted: (_) => _onWidthChanged(provider, elementId),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildNumberInput(
            key: const Key('property-input-height'),
            label: 'H',
            controller: _heightController,
            focusNode: _heightFocusNode,
            onSubmitted: (_) => _onHeightChanged(provider, elementId),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberInput({
    required Key key,
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required ValueChanged<String> onSubmitted,
  }) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          // Apply value when focus is lost
          onSubmitted(controller.text);
        }
      },
      child: TextField(
        key: key,
        controller: controller,
        focusNode: focusNode,
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))],
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }

  Widget _buildFontSizeInput(PosterProvider provider, String elementId) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) {
          _onFontSizeChanged(provider, elementId);
        }
      },
      child: TextField(
        key: const Key('property-input-fontsize'),
        controller: _fontSizeController,
        focusNode: _fontSizeFocusNode,
        keyboardType: const TextInputType.numberWithOptions(decimal: false),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixText: 'px',
          suffixStyle: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        onSubmitted: (_) => _onFontSizeChanged(provider, elementId),
      ),
    );
  }

  Widget _buildColorSection(
    PosterProvider provider,
    PosterElement element,
    String lang,
  ) {
    if (element.type == ElementType.qrCode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(AppTranslations.get('color', lang)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildColorButton(
                  key: const Key('property-color-qr-foreground'),
                  label: AppTranslations.get('qr_foreground', lang),
                  color: element.textColor ?? Colors.black,
                  onTap: () => _showColorPicker(
                    context,
                    element.textColor ?? Colors.black,
                    (color) => provider.updateElementStyle(
                      element.id,
                      textColor: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildColorButton(
                  key: const Key('property-color-qr-background'),
                  label: AppTranslations.get('qr_background', lang),
                  color: element.backgroundColor ?? Colors.white,
                  onTap: () => _showColorPicker(
                    context,
                    element.backgroundColor ?? Colors.white,
                    (color) => provider.updateElementStyle(
                      element.id,
                      backgroundColor: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else if (_isTextElement(element.type)) {
      // 2-column layout: Text Color | Font Size
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(AppTranslations.get('text_color', lang)),
                const SizedBox(height: 6),
                _buildColorButton(
                  key: const Key('property-color-text'),
                  label: AppTranslations.get('text_color', lang),
                  color: element.textColor ?? Colors.black,
                  onTap: () => _showColorPicker(
                    context,
                    element.textColor ?? Colors.black,
                    (color) =>
                        provider.updateElementStyle(element.id, textColor: color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(lang == 'ko' ? '글자 크기' : 'Font Size'),
                const SizedBox(height: 6),
                _buildFontSizeInput(provider, element.id),
              ],
            ),
          ),
        ],
      );
    } else {
      // WiFi icon
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(AppTranslations.get('color', lang)),
          const SizedBox(height: 8),
          _buildColorButton(
            key: const Key('property-color-text'),
            label: AppTranslations.get('icon_color', lang),
            color: element.textColor ?? Colors.black,
            onTap: () => _showColorPicker(
              context,
              element.textColor ?? Colors.black,
              (color) =>
                  provider.updateElementStyle(element.id, textColor: color),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildColorButton({
    required Key key,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppTheme.border),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right, size: 16, color: AppTheme.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSection(
    PosterProvider provider,
    PosterElement element,
    String lang,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(AppTranslations.get('font', lang)),
        const SizedBox(height: 8),
        Container(
          key: const Key('property-font-picker'),
          child: _ElementFontPicker(
            selectedFont: element.fontFamily ?? 'noto',
            onFontChanged: (fontId) =>
                provider.updateElementStyle(element.id, fontFamily: fontId),
          ),
        ),
      ],
    );
  }
}

/// Font picker specifically for element property panel
class _ElementFontPicker extends StatelessWidget {
  final String selectedFont;
  final ValueChanged<String> onFontChanged;

  const _ElementFontPicker({
    required this.selectedFont,
    required this.onFontChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: FontPicker.fontOptions.map((font) {
        final isSelected = selectedFont == font.id;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              key: Key('font-option-${font.id}'),
              onTap: () {
                HapticFeedback.lightImpact();
                onFontChanged(font.id);
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
                        fontSize: 16,
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
                        fontSize: 8,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
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
  }
}

/// Color picker dialog with preset colors and custom color option
class _ColorPickerDialog extends StatefulWidget {
  final Color currentColor;
  final List<Color> presetColors;
  final ValueChanged<Color> onColorChanged;
  final String lang;

  const _ColorPickerDialog({
    required this.currentColor,
    required this.presetColors,
    required this.onColorChanged,
    required this.lang,
  });

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color _selectedColor;
  bool _showCustomPicker = false;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.currentColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.lang == 'ko' ? '색상 선택' : 'Select Color'),
      content: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: _showCustomPicker ? _buildCustomPicker() : _buildPresetPicker(),
      ),
      actions: [
        if (_showCustomPicker)
          TextButton(
            onPressed: () => setState(() => _showCustomPicker = false),
            child: Text(widget.lang == 'ko' ? '프리셋' : 'Presets'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.lang == 'ko' ? '취소' : 'Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onColorChanged(_selectedColor);
            Navigator.of(context).pop();
          },
          child: Text(widget.lang == 'ko' ? '확인' : 'OK'),
        ),
      ],
    );
  }

  Widget _buildPresetPicker() {
    return SizedBox(
      width: 320,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current color preview
            _buildCurrentColorPreview(),
            const SizedBox(height: 16),

            // Preset color grid (7 columns x 8 rows)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 1,
              ),
              itemCount: widget.presetColors.length,
              itemBuilder: (context, index) {
                final color = widget.presetColors[index];
                final isSelected = _selectedColor == color;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _selectedColor = color);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : AppTheme.border,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? Center(
                            child: Icon(
                              Icons.check_rounded,
                              color: _getContrastColor(color),
                              size: 20,
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Custom color button
            GestureDetector(
              onTap: () => setState(() => _showCustomPicker = true),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.palette_outlined,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.lang == 'ko' ? '커스텀 색상' : 'Custom Color',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomPicker() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Current color preview
          _buildCurrentColorPreview(),
          const SizedBox(height: 16),

          // Full color picker
          ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) => setState(() => _selectedColor = color),
            enableAlpha: false,
            displayThumbColor: true,
            pickerAreaHeightPercent: 0.7,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentColorPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _selectedColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.border),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.lang == 'ko' ? '선택한 색상' : 'Selected Color',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '#${_colorToHex(_selectedColor)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get contrasting color (black or white) for visibility
  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Convert color to hex string (without alpha)
  String _colorToHex(Color color) {
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '$r$g$b'.toUpperCase();
  }
}
