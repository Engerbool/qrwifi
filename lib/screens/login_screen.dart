import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../config/translations.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final lang = locale.locale.languageCode;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Main content - scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingLG),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Toggle buttons row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildLocaleToggle(context, locale),
                        const SizedBox(width: AppTheme.spacingSM),
                        _buildThemeToggle(context),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingLG),
                    // Logo
                    _buildLogo()
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 400))
                        .scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1, 1),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                        ),
                    const SizedBox(height: AppTheme.spacingXL),
                    // Title
                    Text(
                      AppTranslations.get('app_title', lang),
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(fontWeight: FontWeight.w800, height: 1.1),
                    ).animate().fadeIn(
                      delay: const Duration(milliseconds: 150),
                      duration: const Duration(milliseconds: 400),
                    ),
                    const SizedBox(height: AppTheme.spacingMD),
                    // Subtitle
                    Text(
                      AppTranslations.get('app_subtitle', lang),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ).animate().fadeIn(
                      delay: const Duration(milliseconds: 250),
                      duration: const Duration(milliseconds: 400),
                    ),
                    const SizedBox(height: AppTheme.spacingXXL),
                    // Features
                    ..._buildFeatures(context, lang),
                  ],
                ),
              ),
            ),
            // Bottom section - fixed
            _buildBottomSection(context, lang),
          ],
        ),
      ),
    );
  }

  Widget _buildLocaleToggle(BuildContext context, LocaleProvider locale) {
    return GestureDetector(
      onTap: () => locale.toggleLocale(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.background,
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

  Widget _buildThemeToggle(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final platformBrightness = MediaQuery.of(context).platformBrightness;
    // Use actual theme brightness, not just ThemeMode setting
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => themeProvider.toggleTheme(platformBrightness),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.background,
          shape: BoxShape.circle,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: AppTheme.textSecondary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: const Icon(Icons.qr_code_2_rounded, size: 36, color: Colors.white),
    );
  }

  List<Widget> _buildFeatures(BuildContext context, String lang) {
    final features = [
      (AppTranslations.get('feature_wifi', lang), Icons.wifi_rounded),
      (AppTranslations.get('feature_template', lang), Icons.palette_outlined),
      (AppTranslations.get('feature_download', lang), Icons.download_rounded),
    ];

    return features.asMap().entries.map((entry) {
      final index = entry.key;
      final feature = entry.value;

      return Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.spacingMD),
        child:
            Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusSmall,
                        ),
                      ),
                      child: Icon(
                        feature.$2,
                        size: 18,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMD),
                    Text(
                      feature.$1,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                )
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: 350 + (index * 80)),
                  duration: const Duration(milliseconds: 400),
                )
                .slideX(
                  begin: -0.1,
                  end: 0,
                  delay: Duration(milliseconds: 350 + (index * 80)),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                ),
      );
    }).toList();
  }

  Widget _buildBottomSection(BuildContext context, String lang) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLG),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error message
              if (auth.error != null)
                Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
                      padding: const EdgeInsets.all(AppTheme.spacingMD),
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusSmall,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: AppTheme.error,
                            size: 18,
                          ),
                          const SizedBox(width: AppTheme.spacingSM),
                          Expanded(
                            child: Text(
                              auth.error!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.error),
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: const Duration(milliseconds: 200))
                    .shakeX(hz: 3, amount: 3),
              // Google Sign In Button
              _GoogleSignInButton(
                isLoading: auth.isLoading,
                onPressed: () => _handleGoogleSignIn(context),
                label: AppTranslations.get('continue_google', lang),
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 600),
                duration: const Duration(milliseconds: 400),
              ),
              const SizedBox(height: AppTheme.spacingMD),
              // Terms
              Text(
                AppTranslations.get('terms_notice', lang),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall,
              ).animate().fadeIn(
                delay: const Duration(milliseconds: 700),
                duration: const Duration(milliseconds: 400),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();

    if (success && context.mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }
}

/// Google Sign In Button - Toss style
class _GoogleSignInButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String label;

  const _GoogleSignInButton({
    required this.isLoading,
    required this.onPressed,
    required this.label,
  });

  @override
  State<_GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<_GoogleSignInButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLoading
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: widget.isLoading
          ? null
          : (_) => setState(() => _isPressed = false),
      onTapCancel: widget.isLoading
          ? null
          : () => setState(() => _isPressed = false),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(_isPressed ? 0.98 : 1.0),
        transformAlignment: Alignment.center,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: _isPressed ? 0.7 : 1.0,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMD),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLoading) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ] else ...[
                  // Google "G" icon
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        'G',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4285F4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSM),
                  Text(
                    widget.label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
