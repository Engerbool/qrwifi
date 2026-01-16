/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = '우리가게 와이파이';
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

/// Poster size type enum
enum PosterSizeType { a4, businessCard }

/// Poster size configuration
class PosterSize {
  final PosterSizeType type;
  final String id;
  final String name;
  final String nameKo;
  final double widthPx;
  final double heightPx;
  final double widthMm;
  final double heightMm;
  final bool isLandscape;
  final bool supportsMessage;
  final bool supportsPasswordDisplay;

  const PosterSize({
    required this.type,
    required this.id,
    required this.name,
    required this.nameKo,
    required this.widthPx,
    required this.heightPx,
    required this.widthMm,
    required this.heightMm,
    required this.isLandscape,
    this.supportsMessage = true,
    this.supportsPasswordDisplay = true,
  });

  double get aspectRatio => widthPx / heightPx;
}

/// Predefined poster sizes
class PosterSizes {
  PosterSizes._();

  static const a4 = PosterSize(
    type: PosterSizeType.a4,
    id: 'a4',
    name: 'A4 Poster',
    nameKo: 'A4 포스터',
    widthPx: 2480,
    heightPx: 3508,
    widthMm: 210,
    heightMm: 297,
    isLandscape: false,
    supportsMessage: true,
    supportsPasswordDisplay: true,
  );

  static const businessCard = PosterSize(
    type: PosterSizeType.businessCard,
    id: 'business_card',
    name: 'Business Card',
    nameKo: '명함',
    widthPx: 1063,
    heightPx: 591,
    widthMm: 90,
    heightMm: 50,
    isLandscape: true,
    supportsMessage: false,
    supportsPasswordDisplay: false,
  );

  static List<PosterSize> get all => [a4, businessCard];

  static PosterSize getById(String id) {
    return all.firstWhere((s) => s.id == id, orElse: () => a4);
  }
}
