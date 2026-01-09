class AppTranslations {
  static const Map<String, Map<String, String>> _translations = {
    // Login Screen
    'app_title': {
      'en': 'WiFi QR\nPoster',
      'ko': 'WiFi QR\n포스터',
    },
    'app_subtitle': {
      'en': 'Create beautiful WiFi posters\nfor your business in seconds',
      'ko': '몇 초만에 멋진 WiFi 포스터를\n만들어보세요',
    },
    'feature_wifi': {
      'en': 'Enter WiFi details',
      'ko': 'WiFi 정보 입력',
    },
    'feature_template': {
      'en': 'Choose a template',
      'ko': '템플릿 선택',
    },
    'feature_download': {
      'en': 'Download A4 poster',
      'ko': 'A4 포스터 다운로드',
    },
    'continue_google': {
      'en': 'Continue with Google',
      'ko': 'Google로 계속하기',
    },
    'terms_notice': {
      'en': 'By continuing, you agree to our Terms and Privacy Policy',
      'ko': '계속하면 이용약관 및 개인정보처리방침에 동의하게 됩니다',
    },

    // Home Screen
    'home_title': {
      'en': 'WiFi QR\nPoster',
      'ko': 'WiFi QR\n포스터',
    },
    'create_new': {
      'en': 'Create New\nPoster',
      'ko': '새 포스터\n만들기',
    },
    'create_description': {
      'en': 'Enter WiFi info and get a printable QR poster',
      'ko': 'WiFi 정보를 입력하고 인쇄용 QR 포스터를 받으세요',
    },
    'how_it_works': {
      'en': 'How it works',
      'ko': '사용 방법',
    },
    'step1_title': {
      'en': 'Enter WiFi info',
      'ko': 'WiFi 정보 입력',
    },
    'step1_subtitle': {
      'en': 'Network name and password',
      'ko': '네트워크 이름과 비밀번호',
    },
    'step2_title': {
      'en': 'Choose template',
      'ko': '템플릿 선택',
    },
    'step2_subtitle': {
      'en': 'Pick a design style',
      'ko': '디자인 스타일 선택',
    },
    'step3_title': {
      'en': 'Download poster',
      'ko': '포스터 다운로드',
    },
    'step3_subtitle': {
      'en': 'Get your A4 printable file',
      'ko': 'A4 인쇄용 파일 받기',
    },
    'info1': {
      'en': 'Completely free, use without worry',
      'ko': '완전 무료니까 걱정 없이 사용하세요',
    },
    'info2': {
      'en': 'Just prepare your WiFi network name and password',
      'ko': 'WiFi 네트워크 이름과 비밀번호만 준비하면 돼요',
    },
    'info3': {
      'en': 'You can apply various templates',
      'ko': '여러가지 템플릿을 적용할 수 있어요',
    },
    'cancel': {
      'en': 'Cancel',
      'ko': '취소',
    },

    // Editor Screen
    'create_poster': {
      'en': 'Create Poster',
      'ko': '포스터 만들기',
    },
    'wifi_network': {
      'en': 'WiFi Network',
      'ko': 'WiFi 네트워크',
    },
    'network_name': {
      'en': 'Network name (SSID)',
      'ko': '네트워크 이름 (SSID)',
    },
    'password': {
      'en': 'Password',
      'ko': '비밀번호',
    },
    'security': {
      'en': 'Security',
      'ko': '보안 유형',
    },
    'template': {
      'en': 'Template',
      'ko': '템플릿',
    },
    'center_icon': {
      'en': 'Center Icon',
      'ko': '중앙 아이콘',
    },
    'upload_custom': {
      'en': 'Upload custom icon',
      'ko': '커스텀 아이콘 업로드',
    },
    'custom_message': {
      'en': 'Custom Message (optional)',
      'ko': '커스텀 메시지 (선택)',
    },
    'message_hint': {
      'en': 'e.g., Welcome to our cafe!',
      'ko': '예: 카페에 오신 것을 환영합니다!',
    },
    'show_password_poster': {
      'en': 'Show password on poster',
      'ko': '포스터에 비밀번호 표시',
    },
    'preview_poster': {
      'en': 'Preview Poster',
      'ko': '포스터 미리보기',
    },
    'enter_network_name': {
      'en': 'Please enter network name',
      'ko': '네트워크 이름을 입력하세요',
    },

    // Preview Screen
    'preview': {
      'en': 'Preview',
      'ko': '미리보기',
    },
    'ready_download': {
      'en': 'Ready to download',
      'ko': '다운로드 준비 완료',
    },
    'download_poster': {
      'en': 'Download Poster',
      'ko': '포스터 다운로드',
    },
    'edit': {
      'en': 'Edit',
      'ko': '수정',
    },
    'saving': {
      'en': 'Saving...',
      'ko': '저장 중...',
    },
    'saved_success': {
      'en': 'Poster saved successfully!',
      'ko': '포스터가 저장되었습니다!',
    },
    'save_failed': {
      'en': 'Failed to save poster',
      'ko': '포스터 저장에 실패했습니다',
    },
    'poster_ready': {
      'en': 'Your poster is ready!',
      'ko': '포스터가 준비되었습니다!',
    },
    'edit_poster': {
      'en': 'Edit Poster',
      'ko': '포스터 수정',
    },

    // Poster Canvas
    'free_wifi': {
      'en': 'FREE WiFi',
      'ko': '무료 WiFi',
    },
    'scan_qr': {
      'en': 'Scan the QR code with your phone camera',
      'ko': '휴대폰 카메라로 QR 코드를 스캔하세요',
    },
    'network': {
      'en': 'Network',
      'ko': '네트워크',
    },

    // Common
    'user': {
      'en': 'User',
      'ko': '사용자',
    },
  };

  static String get(String key, String languageCode) {
    return _translations[key]?[languageCode] ?? _translations[key]?['en'] ?? key;
  }
}
