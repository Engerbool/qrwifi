/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'WiFi QR Poster';
  static const String appVersion = '1.0.0';

  // Output dimensions (A4 @ 300dpi)
  static const double posterWidth = 2480;
  static const double posterHeight = 3508;
  static const double posterDpi = 300;

  // QR Code settings
  static const double qrSize = 800; // pixels in final output
  static const double qrIconSize = 200; // center icon size

  // WiFi encryption types
  static const List<String> encryptionTypes = [
    'WPA',
    'WPA2',
    'WPA3',
    'WEP',
    'nopass',
  ];

  // Default values
  static const String defaultEncryption = 'WPA';
  static const String defaultTitle = 'FREE WiFi';
  static const String defaultTitleKo = '무료 WiFi';
  static const String defaultMessage = 'Scan to connect to WiFi';
}

/// Encryption type enum for type safety
enum WifiEncryptionType {
  wpa('WPA'),
  wpa2('WPA2'),
  wpa3('WPA3'),
  wep('WEP'),
  none('nopass');

  final String value;
  const WifiEncryptionType(this.value);

  static WifiEncryptionType fromString(String value) {
    return WifiEncryptionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => WifiEncryptionType.wpa,
    );
  }
}
