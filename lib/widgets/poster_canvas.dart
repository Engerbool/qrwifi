import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../config/translations.dart';
import '../providers/locale_provider.dart';
import '../providers/poster_provider.dart';
import 'font_picker.dart';
import 'qr_widget.dart';

/// The main poster canvas widget that renders the complete poster
/// Uses RepaintBoundary for high-resolution export
class PosterCanvas extends StatelessWidget {
  final GlobalKey posterKey;
  final bool isPreview;

  const PosterCanvas({
    super.key,
    required this.posterKey,
    this.isPreview = false,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final lang = locale.locale.languageCode;

    return Consumer<PosterProvider>(
      builder: (context, provider, child) {
        final template = provider.selectedTemplate;
        final showPassword = provider.showPasswordOnPoster;

        return RepaintBoundary(
          key: posterKey,
          child: AspectRatio(
            aspectRatio: AppConstants.posterWidth / AppConstants.posterHeight,
            child: Container(
              decoration: template.backgroundDecoration,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate responsive sizes based on available width
                  final width = constraints.maxWidth;
                  // Reduce QR size when showing password to prevent overflow
                  final qrSize = showPassword ? width * 0.48 : width * 0.55;
                  final titleSize = width * 0.07;
                  final messageSize = width * 0.04;
                  final passwordSize = width * 0.032;

                  return Padding(
                    padding: EdgeInsets.all(width * 0.06),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 1),

                        // WiFi Icon and Title
                        Icon(
                          Icons.wifi,
                          size: width * 0.10,
                          color: template.textColor,
                        ),
                        SizedBox(height: width * 0.02),
                        Text(
                          provider.posterTitle.isNotEmpty
                              ? provider.posterTitle
                              : AppTranslations.get('free_wifi', lang),
                          style: FontPicker.getStyleById(
                            provider.selectedFont,
                            fontSize: titleSize,
                            fontWeight: FontWeight.bold,
                            color: template.textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: width * 0.04),

                        // QR Code
                        QrWidget(
                          data: provider.wifiConfig.toQrString(),
                          size: qrSize,
                          backgroundColor: template.qrBackgroundColor,
                          foregroundColor: template.qrForegroundColor,
                          iconId: provider.selectedIconPath,
                          customIconData: provider.customIconData,
                        ),
                        SizedBox(height: width * 0.03),

                        // Custom Message
                        if (provider.customMessage.isNotEmpty)
                          Text(
                            // If default message, use translation; otherwise use custom text
                            provider.customMessage == AppConstants.defaultMessage
                                ? AppTranslations.get('scan_qr', lang)
                                : provider.customMessage,
                            textAlign: TextAlign.center,
                            style: FontPicker.getStyleById(
                              provider.selectedFont,
                              fontSize: messageSize,
                              fontWeight: FontWeight.w500,
                              color: template.textColor.withValues(alpha: 0.9),
                            ),
                          ),

                        // Password display (optional)
                        if (showPassword) ...[
                          SizedBox(height: width * 0.025),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'ID: ${provider.ssid}',
                                style: FontPicker.getStyleById(
                                  provider.selectedFont,
                                  fontSize: passwordSize,
                                  fontWeight: FontWeight.w500,
                                  color: template.textColor.withValues(alpha: 0.8),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: width * 0.008),
                              Text(
                                'PW: ${provider.password}',
                                style: FontPicker.getStyleById(
                                  provider.selectedFont,
                                  fontSize: passwordSize,
                                  fontWeight: FontWeight.w500,
                                  color: template.textColor.withValues(alpha: 0.8),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],

                        const Spacer(flex: 2),

                        // Signature (optional)
                        if (provider.hasSignature) ...[
                          if (provider.useSignatureImage && provider.hasSignatureImage)
                            Container(
                              constraints: BoxConstraints(
                                maxHeight: width * 0.15,
                                maxWidth: width * 0.5,
                              ),
                              child: Image.memory(
                                provider.signatureImageData!,
                                fit: BoxFit.contain,
                              ),
                            )
                          else if (provider.signatureText.isNotEmpty)
                            Text(
                              provider.signatureText,
                              style: FontPicker.getStyleById(
                                provider.selectedFont,
                                fontSize: width * 0.045,
                                fontWeight: FontWeight.w600,
                                color: template.textColor.withValues(alpha: 0.85),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          SizedBox(height: width * 0.02),
                        ],
                      ],
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
}
