import 'package:flutter/material.dart';

/// Template category for grouping
enum TemplateCategory {
  basic,      // 기본
  warm,       // 따뜻한 색
  cool,       // 차가운 색
  nature,     // 자연
  creative,   // 크리에이티브
}

/// Model representing a poster template design
class PosterTemplate {
  final String id;
  final String name;
  final String nameKo;
  final TemplateCategory category;
  final Color backgroundColor;
  final Color? gradientEndColor;
  final Color textColor;
  final Color qrBackgroundColor;
  final Color qrForegroundColor;
  final bool hasGradient;
  final Alignment gradientBegin;
  final Alignment gradientEnd;

  const PosterTemplate({
    required this.id,
    required this.name,
    required this.nameKo,
    required this.category,
    required this.backgroundColor,
    this.gradientEndColor,
    required this.textColor,
    this.qrBackgroundColor = Colors.white,
    this.qrForegroundColor = Colors.black,
    this.hasGradient = false,
    this.gradientBegin = Alignment.topCenter,
    this.gradientEnd = Alignment.bottomCenter,
  });

  /// Get background decoration for the template
  BoxDecoration get backgroundDecoration {
    if (hasGradient && gradientEndColor != null) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: gradientBegin,
          end: gradientEnd,
          colors: [backgroundColor, gradientEndColor!],
        ),
      );
    }
    return BoxDecoration(color: backgroundColor);
  }
}

/// Category info for display
class CategoryInfo {
  final TemplateCategory category;
  final String name;
  final String nameKo;
  final IconData icon;

  const CategoryInfo({
    required this.category,
    required this.name,
    required this.nameKo,
    required this.icon,
  });
}

/// Predefined poster templates
class PosterTemplates {
  PosterTemplates._();

  // Category definitions
  static const List<CategoryInfo> categories = [
    CategoryInfo(category: TemplateCategory.basic, name: 'Basic', nameKo: '기본', icon: Icons.square_rounded),
    CategoryInfo(category: TemplateCategory.warm, name: 'Warm', nameKo: '따뜻한', icon: Icons.wb_sunny_rounded),
    CategoryInfo(category: TemplateCategory.cool, name: 'Cool', nameKo: '차가운', icon: Icons.ac_unit_rounded),
    CategoryInfo(category: TemplateCategory.nature, name: 'Nature', nameKo: '자연', icon: Icons.eco_rounded),
    CategoryInfo(category: TemplateCategory.creative, name: 'Creative', nameKo: '크리에이티브', icon: Icons.auto_awesome_rounded),
  ];

  // ============ BASIC ============
  static const minimal = PosterTemplate(
    id: 'minimal',
    name: 'Minimal',
    nameKo: '미니멀',
    category: TemplateCategory.basic,
    backgroundColor: Colors.white,
    textColor: Color(0xFF1E293B),
    qrBackgroundColor: Colors.white,
    qrForegroundColor: Color(0xFF1E293B),
  );

  static const modernGray = PosterTemplate(
    id: 'modern_gray',
    name: 'Modern',
    nameKo: '모던',
    category: TemplateCategory.basic,
    backgroundColor: Color(0xFFF8FAFC),
    gradientEndColor: Color(0xFFE2E8F0),
    textColor: Color(0xFF1E293B),
    hasGradient: true,
    qrBackgroundColor: Colors.white,
    qrForegroundColor: Color(0xFF1E293B),
  );

  static const midnightBlack = PosterTemplate(
    id: 'midnight_black',
    name: 'Midnight',
    nameKo: '미드나잇',
    category: TemplateCategory.basic,
    backgroundColor: Color(0xFF121212),
    textColor: Colors.white,
    qrBackgroundColor: Colors.white,
    qrForegroundColor: Color(0xFF121212),
  );

  // ============ WARM ============
  static const sunsetOrange = PosterTemplate(
    id: 'sunset_orange',
    name: 'Sunset',
    nameKo: '선셋',
    category: TemplateCategory.warm,
    backgroundColor: Color(0xFFFF6B35),
    gradientEndColor: Color(0xFFFF8E53),
    textColor: Colors.white,
    hasGradient: true,
    qrBackgroundColor: Colors.white,
    qrForegroundColor: Color(0xFFCC4A1D),
  );

  static const cafeWarm = PosterTemplate(
    id: 'cafe_warm',
    name: 'Cafe',
    nameKo: '카페',
    category: TemplateCategory.warm,
    backgroundColor: Color(0xFFFEF3C7),
    gradientEndColor: Color(0xFFFDE68A),
    textColor: Color(0xFF78350F),
    hasGradient: true,
    qrBackgroundColor: Colors.white,
    qrForegroundColor: Color(0xFF78350F),
  );

  static const coralRed = PosterTemplate(
    id: 'coral_red',
    name: 'Coral',
    nameKo: '코랄',
    category: TemplateCategory.warm,
    backgroundColor: Color(0xFFE63946),
    textColor: Colors.white,
    qrBackgroundColor: Colors.white,
    qrForegroundColor: Color(0xFFA4161A),
  );

  static const rosePink = PosterTemplate(
    id: 'rose_pink',
    name: 'Rose',
    nameKo: '로즈',
    category: TemplateCategory.warm,
    backgroundColor: Color(0xFFFFC2D1),
    gradientEndColor: Color(0xFFFFB3C6),
    textColor: Color(0xFF590D22),
    hasGradient: true,
    qrBackgroundColor: Colors.white,
    qrForegroundColor: Color(0xFF800F2F),
  );

  // ============ COOL ============
  static const boldBlue = PosterTemplate(
    id: 'bold_blue',
    name: 'Bold Blue',
    nameKo: '볼드 블루',
    category: TemplateCategory.cool,
    backgroundColor: Color(0xFF2563EB),
    textColor: Colors.white,
    qrBackgroundColor: Colors.white,
    qrForegroundColor: Color(0xFF1E3A5F),
  );

  static const oceanBlue = PosterTemplate(
    id: 'ocean_blue',
    name: 'Ocean',
    nameKo: '오션',
    category: TemplateCategory.cool,
    backgroundColor: Color(0xFF0077B6),
    gradientEndColor: Color(0xFF00B4D8),
    textColor: Colors.white,
    hasGradient: true,
    qrBackgroundColor: Colors.white,
    qrForegroundColor: Color(0xFF005F8A),
  );

  static const elegantPurple = PosterTemplate(
    id: 'elegant_purple',
    name: 'Elegant',
    nameKo: '엘레강트',
    category: TemplateCategory.cool,
    backgroundColor: Color(0xFF7B2CBF),
    gradientEndColor: Color(0xFF9D4EDD),
    textColor: Colors.white,
    hasGradient: true,
    qrBackgroundColor: Colors.white,
    qrForegroundColor: Color(0xFF5A189A),
  );

  static const lavenderDream = PosterTemplate(
    id: 'lavender_dream',
    name: 'Lavender',
    nameKo: '라벤더',
    category: TemplateCategory.cool,
    backgroundColor: Color(0xFFE6E6FA),
    gradientEndColor: Color(0xFFD8BFD8),
    textColor: Color(0xFF4A0E4E),
    hasGradient: true,
    qrBackgroundColor: Colors.white,
    qrForegroundColor: Color(0xFF4A0E4E),
  );

  static const techDark = PosterTemplate(
    id: 'tech_dark',
    name: 'Tech',
    nameKo: '테크',
    category: TemplateCategory.cool,
    backgroundColor: Color(0xFF0F172A),
    gradientEndColor: Color(0xFF1E293B),
    textColor: Colors.white,
    hasGradient: true,
    qrBackgroundColor: Colors.white,
    qrForegroundColor: Color(0xFF0F172A),
  );

  // ============ NATURE ============
  static const forestGreen = PosterTemplate(
    id: 'forest_green',
    name: 'Forest',
    nameKo: '포레스트',
    category: TemplateCategory.nature,
    backgroundColor: Color(0xFF2D6A4F),
    gradientEndColor: Color(0xFF40916C),
    textColor: Colors.white,
    hasGradient: true,
    qrBackgroundColor: Colors.white,
    qrForegroundColor: Color(0xFF1B4332),
  );

  static const freshMint = PosterTemplate(
    id: 'fresh_mint',
    name: 'Mint',
    nameKo: '민트',
    category: TemplateCategory.nature,
    backgroundColor: Color(0xFFB8F2E6),
    gradientEndColor: Color(0xFF89E0CF),
    textColor: Color(0xFF014034),
    hasGradient: true,
    qrBackgroundColor: Colors.white,
    qrForegroundColor: Color(0xFF014034),
  );

  static const skyBlue = PosterTemplate(
    id: 'sky_blue',
    name: 'Sky',
    nameKo: '스카이',
    category: TemplateCategory.nature,
    backgroundColor: Color(0xFF87CEEB),
    gradientEndColor: Color(0xFFB0E0E6),
    textColor: Color(0xFF1E3A5F),
    hasGradient: true,
    qrBackgroundColor: Colors.white,
    qrForegroundColor: Color(0xFF1E3A5F),
  );

  static const earthBrown = PosterTemplate(
    id: 'earth_brown',
    name: 'Earth',
    nameKo: '어스',
    category: TemplateCategory.nature,
    backgroundColor: Color(0xFF8B7355),
    gradientEndColor: Color(0xFFA08060),
    textColor: Colors.white,
    hasGradient: true,
    qrBackgroundColor: Color(0xFFFFF8DC),
    qrForegroundColor: Color(0xFF5D4E37),
  );

  // ============ CREATIVE ============
  static const goldenLuxury = PosterTemplate(
    id: 'golden_luxury',
    name: 'Golden',
    nameKo: '골든',
    category: TemplateCategory.creative,
    backgroundColor: Color(0xFF1A1A2E),
    gradientEndColor: Color(0xFF16213E),
    textColor: Color(0xFFFFD700),
    hasGradient: true,
    qrBackgroundColor: Color(0xFFFFFBE6),
    qrForegroundColor: Color(0xFF1A1A2E),
  );

  static const neonGlow = PosterTemplate(
    id: 'neon_glow',
    name: 'Neon',
    nameKo: '네온',
    category: TemplateCategory.creative,
    backgroundColor: Color(0xFF0D0D0D),
    gradientEndColor: Color(0xFF1A1A2E),
    textColor: Color(0xFF00FF88),
    hasGradient: true,
    qrBackgroundColor: Color(0xFF0D0D0D),
    qrForegroundColor: Color(0xFF00FF88),
  );

  static const retroWave = PosterTemplate(
    id: 'retro_wave',
    name: 'Retro',
    nameKo: '레트로',
    category: TemplateCategory.creative,
    backgroundColor: Color(0xFF2E1065),
    gradientEndColor: Color(0xFFFF006E),
    textColor: Color(0xFFFFE66D),
    hasGradient: true,
    gradientBegin: Alignment.topLeft,
    gradientEnd: Alignment.bottomRight,
    qrBackgroundColor: Color(0xFFFFE66D),
    qrForegroundColor: Color(0xFF2E1065),
  );

  static const holographic = PosterTemplate(
    id: 'holographic',
    name: 'Holo',
    nameKo: '홀로',
    category: TemplateCategory.creative,
    backgroundColor: Color(0xFFE0C3FC),
    gradientEndColor: Color(0xFF8EC5FC),
    textColor: Color(0xFF2D1B69),
    hasGradient: true,
    gradientBegin: Alignment.topLeft,
    gradientEnd: Alignment.bottomRight,
    qrBackgroundColor: Colors.white,
    qrForegroundColor: Color(0xFF2D1B69),
  );

  static const aurora = PosterTemplate(
    id: 'aurora',
    name: 'Aurora',
    nameKo: '오로라',
    category: TemplateCategory.creative,
    backgroundColor: Color(0xFF667EEA),
    gradientEndColor: Color(0xFF64FFDA),
    textColor: Colors.white,
    hasGradient: true,
    gradientBegin: Alignment.topLeft,
    gradientEnd: Alignment.bottomRight,
    qrBackgroundColor: Colors.white,
    qrForegroundColor: Color(0xFF2D3A8C),
  );

  static const cyberpunk = PosterTemplate(
    id: 'cyberpunk',
    name: 'Cyber',
    nameKo: '사이버',
    category: TemplateCategory.creative,
    backgroundColor: Color(0xFF0A0A0A),
    gradientEndColor: Color(0xFF1A0A2E),
    textColor: Color(0xFFFF00FF),
    hasGradient: true,
    qrBackgroundColor: Color(0xFF0A0A0A),
    qrForegroundColor: Color(0xFF00FFFF),
  );

  static List<PosterTemplate> get all => [
    // Basic
    minimal, modernGray, midnightBlack,
    // Warm
    sunsetOrange, cafeWarm, coralRed, rosePink,
    // Cool
    boldBlue, oceanBlue, elegantPurple, lavenderDream, techDark,
    // Nature
    forestGreen, freshMint, skyBlue, earthBrown,
    // Creative
    goldenLuxury, neonGlow, retroWave, holographic, aurora, cyberpunk,
  ];

  static List<PosterTemplate> getByCategory(TemplateCategory category) {
    return all.where((t) => t.category == category).toList();
  }

  static PosterTemplate getById(String id) {
    return all.firstWhere(
      (t) => t.id == id,
      orElse: () => minimal,
    );
  }
}
