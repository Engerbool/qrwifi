import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qrwifi/models/poster_element.dart';
import 'package:qrwifi/providers/poster_provider.dart';
import 'package:qrwifi/providers/locale_provider.dart';
import 'package:qrwifi/providers/theme_provider.dart';
import 'package:qrwifi/screens/preview_screen.dart';
import 'package:qrwifi/screens/canvas_editor_screen.dart';
import 'package:qrwifi/widgets/property_panel.dart';
import 'package:qrwifi/config/routes.dart';

void main() {
  late PosterProvider posterProvider;
  late LocaleProvider localeProvider;
  late ThemeProvider themeProvider;

  setUp(() {
    posterProvider = PosterProvider();
    posterProvider.setSsid('TestNetwork');
    posterProvider.setPassword('TestPassword123');
    localeProvider = LocaleProvider();
    themeProvider = ThemeProvider();
  });

  Widget createTestApp({String initialRoute = AppRoutes.preview}) {
    // Routes without SplashScreen to avoid timer issues in tests
    final testRoutes = <String, WidgetBuilder>{
      AppRoutes.preview: (context) => const PreviewScreen(),
      AppRoutes.canvasEditor: (context) => const CanvasEditorScreen(),
    };

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PosterProvider>.value(value: posterProvider),
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
      ],
      child: MaterialApp(initialRoute: initialRoute, routes: testRoutes),
    );
  }

  group('Navigation Flow', () {
    testWidgets('PreviewScreen should have edit layout button', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Should find edit layout button
      expect(find.byKey(const Key('edit-layout-button')), findsOneWidget);
    });

    testWidgets('should navigate from PreviewScreen to CanvasEditorScreen', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Tap edit layout button
      final editButton = find.byKey(const Key('edit-layout-button'));
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Should be on CanvasEditorScreen
      expect(find.byType(CanvasEditorScreen), findsOneWidget);
    });

    testWidgets(
      'should navigate from CanvasEditorScreen back to PreviewScreen',
      (tester) async {
        await tester.pumpWidget(createTestApp(initialRoute: AppRoutes.preview));
        await tester.pumpAndSettle();

        // Navigate to canvas editor
        final editButton = find.byKey(const Key('edit-layout-button'));
        await tester.tap(editButton);
        await tester.pumpAndSettle();

        // Tap done button (checkmark icon)
        final doneButton = find.byIcon(Icons.check_rounded);
        await tester.tap(doneButton);
        await tester.pumpAndSettle();

        // Should be back on PreviewScreen
        expect(find.byType(PreviewScreen), findsOneWidget);
      },
    );

    testWidgets('should initialize elements when entering CanvasEditorScreen', (
      tester,
    ) async {
      // Elements should be empty initially
      expect(posterProvider.elements, isEmpty);

      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to canvas editor
      final editButton = find.byKey(const Key('edit-layout-button'));
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Elements should be initialized
      expect(posterProvider.elements, isNotEmpty);
    });

    testWidgets('should preserve element changes after navigating back', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to canvas editor
      final editButton = find.byKey(const Key('edit-layout-button'));
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Get initial position of an element
      final qrElement = posterProvider.getElementById('qr-code');
      expect(qrElement, isNotNull);
      final initialX = qrElement!.x;

      // Modify element position
      posterProvider.updateElementPosition(
        'qr-code',
        initialX + 50,
        qrElement.y,
      );

      // Navigate back
      final doneButton = find.byIcon(Icons.check_rounded);
      await tester.tap(doneButton);
      await tester.pumpAndSettle();

      // Navigate to editor again
      final editButton2 = find.byKey(const Key('edit-layout-button'));
      await tester.tap(editButton2);
      await tester.pumpAndSettle();

      // Position should be preserved
      final updatedElement = posterProvider.getElementById('qr-code');
      expect(updatedElement?.x, equals(initialX + 50));
    });
  });

  group('Editor Mode State', () {
    testWidgets(
      'should set editor mode true when entering CanvasEditorScreen',
      (tester) async {
        expect(posterProvider.isEditorMode, isFalse);

        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Navigate to canvas editor
        final editButton = find.byKey(const Key('edit-layout-button'));
        await tester.tap(editButton);
        await tester.pumpAndSettle();

        expect(posterProvider.isEditorMode, isTrue);
      },
    );

    testWidgets(
      'should set editor mode false when exiting CanvasEditorScreen',
      (tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Navigate to canvas editor
        final editButton = find.byKey(const Key('edit-layout-button'));
        await tester.tap(editButton);
        await tester.pumpAndSettle();

        expect(posterProvider.isEditorMode, isTrue);

        // Navigate back
        final doneButton = find.byIcon(Icons.check_rounded);
        await tester.tap(doneButton);
        await tester.pumpAndSettle();

        expect(posterProvider.isEditorMode, isFalse);
      },
    );

    testWidgets('should deselect element when exiting CanvasEditorScreen', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Navigate to canvas editor
      final editButton = find.byKey(const Key('edit-layout-button'));
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Select an element
      posterProvider.selectElement('qr-code');
      expect(posterProvider.hasSelectedElement, isTrue);

      // Navigate back
      final doneButton = find.byIcon(Icons.check_rounded);
      await tester.tap(doneButton);
      await tester.pumpAndSettle();

      // Should be deselected
      expect(posterProvider.hasSelectedElement, isFalse);
    });
  });

  group('PropertyPanel Integration', () {
    testWidgets('PropertyPanel should show when element is selected', (
      tester,
    ) async {
      // Add and select an element
      final element = PosterElement(
        id: 'test-title',
        type: ElementType.title,
        x: 100,
        y: 100,
        width: 200,
        height: 50,
        textColor: Colors.black,
        content: 'Test',
      );
      posterProvider.addElement(element);
      posterProvider.selectElement('test-title');

      // Build just the PropertyPanel widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<PosterProvider>.value(value: posterProvider),
            ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
          ],
          child: const MaterialApp(home: Scaffold(body: PropertyPanel())),
        ),
      );
      await tester.pumpAndSettle();

      // PropertyPanel should be visible
      expect(find.byKey(const Key('property-panel-content')), findsOneWidget);
    });

    testWidgets('PropertyPanel should hide when element is deselected', (
      tester,
    ) async {
      // Build PropertyPanel without selected element
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<PosterProvider>.value(value: posterProvider),
            ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
          ],
          child: const MaterialApp(home: Scaffold(body: PropertyPanel())),
        ),
      );
      await tester.pumpAndSettle();

      // PropertyPanel should be hidden (no selected element)
      expect(find.byKey(const Key('property-panel-content')), findsNothing);
    });
  });
}
