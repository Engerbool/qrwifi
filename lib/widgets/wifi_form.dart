import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/translations.dart';
import '../providers/poster_provider.dart';

class WifiForm extends StatefulWidget {
  final TextEditingController ssidController;
  final TextEditingController passwordController;
  final String lang;

  const WifiForm({
    super.key,
    required this.ssidController,
    required this.passwordController,
    this.lang = 'en',
  });

  @override
  State<WifiForm> createState() => _WifiFormState();
}

class _WifiFormState extends State<WifiForm> {
  bool _obscurePassword = true;
  final FocusNode _ssidFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _ssidFocused = false;
  bool _passwordFocused = false;

  @override
  void initState() {
    super.initState();
    _ssidFocusNode.addListener(() {
      setState(() => _ssidFocused = _ssidFocusNode.hasFocus);
    });
    _passwordFocusNode.addListener(() {
      setState(() => _passwordFocused = _passwordFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _ssidFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PosterProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SSID Field
            _buildTextField(
              controller: widget.ssidController,
              focusNode: _ssidFocusNode,
              isFocused: _ssidFocused,
              label: AppTranslations.get('network_name', widget.lang),
              hint: widget.lang == 'ko'
                  ? 'WiFi 네트워크 이름 입력'
                  : 'Enter WiFi network name',
              icon: Icons.wifi_rounded,
              maxLength: 32,
              textInputAction: TextInputAction.next,
              onChanged: (value) => provider.setSsid(value),
            ),
            const SizedBox(height: AppTheme.spacingLG),

            // Password Field with tooltip
            _buildPasswordField(context, provider),
          ],
        );
      },
    );
  }

  Widget _buildPasswordField(BuildContext context, PosterProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppTranslations.get('password', widget.lang),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: _passwordFocused ? AppTheme.primary : AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Tooltip(
              message: widget.lang == 'ko'
                  ? '비밀번호가 없으면 비워두세요'
                  : 'Leave empty if no password',
              preferBelow: true,
              showDuration: const Duration(seconds: 3),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMD,
                vertical: AppTheme.spacingSM,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              textStyle: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              // 웹에서는 호버로, 모바일에서는 탭으로 툴팁 표시
              triggerMode: kIsWeb ? TooltipTriggerMode.manual : TooltipTriggerMode.tap,
              child: MouseRegion(
                cursor: SystemMouseCursors.help,
                child: Icon(
                  Icons.help_outline_rounded,
                  size: 16,
                  color: AppTheme.textTertiary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSM),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            border: Border.all(
              color: _passwordFocused ? AppTheme.primary : AppTheme.border,
              width: _passwordFocused ? 1.5 : 1,
            ),
            boxShadow: _passwordFocused
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.passwordController,
            focusNode: _passwordFocusNode,
            decoration: InputDecoration(
              hintText: widget.lang == 'ko'
                  ? 'WiFi 비밀번호 입력'
                  : 'Enter WiFi password',
              hintStyle: TextStyle(color: AppTheme.textTertiary, fontSize: 15),
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: _passwordFocused ? AppTheme.primary : AppTheme.textSecondary,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: _passwordFocused ? AppTheme.primary : AppTheme.textSecondary,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMD,
                vertical: AppTheme.spacingMD,
              ),
              counterText: '',
            ),
            maxLength: 63,
            textInputAction: TextInputAction.done,
            obscureText: _obscurePassword,
            onChanged: (value) => provider.setPassword(value),
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required String label,
    required String hint,
    required IconData icon,
    required int maxLength,
    required TextInputAction textInputAction,
    required Function(String) onChanged,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: isFocused ? AppTheme.primary : AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSM),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            border: Border.all(
              color: isFocused ? AppTheme.primary : AppTheme.border,
              width: isFocused ? 1.5 : 1,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppTheme.textTertiary, fontSize: 15),
              prefixIcon: Icon(
                icon,
                color: isFocused ? AppTheme.primary : AppTheme.textSecondary,
                size: 20,
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMD,
                vertical: AppTheme.spacingMD,
              ),
              counterText: '',
            ),
            maxLength: maxLength,
            textInputAction: textInputAction,
            obscureText: obscureText,
            onChanged: onChanged,
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 15),
          ),
        ),
      ],
    );
  }
}
