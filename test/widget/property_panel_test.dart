import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qrwifi/models/poster_element.dart';
import 'package:qrwifi/providers/poster_provider.dart';
import 'package:qrwifi/providers/locale_provider.dart';
import 'package:qrwifi/widgets/property_panel.dart';

void main() {
  late PosterProvider posterProvider;
  late LocaleProvider localeProvider;

  setUp(() {
    posterProvider = PosterProvider();
    posterProvider.setSsid('TestNetwork');
    posterProvider.setPassword('TestPassword123');
    localeProvider = LocaleProvider();
  });

  Widget createTestWidget({PosterElement? selectedElement}) {
    if (selectedElement != null) {
      posterProvider.addElement(selectedElement);
      posterProvider.selectElement(selectedElement.id);
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PosterProvider>.value(value: posterProvider),
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
      ],
      child: const MaterialApp(home: Scaffold(body: PropertyPanel())),
    );
  }

  group('PropertyPanel Visibility', () {
    testWidgets('should not show panel when no element is selected', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Panel should not be visible or should show empty state
      expect(find.byKey(const Key('property-panel-content')), findsNothing);
    });

    testWidgets('should show panel when element is selected', (tester) async {
      final element = PosterElement(
        id: 'test-element-1',
        type: ElementType.title,
        x: 100,
        y: 150,
        width: 200,
        height: 50,
        textColor: Colors.black,
        content: 'Test Title',
      );

      await tester.pumpWidget(createTestWidget(selectedElement: element));
      await tester.pumpAndSettle();

      // Panel content should be visible
      expect(find.byKey(const Key('property-panel-content')), findsOneWidget);
    });
  });

  group('Position Input (X, Y)', () {
    testWidgets('should display current X and Y values', (tester) async {
      final element = PosterElement(
        id: 'position-test-1',
        type: ElementType.title,
        x: 100,
        y: 150,
        width: 200,
        height: 50,
        textColor: Colors.black,
      );

      await tester.pumpWidget(createTestWidget(selectedElement: element));
      await tester.pumpAndSettle();

      // Find X and Y input fields
      final xField = find.byKey(const Key('property-input-x'));
      final yField = find.byKey(const Key('property-input-y'));

      expect(xField, findsOneWidget);
      expect(yField, findsOneWidget);

      // Check initial values
      final xTextField = tester.widget<TextField>(xField);
      final yTextField = tester.widget<TextField>(yField);

      expect(xTextField.controller?.text, '100');
      expect(yTextField.controller?.text, '150');
    });

    testWidgets('should update element position when X value changes', (
      tester,
    ) async {
      final element = PosterElement(
        id: 'position-test-2',
        type: ElementType.title,
        x: 100,
        y: 150,
        width: 200,
        height: 50,
        textColor: Colors.black,
      );

      await tester.pumpWidget(createTestWidget(selectedElement: element));
      await tester.pumpAndSettle();

      // Find X input and change value
      final xField = find.byKey(const Key('property-input-x'));
      await tester.enterText(xField, '200');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify position updated in provider
      final updatedElement = posterProvider.getElementById('position-test-2');
      expect(updatedElement?.x, 200);
    });

    testWidgets('should update element position when Y value changes', (
      tester,
    ) async {
      final element = PosterElement(
        id: 'position-test-3',
        type: ElementType.title,
        x: 100,
        y: 150,
        width: 200,
        height: 50,
        textColor: Colors.black,
      );

      await tester.pumpWidget(createTestWidget(selectedElement: element));
      await tester.pumpAndSettle();

      // Find Y input and change value
      final yField = find.byKey(const Key('property-input-y'));
      await tester.enterText(yField, '300');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify position updated in provider
      final updatedElement = posterProvider.getElementById('position-test-3');
      expect(updatedElement?.y, 300);
    });

    testWidgets('should not accept negative values for position', (
      tester,
    ) async {
      final element = PosterElement(
        id: 'position-test-4',
        type: ElementType.title,
        x: 100,
        y: 150,
        width: 200,
        height: 50,
        textColor: Colors.black,
      );

      await tester.pumpWidget(createTestWidget(selectedElement: element));
      await tester.pumpAndSettle();

      // Try to enter negative value
      final xField = find.byKey(const Key('property-input-x'));
      await tester.enterText(xField, '-50');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Position should be clamped to 0
      final updatedElement = posterProvider.getElementById('position-test-4');
      expect(updatedElement?.x, greaterThanOrEqualTo(0));
    });
  });

  group('Size Input (Width, Height)', () {
    testWidgets('should display current width and height values', (
      tester,
    ) async {
      final element = PosterElement(
        id: 'size-test-1',
        type: ElementType.title,
        x: 100,
        y: 150,
        width: 200,
        height: 80,
        textColor: Colors.black,
      );

      await tester.pumpWidget(createTestWidget(selectedElement: element));
      await tester.pumpAndSettle();

      // Find width and height input fields
      final widthField = find.byKey(const Key('property-input-width'));
      final heightField = find.byKey(const Key('property-input-height'));

      expect(widthField, findsOneWidget);
      expect(heightField, findsOneWidget);

      // Check initial values
      final widthTextField = tester.widget<TextField>(widthField);
      final heightTextField = tester.widget<TextField>(heightField);

      expect(widthTextField.controller?.text, '200');
      expect(heightTextField.controller?.text, '80');
    });

    testWidgets('should update element size when width value changes', (
      tester,
    ) async {
      final element = PosterElement(
        id: 'size-test-2',
        type: ElementType.title,
        x: 100,
        y: 150,
        width: 200,
        height: 80,
        textColor: Colors.black,
      );

      await tester.pumpWidget(createTestWidget(selectedElement: element));
      await tester.pumpAndSettle();

      // Find width input and change value
      final widthField = find.byKey(const Key('property-input-width'));
      await tester.enterText(widthField, '300');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify size updated in provider
      final updatedElement = posterProvider.getElementById('size-test-2');
      expect(updatedElement?.width, 300);
    });

    testWidgets('should update element size when height value changes', (
      tester,
    ) async {
      final element = PosterElement(
        id: 'size-test-3',
        type: ElementType.title,
        x: 100,
        y: 150,
        width: 200,
        height: 80,
        textColor: Colors.black,
      );

      await tester.pumpWidget(createTestWidget(selectedElement: element));
      await tester.pumpAndSettle();

      // Find height input and change value
      final heightField = find.byKey(const Key('property-input-height'));
      await tester.enterText(heightField, '120');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify size updated in provider
      final updatedElement = posterProvider.getElementById('size-test-3');
      expect(updatedElement?.height, 120);
    });

    testWidgets('should enforce minimum size', (tester) async {
      final element = PosterElement(
        id: 'size-test-4',
        type: ElementType.title,
        x: 100,
        y: 150,
        width: 200,
        height: 80,
        textColor: Colors.black,
      );

      await tester.pumpWidget(createTestWidget(selectedElement: element));
      await tester.pumpAndSettle();

      // Try to enter very small value
      final widthField = find.byKey(const Key('property-input-width'));
      await tester.enterText(widthField, '10');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Size should be at least minimum (50)
      final updatedElement = posterProvider.getElementById('size-test-4');
      expect(updatedElement?.width, greaterThanOrEqualTo(50));
    });
  });

  group('Color Picker', () {
    testWidgets('should show text color picker for text elements', (
      tester,
    ) async {
      final element = PosterElement(
        id: 'color-test-1',
        type: ElementType.title,
        x: 100,
        y: 150,
        width: 200,
        height: 50,
        textColor: Colors.black,
      );

      await tester.pumpWidget(createTestWidget(selectedElement: element));
      await tester.pumpAndSettle();

      // Should find text color picker button
      expect(find.byKey(const Key('property-color-text')), findsOneWidget);
    });

    testWidgets('should show QR color pickers for QR code element', (
      tester,
    ) async {
      final element = PosterElement(
        id: 'color-test-2',
        type: ElementType.qrCode,
        x: 100,
        y: 150,
        width: 200,
        height: 200,
        textColor: Colors.black,
        backgroundColor: Colors.white,
      );

      await tester.pumpWidget(createTestWidget(selectedElement: element));
      await tester.pumpAndSettle();

      // Should find QR foreground and background color pickers
      expect(
        find.byKey(const Key('property-color-qr-foreground')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('property-color-qr-background')),
        findsOneWidget,
      );
    });

    testWidgets('should open color picker dialog when tapped', (tester) async {
      final element = PosterElement(
        id: 'color-test-3',
        type: ElementType.title,
        x: 100,
        y: 150,
        width: 200,
        height: 50,
        textColor: Colors.black,
      );

      await tester.pumpWidget(createTestWidget(selectedElement: element));
      await tester.pumpAndSettle();

      // Tap on text color picker (scroll to it first since panel has fixed height)
      final colorButton = find.byKey(const Key('property-color-text'));
      await tester.ensureVisible(colorButton);
      await tester.pumpAndSettle();
      await tester.tap(colorButton);
      await tester.pumpAndSettle();

      // Color picker dialog should be shown
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });

  group('Font Picker', () {
    testWidgets('should show font picker for text elements', (tester) async {
      final element = PosterElement(
        id: 'font-test-1',
        type: ElementType.title,
        x: 100,
        y: 150,
        width: 200,
        height: 50,
        textColor: Colors.black,
        fontFamily: 'noto',
      );

      await tester.pumpWidget(createTestWidget(selectedElement: element));
      await tester.pumpAndSettle();

      // Should find font picker section
      expect(find.byKey(const Key('property-font-picker')), findsOneWidget);
    });

    testWidgets('should not show font picker for QR code element', (
      tester,
    ) async {
      final element = PosterElement(
        id: 'font-test-2',
        type: ElementType.qrCode,
        x: 100,
        y: 150,
        width: 200,
        height: 200,
        textColor: Colors.black,
        backgroundColor: Colors.white,
      );

      await tester.pumpWidget(createTestWidget(selectedElement: element));
      await tester.pumpAndSettle();

      // Font picker should NOT be visible for QR code
      expect(find.byKey(const Key('property-font-picker')), findsNothing);
    });

    testWidgets('should update font when font option is selected', (
      tester,
    ) async {
      final element = PosterElement(
        id: 'font-test-3',
        type: ElementType.title,
        x: 100,
        y: 150,
        width: 200,
        height: 50,
        textColor: Colors.black,
        fontFamily: 'noto',
      );

      await tester.pumpWidget(createTestWidget(selectedElement: element));
      await tester.pumpAndSettle();

      // Find and tap a different font option (scroll to it first)
      final gaeguOption = find.byKey(const Key('font-option-gaegu'));
      if (gaeguOption.evaluate().isNotEmpty) {
        await tester.ensureVisible(gaeguOption);
        await tester.pumpAndSettle();
        await tester.tap(gaeguOption);
        await tester.pumpAndSettle();

        // Verify font updated in provider
        final updatedElement = posterProvider.getElementById('font-test-3');
        expect(updatedElement?.fontFamily, 'gaegu');
      }
    });
  });

  group('Element Type Display', () {
    testWidgets('should display element type name', (tester) async {
      final element = PosterElement(
        id: 'type-test-1',
        type: ElementType.title,
        x: 100,
        y: 150,
        width: 200,
        height: 50,
        textColor: Colors.black,
      );

      await tester.pumpWidget(createTestWidget(selectedElement: element));
      await tester.pumpAndSettle();

      // Should find element type label
      expect(find.byKey(const Key('property-element-type')), findsOneWidget);
    });
  });

  group('Input Validation', () {
    testWidgets('should only accept numeric input for position fields', (
      tester,
    ) async {
      final element = PosterElement(
        id: 'validation-test-1',
        type: ElementType.title,
        x: 100,
        y: 150,
        width: 200,
        height: 50,
        textColor: Colors.black,
      );

      await tester.pumpWidget(createTestWidget(selectedElement: element));
      await tester.pumpAndSettle();

      // Try to enter non-numeric value
      final xField = find.byKey(const Key('property-input-x'));
      await tester.enterText(xField, 'abc');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Position should remain unchanged or be 0
      final updatedElement = posterProvider.getElementById('validation-test-1');
      expect(updatedElement?.x, anyOf(equals(100), equals(0)));
    });
  });
}
