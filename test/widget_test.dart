import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qrwifi/app.dart';
import 'package:qrwifi/providers/auth_provider.dart';
import 'package:qrwifi/providers/poster_provider.dart';

void main() {
  testWidgets('App should render splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => PosterProvider()),
        ],
        child: const QRWifiApp(),
      ),
    );

    // Verify splash screen renders
    expect(find.text('WiFi QR'), findsOneWidget);
  });
}
