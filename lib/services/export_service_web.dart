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

/// Check if Web Share API is available and can share files
bool _canShareFiles() {
  try {
    // Check if navigator.canShare exists (indicates file sharing support)
    final navigator = web.window.navigator;
    // Use hasProperty check via JS interop
    return navigator.canShare(web.ShareData()) == true;
  } catch (e) {
    return false;
  }
}

/// Web implementation for saving image
Future<ExportResult> saveImage(Uint8List imageBytes, String filename) async {
  try {
    final isMobile = _isMobileBrowser();

    if (isMobile) {
      // For mobile: try Web Share API first, then fallback to new tab
      final canShare = _canShareFiles();

      if (canShare) {
        try {
          // Create a File object for sharing
          final blob = web.Blob(
            [imageBytes.toJS].toJS,
            web.BlobPropertyBag(type: 'image/png'),
          );

          final file = web.File(
            [blob].toJS,
            filename,
            web.FilePropertyBag(type: 'image/png'),
          );

          final shareData = web.ShareData(
            files: [file].toJS,
          );

          await web.window.navigator.share(shareData).toDart;

          return ExportResult(
            success: true,
            message: '포스터가 공유되었습니다!',
            filePath: filename,
          );
        } catch (e) {
          // Share was cancelled or failed, try fallback
          return _openInNewTab(imageBytes, filename);
        }
      } else {
        // No share API, open in new tab
        return _openInNewTab(imageBytes, filename);
      }
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

/// Fallback: open image in new tab for manual save
ExportResult _openInNewTab(Uint8List imageBytes, String filename) {
  try {
    final blob = web.Blob(
      [imageBytes.toJS].toJS,
      web.BlobPropertyBag(type: 'image/png'),
    );
    final url = web.URL.createObjectURL(blob);

    // Open in new tab
    web.window.open(url, '_blank');

    return ExportResult(
      success: true,
      message: '새 탭에서 이미지를 길게 눌러 저장하세요.',
      filePath: filename,
    );
  } catch (e) {
    return ExportResult(
      success: false,
      message: 'Failed to open image: ${e.toString()}',
    );
  }
}
