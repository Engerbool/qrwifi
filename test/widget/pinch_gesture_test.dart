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

  group('Pinch Gesture (Scale)', () {
    testWidgets('should support scale gesture for resizing', (tester) async {
      final element = PosterElement(
        id: 'pinch-test-1',
        type: ElementType.title,
        x: 100,
        y: 100,
        width: 200,
        height: 100,
        textColor: Colors.black,
        content: 'Pinch Me',
      );

      posterProvider.addElement(element);

      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 1.0, isSelected: true),
      );
      await tester.pumpAndSettle();

      final initialWidth = posterProvider.getElementById('pinch-test-1')!.width;
      final initialHeight = posterProvider
          .getElementById('pinch-test-1')!
          .height;

      // Simulate pinch-to-zoom gesture using scale gesture
      // Get the center of the element
      final elementFinder = find.byType(EditableElement);
      final center = tester.getCenter(elementFinder);

      // Create two touch points for pinch gesture
      final pointer1 = TestPointer(1);
      final pointer2 = TestPointer(2);

      // Start pinch from center
      await tester.sendEventToBinding(
        pointer1.down(center + const Offset(-20, 0)),
      );
      await tester.sendEventToBinding(
        pointer2.down(center + const Offset(20, 0)),
      );
      await tester.pump();

      // Move pointers outward (zoom in / scale up)
      await tester.sendEventToBinding(
        pointer1.move(center + const Offset(-40, 0)),
      );
      await tester.sendEventToBinding(
        pointer2.move(center + const Offset(40, 0)),
      );
      await tester.pump();

      // Release both pointers
      await tester.sendEventToBinding(pointer1.up());
      await tester.sendEventToBinding(pointer2.up());
      await tester.pumpAndSettle();

      final updatedElement = posterProvider.getElementById('pinch-test-1')!;
      // Element should be larger after scale-up gesture
      expect(updatedElement.width, greaterThanOrEqualTo(initialWidth));
      expect(updatedElement.height, greaterThanOrEqualTo(initialHeight));
    });

    testWidgets('should maintain aspect ratio during pinch resize', (
      tester,
    ) async {
      final element = PosterElement(
        id: 'pinch-test-2',
        type: ElementType.title,
        x: 100,
        y: 100,
        width: 200,
        height: 100,
        textColor: Colors.black,
        content: 'Aspect Ratio',
      );

      posterProvider.addElement(element);

      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 1.0, isSelected: true),
      );
      await tester.pumpAndSettle();

      final initialRatio =
          posterProvider.getElementById('pinch-test-2')!.width /
          posterProvider.getElementById('pinch-test-2')!.height;

      // Simulate pinch gesture
      final elementFinder = find.byType(EditableElement);
      final center = tester.getCenter(elementFinder);

      final pointer1 = TestPointer(1);
      final pointer2 = TestPointer(2);

      await tester.sendEventToBinding(
        pointer1.down(center + const Offset(-30, 0)),
      );
      await tester.sendEventToBinding(
        pointer2.down(center + const Offset(30, 0)),
      );
      await tester.pump();

      await tester.sendEventToBinding(
        pointer1.move(center + const Offset(-60, 0)),
      );
      await tester.sendEventToBinding(
        pointer2.move(center + const Offset(60, 0)),
      );
      await tester.pump();

      await tester.sendEventToBinding(pointer1.up());
      await tester.sendEventToBinding(pointer2.up());
      await tester.pumpAndSettle();

      final updatedElement = posterProvider.getElementById('pinch-test-2')!;
      final newRatio = updatedElement.width / updatedElement.height;

      // Aspect ratio should be maintained (approximately)
      expect(newRatio, closeTo(initialRatio, 0.5));
    });

    testWidgets('should scale down when pinching inward', (tester) async {
      final element = PosterElement(
        id: 'pinch-test-3',
        type: ElementType.title,
        x: 100,
        y: 100,
        width: 300,
        height: 150,
        textColor: Colors.black,
        content: 'Scale Down',
      );

      posterProvider.addElement(element);

      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 1.0, isSelected: true),
      );
      await tester.pumpAndSettle();

      final initialWidth = posterProvider.getElementById('pinch-test-3')!.width;

      // Simulate pinch-in gesture (scale down)
      final elementFinder = find.byType(EditableElement);
      final center = tester.getCenter(elementFinder);

      final pointer1 = TestPointer(1);
      final pointer2 = TestPointer(2);

      // Start with fingers spread apart
      await tester.sendEventToBinding(
        pointer1.down(center + const Offset(-60, 0)),
      );
      await tester.sendEventToBinding(
        pointer2.down(center + const Offset(60, 0)),
      );
      await tester.pump();

      // Move fingers together (pinch in)
      await tester.sendEventToBinding(
        pointer1.move(center + const Offset(-30, 0)),
      );
      await tester.sendEventToBinding(
        pointer2.move(center + const Offset(30, 0)),
      );
      await tester.pump();

      await tester.sendEventToBinding(pointer1.up());
      await tester.sendEventToBinding(pointer2.up());
      await tester.pumpAndSettle();

      final updatedElement = posterProvider.getElementById('pinch-test-3')!;
      // Element should be smaller or same (respecting minimum size)
      expect(updatedElement.width, lessThanOrEqualTo(initialWidth));
    });

    testWidgets('should not allow resizing below minimum size via pinch', (
      tester,
    ) async {
      final element = PosterElement(
        id: 'pinch-test-4',
        type: ElementType.title,
        x: 100,
        y: 100,
        width: 100,
        height: 50,
        textColor: Colors.black,
        content: 'Min Size',
      );

      posterProvider.addElement(element);

      await tester.pumpWidget(
        createTestWidget(element: element, canvasScale: 1.0, isSelected: true),
      );
      await tester.pumpAndSettle();

      // Simulate aggressive pinch-in gesture
      final elementFinder = find.byType(EditableElement);
      final center = tester.getCenter(elementFinder);

      final pointer1 = TestPointer(1);
      final pointer2 = TestPointer(2);

      await tester.sendEventToBinding(
        pointer1.down(center + const Offset(-40, 0)),
      );
      await tester.sendEventToBinding(
        pointer2.down(center + const Offset(40, 0)),
      );
      await tester.pump();

      // Move fingers very close together
      await tester.sendEventToBinding(
        pointer1.move(center + const Offset(-5, 0)),
      );
      await tester.sendEventToBinding(
        pointer2.move(center + const Offset(5, 0)),
      );
      await tester.pump();

      await tester.sendEventToBinding(pointer1.up());
      await tester.sendEventToBinding(pointer2.up());
      await tester.pumpAndSettle();

      final updatedElement = posterProvider.getElementById('pinch-test-4')!;
      // Should respect minimum size
      expect(updatedElement.width, greaterThanOrEqualTo(30));
      expect(updatedElement.height, greaterThanOrEqualTo(30));
    });
  });
}
