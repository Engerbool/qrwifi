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
        final size = provider.selectedSize;

        return RepaintBoundary(
          key: posterKey,
          child: AspectRatio(
            aspectRatio: size.aspectRatio,
            child: Container(
              decoration: template.backgroundDecoration,
              child: size.type == PosterSizeType.businessCard
                  ? _buildBusinessCardLayout(context, provider, lang)
                  : _buildA4Layout(context, provider, lang),
            ),
          ),
        );
      },
    );
  }

  /// A4 vertical layout (original layout)
  Widget _buildA4Layout(
    BuildContext context,
    PosterProvider provider,
    String lang,
  ) {
    final template = provider.selectedTemplate;
    final showPassword = provider.showPasswordOnPoster;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
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
    );
  }

  /// Business card horizontal layout: LEFT (Title + Signature) | RIGHT (QR Code)
  Widget _buildBusinessCardLayout(
    BuildContext context,
    PosterProvider provider,
    String lang,
  ) {
    final template = provider.selectedTemplate;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        // Font sizes for business card
        final titleSize = height * 0.14; // Reduced from 0.18
        final signatureSize = height * 0.11;

        // QR code: 75% of height for good scannability
        final qrSize = height * 0.75;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.08,
          ),
          child: Row(
            children: [
              // LEFT SIDE: Title + Signature (40% of width)
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top group: Icon + Title
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // WiFi Icon (small)
                        Icon(
                          Icons.wifi,
                          size: height * 0.15,
                          color: template.textColor,
                        ),
                        SizedBox(height: height * 0.06),

                        // Title with FittedBox to prevent overflow
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            provider.posterTitle.isNotEmpty
                                ? provider.posterTitle
                                : AppTranslations.get('free_wifi', lang),
                            style: FontPicker.getStyleById(
                              provider.selectedFont,
                              fontSize: titleSize,
                              fontWeight: FontWeight.bold,
                              color: template.textColor,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),

                    // Signature (aligned with QR bottom)
                    if (provider.hasSignature)
                      if (provider.useSignatureImage && provider.hasSignatureImage)
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: height * 0.22,
                            maxWidth: width * 0.32,
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
                            fontSize: signatureSize,
                            fontWeight: FontWeight.w600,
                            color: template.textColor.withValues(alpha: 0.85),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        const SizedBox.shrink()
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ),

              // Spacing between sides
              SizedBox(width: width * 0.04),

              // RIGHT SIDE: QR Code (60% of width) - aligned to right
              Expanded(
                flex: 6,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: QrWidget(
                    data: provider.wifiConfig.toQrString(),
                    size: qrSize,
                    backgroundColor: template.qrBackgroundColor,
                    foregroundColor: template.qrForegroundColor,
                    iconId: provider.selectedIconPath,
                    customIconData: provider.customIconData,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
