import 'dart:typed_data';
import 'export_service.dart';

/// Stub implementation - should never be called
Future<ExportResult> saveImage(Uint8List imageBytes, String filename) async {
  return ExportResult(
    success: false,
    message: 'Platform not supported',
  );
}
