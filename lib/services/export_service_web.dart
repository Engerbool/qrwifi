import 'dart:convert';
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'export_service.dart';

/// Web implementation for saving image
Future<ExportResult> saveImage(Uint8List imageBytes) async {
  try {
    final filename = ExportService.generateFilename();

    // Create blob and download link
    final blob = html.Blob([imageBytes], 'image/png');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create and trigger download
    final anchor = html.AnchorElement()
      ..href = url
      ..download = filename
      ..style.display = 'none';

    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    // Cleanup
    html.Url.revokeObjectUrl(url);

    return ExportResult(
      success: true,
      message: 'Poster downloaded successfully!',
      filePath: filename,
    );
  } catch (e) {
    return ExportResult(
      success: false,
      message: 'Failed to download: ${e.toString()}',
    );
  }
}
