import 'dart:convert';
import 'dart:typed_data';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'export_service.dart';

/// Check if running on mobile browser
bool _isMobileBrowser() {
  final userAgent = web.window.navigator.userAgent.toLowerCase();
  return userAgent.contains('mobile') ||
      userAgent.contains('android') ||
      userAgent.contains('iphone') ||
      userAgent.contains('ipad');
}

/// Web implementation for saving image
Future<ExportResult> saveImage(Uint8List imageBytes, String filename) async {
  try {
    final isMobile = _isMobileBrowser();

    if (isMobile) {
      // Mobile: Try Web Share API first
      return await _tryShareOrFallback(imageBytes, filename);
    } else {
      // Desktop: use traditional download
      return _downloadFile(imageBytes, filename);
    }
  } catch (e) {
    return ExportResult(
      success: false,
      message: 'Failed to download: ${e.toString()}',
    );
  }
}

/// Try Web Share API, fallback to data URL download
Future<ExportResult> _tryShareOrFallback(
    Uint8List imageBytes, String filename) async {
  try {
    // Create blob and file for sharing
    final blob = web.Blob(
      [imageBytes.toJS].toJS,
      web.BlobPropertyBag(type: 'image/png'),
    );

    final file = web.File(
      [blob].toJS,
      filename,
      web.FilePropertyBag(type: 'image/png'),
    );

    // Check if we can share files
    final shareData = web.ShareData(files: [file].toJS);

    if (web.window.navigator.canShare(shareData)) {
      // Share API available and can share files
      await web.window.navigator.share(shareData).toDart;
      return ExportResult(
        success: true,
        message: '포스터가 공유되었습니다!',
        filePath: filename,
      );
    } else {
      // Can't share files, use data URL approach
      return _downloadWithDataUrl(imageBytes, filename);
    }
  } catch (e) {
    // Share failed or was cancelled, try data URL approach
    return _downloadWithDataUrl(imageBytes, filename);
  }
}

/// Download using data URL (works better on some mobile browsers)
ExportResult _downloadWithDataUrl(Uint8List imageBytes, String filename) {
  try {
    // Convert to base64 data URL
    final base64 = base64Encode(imageBytes);
    final dataUrl = 'data:image/png;base64,$base64';

    // Create download link
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = dataUrl;
    anchor.download = filename;

    // For iOS Safari, we need to open in same window
    final userAgent = web.window.navigator.userAgent.toLowerCase();
    if (userAgent.contains('iphone') || userAgent.contains('ipad')) {
      // iOS: Open data URL directly (user can long-press to save)
      web.window.location.href = dataUrl;
      return ExportResult(
        success: true,
        message: '이미지가 열렸습니다. 길게 눌러 저장하세요.',
        filePath: filename,
      );
    }

    // Android and others: try anchor click
    web.document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    return ExportResult(
      success: true,
      message: '포스터가 다운로드되었습니다!',
      filePath: filename,
    );
  } catch (e) {
    return ExportResult(
      success: false,
      message: 'Failed to download: ${e.toString()}',
    );
  }
}

/// Traditional download for desktop browsers
ExportResult _downloadFile(Uint8List imageBytes, String filename) {
  try {
    final blob = web.Blob(
      [imageBytes.toJS].toJS,
      web.BlobPropertyBag(type: 'image/png'),
    );
    final url = web.URL.createObjectURL(blob);

    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = filename;
    anchor.style.display = 'none';

    web.document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    web.URL.revokeObjectURL(url);

    return ExportResult(
      success: true,
      message: '포스터가 다운로드되었습니다!',
      filePath: filename,
    );
  } catch (e) {
    return ExportResult(
      success: false,
      message: 'Failed to download: ${e.toString()}',
    );
  }
}
