import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'icon_picker.dart';

/// QR code widget with center icon overlay
class QrWidget extends StatelessWidget {
  final String data;
  final double size;
  final Color backgroundColor;
  final Color foregroundColor;
  final String iconId;
  final Uint8List? customIconData;

  const QrWidget({
    super.key,
    required this.data,
    required this.size,
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black,
    this.iconId = 'wifi',
    this.customIconData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // QR Code
          QrImageView(
            data: data,
            version: QrVersions.auto,
            size: size - 32,
            backgroundColor: backgroundColor,
            eyeStyle: QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: foregroundColor,
            ),
            dataModuleStyle: QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: foregroundColor,
            ),
            errorCorrectionLevel: QrErrorCorrectLevel.H,
            gapless: true,
          ),
          // Center Icon (colors inverted for contrast) - hide if 'none' selected
          if (iconId != 'none' || customIconData != null)
            Container(
              width: size * 0.22,
              height: size * 0.22,
              decoration: BoxDecoration(
                color: foregroundColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildCenterIcon(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCenterIcon() {
    // Icon size relative to container (75% of container)
    final iconSize = size * 0.22 * 0.75;

    // Custom uploaded icon
    if (customIconData != null) {
      return Image.memory(
        customIconData!,
        fit: BoxFit.cover,
      );
    }

    // Preset icon
    final preset = IconPicker.presetIcons.firstWhere(
      (p) => p.id == iconId,
      orElse: () => IconPicker.presetIcons.first,
    );

    return Container(
      color: foregroundColor,
      child: Center(
        child: Icon(
          preset.icon,
          size: iconSize,
          color: backgroundColor,
        ),
      ),
    );
  }
}
