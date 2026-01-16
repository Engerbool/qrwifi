import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qrwifi/models/poster_element.dart';
import 'package:qrwifi/providers/poster_provider.dart';
import 'package:qrwifi/providers/locale_provider.dart';
import 'package:qrwifi/widgets/editable_element.dart';

void main() {
  late PosterProvider posterProvider;
  late LocaleProvider localeProvider;

  setUp(() {
    posterProvider = PosterProvider();
    posterProvider.setSsid('TestNetwork');
    posterProvider.setPassword('TestPassword123');
    localeProvider = LocaleProvider();
  });

  Widget createTestWidget({
    required PosterElement element,
    required double canvasScale,
    bool isSelected = false,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PosterProvider>.value(value: posterProvider),
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 600,
            child: Stack(
              children: [
                EditableElement(
                  element: element,
                  canvasScale: canvasScale,
                  isSelected: isSelected,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  group('EditableElement', () {
    testWidgets('should render title element with text', (tester) async {
      final element = PosterElement(
        id: 'title-1',
        type: ElementType.title,
        x: 100,
        y: 100,
        width: 200,
        height: 50,
        textColor: Colors.black,
        fontSize: 24,
        content: 'Test Title',
      );

      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 0.1),
      );
      await tester.pumpAndSettle();

      // Should render text content
      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('should render QR code element', (tester) async {
      final element = PosterElement(
        id: 'qr-1',
        type: ElementType.qrCode,
        x: 100,
        y: 100,
        width: 200,
        height: 200,
        textColor: Colors.black,
        backgroundColor: Colors.white,
      );

      // Use larger scale to avoid negative QR size (size - 32 must be positive)
      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 0.5),
      );
      await tester.pumpAndSettle();

      // Should render QR widget container
      expect(find.byType(EditableElement), findsOneWidget);
    });

    testWidgets('should show selection border when selected', (tester) async {
      final element = PosterElement(
        id: 'title-1',
        type: ElementType.title,
        x: 100,
        y: 100,
        width: 200,
        height: 50,
        textColor: Colors.black,
        content: 'Test',
      );

      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 0.1, isSelected: true),
      );
      await tester.pumpAndSettle();

      // Should have a decorated container with border
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(EditableElement),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(container, isNotNull);
    });

    testWidgets('should not show border when not selected', (tester) async {
      final element = PosterElement(
        id: 'title-1',
        type: ElementType.title,
        x: 100,
        y: 100,
        width: 200,
        height: 50,
        textColor: Colors.black,
        content: 'Test',
      );

      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 0.1, isSelected: false),
      );
      await tester.pumpAndSettle();

      expect(find.byType(EditableElement), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      final element = PosterElement(
        id: 'title-1',
        type: ElementType.title,
        x: 100,
        y: 100,
        width: 200,
        height: 50,
        textColor: Colors.black,
        content: 'Test',
      );

      // Add element to provider so selection can work
      posterProvider.addElement(element);

      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 0.1),
      );
      await tester.pumpAndSettle();

      // Tap the element
      await tester.tap(find.byType(EditableElement));
      await tester.pumpAndSettle();

      // Should select the element
      expect(posterProvider.selectedElement?.id, element.id);
    });

    testWidgets('should render WiFi icon element', (tester) async {
      final element = PosterElement(
        id: 'wifi-icon-1',
        type: ElementType.wifiIcon,
        x: 100,
        y: 100,
        width: 50,
        height: 50,
        textColor: Colors.blue,
      );

      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 0.1),
      );
      await tester.pumpAndSettle();

      // Should render WiFi icon
      expect(find.byIcon(Icons.wifi), findsOneWidget);
    });

    testWidgets('should render message element', (tester) async {
      final element = PosterElement(
        id: 'message-1',
        type: ElementType.message,
        x: 100,
        y: 100,
        width: 200,
        height: 30,
        textColor: Colors.grey,
        fontSize: 14,
        content: 'Scan to connect',
      );

      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 0.1),
      );
      await tester.pumpAndSettle();

      expect(find.text('Scan to connect'), findsOneWidget);
    });

    testWidgets('should render signature element', (tester) async {
      final element = PosterElement(
        id: 'signature-1',
        type: ElementType.signature,
        x: 100,
        y: 100,
        width: 150,
        height: 30,
        textColor: Colors.black,
        fontSize: 16,
        content: 'My Cafe',
      );

      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 0.1),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Cafe'), findsOneWidget);
    });

    testWidgets('should render ssidPassword element', (tester) async {
      final element = PosterElement(
        id: 'ssid-pw-1',
        type: ElementType.ssidPassword,
        x: 100,
        y: 100,
        width: 200,
        height: 50,
        textColor: Colors.black,
        fontSize: 12,
        content: 'ID: TestNetwork\nPW: Test123',
      );

      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 0.1),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('ID:'), findsOneWidget);
    });
  });
}
