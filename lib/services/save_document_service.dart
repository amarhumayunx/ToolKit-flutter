import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path/path.dart' as path;
import '../utils/app_snackbar.dart';

class SaveDocumentService {
  /// Checks if storage permission is available or needed
  /// For Android 10+ (API 29+), we don't need explicit storage permission
  static Future<bool> checkAndRequestStoragePermission(
      BuildContext context) async {
    if (Platform.isAndroid) {
      // For Android 10 (API 29) and above, we can use the media store without storage permission
      if (await _isAndroidVersionAbove29()) {
        return true; // No need for storage permission on Android 10+
      }

      // For older Android versions, request storage permission
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      return status.isGranted;
    } else if (Platform.isIOS) {
      // iOS doesn't need explicit permission for this operation
      return true;
    }

    return false;
  }

  /// Helper method to check Android version
  static Future<bool> _isAndroidVersionAbove29() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt >= 29; // Android 10 is API 29
    }
    return false;
  }

  /// Shows a helper dialog for permission issues
  static Future<void> showPermissionHelperDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Issue'),
          content: const Text(
              'Unable to save document. This might be due to permission restrictions on your device.\n\n'
              'For Android 11+ users: Please allow the app to manage all files in your device settings.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  /// Main method to save a document file
  static Future<bool?> saveDocument(
      BuildContext context, File documentFile) async {
    try {
      // Check if we can access storage (either with permission or on Android 10+)
      bool canAccessStorage = await checkAndRequestStoragePermission(context);

      if (canAccessStorage) {
        // Generate a unique filename
        String baseFileName = path.basename(documentFile.path);
        if (!baseFileName.toLowerCase().endsWith('.docx')) {
          baseFileName =
              'Document.docx'; // Default name if file doesn't have proper extension
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        String uniqueFileName =
            '${path.basenameWithoutExtension(baseFileName)}_$timestamp${path.extension(baseFileName)}';

        // Use the FlutterFileDialog directly (this handles permissions internally)
        final params = SaveFileDialogParams(
          sourceFilePath: documentFile.path,
          fileName: uniqueFileName,
        );

        final savedFilePath = await FlutterFileDialog.saveFile(params: params);

        if (savedFilePath != null) {
          AppSnackBar.show(context, message: 'Document saved successfully');
          return true; // Successful save
        } else {
          AppSnackBar.show(context, message: 'Document saving canceled');
          return false; // Save was canceled
        }
      } else {
        // Show a dialog with a more helpful message about permission issues
        showPermissionHelperDialog(context);
        return null; // Permission issue
      }
    } on PlatformException catch (e) {
      print('Platform Exception in saving file: ${e.message}');
      AppSnackBar.show(context,
          message: 'Failed to save document: ${e.message}');
      return null; // Error
    } catch (e) {
      print('Error saving file: $e');
      AppSnackBar.show(context, message: 'Failed to save document: $e');
      return null; // Error
    }
  }
}
