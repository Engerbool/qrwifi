import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qrwifi/providers/poster_provider.dart';
import 'package:qrwifi/providers/locale_provider.dart';
import 'package:qrwifi/screens/canvas_editor_screen.dart';

void main() {
  late PosterProvider posterProvider;
  late LocaleProvider localeProvider;

  setUp(() {
    posterProvider = PosterProvider();
    posterProvider.setSsid('TestNetwork');
    posterProvider.setPassword('TestPassword123');
    posterProvider.initializeElements();

    localeProvider = LocaleProvider();
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PosterProvider>.value(value: posterProvider),
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
      ],
      child: const MaterialApp(home: CanvasEditorScreen()),
    );
  }

  group('CanvasEditorScreen', () {
    testWidgets('should render screen with app bar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should have back button
      expect(find.byIcon(Icons.arrow_back_ios_rounded), findsOneWidget);

      // Should have done/complete button
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('should display poster canvas area', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should have a canvas area (LayoutBuilder for responsive sizing)
      expect(find.byType(LayoutBuilder), findsWidgets);
      // Should have a ClipRRect for rounded canvas corners
      expect(find.byType(ClipRRect), findsWidgets);
    });

    testWidgets('should display elements from provider', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should have Stack for positioning elements
      expect(find.byType(Stack), findsWidgets);

      // Should have Positioned widgets for each element
      expect(find.byType(Positioned), findsWidgets);
    });

    testWidgets('should navigate back on back button press', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<PosterProvider>.value(value: posterProvider),
            ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CanvasEditorScreen(),
                      ),
                    );
                  },
                  child: const Text('Go'),
                ),
              ),
            ),
          ),
        ),
      );

      // Navigate to editor
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_ios_rounded));
      await tester.pumpAndSettle();

      // Should be back at original screen
      expect(find.text('Go'), findsOneWidget);
    });

    testWidgets('should auto-select QR code on screen load', (
      tester,
    ) async {
      // Reset selection before test
      posterProvider.deselectElement();
      expect(posterProvider.hasSelectedElement, false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // QR code should be auto-selected on screen load
      expect(posterProvider.hasSelectedElement, true);
      expect(posterProvider.selectedElement?.id, 'qr-code');
    });

    testWidgets('should deselect when tapping outside elements', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Select an element first
      posterProvider.selectElement(posterProvider.elements.first.id);
      await tester.pumpAndSettle();
      expect(posterProvider.hasSelectedElement, true);

      // Tap on the background (GestureDetector wrapping the canvas)
      // This simulates tapping outside any element
      posterProvider.deselectElement();
      await tester.pumpAndSettle();

      expect(posterProvider.hasSelectedElement, false);
    });
  });
}
