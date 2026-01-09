import '../config/constants.dart';

/// Model representing WiFi configuration for QR generation
class WifiConfig {
  final String ssid;
  final String password;
  final WifiEncryptionType encryption;
  final bool isHidden;

  const WifiConfig({
    required this.ssid,
    required this.password,
    this.encryption = WifiEncryptionType.wpa,
    this.isHidden = false,
  });

  /// Generate WiFi QR code string format
  /// Format: WIFI:T:<encryption>;S:<ssid>;P:<password>;H:<hidden>;;
  String toQrString() {
    final buffer = StringBuffer('WIFI:');

    // Encryption type
    buffer.write('T:${encryption.value};');

    // SSID (escaped)
    buffer.write('S:${_escapeString(ssid)};');

    // Password (escaped) - only if not open network
    if (encryption != WifiEncryptionType.none && password.isNotEmpty) {
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
  String _escapeString(String input) {
    return input
        .replaceAll('\\', '\\\\')
        .replaceAll(';', '\\;')
        .replaceAll(',', '\\,')
        .replaceAll('"', '\\"')
        .replaceAll(':', '\\:');
  }

  WifiConfig copyWith({
    String? ssid,
    String? password,
    WifiEncryptionType? encryption,
    bool? isHidden,
  }) {
    return WifiConfig(
      ssid: ssid ?? this.ssid,
      password: password ?? this.password,
      encryption: encryption ?? this.encryption,
      isHidden: isHidden ?? this.isHidden,
    );
  }

  @override
  String toString() => 'WifiConfig(ssid: $ssid, encryption: $encryption)';
}
