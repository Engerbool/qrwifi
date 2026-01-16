import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/wifi_config.dart';
import '../models/poster_template.dart';
import '../models/poster_element.dart';
import '../config/constants.dart';

/// Provider for managing poster creation state
class PosterProvider extends ChangeNotifier {
  /// Minimum size for any element (in canvas pixels)
  static const double minElementSize = 50.0;

  /// Counter for generating z-index
  int _maxZIndex = 0;
  // WiFi Configuration
  String _ssid = '';
  String _password = '';
  WifiEncryptionType _encryption = WifiEncryptionType.wpa;
  bool _isHidden = false;
  bool _showPasswordOnPoster = false;

  // Poster Customization
  PosterTemplate _selectedTemplate = PosterTemplates.minimal;
  PosterSize _selectedSize = PosterSizes.a4;
  String _posterTitle = ''; // Empty means use default (FREE WiFi / 무료 WiFi)
  String _customMessage = AppConstants.defaultMessage;
  String _selectedIconPath = 'wifi'; // Built-in icon identifier
  Uint8List? _customIconData; // For user-uploaded icons
  String _selectedFont = 'noto'; // Font family identifier

  // Signature
  String _signatureText = '';
  Uint8List? _signatureImageData;
  bool _useSignatureImage = false;

  // Export state
  bool _isExporting = false;
  String? _exportError;

  // Editor state
  List<PosterElement> _elements = [];
  String? _selectedElementId;
  bool _isEditorMode = false;

  // Getters - WiFi
  String get ssid => _ssid;
  String get password => _password;
  WifiEncryptionType get encryption => _encryption;
  bool get isHidden => _isHidden;
  bool get showPasswordOnPoster => _showPasswordOnPoster;

  // Getters - Poster
  PosterTemplate get selectedTemplate => _selectedTemplate;
  PosterSize get selectedSize => _selectedSize;
  String get posterTitle => _posterTitle;
  String get customMessage => _customMessage;
  String get selectedIconPath => _selectedIconPath;
  Uint8List? get customIconData => _customIconData;
  bool get hasCustomIcon => _customIconData != null;
  String get selectedFont => _selectedFont;

  // Computed - Size-dependent feature availability
  bool get canShowMessage => _selectedSize.supportsMessage;
  bool get canShowPassword => _selectedSize.supportsPasswordDisplay;

  // Getters - Signature
  String get signatureText => _signatureText;
  Uint8List? get signatureImageData => _signatureImageData;
  bool get useSignatureImage => _useSignatureImage;
  bool get hasSignatureImage => _signatureImageData != null;
  bool get hasSignature =>
      _signatureText.isNotEmpty || _signatureImageData != null;

  // Getters - Export
  bool get isExporting => _isExporting;
  String? get exportError => _exportError;

  // Getters - Editor
  List<PosterElement> get elements => List.unmodifiable(_elements);
  bool get isEditorMode => _isEditorMode;
  bool get hasSelectedElement => _selectedElementId != null;
  PosterElement? get selectedElement {
    if (_selectedElementId == null) return null;
    try {
      return _elements.firstWhere((e) => e.id == _selectedElementId);
    } catch (_) {
      return null;
    }
  }

  /// Returns elements sorted by z-index (for rendering order)
  List<PosterElement> get sortedElements {
    final sorted = List<PosterElement>.from(_elements);
    sorted.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    return sorted;
  }

  // Computed
  bool get isValid => _ssid.isNotEmpty && _password.isNotEmpty;

  WifiConfig get wifiConfig => WifiConfig(
    ssid: _ssid,
    password: _password,
    encryption: _encryption,
    isHidden: _isHidden,
  );

  // Setters - WiFi
  void setSsid(String value) {
    _ssid = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void setEncryption(WifiEncryptionType value) {
    _encryption = value;
    // Clear password when no security selected
    if (value == WifiEncryptionType.none) {
      _password = '';
    }
    notifyListeners();
  }

  void setIsHidden(bool value) {
    _isHidden = value;
    notifyListeners();
  }

  void setShowPasswordOnPoster(bool value) {
    _showPasswordOnPoster = value;
    notifyListeners();
  }

  // Setters - Poster
  void setTemplate(PosterTemplate template) {
    _selectedTemplate = template;
    notifyListeners();
  }

  void setSize(PosterSize size) {
    _selectedSize = size;
    // Clear irrelevant settings when switching to size that doesn't support them
    if (!size.supportsMessage) {
      _customMessage = '';
    }
    if (!size.supportsPasswordDisplay) {
      _showPasswordOnPoster = false;
    }
    notifyListeners();
  }

  void setPosterTitle(String title) {
    _posterTitle = title;
    notifyListeners();
  }

  void setCustomMessage(String message) {
    _customMessage = message;
    notifyListeners();
  }

  void setIconPath(String path) {
    _selectedIconPath = path;
    _customIconData = null; // Clear custom icon when selecting preset
    notifyListeners();
  }

  void setCustomIcon(Uint8List data) {
    _customIconData = data;
    _selectedIconPath = 'custom';
    notifyListeners();
  }

  void clearCustomIcon() {
    _customIconData = null;
    _selectedIconPath = 'wifi';
    notifyListeners();
  }

  void setFont(String fontId) {
    _selectedFont = fontId;
    notifyListeners();
  }

  // Setters - Signature
  void setSignatureText(String text) {
    _signatureText = text;
    notifyListeners();
  }

  void setSignatureImage(Uint8List data) {
    _signatureImageData = data;
    _useSignatureImage = true;
    notifyListeners();
  }

  void clearSignatureImage() {
    _signatureImageData = null;
    _useSignatureImage = false;
    notifyListeners();
  }

  void setUseSignatureImage(bool value) {
    _useSignatureImage = value;
    notifyListeners();
  }

  // Export
  void setExporting(bool value) {
    _isExporting = value;
    notifyListeners();
  }

  void setExportError(String? error) {
    _exportError = error;
    notifyListeners();
  }

  // ========== Editor Methods ==========

  /// Set editor mode
  void setEditorMode(bool value) {
    _isEditorMode = value;
    notifyListeners();
  }

  /// Initialize elements from current poster configuration
  void initializeElements() {
    _elements = [];
    _maxZIndex = 0;
    _selectedElementId = null;

    final canvasWidth = _selectedSize.widthPx;
    final canvasHeight = _selectedSize.heightPx;
    final isLandscape = _selectedSize.isLandscape;

    if (isLandscape) {
      _initializeBusinessCardElements(canvasWidth, canvasHeight);
    } else {
      _initializeA4Elements(canvasWidth, canvasHeight);
    }

    notifyListeners();
  }

  /// Initialize elements for A4 layout
  void _initializeA4Elements(double width, double height) {
    final padding = width * 0.06;
    final qrSize = _showPasswordOnPoster ? width * 0.48 : width * 0.55;
    final titleSize = width * 0.07;
    final messageSize = width * 0.04;
    final iconSize = width * 0.10;

    // WiFi Icon (top)
    _elements.add(
      PosterElement(
        id: 'wifi-icon',
        type: ElementType.wifiIcon,
        x: (width - iconSize) / 2,
        y: height * 0.15,
        width: iconSize,
        height: iconSize,
        zIndex: _maxZIndex++,
        textColor: _selectedTemplate.textColor,
      ),
    );

    // Title
    final titleWidth = width * 0.8;
    final titleHeight = titleSize * 1.5;
    _elements.add(
      PosterElement(
        id: 'title',
        type: ElementType.title,
        x: (width - titleWidth) / 2,
        y: height * 0.22,
        width: titleWidth,
        height: titleHeight,
        zIndex: _maxZIndex++,
        textColor: _selectedTemplate.textColor,
        fontFamily: _selectedFont,
        fontSize: titleSize,
        content: _posterTitle.isNotEmpty ? _posterTitle : null,
      ),
    );

    // QR Code (center)
    _elements.add(
      PosterElement(
        id: 'qr-code',
        type: ElementType.qrCode,
        x: (width - qrSize) / 2,
        y: height * 0.32,
        width: qrSize,
        height: qrSize,
        zIndex: _maxZIndex++,
        textColor: _selectedTemplate.qrForegroundColor,
        backgroundColor: _selectedTemplate.qrBackgroundColor,
      ),
    );

    // Message (below QR)
    if (_customMessage.isNotEmpty && _selectedSize.supportsMessage) {
      final messageWidth = width * 0.8;
      final messageHeight = messageSize * 2;
      _elements.add(
        PosterElement(
          id: 'message',
          type: ElementType.message,
          x: (width - messageWidth) / 2,
          y: height * 0.32 + qrSize + padding,
          width: messageWidth,
          height: messageHeight,
          zIndex: _maxZIndex++,
          textColor: _selectedTemplate.textColor.withValues(alpha: 0.9),
          fontFamily: _selectedFont,
          fontSize: messageSize,
          content: _customMessage,
        ),
      );
    }

    // SSID/Password (optional)
    if (_showPasswordOnPoster && _selectedSize.supportsPasswordDisplay) {
      final ssidPwWidth = width * 0.6;
      final ssidPwHeight = width * 0.08;
      _elements.add(
        PosterElement(
          id: 'ssid-password',
          type: ElementType.ssidPassword,
          x: (width - ssidPwWidth) / 2,
          y: height * 0.65,
          width: ssidPwWidth,
          height: ssidPwHeight,
          zIndex: _maxZIndex++,
          textColor: _selectedTemplate.textColor.withValues(alpha: 0.8),
          fontFamily: _selectedFont,
          fontSize: width * 0.032,
          content: _password.isNotEmpty ? 'ID: $_ssid\nPW: $_password' : 'ID: $_ssid',
        ),
      );
    }

    // Signature (bottom)
    if (hasSignature && _signatureText.isNotEmpty) {
      final sigWidth = width * 0.5;
      final sigHeight = width * 0.08;
      _elements.add(
        PosterElement(
          id: 'signature',
          type: ElementType.signature,
          x: (width - sigWidth) / 2,
          y: height * 0.85,
          width: sigWidth,
          height: sigHeight,
          zIndex: _maxZIndex++,
          textColor: _selectedTemplate.textColor.withValues(alpha: 0.85),
          fontFamily: _selectedFont,
          fontSize: width * 0.045,
          content: _signatureText,
        ),
      );
    }
  }

  /// Initialize elements for business card layout
  void _initializeBusinessCardElements(double width, double height) {
    final qrSize = height * 0.75;
    final titleSize = height * 0.14;
    final iconSize = height * 0.15;

    // WiFi Icon (left top)
    _elements.add(
      PosterElement(
        id: 'wifi-icon',
        type: ElementType.wifiIcon,
        x: width * 0.05,
        y: height * 0.08,
        width: iconSize,
        height: iconSize,
        zIndex: _maxZIndex++,
        textColor: _selectedTemplate.textColor,
      ),
    );

    // Title (left side)
    final titleWidth = width * 0.35;
    final titleHeight = titleSize * 1.5;
    _elements.add(
      PosterElement(
        id: 'title',
        type: ElementType.title,
        x: width * 0.05,
        y: height * 0.35,
        width: titleWidth,
        height: titleHeight,
        zIndex: _maxZIndex++,
        textColor: _selectedTemplate.textColor,
        fontFamily: _selectedFont,
        fontSize: titleSize,
        content: _posterTitle.isNotEmpty ? _posterTitle : null,
      ),
    );

    // QR Code (right side)
    _elements.add(
      PosterElement(
        id: 'qr-code',
        type: ElementType.qrCode,
        x: width - qrSize - width * 0.05,
        y: (height - qrSize) / 2,
        width: qrSize,
        height: qrSize,
        zIndex: _maxZIndex++,
        textColor: _selectedTemplate.qrForegroundColor,
        backgroundColor: _selectedTemplate.qrBackgroundColor,
      ),
    );

    // Signature (left bottom)
    if (hasSignature && _signatureText.isNotEmpty) {
      final sigWidth = width * 0.32;
      final sigHeight = height * 0.15;
      _elements.add(
        PosterElement(
          id: 'signature',
          type: ElementType.signature,
          x: width * 0.05,
          y: height * 0.75,
          width: sigWidth,
          height: sigHeight,
          zIndex: _maxZIndex++,
          textColor: _selectedTemplate.textColor.withValues(alpha: 0.85),
          fontFamily: _selectedFont,
          fontSize: height * 0.11,
          content: _signatureText,
        ),
      );
    }
  }

  /// Select an element by ID
  void selectElement(String id) {
    final exists = _elements.any((e) => e.id == id);
    _selectedElementId = exists ? id : null;
    notifyListeners();
  }

  /// Deselect current element
  void deselectElement() {
    _selectedElementId = null;
    notifyListeners();
  }

  /// Get element by ID
  PosterElement? getElementById(String id) {
    try {
      return _elements.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Update element position with boundary clamping
  void updateElementPosition(String id, double x, double y) {
    final index = _elements.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final element = _elements[index];
    final canvasWidth = _selectedSize.widthPx;
    final canvasHeight = _selectedSize.heightPx;

    // Clamp position to canvas bounds
    final clampedX = x.clamp(0.0, canvasWidth - element.width);
    final clampedY = y.clamp(0.0, canvasHeight - element.height);

    _elements[index] = element.copyWith(x: clampedX, y: clampedY);
    notifyListeners();
  }

  /// Update element size with minimum size constraint
  void updateElementSize(String id, double width, double height) {
    final index = _elements.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final element = _elements[index];

    // Apply minimum size constraint
    var newWidth = width.clamp(minElementSize, _selectedSize.widthPx);
    var newHeight = height.clamp(minElementSize, _selectedSize.heightPx);

    // Maintain aspect ratio for QR code (use larger dimension)
    if (element.maintainAspectRatio) {
      final maxDim = newWidth > newHeight ? newWidth : newHeight;
      newWidth = maxDim;
      newHeight = maxDim;
    }

    // Ensure element stays within canvas
    final canvasWidth = _selectedSize.widthPx;
    final canvasHeight = _selectedSize.heightPx;

    if (element.x + newWidth > canvasWidth) {
      newWidth = canvasWidth - element.x;
      if (element.maintainAspectRatio) newHeight = newWidth;
    }
    if (element.y + newHeight > canvasHeight) {
      newHeight = canvasHeight - element.y;
      if (element.maintainAspectRatio) newWidth = newHeight;
    }

    _elements[index] = element.copyWith(width: newWidth, height: newHeight);
    notifyListeners();
  }

  /// Bring element to front (highest z-index)
  void bringToFront(String id) {
    final index = _elements.indexWhere((e) => e.id == id);
    if (index == -1) return;

    _maxZIndex++;
    _elements[index] = _elements[index].copyWith(zIndex: _maxZIndex);
    notifyListeners();
  }

  /// Update element style (color, font, etc.)
  void updateElementStyle(
    String id, {
    Color? textColor,
    Color? backgroundColor,
    String? fontFamily,
    double? fontSize,
  }) {
    final index = _elements.indexWhere((e) => e.id == id);
    if (index == -1) return;

    _elements[index] = _elements[index].copyWith(
      textColor: textColor,
      backgroundColor: backgroundColor,
      fontFamily: fontFamily,
      fontSize: fontSize,
    );
    notifyListeners();
  }

  /// Reset a specific element to its initial state
  void resetElement(String id) {
    final index = _elements.indexWhere((e) => e.id == id);
    if (index == -1) return;

    final element = _elements[index];
    final width = _selectedSize.widthPx;
    final height = _selectedSize.heightPx;
    final isLandscape = _selectedSize.isLandscape;

    PosterElement? newElement;

    if (isLandscape) {
      newElement = _getInitialBusinessCardElement(id, element.zIndex, width, height);
    } else {
      newElement = _getInitialA4Element(id, element.zIndex, width, height);
    }

    if (newElement != null) {
      _elements[index] = newElement;
      notifyListeners();
    }
  }

  /// Get initial A4 element by ID
  PosterElement? _getInitialA4Element(String id, int zIndex, double width, double height) {
    final qrSize = _showPasswordOnPoster ? width * 0.48 : width * 0.55;
    final titleSize = width * 0.07;
    final messageSize = width * 0.04;
    final iconSize = width * 0.10;
    final passwordSize = width * 0.032;

    switch (id) {
      case 'wifi-icon':
        return PosterElement(
          id: 'wifi-icon',
          type: ElementType.wifiIcon,
          x: (width - iconSize) / 2,
          y: height * 0.15,
          width: iconSize,
          height: iconSize,
          zIndex: zIndex,
          textColor: _selectedTemplate.textColor,
        );
      case 'title':
        final titleWidth = width * 0.8;
        final titleHeight = titleSize * 1.5;
        return PosterElement(
          id: 'title',
          type: ElementType.title,
          x: (width - titleWidth) / 2,
          y: height * 0.22,
          width: titleWidth,
          height: titleHeight,
          zIndex: zIndex,
          textColor: _selectedTemplate.textColor,
          fontFamily: _selectedFont,
          fontSize: titleSize,
          content: _posterTitle.isNotEmpty ? _posterTitle : null,
        );
      case 'qr-code':
        return PosterElement(
          id: 'qr-code',
          type: ElementType.qrCode,
          x: (width - qrSize) / 2,
          y: height * 0.32,
          width: qrSize,
          height: qrSize,
          zIndex: zIndex,
          textColor: _selectedTemplate.qrForegroundColor,
          backgroundColor: _selectedTemplate.qrBackgroundColor,
        );
      case 'message':
        final messageWidth = width * 0.8;
        final messageHeight = messageSize * 2;
        return PosterElement(
          id: 'message',
          type: ElementType.message,
          x: (width - messageWidth) / 2,
          y: height * 0.62,
          width: messageWidth,
          height: messageHeight,
          zIndex: zIndex,
          textColor: _selectedTemplate.textColor,
          fontFamily: _selectedFont,
          fontSize: messageSize,
          content: _customMessage,
        );
      case 'ssid-password':
        final pwWidth = width * 0.6;
        final pwHeight = passwordSize * 3;
        return PosterElement(
          id: 'ssid-password',
          type: ElementType.ssidPassword,
          x: (width - pwWidth) / 2,
          y: height * 0.68,
          width: pwWidth,
          height: pwHeight,
          zIndex: zIndex,
          textColor: _selectedTemplate.textColor,
          fontFamily: _selectedFont,
          fontSize: passwordSize,
          content: _password.isNotEmpty ? 'ID: $_ssid\nPW: $_password' : 'ID: $_ssid',
        );
      case 'signature':
        final sigWidth = width * 0.4;
        final sigHeight = width * 0.06;
        return PosterElement(
          id: 'signature',
          type: ElementType.signature,
          x: (width - sigWidth) / 2,
          y: height * 0.85,
          width: sigWidth,
          height: sigHeight,
          zIndex: zIndex,
          textColor: _selectedTemplate.textColor,
          fontFamily: _selectedFont,
          fontSize: width * 0.045,
          content: _signatureText,
        );
      default:
        return null;
    }
  }

  /// Get initial business card element by ID
  PosterElement? _getInitialBusinessCardElement(String id, int zIndex, double width, double height) {
    final qrSize = height * 0.75;
    final titleSize = height * 0.14;
    final iconSize = height * 0.15;

    switch (id) {
      case 'wifi-icon':
        return PosterElement(
          id: 'wifi-icon',
          type: ElementType.wifiIcon,
          x: width * 0.05,
          y: height * 0.08,
          width: iconSize,
          height: iconSize,
          zIndex: zIndex,
          textColor: _selectedTemplate.textColor,
        );
      case 'title':
        final titleWidth = width * 0.35;
        final titleHeight = titleSize * 1.5;
        return PosterElement(
          id: 'title',
          type: ElementType.title,
          x: width * 0.05,
          y: height * 0.35,
          width: titleWidth,
          height: titleHeight,
          zIndex: zIndex,
          textColor: _selectedTemplate.textColor,
          fontFamily: _selectedFont,
          fontSize: titleSize,
          content: _posterTitle.isNotEmpty ? _posterTitle : null,
        );
      case 'qr-code':
        return PosterElement(
          id: 'qr-code',
          type: ElementType.qrCode,
          x: width - qrSize - width * 0.05,
          y: (height - qrSize) / 2,
          width: qrSize,
          height: qrSize,
          zIndex: zIndex,
          textColor: _selectedTemplate.qrForegroundColor,
          backgroundColor: _selectedTemplate.qrBackgroundColor,
        );
      case 'signature':
        final sigWidth = width * 0.32;
        final sigHeight = height * 0.15;
        return PosterElement(
          id: 'signature',
          type: ElementType.signature,
          x: width * 0.05,
          y: height * 0.7,
          width: sigWidth,
          height: sigHeight,
          zIndex: zIndex,
          textColor: _selectedTemplate.textColor,
          fontFamily: _selectedFont,
          fontSize: height * 0.11,
          content: _signatureText,
        );
      default:
        return null;
    }
  }

  /// Clear all elements
  void clearElements() {
    _elements = [];
    _selectedElementId = null;
    _maxZIndex = 0;
    notifyListeners();
  }

  /// Add an element to the canvas (for testing/advanced use)
  void addElement(PosterElement element) {
    _elements.add(element);
    if (element.zIndex > _maxZIndex) {
      _maxZIndex = element.zIndex;
    }
    notifyListeners();
  }

  // Reset
  void reset() {
    _ssid = '';
    _password = '';
    _encryption = WifiEncryptionType.wpa;
    _isHidden = false;
    _showPasswordOnPoster = false;
    _selectedTemplate = PosterTemplates.minimal;
    _selectedSize = PosterSizes.a4;
    _posterTitle = '';
    _customMessage = AppConstants.defaultMessage;
    _selectedIconPath = 'wifi';
    _customIconData = null;
    _selectedFont = 'noto';
    _signatureText = '';
    _signatureImageData = null;
    _useSignatureImage = false;
    _isExporting = false;
    _exportError = null;
    // Editor state
    _elements = [];
    _selectedElementId = null;
    _isEditorMode = false;
    _maxZIndex = 0;
    notifyListeners();
  }
}
