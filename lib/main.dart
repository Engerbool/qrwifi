import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/locale_provider.dart';
import 'providers/poster_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Provider를 미리 생성하고 초기화 (이전 세션 상태 노출 방지)
  final posterProvider = PosterProvider();
  posterProvider.reset(); // 앱 시작 시 즉시 초기화

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider.value(value: posterProvider),
      ],
      child: const QRWifiApp(),
    ),
  );
}
