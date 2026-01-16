import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qrwifi/app.dart';
import 'package:qrwifi/providers/auth_provider.dart';
import 'package:qrwifi/providers/poster_provider.dart';
import 'package:qrwifi/providers/locale_provider.dart';
import 'package:qrwifi/providers/theme_provider.dart';

void main() {
  testWidgets('App should render splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => PosterProvider()),
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const QRWifiApp(),
      ),
    );

    // Verify splash screen renders initially
    expect(find.text('WiFi QR'), findsOneWidget);

    // Let the splash timer complete and navigate
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
}
