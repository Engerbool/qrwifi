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
            width: 800,
            height: 1000,
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

  group('Resize Handles', () {
    testWidgets('should show 8 resize handles when element is selected', (
      tester,
    ) async {
      final element = PosterElement(
        id: 'resize-test-1',
        type: ElementType.title,
        x: 100,
        y: 100,
        width: 200,
        height: 100,
        textColor: Colors.black,
        content: 'Resize Me',
      );

      posterProvider.addElement(element);

      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 1.0, isSelected: true),
      );
      await tester.pumpAndSettle();

      // Should show 8 resize handles (4 corners + 4 edges)
      // Handles are small containers with specific keys
      expect(find.byKey(const Key('handle-topLeft')), findsOneWidget);
      expect(find.byKey(const Key('handle-topCenter')), findsOneWidget);
      expect(find.byKey(const Key('handle-topRight')), findsOneWidget);
      expect(find.byKey(const Key('handle-centerLeft')), findsOneWidget);
      expect(find.byKey(const Key('handle-centerRight')), findsOneWidget);
      expect(find.byKey(const Key('handle-bottomLeft')), findsOneWidget);
      expect(find.byKey(const Key('handle-bottomCenter')), findsOneWidget);
      expect(find.byKey(const Key('handle-bottomRight')), findsOneWidget);
    });

    testWidgets('should not show resize handles when element is not selected', (
      tester,
    ) async {
      final element = PosterElement(
        id: 'resize-test-2',
        type: ElementType.title,
        x: 100,
        y: 100,
        width: 200,
        height: 100,
        textColor: Colors.black,
        content: 'Test',
      );

      posterProvider.addElement(element);

      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 1.0, isSelected: false),
      );
      await tester.pumpAndSettle();

      // Should not show any resize handles
      expect(find.byKey(const Key('handle-topLeft')), findsNothing);
      expect(find.byKey(const Key('handle-bottomRight')), findsNothing);
    });

    testWidgets('should resize element when dragging bottom-right handle', (
      tester,
    ) async {
      final element = PosterElement(
        id: 'resize-test-3',
        type: ElementType.title,
        x: 100,
        y: 100,
        width: 200,
        height: 100,
        textColor: Colors.black,
        content: 'Resize Me',
      );

      posterProvider.addElement(element);

      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 1.0, isSelected: true),
      );
      await tester.pumpAndSettle();

      final initialWidth = posterProvider
          .getElementById('resize-test-3')!
          .width;
      final initialHeight = posterProvider
          .getElementById('resize-test-3')!
          .height;

      // Drag bottom-right handle to increase size
      final handleFinder = find.byKey(const Key('handle-bottomRight'));
      await tester.drag(handleFinder, const Offset(50, 30));
      await tester.pumpAndSettle();

      final updatedElement = posterProvider.getElementById('resize-test-3')!;
      expect(updatedElement.width, greaterThan(initialWidth));
      expect(updatedElement.height, greaterThan(initialHeight));
    });

    testWidgets('should resize element when dragging top-left handle', (
      tester,
    ) async {
      final element = PosterElement(
        id: 'resize-test-4',
        type: ElementType.title,
        x: 200,
        y: 200,
        width: 200,
        height: 100,
        textColor: Colors.black,
        content: 'Resize Me',
      );

      posterProvider.addElement(element);

      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 1.0, isSelected: true),
      );
      await tester.pumpAndSettle();

      final initialX = posterProvider.getElementById('resize-test-4')!.x;
      final initialY = posterProvider.getElementById('resize-test-4')!.y;
      final initialWidth = posterProvider
          .getElementById('resize-test-4')!
          .width;
      final initialHeight = posterProvider
          .getElementById('resize-test-4')!
          .height;

      // Drag top-left handle to resize (moves position and changes size)
      final handleFinder = find.byKey(const Key('handle-topLeft'));
      await tester.drag(handleFinder, const Offset(-30, -20));
      await tester.pumpAndSettle();

      final updatedElement = posterProvider.getElementById('resize-test-4')!;
      // Top-left drag should move position and increase size
      expect(updatedElement.x, lessThan(initialX));
      expect(updatedElement.y, lessThan(initialY));
      expect(updatedElement.width, greaterThan(initialWidth));
      expect(updatedElement.height, greaterThan(initialHeight));
    });

    testWidgets('should only change width when dragging right edge handle', (
      tester,
    ) async {
      final element = PosterElement(
        id: 'resize-test-5',
        type: ElementType.title,
        x: 100,
        y: 100,
        width: 200,
        height: 100,
        textColor: Colors.black,
        content: 'Resize Me',
      );

      posterProvider.addElement(element);

      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 1.0, isSelected: true),
      );
      await tester.pumpAndSettle();

      final initialWidth = posterProvider
          .getElementById('resize-test-5')!
          .width;
      final initialHeight = posterProvider
          .getElementById('resize-test-5')!
          .height;

      // Drag right center handle (should only change width)
      final handleFinder = find.byKey(const Key('handle-centerRight'));
      await tester.drag(handleFinder, const Offset(50, 0));
      await tester.pumpAndSettle();

      final updatedElement = posterProvider.getElementById('resize-test-5')!;
      expect(updatedElement.width, greaterThan(initialWidth));
      // Height should remain approximately the same
      expect(updatedElement.height, closeTo(initialHeight, 1.0));
    });

    testWidgets('should only change height when dragging bottom edge handle', (
      tester,
    ) async {
      final element = PosterElement(
        id: 'resize-test-6',
        type: ElementType.title,
        x: 100,
        y: 100,
        width: 200,
        height: 100,
        textColor: Colors.black,
        content: 'Resize Me',
      );

      posterProvider.addElement(element);

      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 1.0, isSelected: true),
      );
      await tester.pumpAndSettle();

      final initialWidth = posterProvider
          .getElementById('resize-test-6')!
          .width;
      final initialHeight = posterProvider
          .getElementById('resize-test-6')!
          .height;

      // Drag bottom center handle (should only change height)
      final handleFinder = find.byKey(const Key('handle-bottomCenter'));
      await tester.drag(handleFinder, const Offset(0, 50));
      await tester.pumpAndSettle();

      final updatedElement = posterProvider.getElementById('resize-test-6')!;
      // Width should remain approximately the same
      expect(updatedElement.width, closeTo(initialWidth, 1.0));
      expect(updatedElement.height, greaterThan(initialHeight));
    });

    testWidgets('should enforce minimum size when resizing', (tester) async {
      final element = PosterElement(
        id: 'resize-test-7',
        type: ElementType.title,
        x: 100,
        y: 100,
        width: 100,
        height: 50,
        textColor: Colors.black,
        content: 'Min Size Test',
      );

      posterProvider.addElement(element);

      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 1.0, isSelected: true),
      );
      await tester.pumpAndSettle();

      // Try to make element very small by dragging bottom-right towards top-left
      final handleFinder = find.byKey(const Key('handle-bottomRight'));
      await tester.drag(handleFinder, const Offset(-200, -200));
      await tester.pumpAndSettle();

      final updatedElement = posterProvider.getElementById('resize-test-7')!;
      // Should enforce minimum size (e.g., 30x30)
      expect(updatedElement.width, greaterThanOrEqualTo(30));
      expect(updatedElement.height, greaterThanOrEqualTo(30));
    });

    testWidgets('should maintain aspect ratio for QR code element', (
      tester,
    ) async {
      final element = PosterElement(
        id: 'resize-test-8',
        type: ElementType.qrCode,
        x: 100,
        y: 100,
        width: 200,
        height: 200,
        textColor: Colors.black,
        backgroundColor: Colors.white,
      );

      posterProvider.addElement(element);

      // Use larger scale to avoid negative QR size
      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 0.5, isSelected: true),
      );
      await tester.pumpAndSettle();

      // Drag corner handle
      final handleFinder = find.byKey(const Key('handle-bottomRight'));
      await tester.drag(handleFinder, const Offset(50, 30));
      await tester.pumpAndSettle();

      final updatedElement = posterProvider.getElementById('resize-test-8')!;
      // QR code should remain square (width == height)
      expect(updatedElement.width, closeTo(updatedElement.height, 1.0));
    });

    testWidgets('should handle resize with canvas scale', (tester) async {
      final element = PosterElement(
        id: 'resize-test-9',
        type: ElementType.title,
        x: 100,
        y: 100,
        width: 200,
        height: 100,
        textColor: Colors.black,
        content: 'Scale Test',
      );

      posterProvider.addElement(element);

      // Use 0.5 scale
      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 0.5, isSelected: true),
      );
      await tester.pumpAndSettle();

      final initialWidth = posterProvider
          .getElementById('resize-test-9')!
          .width;

      // Drag handle by 25 screen pixels
      final handleFinder = find.byKey(const Key('handle-centerRight'));
      await tester.drag(handleFinder, const Offset(25, 0));
      await tester.pumpAndSettle();

      final updatedElement = posterProvider.getElementById('resize-test-9')!;
      // With 0.5 scale, canvas change should be larger than screen pixels
      // 25 screen pixels / 0.5 scale = 50 canvas pixels
      expect(updatedElement.width, greaterThan(initialWidth + 25));
    });
  });
}
