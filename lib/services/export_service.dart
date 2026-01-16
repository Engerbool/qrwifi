import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../config/constants.dart';

// Conditional imports for platform-specific code
import 'export_service_stub.dart'
    if (dart.library.html) 'export_service_web.dart'
    if (dart.library.io) 'export_service_mobile.dart'
    as platform;

/// Result of export operation
class ExportResult {
  final bool success;
  final String message;
  final String? filePath;

  ExportResult({required this.success, required this.message, this.filePath});
}

/// Service for exporting poster as image
class ExportService {
  ExportService._();

  /// Export poster widget to image and save
  static Future<ExportResult> exportPoster(
    GlobalKey posterKey,
    PosterSize size,
  ) async {
    try {
      // Capture widget as image using selected size dimensions
      final imageBytes = await _captureWidgetAsImage(posterKey, size);

      if (imageBytes == null) {
        return ExportResult(
          success: false,
          message: 'Failed to capture poster image',
        );
      }

      // Save using platform-specific implementation
      return await platform.saveImage(imageBytes, generateFilename(size));
    } catch (e) {
      return ExportResult(
        success: false,
        message: 'Export failed: ${e.toString()}',
      );
    }
  }

  /// Capture widget as PNG image bytes
  static Future<Uint8List?> _captureWidgetAsImage(
    GlobalKey key,
    PosterSize size,
  ) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        debugPrint('ExportService: RenderRepaintBoundary not found');
        return null;
      }

      // Calculate pixel ratio for high-quality output using selected size
      final targetWidth = size.widthPx;
      final currentWidth = boundary.size.width;
      final pixelRatio = targetWidth / currentWidth;

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('ExportService: Error capturing image: $e');
      return null;
    }
  }

  /// Generate filename for export (includes size type)
  static String generateFilename(PosterSize size) {
    final now = DateTime.now();
    final timestamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    return 'wifi_${size.id}_$timestamp.png';
  }
}
