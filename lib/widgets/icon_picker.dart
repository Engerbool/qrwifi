import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/translations.dart';
import '../providers/locale_provider.dart';
import '../providers/poster_provider.dart';
import '../utils/responsive.dart';

/// Preset icons available for QR code center
class PresetIcon {
  final String id;
  final String name;
  final IconData icon;

  const PresetIcon({required this.id, required this.name, required this.icon});
}

class IconPicker extends StatelessWidget {
  const IconPicker({super.key});

  static const List<PresetIcon> presetIcons = [
    PresetIcon(id: 'none', name: '없음', icon: Icons.block_rounded),
    PresetIcon(id: 'wifi', name: 'WiFi', icon: Icons.wifi_rounded),
    PresetIcon(id: 'coffee', name: 'Coffee', icon: Icons.coffee_rounded),
    PresetIcon(
      id: 'restaurant',
      name: 'Restaurant',
      icon: Icons.restaurant_rounded,
    ),
    PresetIcon(id: 'local_bar', name: 'Bar', icon: Icons.local_bar_rounded),
    PresetIcon(id: 'store', name: 'Store', icon: Icons.storefront_rounded),
    PresetIcon(id: 'hotel', name: 'Hotel', icon: Icons.hotel_rounded),
    PresetIcon(id: 'fitness', name: 'Gym', icon: Icons.fitness_center_rounded),
    PresetIcon(id: 'spa', name: 'Spa', icon: Icons.spa_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<PosterProvider>(
      builder: (context, provider, child) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.gridCrossAxisCount(context, mobileCount: 4),
            mainAxisSpacing: AppTheme.spacingSM,
            crossAxisSpacing: AppTheme.spacingSM,
            childAspectRatio: 1,
          ),
          itemCount: presetIcons.length + 1, // +1 for upload button
          itemBuilder: (context, index) {
            if (index < presetIcons.length) {
              final preset = presetIcons[index];
              final isSelected =
                  provider.selectedIconPath == preset.id &&
                  !provider.hasCustomIcon;

              return _IconCard(
                icon: preset.icon,
                label: preset.name,
                isSelected: isSelected,
                onTap: () {
                  if (!kIsWeb) HapticFeedback.lightImpact();
                  provider.setIconPath(preset.id);
                },
              );
            } else {
              // Upload custom icon button
              return _UploadCard(
                hasCustomIcon: provider.hasCustomIcon,
                onTap: () => _pickCustomIcon(context),
                onClear: provider.hasCustomIcon
                    ? () => provider.clearCustomIcon()
                    : null,
              );
            }
          },
        );
      },
    );
  }

  Future<void> _pickCustomIcon(BuildContext context) async {
    final picker = ImagePicker();
    final locale = context.read<LocaleProvider>();
    final lang = locale.locale.languageCode;

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 200,
        maxHeight: 200,
        imageQuality: 90,
      );

      if (image != null && context.mounted) {
        final bytes = await image.readAsBytes();
        context.read<PosterProvider>().setCustomIcon(bytes);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: AppTheme.spacingSM),
                Expanded(
                  child: Text(AppTranslations.get('error_image_pick', lang)),
                ),
              ],
            ),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
          ),
        );
      }
    }
  }
}

class _IconCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _IconCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_IconCard> createState() => _IconCardState();
}

class _IconCardState extends State<_IconCard> {
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
          transform: _isHovered && !widget.isSelected
              ? (Matrix4.identity()..scale(1.05))
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
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
            boxShadow: _isHovered ? AppTheme.cardShadow : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.icon,
                  size: widget.isSelected || _isHovered ? 28 : 24,
                  color: widget.isSelected || _isHovered
                      ? AppTheme.primary
                      : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: widget.isSelected || _isHovered
                      ? AppTheme.primary
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadCard extends StatefulWidget {
  final bool hasCustomIcon;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _UploadCard({
    required this.hasCustomIcon,
    required this.onTap,
    this.onClear,
  });

  @override
  State<_UploadCard> createState() => _UploadCardState();
}

class _UploadCardState extends State<_UploadCard> {
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
          transform: _isHovered && !widget.hasCustomIcon
              ? (Matrix4.identity()..scale(1.05))
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.hasCustomIcon
                ? AppTheme.success.withValues(alpha: 0.1)
                : _isHovered
                    ? AppTheme.primary.withValues(alpha: 0.05)
                    : AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: widget.hasCustomIcon
                  ? AppTheme.success
                  : _isHovered
                      ? AppTheme.primary.withValues(alpha: 0.5)
                      : AppTheme.border,
              width: widget.hasCustomIcon ? 2 : 1,
            ),
            boxShadow: _isHovered ? AppTheme.cardShadow : null,
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.hasCustomIcon
                          ? Icons.check_circle_rounded
                          : Icons.add_photo_alternate_rounded,
                      size: widget.hasCustomIcon || _isHovered ? 28 : 24,
                      color: widget.hasCustomIcon
                          ? AppTheme.success
                          : _isHovered
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.hasCustomIcon ? 'Custom' : 'Upload',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: widget.hasCustomIcon
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: widget.hasCustomIcon
                            ? AppTheme.success
                            : _isHovered
                                ? AppTheme.primary
                                : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.hasCustomIcon && widget.onClear != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: widget.onClear,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppTheme.error,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
