import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrwifi/models/poster_element.dart';

void main() {
  group('PosterElement', () {
    group('creation', () {
      test('should create element with required properties', () {
        final element = PosterElement(
          id: 'test-1',
          type: ElementType.title,
          x: 100,
          y: 200,
          width: 300,
          height: 50,
        );

        expect(element.id, 'test-1');
        expect(element.type, ElementType.title);
        expect(element.x, 100);
        expect(element.y, 200);
        expect(element.width, 300);
        expect(element.height, 50);
      });

      test('should have default zIndex of 0', () {
        final element = PosterElement(
          id: 'test-2',
          type: ElementType.qrCode,
          x: 0,
          y: 0,
          width: 100,
          height: 100,
        );

        expect(element.zIndex, 0);
      });

      test('should accept optional style properties', () {
        final element = PosterElement(
          id: 'test-3',
          type: ElementType.message,
          x: 50,
          y: 50,
          width: 200,
          height: 30,
          textColor: Colors.red,
          backgroundColor: Colors.white,
          fontFamily: 'Roboto',
          fontSize: 16,
          content: 'Test message',
        );

        expect(element.textColor, Colors.red);
        expect(element.backgroundColor, Colors.white);
        expect(element.fontFamily, 'Roboto');
        expect(element.fontSize, 16);
        expect(element.content, 'Test message');
      });
    });

    group('copyWith', () {
      late PosterElement original;

      setUp(() {
        original = PosterElement(
          id: 'original',
          type: ElementType.title,
          x: 100,
          y: 200,
          width: 300,
          height: 50,
          zIndex: 1,
          textColor: Colors.black,
          content: 'Original',
        );
      });

      test('should create copy with updated position', () {
        final updated = original.copyWith(x: 150, y: 250);

        expect(updated.id, original.id);
        expect(updated.type, original.type);
        expect(updated.x, 150);
        expect(updated.y, 250);
        expect(updated.width, original.width);
        expect(updated.height, original.height);
        expect(updated.zIndex, original.zIndex);
        expect(updated.textColor, original.textColor);
        expect(updated.content, original.content);
      });

      test('should create copy with updated size', () {
        final updated = original.copyWith(width: 400, height: 60);

        expect(updated.width, 400);
        expect(updated.height, 60);
        expect(updated.x, original.x);
        expect(updated.y, original.y);
      });

      test('should create copy with updated zIndex', () {
        final updated = original.copyWith(zIndex: 5);

        expect(updated.zIndex, 5);
      });

      test('should create copy with updated style', () {
        final updated = original.copyWith(
          textColor: Colors.blue,
          fontFamily: 'Arial',
          fontSize: 20,
        );

        expect(updated.textColor, Colors.blue);
        expect(updated.fontFamily, 'Arial');
        expect(updated.fontSize, 20);
      });

      test('should not modify original element', () {
        original.copyWith(x: 500, y: 600);

        expect(original.x, 100);
        expect(original.y, 200);
      });
    });

    group('ElementType', () {
      test('should have all required types', () {
        expect(ElementType.values, contains(ElementType.qrCode));
        expect(ElementType.values, contains(ElementType.title));
        expect(ElementType.values, contains(ElementType.message));
        expect(ElementType.values, contains(ElementType.ssidPassword));
        expect(ElementType.values, contains(ElementType.signature));
        expect(ElementType.values, contains(ElementType.wifiIcon));
      });
    });

    group('bounds', () {
      test('should calculate correct bounds rect', () {
        final element = PosterElement(
          id: 'bounds-test',
          type: ElementType.qrCode,
          x: 100,
          y: 200,
          width: 300,
          height: 300,
        );

        final bounds = element.bounds;

        expect(bounds.left, 100);
        expect(bounds.top, 200);
        expect(bounds.width, 300);
        expect(bounds.height, 300);
        expect(bounds.right, 400);
        expect(bounds.bottom, 500);
      });
    });

    group('center', () {
      test('should calculate correct center point', () {
        final element = PosterElement(
          id: 'center-test',
          type: ElementType.qrCode,
          x: 100,
          y: 200,
          width: 300,
          height: 300,
        );

        final center = element.center;

        expect(center.dx, 250); // 100 + 300/2
        expect(center.dy, 350); // 200 + 300/2
      });
    });

    group('isResizable', () {
      test('qrCode should maintain aspect ratio', () {
        final qr = PosterElement(
          id: 'qr',
          type: ElementType.qrCode,
          x: 0,
          y: 0,
          width: 100,
          height: 100,
        );

        expect(qr.maintainAspectRatio, true);
      });

      test('text elements should not require aspect ratio', () {
        final title = PosterElement(
          id: 'title',
          type: ElementType.title,
          x: 0,
          y: 0,
          width: 200,
          height: 50,
        );

        expect(title.maintainAspectRatio, false);
      });
    });
  });
}
