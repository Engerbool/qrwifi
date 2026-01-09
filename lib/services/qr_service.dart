import '../models/wifi_config.dart';

/// Service for generating WiFi QR code data
class QrService {
  QrService._();

  /// Generate WiFi QR string from config
  /// Format: WIFI:T:<encryption>;S:<ssid>;P:<password>;H:<hidden>;;
  static String generateWifiQrData(WifiConfig config) {
    return config.toQrString();
  }

  /// Generate WiFi QR string from individual parameters
  static String generateWifiQrDataFromParams({
    required String ssid,
    required String password,
    String encryption = 'WPA',
    bool isHidden = false,
  }) {
    final buffer = StringBuffer('WIFI:');

    // Encryption type
    buffer.write('T:$encryption;');

    // SSID (escaped)
    buffer.write('S:${_escapeString(ssid)};');

    // Password (escaped) - only if not open network
    if (encryption != 'nopass' && password.isNotEmpty) {
      buffer.write('P:${_escapeString(password)};');
    }

    // Hidden network flag
    if (isHidden) {
      buffer.write('H:true;');
    }

    buffer.write(';');
    return buffer.toString();
  }

  /// Escape special characters for WiFi QR format
  static String _escapeString(String input) {
    return input
        .replaceAll('\\', '\\\\')
        .replaceAll(';', '\\;')
        .replaceAll(',', '\\,')
        .replaceAll('"', '\\"')
        .replaceAll(':', '\\:');
  }

  /// Validate WiFi configuration
  static ValidationResult validateConfig({
    required String ssid,
    required String password,
    required String encryption,
  }) {
    if (ssid.isEmpty) {
      return ValidationResult(
        isValid: false,
        error: 'SSID cannot be empty',
      );
    }

    if (ssid.length > 32) {
      return ValidationResult(
        isValid: false,
        error: 'SSID cannot exceed 32 characters',
      );
    }

    if (encryption != 'nopass' && password.isEmpty) {
      return ValidationResult(
        isValid: false,
        error: 'Password is required for secured networks',
      );
    }

    if (password.length > 63) {
      return ValidationResult(
        isValid: false,
        error: 'Password cannot exceed 63 characters',
      );
    }

    return ValidationResult(isValid: true);
  }
}

/// Result of validation
class ValidationResult {
  final bool isValid;
  final String? error;

  ValidationResult({
    required this.isValid,
    this.error,
  });
}
