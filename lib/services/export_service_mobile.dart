import 'dart:io';
import 'dart:typed_data';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'export_service.dart';

/// Mobile implementation for saving image to gallery
Future<ExportResult> saveImage(Uint8List imageBytes, String filename) async {
  try {
    // Request permission on Android
    if (Platform.isAndroid) {
      final status = await _requestStoragePermission();
      if (!status) {
        return ExportResult(
          success: false,
          message: 'Storage permission denied. Please grant permission in settings.',
        );
      }
    }

    // Save to gallery
    final result = await ImageGallerySaver.saveImage(
      imageBytes,
      quality: 100,
      name: filename,
    );

    if (result['isSuccess'] == true) {
      return ExportResult(
        success: true,
        message: 'Poster saved to gallery!',
        filePath: result['filePath']?.toString(),
      );
    } else {
      return ExportResult(
        success: false,
        message: 'Failed to save to gallery',
      );
    }
  } catch (e) {
    return ExportResult(
      success: false,
      message: 'Failed to save: ${e.toString()}',
    );
  }
}

/// Request storage permission for Android
Future<bool> _requestStoragePermission() async {
  // For Android 13+, we need photos permission
  // For older versions, we need storage permission
  if (Platform.isAndroid) {
    // Try photos permission first (Android 13+)
    var status = await Permission.photos.status;
    if (status.isDenied) {
      status = await Permission.photos.request();
    }

    if (status.isGranted) {
      return true;
    }

    // Fall back to storage permission for older Android
    status = await Permission.storage.status;
    if (status.isDenied) {
      status = await Permission.storage.request();
    }

    return status.isGranted;
  }

  return true;
}
