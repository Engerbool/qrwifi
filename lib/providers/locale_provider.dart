import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ko');

  Locale get locale => _locale;
  bool get isKorean => _locale.languageCode == 'ko';

  void toggleLocale() {
    _locale = _locale.languageCode == 'en'
        ? const Locale('ko')
        : const Locale('en');
    notifyListeners();
  }

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }
}
