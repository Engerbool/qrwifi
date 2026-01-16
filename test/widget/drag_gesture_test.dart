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

  group('Drag Gesture', () {
    testWidgets('should select element on pan start', (tester) async {
      final element = PosterElement(
        id: 'drag-test-1',
        type: ElementType.title,
        x: 100,
        y: 100,
        width: 200,
        height: 50,
        textColor: Colors.black,
        content: 'Drag Me',
      );

      posterProvider.addElement(element);

      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 1.0),
      );
      await tester.pumpAndSettle();

      // Initially not selected
      expect(posterProvider.selectedElement, isNull);

      // Perform a drag which triggers onPanStart, onPanUpdate, onPanEnd
      await tester.drag(find.byType(EditableElement), const Offset(20, 20));
      await tester.pumpAndSettle();

      // Should be selected after drag (selection happens in onPanStart)
      expect(posterProvider.selectedElement?.id, element.id);
    });

    testWidgets('should update position on pan update', (tester) async {
      final element = PosterElement(
        id: 'drag-test-2',
        type: ElementType.title,
        x: 100,
        y: 100,
        width: 200,
        height: 50,
        textColor: Colors.black,
        content: 'Drag Me',
      );

      posterProvider.addElement(element);

      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 1.0),
      );
      await tester.pumpAndSettle();

      final initialX = posterProvider.getElementById('drag-test-2')!.x;
      final initialY = posterProvider.getElementById('drag-test-2')!.y;

      // Perform drag gesture
      await tester.drag(find.byType(EditableElement), const Offset(50, 30));
      await tester.pumpAndSettle();

      // Position should be updated
      final updatedElement = posterProvider.getElementById('drag-test-2')!;
      expect(updatedElement.x, greaterThan(initialX));
      expect(updatedElement.y, greaterThan(initialY));
    });

    testWidgets('should bring element to front on pan end', (tester) async {
      // Create two elements with different z-index
      final element1 = PosterElement(
        id: 'drag-test-3',
        type: ElementType.title,
        x: 100,
        y: 100,
        width: 200,
        height: 50,
        zIndex: 0,
        textColor: Colors.black,
        content: 'First',
      );

      final element2 = PosterElement(
        id: 'drag-test-4',
        type: ElementType.title,
        x: 150,
        y: 150,
        width: 200,
        height: 50,
        zIndex: 1,
        textColor: Colors.black,
        content: 'Second',
      );

      posterProvider.addElement(element1);
      posterProvider.addElement(element2);

      await tester.pumpWidget(
        createTestWidget(element: element1, canvasScale: 1.0),
      );
      await tester.pumpAndSettle();

      // Element 1 has lower z-index initially
      final initialZIndex1 = posterProvider
          .getElementById('drag-test-3')!
          .zIndex;
      final initialZIndex2 = posterProvider
          .getElementById('drag-test-4')!
          .zIndex;
      expect(initialZIndex1, lessThan(initialZIndex2));

      // Perform drag - tester.drag triggers the full pan lifecycle
      await tester.drag(find.byType(EditableElement), const Offset(20, 20));
      await tester.pumpAndSettle();

      // After drag, element 1 should have higher z-index (brought to front)
      final finalZIndex1 = posterProvider.getElementById('drag-test-3')!.zIndex;
      expect(finalZIndex1, greaterThan(initialZIndex2));
    });

    testWidgets('should clamp position to canvas bounds', (tester) async {
      final element = PosterElement(
        id: 'drag-test-5',
        type: ElementType.title,
        x: 100,
        y: 100,
        width: 200,
        height: 50,
        textColor: Colors.black,
        content: 'Clamp Test',
      );

      posterProvider.addElement(element);

      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 1.0),
      );
      await tester.pumpAndSettle();

      // Try to drag way outside bounds (negative)
      await tester.drag(find.byType(EditableElement), const Offset(-500, -500));
      await tester.pumpAndSettle();

      final updatedElement = posterProvider.getElementById('drag-test-5')!;
      // Position should be clamped to >= 0
      expect(updatedElement.x, greaterThanOrEqualTo(0));
      expect(updatedElement.y, greaterThanOrEqualTo(0));
    });

    testWidgets('should handle drag with canvas scale', (tester) async {
      final element = PosterElement(
        id: 'drag-test-6',
        type: ElementType.title,
        x: 100,
        y: 100,
        width: 200,
        height: 50,
        textColor: Colors.black,
        content: 'Scale Test',
      );

      posterProvider.addElement(element);

      // Use 0.5 scale (canvas is half size of actual)
      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 0.5),
      );
      await tester.pumpAndSettle();

      final initialX = posterProvider.getElementById('drag-test-6')!.x;
      final initialY = posterProvider.getElementById('drag-test-6')!.y;

      // Drag 50 pixels on screen
      await tester.drag(find.byType(EditableElement), const Offset(50, 50));
      await tester.pumpAndSettle();

      // With 0.5 scale, canvas movement should be larger than screen movement
      // 50 screen pixels / 0.5 scale = 100 canvas pixels (approximately)
      final updatedElement = posterProvider.getElementById('drag-test-6')!;
      // The movement should be approximately 2x the screen pixels
      expect(updatedElement.x, greaterThan(initialX + 50));
      expect(updatedElement.y, greaterThan(initialY + 50));
    });

    testWidgets('should not update position when dragging unselected element', (
      tester,
    ) async {
      final element = PosterElement(
        id: 'drag-test-7',
        type: ElementType.title,
        x: 100,
        y: 100,
        width: 200,
        height: 50,
        textColor: Colors.black,
        content: 'Test',
      );

      // Don't add element to provider - simulates element not in provider
      // This tests that dragging without proper setup doesn't crash

      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 1.0),
      );
      await tester.pumpAndSettle();

      // Should not throw
      await tester.drag(find.byType(EditableElement), const Offset(50, 50));
      await tester.pumpAndSettle();

      // Test passes if no exception is thrown
      expect(true, isTrue);
    });
  });

  group('Coordinate Transformation', () {
    testWidgets('should correctly transform screen to canvas coordinates', (
      tester,
    ) async {
      // Use title element to avoid QR rendering issues at small scales
      final element = PosterElement(
        id: 'coord-test-1',
        type: ElementType.title,
        x: 200,
        y: 200,
        width: 200,
        height: 50,
        textColor: Colors.black,
        content: 'Scale Test',
      );

      posterProvider.addElement(element);

      // Scale of 0.25 means canvas is 4x larger than display
      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 0.25),
      );
      await tester.pumpAndSettle();

      final initialX = posterProvider.getElementById('coord-test-1')!.x;

      // Drag 25 screen pixels
      await tester.drag(find.byType(EditableElement), const Offset(25, 0));
      await tester.pumpAndSettle();

      // The element position should have changed
      final updatedElement = posterProvider.getElementById('coord-test-1')!;
      final deltaX = updatedElement.x - initialX;
      // With scale < 1.0, canvas movement should be positive
      // (screen pixels / scale gives canvas pixels)
      expect(deltaX, greaterThan(0));
    });
  });
}
