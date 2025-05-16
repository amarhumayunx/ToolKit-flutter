import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path/path.dart' as path;

class SaveFileService {
  /// Checks if storage permission is available or needed
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
      // For iOS, we need photos permission to save to gallery
      if (await Permission.photos.status.isGranted) {
        return true;
      }
      final result = await Permission.photos.request();
      return result.isGranted;
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
              'Unable to save file. This might be due to permission restrictions on your device.\n\n'
                  'For Android 11+ users: Please allow the app to manage files and photos in your device settings.'),
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

  /// Save PNG file to device storage (like downloads)
  static Future<void> savePngFile(BuildContext context, File imageFile) async {
    try {
      // Check if we can access storage
      bool hasPermission = await checkAndRequestStoragePermission(context);

      if (hasPermission) {
        // Generate a unique filename
        String baseFileName = path.basenameWithoutExtension(imageFile.path);
        String uniqueFileName = '${baseFileName}_${DateTime.now().millisecondsSinceEpoch}.png';

        // Use the FlutterFileDialog to save the file
        final params = SaveFileDialogParams(
          sourceFilePath: imageFile.path,
          fileName: uniqueFileName,
        );

        final savedFilePath = await FlutterFileDialog.saveFile(params: params);

        if (savedFilePath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image saved successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image saving canceled')),
          );
        }
      } else {
        await showPermissionHelperDialog(context);
      }
    } on PlatformException catch (e) {
      debugPrint('Platform Exception in saving PNG file: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image: ${e.message}')),
      );
    } catch (e) {
      debugPrint('Error saving PNG file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image: ${e.toString()}')),
      );
    }
  }

  /// Save ZIP file to device storage
  static Future<void> saveZipFile(BuildContext context, File zipFile) async {
    try {
      // Check if we can access storage
      bool hasPermission = await checkAndRequestStoragePermission(context);

      if (hasPermission) {
        // Generate a unique filename
        String baseFileName = path.basenameWithoutExtension(zipFile.path);
        String uniqueFileName = '${baseFileName}_${DateTime.now().millisecondsSinceEpoch}.zip';

        // Use the FlutterFileDialog to save the file
        final params = SaveFileDialogParams(
          sourceFilePath: zipFile.path,
          fileName: uniqueFileName,
        );

        final savedFilePath = await FlutterFileDialog.saveFile(params: params);

        if (savedFilePath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ZIP file saved successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ZIP file saving canceled')),
          );
        }
      } else {
        await showPermissionHelperDialog(context);
      }
    } on PlatformException catch (e) {
      debugPrint('Platform Exception in saving ZIP file: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save ZIP file: ${e.message}')),
      );
    } catch (e) {
      debugPrint('Error saving ZIP file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save ZIP file: ${e.toString()}')),
      );
    }
  }

  /// Main method to save any file based on its type
  static Future<void> saveFile(
      BuildContext context, File file, String fileType) async {
    try {
      switch (fileType.toLowerCase()) {
        case 'png':
        case 'jpg':
        case 'jpeg':
          await savePngFile(context, file);
          break;
        case 'zip':
          await saveZipFile(context, file);
          break;
        case 'docx':
        case 'xlsx':
        case 'pptx':
        // Delegate to document service if you have one
          await _saveGenericFile(context, file);
          break;
        default:
          await _saveGenericFile(context, file);
      }
    } catch (e) {
      debugPrint('Error in saveFile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save file: ${e.toString()}')),
      );
    }
  }

  /// Generic file saving method for other file types
  static Future<void> _saveGenericFile(BuildContext context, File file) async {
    try {
      bool hasPermission = await checkAndRequestStoragePermission(context);

      if (hasPermission) {
        String baseFileName = path.basename(file.path);
        final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        String uniqueFileName =
            '${path.basenameWithoutExtension(baseFileName)}_$timestamp${path.extension(baseFileName)}';

        final params = SaveFileDialogParams(
          sourceFilePath: file.path,
          fileName: uniqueFileName,
        );

        final savedFilePath = await FlutterFileDialog.saveFile(params: params);

        if (savedFilePath != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File saved successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File saving canceled')),
          );
        }
      } else {
        await showPermissionHelperDialog(context);
      }
    } catch (e) {
      debugPrint('Error saving generic file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save file: ${e.toString()}')),
      );
    }
  }
}