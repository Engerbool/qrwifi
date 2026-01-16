import 'dart:convert';
import 'dart:typed_data';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'export_service.dart';

/// Web implementation for saving image
Future<ExportResult> saveImage(Uint8List imageBytes, String filename) async {
  try {
    final userAgent = web.window.navigator.userAgent.toLowerCase();
    final isIOS = userAgent.contains('iphone') || userAgent.contains('ipad');
    final isAndroid = userAgent.contains('android');

    // In-app browsers (Kakao, Naver, Facebook, Instagram, etc.)
    final isInAppBrowser = userAgent.contains('kakaotalk') ||
        userAgent.contains('naver') ||
        userAgent.contains('fban') ||
        userAgent.contains('fbav') ||
        userAgent.contains('instagram');

    if (isIOS) {
      // iOS Safari: Share API works best
      return await _tryShareOrFallback(imageBytes, filename);
    } else if (isInAppBrowser) {
      // In-app browsers: Use Data URL (Blob URL doesn't work properly)
      return _downloadWithDataUrl(imageBytes, filename);
    } else if (isAndroid) {
      // Android Chrome/Samsung: Blob URL download
      return _downloadForAndroid(imageBytes, filename);
    } else {
      // Desktop: traditional download
      return _downloadFile(imageBytes, filename);
    }
  } catch (e) {
    return ExportResult(
      success: false,
      message: 'Failed to download: ${e.toString()}',
    );
  }
}

/// Android: Direct download (including in-app browsers like Kakao, Naver)
ExportResult _downloadForAndroid(Uint8List imageBytes, String filename) {
  try {
    // Create blob URL for download
    final blob = web.Blob(
      [imageBytes.toJS].toJS,
      web.BlobPropertyBag(type: 'image/png'),
    );
    final url = web.URL.createObjectURL(blob);

    // Create and click download link
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = filename;
    anchor.style.display = 'none';

    web.document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    // Revoke URL after a delay (fire and forget)
    Future.delayed(const Duration(milliseconds: 500), () {
      web.URL.revokeObjectURL(url);
    });

    return ExportResult(
      success: true,
      message: '포스터가 다운로드되었습니다!',
      filePath: filename,
    );
  } catch (e) {
    return ExportResult(
      success: false,
      message: '다운로드 실패: ${e.toString()}',
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

/// Download using Data URL (for in-app browsers like Kakao)
/// Note: Kakao ignores download attribute, so filename will be random base64 string
ExportResult _downloadWithDataUrl(Uint8List imageBytes, String filename) {
  try {
    final base64 = base64Encode(imageBytes);
    final dataUrl = 'data:image/png;base64,$base64';

    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = dataUrl;
    anchor.download = filename;
    anchor.style.display = 'none';

    web.document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    return ExportResult(
      success: true,
      message: '포스터가 다운로드되었습니다!\n(파일명은 갤러리에서 변경 가능)',
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
