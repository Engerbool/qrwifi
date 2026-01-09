import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/wifi_config.dart';
import '../models/poster_template.dart';
import '../config/constants.dart';

/// Provider for managing poster creation state
class PosterProvider extends ChangeNotifier {
  // WiFi Configuration
  String _ssid = '';
  String _password = '';
  WifiEncryptionType _encryption = WifiEncryptionType.wpa;
  bool _isHidden = false;
  bool _showPasswordOnPoster = false;

  // Poster Customization
  PosterTemplate _selectedTemplate = PosterTemplates.minimal;
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

  // Getters - WiFi
  String get ssid => _ssid;
  String get password => _password;
  WifiEncryptionType get encryption => _encryption;
  bool get isHidden => _isHidden;
  bool get showPasswordOnPoster => _showPasswordOnPoster;

  // Getters - Poster
  PosterTemplate get selectedTemplate => _selectedTemplate;
  String get posterTitle => _posterTitle;
  String get customMessage => _customMessage;
  String get selectedIconPath => _selectedIconPath;
  Uint8List? get customIconData => _customIconData;
  bool get hasCustomIcon => _customIconData != null;
  String get selectedFont => _selectedFont;

  // Getters - Signature
  String get signatureText => _signatureText;
  Uint8List? get signatureImageData => _signatureImageData;
  bool get useSignatureImage => _useSignatureImage;
  bool get hasSignatureImage => _signatureImageData != null;
  bool get hasSignature => _signatureText.isNotEmpty || _signatureImageData != null;

  // Getters - Export
  bool get isExporting => _isExporting;
  String? get exportError => _exportError;

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

  // Reset
  void reset() {
    _ssid = '';
    _password = '';
    _encryption = WifiEncryptionType.wpa;
    _isHidden = false;
    _showPasswordOnPoster = false;
    _selectedTemplate = PosterTemplates.minimal;
    _posterTitle = '';
    _customMessage = AppConstants.defaultMessage;
    _selectedIconPath = 'wifi';
    _customIconData = null;
    _selectedFont = 'noto';
    _isExporting = false;
    _exportError = null;
    notifyListeners();
  }
}
