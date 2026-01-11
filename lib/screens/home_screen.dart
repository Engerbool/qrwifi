import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../config/translations.dart';
import '../providers/locale_provider.dart';
import '../providers/poster_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/toss_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final lang = locale.locale.languageCode;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 패딩이 필요한 섹션들
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLG),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(context, locale)
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 300)),
                    const SizedBox(height: AppTheme.spacingXL),
                    // Create card
                    _buildCreateCard(context, lang)
                        .animate()
                        .fadeIn(
                          delay: const Duration(milliseconds: 200),
                          duration: const Duration(milliseconds: 400),
                        )
                        .slideY(
                          begin: 0.1,
                          end: 0,
                          delay: const Duration(milliseconds: 200),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                        ),
                    const SizedBox(height: AppTheme.spacingXL),
                    // Info card
                    _buildInfoCard(context, lang)
                        .animate()
                        .fadeIn(
                          delay: const Duration(milliseconds: 400),
                          duration: const Duration(milliseconds: 400),
                        ),
                  ],
                ),
              ),
              // 캐릭터 섹션 - 최대 너비 제한으로 가독성 확보
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: _buildCharacterConversation(context, lang)
                      .animate()
                      .fadeIn(
                        delay: const Duration(milliseconds: 600),
                        duration: const Duration(milliseconds: 400),
                      ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingXL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LocaleProvider locale) {
    final themeProvider = context.watch<ThemeProvider>();

    return Row(
      children: [
        const Spacer(),
        // Locale toggle
        _buildLocaleToggle(context, locale),
        const SizedBox(width: AppTheme.spacingSM),
        // Dark mode toggle
        _buildThemeToggle(context, themeProvider),
        const SizedBox(width: AppTheme.spacingSM),
        // Info button
        _buildInfoButton(context, locale.locale.languageCode),
      ],
    );
  }

  Widget _buildLocaleToggle(BuildContext context, LocaleProvider locale) {
    return GestureDetector(
      onTap: () => locale.toggleLocale(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Text(
          locale.isKorean ? '한국어' : 'EN',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, ThemeProvider themeProvider) {
    final platformBrightness = MediaQuery.of(context).platformBrightness;
    // Use actual theme brightness, not just ThemeMode setting
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => themeProvider.toggleTheme(platformBrightness),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          shape: BoxShape.circle,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Icon(
          isDark
              ? Icons.light_mode_rounded
              : Icons.dark_mode_rounded,
          color: AppTheme.textSecondary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildInfoButton(BuildContext context, String lang) {
    return GestureDetector(
      onTap: () => _showInfoDialog(context, lang),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          shape: BoxShape.circle,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Icon(
          Icons.info_outline_rounded,
          color: AppTheme.textSecondary,
          size: 20,
        ),
      ),
    );
  }

  Future<void> _showInfoDialog(BuildContext context, String lang) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final isKorean = lang == 'ko';

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Icon(
                Icons.wifi_rounded,
                color: AppTheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'WiFi QR',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoRow(
              isKorean ? '버전' : 'Version',
              'v${packageInfo.version}',
            ),
            const SizedBox(height: 16),
            Text(
              isKorean
                  ? 'WiFi 정보를 QR 코드로 만들어\n쉽게 공유할 수 있는 앱입니다.'
                  : 'Create QR codes for WiFi\nand share them easily.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _launchEmail(isKorean),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: BorderSide(color: AppTheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: Icon(Icons.email_outlined, size: 18),
                label: Text(
                  isKorean ? '건의사항 보내기' : 'Send Feedback',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isKorean ? '닫기' : 'Close',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Future<void> _launchEmail(bool isKorean) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'tbd@tbd.com',
      queryParameters: {
        'subject': isKorean ? 'WiFi QR 앱 건의사항' : 'WiFi QR App Feedback',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Widget _buildCreateCard(BuildContext context, String lang) {
    return TossCard(
      onTap: () => _navigateToEditor(context),
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(
              Icons.wifi_rounded,
              color: AppTheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTranslations.get('create_new', lang).replaceAll('\n', ' '),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  AppTranslations.get('create_description', lang),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_rounded,
            color: AppTheme.primary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String lang) {
    return TossListCard(
      children: [
        _buildInfoItem(context, '1', AppTranslations.get('info1', lang)),
        _buildInfoItem(context, '2', AppTranslations.get('info2', lang)),
        _buildInfoItem(context, '3', AppTranslations.get('info3', lang)),
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMD,
        vertical: AppTheme.spacingSM + 4,
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingMD),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterConversation(BuildContext context, String lang) {
    final isKorean = lang == 'ko';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // Row가 전체 너비 사용
      children: [
        // Sad customer - left aligned
        _buildCharacterRow(
          imagePath: 'assets/images/sad_costomer_nobg.png',
          message: isKorean
              ? '복잡한 비밀번호,\n입력하기 귀찮아요.'
              : 'Complex passwords\nare annoying to type.',
          isLeft: true,
          bubbleColor: Colors.grey.shade200,
          textColor: Colors.grey.shade700,
        ),
        const SizedBox(height: AppTheme.spacingMD),
        // Master - right aligned
        _buildCharacterRow(
          imagePath: 'assets/images/master_nobg.png',
          message: isKorean
              ? '기본 카메라로\n스캔만 해주세요!'
              : 'Just scan with\nyour camera!',
          isLeft: false,
          bubbleColor: Colors.blue.shade100,
          textColor: Colors.blue.shade700,
        ),
        const SizedBox(height: AppTheme.spacingMD),
        // Happy customer - left aligned
        _buildCharacterRow(
          imagePath: 'assets/images/happy_costomer_nobg.png',
          message: isKorean ? '이 매장 편하네!' : 'This place is convenient!',
          isLeft: true,
          bubbleColor: Colors.green.shade100,
          textColor: Colors.green.shade700,
        ),
      ],
    );
  }

  Widget _buildCharacterRow({
    required String imagePath,
    required String message,
    required bool isLeft,
    required Color bubbleColor,
    required Color textColor,
  }) {
    const characterSize = 120.0;

    final bool isMaster = imagePath.contains('master');

    final characterWidget = isMaster
        ? SizedBox(
            width: characterSize,
            height: characterSize,
            child: ClipRect(
              child: Align(
                alignment: Alignment.centerRight,
                widthFactor: 0.5,
                child: Image.asset(
                  imagePath,
                  width: characterSize * 2,
                  height: characterSize,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          )
        : Image.asset(
            imagePath,
            width: characterSize,
            height: characterSize,
            fit: BoxFit.contain,
          );

    final character = characterWidget;

    final bubble = CustomPaint(
      painter: _BubblePainter(color: bubbleColor, isLeft: isLeft),
      child: Container(
        padding: EdgeInsets.only(
          left: isLeft ? 16 : 12,
          right: isLeft ? 12 : 16,
          top: 10,
          bottom: 10,
        ),
        child: Text(
          message,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor,
            height: 1.4,
          ),
        ),
      ),
    );

    if (isLeft) {
      // 왼쪽: 캐릭터가 왼쪽 끝에 붙음
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: AppTheme.spacingLG), // 카드와 같은 여백
          character,
          const SizedBox(width: 8),
          bubble,
          const Spacer(),
        ],
      );
    } else {
      // 오른쪽: 캐릭터가 오른쪽 끝에 붙음
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          bubble,
          const SizedBox(width: 8),
          character,
          const SizedBox(width: AppTheme.spacingLG), // 카드와 같은 여백
        ],
      );
    }
  }

  void _navigateToEditor(BuildContext context) {
    context.read<PosterProvider>().reset();
    Navigator.pushNamed(context, AppRoutes.editor);
  }
}

class _BubblePainter extends CustomPainter {
  final Color color;
  final bool isLeft;

  _BubblePainter({required this.color, required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final radius = 12.0;
    final tailWidth = 8.0;
    final centerY = size.height / 2;

    final path = Path();

    if (isLeft) {
      // 왼쪽 말풍선: 꼬리가 왼쪽 중앙
      path.moveTo(tailWidth + radius, 0);
      path.lineTo(size.width - radius, 0);
      path.quadraticBezierTo(size.width, 0, size.width, radius);
      path.lineTo(size.width, size.height - radius);
      path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);
      path.lineTo(tailWidth + radius, size.height);
      path.quadraticBezierTo(tailWidth, size.height, tailWidth, size.height - radius);
      path.lineTo(tailWidth, centerY + 8);
      // 꼬리 (중앙)
      path.lineTo(0, centerY);
      path.lineTo(tailWidth, centerY - 8);
      path.lineTo(tailWidth, radius);
      path.quadraticBezierTo(tailWidth, 0, tailWidth + radius, 0);
    } else {
      // 오른쪽 말풍선: 꼬리가 오른쪽 중앙
      path.moveTo(radius, 0);
      path.lineTo(size.width - tailWidth - radius, 0);
      path.quadraticBezierTo(size.width - tailWidth, 0, size.width - tailWidth, radius);
      path.lineTo(size.width - tailWidth, centerY - 8);
      // 꼬리 (중앙)
      path.lineTo(size.width, centerY);
      path.lineTo(size.width - tailWidth, centerY + 8);
      path.lineTo(size.width - tailWidth, size.height - radius);
      path.quadraticBezierTo(size.width - tailWidth, size.height, size.width - tailWidth - radius, size.height);
      path.lineTo(radius, size.height);
      path.quadraticBezierTo(0, size.height, 0, size.height - radius);
      path.lineTo(0, radius);
      path.quadraticBezierTo(0, 0, radius, 0);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
