import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrwifi/models/poster_element.dart';
import 'package:qrwifi/providers/poster_provider.dart';

void main() {
  group('PosterProvider Editor Features', () {
    late PosterProvider provider;

    setUp(() {
      provider = PosterProvider();
      // Set up basic WiFi config for testing
      provider.setSsid('TestNetwork');
      provider.setPassword('TestPassword123');
    });

    group('elements initialization', () {
      test('should have empty elements list initially', () {
        expect(provider.elements, isEmpty);
      });

      test('should initialize elements from current config', () {
        provider.initializeElements();

        expect(provider.elements, isNotEmpty);
      });

      test('should create title element', () {
        provider.initializeElements();

        final titleElement = provider.elements.firstWhere(
          (e) => e.type == ElementType.title,
          orElse: () => throw Exception('Title element not found'),
        );

        expect(titleElement, isNotNull);
        expect(titleElement.type, ElementType.title);
      });

      test('should create qrCode element', () {
        provider.initializeElements();

        final qrElement = provider.elements.firstWhere(
          (e) => e.type == ElementType.qrCode,
          orElse: () => throw Exception('QR element not found'),
        );

        expect(qrElement, isNotNull);
        expect(qrElement.type, ElementType.qrCode);
        // QR code should be square
        expect(qrElement.width, qrElement.height);
      });

      test('should create wifiIcon element', () {
        provider.initializeElements();

        final iconElement = provider.elements.firstWhere(
          (e) => e.type == ElementType.wifiIcon,
          orElse: () => throw Exception('WiFi icon element not found'),
        );

        expect(iconElement, isNotNull);
      });

      test('should create message element when message is set', () {
        provider.setCustomMessage('Scan to connect');
        provider.initializeElements();

        final messageElement = provider.elements.firstWhere(
          (e) => e.type == ElementType.message,
          orElse: () => throw Exception('Message element not found'),
        );

        expect(messageElement, isNotNull);
        expect(messageElement.content, 'Scan to connect');
      });

      test(
        'should create ssidPassword element when showPasswordOnPoster is true',
        () {
          provider.setShowPasswordOnPoster(true);
          provider.initializeElements();

          final ssidPwElement = provider.elements.firstWhere(
            (e) => e.type == ElementType.ssidPassword,
            orElse: () => throw Exception('SSID/Password element not found'),
          );

          expect(ssidPwElement, isNotNull);
        },
      );

      test('should create signature element when signature is set', () {
        provider.setSignatureText('My Cafe');
        provider.initializeElements();

        final signatureElement = provider.elements.firstWhere(
          (e) => e.type == ElementType.signature,
          orElse: () => throw Exception('Signature element not found'),
        );

        expect(signatureElement, isNotNull);
        expect(signatureElement.content, 'My Cafe');
      });

      test('should use template colors for elements', () {
        provider.initializeElements();

        final titleElement = provider.elements.firstWhere(
          (e) => e.type == ElementType.title,
        );

        expect(titleElement.textColor, provider.selectedTemplate.textColor);
      });
    });

    group('element selection', () {
      setUp(() {
        provider.initializeElements();
      });

      test('should have no selected element initially', () {
        expect(provider.selectedElement, isNull);
        expect(provider.hasSelectedElement, false);
      });

      test('should select element by id', () {
        final firstElement = provider.elements.first;
        provider.selectElement(firstElement.id);

        expect(provider.selectedElement, isNotNull);
        expect(provider.selectedElement!.id, firstElement.id);
        expect(provider.hasSelectedElement, true);
      });

      test('should deselect element', () {
        final firstElement = provider.elements.first;
        provider.selectElement(firstElement.id);
        provider.deselectElement();

        expect(provider.selectedElement, isNull);
        expect(provider.hasSelectedElement, false);
      });

      test('should return null for non-existent element id', () {
        provider.selectElement('non-existent-id');

        expect(provider.selectedElement, isNull);
      });
    });

    group('element position update', () {
      setUp(() {
        provider.initializeElements();
      });

      test('should update element position', () {
        final element = provider.elements.first;
        final originalX = element.x;
        final originalY = element.y;

        provider.updateElementPosition(element.id, 500, 600);

        final updated = provider.elements.firstWhere((e) => e.id == element.id);
        expect(updated.x, 500);
        expect(updated.y, 600);
        expect(updated.x, isNot(originalX));
        expect(updated.y, isNot(originalY));
      });

      test('should clamp position to canvas bounds', () {
        final element = provider.elements.first;

        // Try to set negative position
        provider.updateElementPosition(element.id, -100, -100);

        final updated = provider.elements.firstWhere((e) => e.id == element.id);
        expect(updated.x, greaterThanOrEqualTo(0));
        expect(updated.y, greaterThanOrEqualTo(0));
      });

      test('should clamp position to not exceed canvas width', () {
        final element = provider.elements.first;
        final canvasWidth = provider.selectedSize.widthPx;

        provider.updateElementPosition(element.id, canvasWidth + 100, 0);

        final updated = provider.elements.firstWhere((e) => e.id == element.id);
        expect(updated.x + updated.width, lessThanOrEqualTo(canvasWidth));
      });

      test('should notify listeners on position update', () {
        final element = provider.elements.first;
        bool notified = false;
        provider.addListener(() => notified = true);

        provider.updateElementPosition(element.id, 100, 100);

        expect(notified, true);
      });
    });

    group('element size update', () {
      setUp(() {
        provider.initializeElements();
      });

      test('should update element size', () {
        final element = provider.elements.first;

        provider.updateElementSize(element.id, 400, 100);

        final updated = provider.elements.firstWhere((e) => e.id == element.id);
        expect(updated.width, 400);
        expect(updated.height, 100);
      });

      test('should enforce minimum size', () {
        final element = provider.elements.first;

        provider.updateElementSize(element.id, 10, 10);

        final updated = provider.elements.firstWhere((e) => e.id == element.id);
        expect(
          updated.width,
          greaterThanOrEqualTo(PosterProvider.minElementSize),
        );
        expect(
          updated.height,
          greaterThanOrEqualTo(PosterProvider.minElementSize),
        );
      });

      test('should maintain aspect ratio for QR code', () {
        provider.initializeElements();
        final qrElement = provider.elements.firstWhere(
          (e) => e.type == ElementType.qrCode,
        );

        provider.updateElementSize(qrElement.id, 500, 300);

        final updated = provider.elements.firstWhere(
          (e) => e.id == qrElement.id,
        );
        // QR code should remain square (use larger dimension)
        expect(updated.width, updated.height);
      });
    });

    group('z-order management', () {
      setUp(() {
        provider.initializeElements();
      });

      test('should bring element to front', () {
        final elements = provider.elements;
        final firstElement = elements.first;
        final maxZIndex = elements
            .map((e) => e.zIndex)
            .reduce((a, b) => a > b ? a : b);

        provider.bringToFront(firstElement.id);

        final updated = provider.elements.firstWhere(
          (e) => e.id == firstElement.id,
        );
        expect(updated.zIndex, greaterThan(maxZIndex));
      });

      test('should update z-order after position change', () {
        final elements = provider.elements;
        final firstElement = elements.first;
        final initialZIndex = firstElement.zIndex;

        provider.updateElementPosition(firstElement.id, 100, 100);
        provider.bringToFront(firstElement.id);

        final updated = provider.elements.firstWhere(
          (e) => e.id == firstElement.id,
        );
        expect(updated.zIndex, greaterThan(initialZIndex));
      });

      test('elements should be sortable by z-index', () {
        // Bring different elements to front in sequence
        for (final element in provider.elements) {
          provider.bringToFront(element.id);
        }

        final sortedElements = provider.sortedElements;
        for (int i = 1; i < sortedElements.length; i++) {
          expect(
            sortedElements[i].zIndex,
            greaterThanOrEqualTo(sortedElements[i - 1].zIndex),
          );
        }
      });
    });

    group('element style update', () {
      setUp(() {
        provider.initializeElements();
      });

      test('should update text color', () {
        final titleElement = provider.elements.firstWhere(
          (e) => e.type == ElementType.title,
        );

        provider.updateElementStyle(titleElement.id, textColor: Colors.red);

        final updated = provider.elements.firstWhere(
          (e) => e.id == titleElement.id,
        );
        expect(updated.textColor, Colors.red);
      });

      test('should update font family', () {
        final titleElement = provider.elements.firstWhere(
          (e) => e.type == ElementType.title,
        );

        provider.updateElementStyle(titleElement.id, fontFamily: 'nanum');

        final updated = provider.elements.firstWhere(
          (e) => e.id == titleElement.id,
        );
        expect(updated.fontFamily, 'nanum');
      });

      test('should update QR colors', () {
        final qrElement = provider.elements.firstWhere(
          (e) => e.type == ElementType.qrCode,
        );

        provider.updateElementStyle(
          qrElement.id,
          textColor: Colors.blue, // QR foreground
          backgroundColor: Colors.yellow, // QR background
        );

        final updated = provider.elements.firstWhere(
          (e) => e.id == qrElement.id,
        );
        expect(updated.textColor, Colors.blue);
        expect(updated.backgroundColor, Colors.yellow);
      });
    });

    group('editor mode', () {
      test('should track editor mode state', () {
        expect(provider.isEditorMode, false);

        provider.setEditorMode(true);
        expect(provider.isEditorMode, true);

        provider.setEditorMode(false);
        expect(provider.isEditorMode, false);
      });

      test('should clear elements when exiting editor mode', () {
        provider.initializeElements();
        expect(provider.elements, isNotEmpty);

        provider.setEditorMode(false);
        provider.clearElements();

        expect(provider.elements, isEmpty);
      });
    });

    group('element by id', () {
      setUp(() {
        provider.initializeElements();
      });

      test('should get element by id', () {
        final firstElement = provider.elements.first;

        final found = provider.getElementById(firstElement.id);

        expect(found, isNotNull);
        expect(found!.id, firstElement.id);
      });

      test('should return null for non-existent id', () {
        final found = provider.getElementById('non-existent');

        expect(found, isNull);
      });
    });
  });
}
