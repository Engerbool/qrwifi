import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../config/translations.dart';
import '../providers/locale_provider.dart';
import '../providers/poster_provider.dart';
import '../utils/responsive.dart';
import '../widgets/wifi_form.dart';
import '../widgets/template_picker.dart';
import '../widgets/size_picker.dart';
import '../widgets/icon_picker.dart';
import '../widgets/font_picker.dart';
import '../widgets/toss_card.dart';
import '../widgets/toss_button.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _ssidController;
  late TextEditingController _passwordController;
  late TextEditingController _titleController;
  late TextEditingController _messageController;
  late TextEditingController _signatureController;
  bool _initialized = false;
  bool _isMessageDefault = true;
  String _defaultMessage = '';
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final provider = context.read<PosterProvider>();
    _ssidController = TextEditingController(text: provider.ssid);
    _passwordController = TextEditingController(text: provider.password);
    _titleController = TextEditingController(text: provider.posterTitle);
    _messageController = TextEditingController();
    _signatureController = TextEditingController(text: provider.signatureText);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final provider = context.read<PosterProvider>();
      final lang = context.read<LocaleProvider>().locale.languageCode;
      _defaultMessage = AppTranslations.get('scan_qr', lang);

      // 커스텀 메시지가 비어있거나 영어 기본값이면 번역된 기본값 사용
      if (provider.customMessage.isEmpty ||
          provider.customMessage == AppConstants.defaultMessage ||
          provider.customMessage == _defaultMessage) {
        _messageController.text = _defaultMessage;
        _isMessageDefault = true;
        // 빌드 후에 provider 업데이트
        WidgetsBinding.instance.addPostFrameCallback((_) {
          provider.setCustomMessage(_defaultMessage);
        });
      } else {
        _messageController.text = provider.customMessage;
        _isMessageDefault = false;
      }
    }
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    _titleController.dispose();
    _messageController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop(String lang) async {
    final provider = context.read<PosterProvider>();
    // Check if user has entered any data
    final hasData = _ssidController.text.isNotEmpty ||
        _passwordController.text.isNotEmpty ||
        _titleController.text.isNotEmpty ||
        provider.signatureText.isNotEmpty;

    if (!hasData) {
      return true; // Allow back without confirmation
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTranslations.get('discard_changes', lang)),
        content: Text(AppTranslations.get('discard_changes_message', lang)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              AppTranslations.get('stay', lang),
              style: TextStyle(color: AppTheme.primary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppTranslations.get('discard', lang),
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final lang = locale.locale.languageCode;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop(lang);
        if (shouldPop && mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context, lang),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: Responsive.contentMaxWidth(context),
                      ),
                      child: Padding(
                        padding: Responsive.screenPadding(context),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section 1: WiFi Details
                              _buildSectionTitle(
                                context,
                                AppTranslations.get('wifi_network', lang),
                                0,
                              ),
                              const SizedBox(height: AppTheme.spacingMD),
                              TossCard(
                                padding: const EdgeInsets.all(AppTheme.spacingLG),
                                child: WifiForm(
                                  ssidController: _ssidController,
                                  passwordController: _passwordController,
                                  lang: lang,
                                ),
                              ).animate().fadeIn(
                                delay: const Duration(milliseconds: 100),
                                duration: const Duration(milliseconds: 400),
                              ),
                              const SizedBox(height: AppTheme.spacingXL),

                              // Section 2: Template Selection
                              _buildSectionTitle(
                                context,
                                AppTranslations.get('template', lang),
                                1,
                              ),
                              const SizedBox(height: AppTheme.spacingMD),
                              const TemplatePicker().animate().fadeIn(
                                delay: const Duration(milliseconds: 200),
                                duration: const Duration(milliseconds: 400),
                              ),
                              const SizedBox(height: AppTheme.spacingXL),

                              // Section 2.5: Poster Size
                              _buildSectionTitle(
                                context,
                                AppTranslations.get('poster_size', lang),
                                2,
                              ),
                              const SizedBox(height: AppTheme.spacingMD),
                              const SizePicker().animate().fadeIn(
                                delay: const Duration(milliseconds: 250),
                                duration: const Duration(milliseconds: 400),
                              ),
                              const SizedBox(height: AppTheme.spacingXL),

                              // Section 3: QR Icon
                              _buildSectionTitle(
                                context,
                                AppTranslations.get('center_icon', lang),
                                2,
                              ),
                              const SizedBox(height: AppTheme.spacingXS),
                              Text(
                                lang == 'ko'
                                    ? 'QR 코드 중앙에 표시할 아이콘을 선택하세요'
                                    : 'Choose an icon to display in the center of the QR code',
                                style: Theme.of(context).textTheme.bodySmall,
                              ).animate().fadeIn(
                                delay: const Duration(milliseconds: 250),
                                duration: const Duration(milliseconds: 400),
                              ),
                              const SizedBox(height: AppTheme.spacingMD),
                              const IconPicker().animate().fadeIn(
                                delay: const Duration(milliseconds: 300),
                                duration: const Duration(milliseconds: 400),
                              ),
                              const SizedBox(height: AppTheme.spacingXL),

                              // Section 4: Font Selection
                              _buildSectionTitle(
                                context,
                                lang == 'ko' ? '글씨체' : 'Font',
                                3,
                              ),
                              const SizedBox(height: AppTheme.spacingMD),
                              const FontPicker().animate().fadeIn(
                                delay: const Duration(milliseconds: 350),
                                duration: const Duration(milliseconds: 400),
                              ),
                              const SizedBox(height: AppTheme.spacingXL),

                              // Section 5: Poster Title
                              _buildSectionTitle(
                                context,
                                lang == 'ko' ? '포스터 제목' : 'Poster Title',
                                3,
                              ),
                              const SizedBox(height: AppTheme.spacingMD),
                              TossCard(
                                padding: const EdgeInsets.all(AppTheme.spacingMD),
                                child: TextFormField(
                                  controller: _titleController,
                                  decoration: InputDecoration(
                                    hintText: lang == 'ko' ? '무료 WiFi' : 'FREE WiFi',
                                    hintStyle: TextStyle(color: AppTheme.textTertiary),
                                    prefixIcon: Icon(
                                      Icons.title_rounded,
                                      color: AppTheme.textSecondary,
                                      size: 20,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    filled: false,
                                    counterStyle: TextStyle(
                                      color: AppTheme.textTertiary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  maxLength: 30,
                                  onChanged: (value) {
                                    context.read<PosterProvider>().setPosterTitle(value);
                                  },
                                ),
                              ).animate().fadeIn(
                                delay: const Duration(milliseconds: 400),
                                duration: const Duration(milliseconds: 400),
                              ),
                              const SizedBox(height: AppTheme.spacingXL),

                              // Section 5: Custom Message (only for sizes that support it)
                              Consumer<PosterProvider>(
                                builder: (context, provider, child) {
                                  if (!provider.canShowMessage) {
                                    return const SizedBox.shrink();
                                  }
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionTitle(
                                        context,
                                        AppTranslations.get('custom_message', lang),
                                        4,
                                      ),
                                      const SizedBox(height: AppTheme.spacingMD),
                                      TossCard(
                                        padding: const EdgeInsets.all(AppTheme.spacingMD),
                                        child: TextFormField(
                                          controller: _messageController,
                                          style: TextStyle(
                                            color: _isMessageDefault
                                                ? AppTheme.textTertiary
                                                : AppTheme.textPrimary,
                                          ),
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.message_outlined,
                                              color: AppTheme.textSecondary,
                                              size: 20,
                                            ),
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            filled: false,
                                            counterStyle: TextStyle(
                                              color: AppTheme.textTertiary,
                                              fontSize: 12,
                                            ),
                                          ),
                                          maxLength: 50,
                                          onTap: () {
                                            if (_isMessageDefault) {
                                              _messageController.selection = TextSelection(
                                                baseOffset: 0,
                                                extentOffset: 0,
                                              );
                                            }
                                          },
                                          onChanged: (value) {
                                            if (_isMessageDefault && value != _defaultMessage) {
                                              final newChar = value.replaceFirst(_defaultMessage, '');
                                              setState(() {
                                                _isMessageDefault = false;
                                                _messageController.text = newChar;
                                                _messageController.selection = TextSelection.collapsed(
                                                  offset: newChar.length,
                                                );
                                              });
                                              context.read<PosterProvider>().setCustomMessage(newChar);
                                            } else if (value.isEmpty) {
                                              setState(() {
                                                _isMessageDefault = true;
                                                _messageController.text = _defaultMessage;
                                              });
                                              context.read<PosterProvider>().setCustomMessage(_defaultMessage);
                                            } else {
                                              context.read<PosterProvider>().setCustomMessage(value);
                                            }
                                          },
                                        ),
                                      ).animate().fadeIn(
                                        delay: const Duration(milliseconds: 450),
                                        duration: const Duration(milliseconds: 400),
                                      ),
                                      const SizedBox(height: AppTheme.spacingMD),
                                    ],
                                  );
                                },
                              ),

                              // Show password option (only for sizes that support it)
                              Consumer<PosterProvider>(
                                builder: (context, provider, child) {
                                  if (!provider.canShowPassword) {
                                    return const SizedBox.shrink();
                                  }
                                  return Column(
                                    children: [
                                      _buildShowPasswordOption(context, lang),
                                      const SizedBox(height: AppTheme.spacingXL),
                                    ],
                                  );
                                },
                              ),

                              // Section 6: Signature
                              _buildSectionTitle(
                                context,
                                lang == 'ko' ? '서명 (선택)' : 'Signature (Optional)',
                                5,
                              ),
                              const SizedBox(height: AppTheme.spacingMD),
                              _buildSignatureSection(context, lang),
                              const SizedBox(height: AppTheme.spacingXL),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Bottom button
              _buildBottomButton(context, lang),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String lang) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMD,
        vertical: AppTheme.spacingSM,
      ),
      child: Row(
        children: [
          TossIconButton(
            icon: Icons.arrow_back_ios_rounded,
            onPressed: () async {
              final shouldPop = await _onWillPop(lang);
              if (shouldPop && mounted) {
                Navigator.pop(context);
              }
            },
            size: 40,
          ),
          const SizedBox(width: AppTheme.spacingSM),
          Text(
            AppTranslations.get('create_poster', lang),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 300));
  }

  Widget _buildSectionTitle(BuildContext context, String title, int index) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: AppTheme.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    ).animate().fadeIn(
      delay: Duration(milliseconds: 50 * index),
      duration: const Duration(milliseconds: 400),
    );
  }

  Widget _buildShowPasswordOption(BuildContext context, String lang) {
    return Consumer<PosterProvider>(
      builder: (context, provider, child) {
        return TossCard(
          onTap: () {
            provider.setShowPasswordOnPoster(!provider.showPasswordOnPoster);
          },
          padding: const EdgeInsets.all(AppTheme.spacingMD),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(
                  Icons.password_rounded,
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
                      AppTranslations.get('show_password_poster', lang),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lang == 'ko'
                          ? 'WiFi 비밀번호를 텍스트로 표시'
                          : 'Display WiFi password as text',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Switch(
                value: provider.showPasswordOnPoster,
                onChanged: (value) {
                  provider.setShowPasswordOnPoster(value);
                },
                activeColor: AppTheme.primary,
                trackOutlineColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.transparent;
                  }
                  return AppTheme.border;
                }),
              ),
            ],
          ),
        ).animate().fadeIn(
          delay: const Duration(milliseconds: 500),
          duration: const Duration(milliseconds: 400),
        );
      },
    );
  }

  Widget _buildSignatureSection(BuildContext context, String lang) {
    return Consumer<PosterProvider>(
      builder: (context, provider, child) {
        return TossCard(
          padding: const EdgeInsets.all(AppTheme.spacingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toggle buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        provider.setUseSignatureImage(false);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingSM,
                        ),
                        decoration: BoxDecoration(
                          color: !provider.useSignatureImage
                              ? AppTheme.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSmall,
                          ),
                          border: Border.all(
                            color: !provider.useSignatureImage
                                ? AppTheme.primary
                                : AppTheme.border,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.text_fields_rounded,
                              size: 18,
                              color: !provider.useSignatureImage
                                  ? AppTheme.primary
                                  : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              lang == 'ko' ? '텍스트' : 'Text',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: !provider.useSignatureImage
                                    ? AppTheme.primary
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSM),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        provider.setUseSignatureImage(true);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.spacingSM,
                        ),
                        decoration: BoxDecoration(
                          color: provider.useSignatureImage
                              ? AppTheme.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSmall,
                          ),
                          border: Border.all(
                            color: provider.useSignatureImage
                                ? AppTheme.primary
                                : AppTheme.border,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_rounded,
                              size: 18,
                              color: provider.useSignatureImage
                                  ? AppTheme.primary
                                  : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              lang == 'ko' ? '이미지' : 'Image',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: provider.useSignatureImage
                                    ? AppTheme.primary
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMD),
              // Content based on selection
              if (!provider.useSignatureImage)
                TextFormField(
                  controller: _signatureController,
                  decoration: InputDecoration(
                    hintText: lang == 'ko'
                        ? '가게 이름, 본인 이름 등'
                        : 'Store name, your name, etc.',
                    hintStyle: TextStyle(color: AppTheme.textTertiary),
                    prefixIcon: Icon(
                      Icons.edit_rounded,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    counterStyle: TextStyle(
                      color: AppTheme.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                  maxLength: 30,
                  onChanged: (value) {
                    provider.setSignatureText(value);
                  },
                )
              else
                _buildSignatureImagePicker(context, provider, lang),
            ],
          ),
        ).animate().fadeIn(
          delay: const Duration(milliseconds: 550),
          duration: const Duration(milliseconds: 400),
        );
      },
    );
  }

  Widget _buildSignatureImagePicker(
    BuildContext context,
    PosterProvider provider,
    String lang,
  ) {
    if (provider.hasSignatureImage) {
      return Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            child: Image.memory(
              provider.signatureImageData!,
              height: 60,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSM),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () => _pickSignatureImage(provider),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(lang == 'ko' ? '변경' : 'Change'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
              ),
              TextButton.icon(
                onPressed: () => provider.clearSignatureImage(),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: Text(lang == 'ko' ? '삭제' : 'Delete'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.error),
              ),
            ],
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: () => _pickSignatureImage(provider),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingLG),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(color: AppTheme.border, style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: AppTheme.spacingSM),
            Text(
              lang == 'ko' ? '로고 또는 이미지 업로드' : 'Upload logo or image',
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickSignatureImage(PosterProvider provider) async {
    final locale = context.read<LocaleProvider>();
    final lang = locale.locale.languageCode;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (image != null) {
        final Uint8List bytes = await image.readAsBytes();
        provider.setSignatureImage(bytes);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(AppTranslations.get('error_image_pick', lang));
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: AppTheme.spacingSM),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, String lang) {
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
      child: TossPrimaryButton(
        text: AppTranslations.get('preview_poster', lang),
        onPressed: () => _handlePreview(lang),
        icon: Icons.visibility_rounded,
      ),
    ).animate().fadeIn(
      delay: const Duration(milliseconds: 550),
      duration: const Duration(milliseconds: 400),
    );
  }

  void _handlePreview(String lang) {
    final provider = context.read<PosterProvider>();
    provider.setSsid(_ssidController.text.trim());
    provider.setPassword(_passwordController.text);

    if (_ssidController.text.trim().isEmpty) {
      _showError(AppTranslations.get('enter_network_name', lang));
      return;
    }

    // Auto-set encryption based on password
    if (_passwordController.text.isEmpty) {
      provider.setEncryption(WifiEncryptionType.none);
    } else {
      provider.setEncryption(WifiEncryptionType.wpa);
    }

    Navigator.pushNamed(context, AppRoutes.preview);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: AppTheme.spacingSM),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        margin: const EdgeInsets.all(AppTheme.spacingMD),
      ),
    );
  }
}
