import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../utils/app_snackbar.dart';

class SaveFileService {
  static const String toolkitFolderName = 'Toolkit';

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

  /// Creates Toolkit folder if it doesn't exist
  static Future<Directory?> _createToolkitFolder() async {
    try {
      Directory? baseDir;

      if (Platform.isAndroid) {
        // For Android, we'll use the Downloads directory
        baseDir = Directory('/storage/emulated/0/Download');
        if (!await baseDir.exists()) {
          // Fallback to app documents directory if Downloads not accessible
          baseDir = await getApplicationDocumentsDirectory();
        }
      } else if (Platform.isIOS) {
        // For iOS, use the app's documents directory
        baseDir = await getApplicationDocumentsDirectory();
      } else {
        // Unsupported platform
        return null;
      }

      // Create the Toolkit directory
      final toolkitDir = Directory('${baseDir.path}/$toolkitFolderName');
      if (!await toolkitDir.exists()) {
        await toolkitDir.create(recursive: true);
      }

      return toolkitDir;
    } catch (e) {
      debugPrint('Error creating Toolkit folder: $e');
      return null;
    }
  }

  /// Save PNG file to Toolkit folder
  static Future<void> savePngFile(BuildContext context, File imageFile) async {
    try {
      // Check if we can access storage
      bool hasPermission = await checkAndRequestStoragePermission(context);

      if (hasPermission) {
        // Try to create the Toolkit folder
        final toolkitDir = await _createToolkitFolder();

        if (toolkitDir == null) {
          // If folder creation failed, use default save mechanism
          await _saveFileWithDialog(context, imageFile, 'png');
          return;
        }

        // Generate a unique filename
        String baseFileName = path.basenameWithoutExtension(imageFile.path);
        String uniqueFileName = '${baseFileName}_${DateTime.now().millisecondsSinceEpoch}.png';

        // Create destination file path in Toolkit folder
        final destinationPath = '${toolkitDir.path}/$uniqueFileName';

        // Copy the file to the Toolkit folder
        await imageFile.copy(destinationPath);

        AppSnackBar.show(context, message: 'Image saved to ${toolkitDir.path}');
      } else {
        await showPermissionHelperDialog(context);
      }
    } on PlatformException catch (e) {
      debugPrint('Platform Exception in saving PNG file: ${e.message}');
      AppSnackBar.show(context, message: 'Failed to save image: ${e.message}');
    } catch (e) {
      debugPrint('Error saving PNG file: $e');
      AppSnackBar.show(context, message: 'Failed to save image: ${e.toString()}');
    }
  }

  /// Save ZIP file to Toolkit folder
  static Future<void> saveZipFile(BuildContext context, File zipFile) async {
    try {
      // Check if we can access storage
      bool hasPermission = await checkAndRequestStoragePermission(context);

      if (hasPermission) {
        // Try to create the Toolkit folder
        final toolkitDir = await _createToolkitFolder();

        if (toolkitDir == null) {
          // If folder creation failed, use default save mechanism
          await _saveFileWithDialog(context, zipFile, 'zip');
          return;
        }

        // Generate a unique filename
        String baseFileName = path.basenameWithoutExtension(zipFile.path);
        String uniqueFileName = '${baseFileName}_${DateTime.now().millisecondsSinceEpoch}.zip';

        // Create destination file path in Toolkit folder
        final destinationPath = '${toolkitDir.path}/$uniqueFileName';

        // Copy the file to the Toolkit folder
        await zipFile.copy(destinationPath);

        AppSnackBar.show(context, message: 'ZIP file saved to ${toolkitDir.path}');
      } else {
        await showPermissionHelperDialog(context);
      }
    } on PlatformException catch (e) {
      debugPrint('Platform Exception in saving ZIP file: ${e.message}');
      AppSnackBar.show(context, message: 'Failed to save ZIP file: ${e.message}');
    } catch (e) {
      debugPrint('Error saving ZIP file: $e');
      AppSnackBar.show(context, message: 'Failed to save ZIP file: ${e.toString()}');
    }
  }

  /// Main method to save any file based on its type to Toolkit folder
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
        case 'pdf':
          await _savePdfFile(context, file);
          break;
        case 'docx':
          await _saveDocumentFile(context, file);
          break;
        case 'xlsx':
        case 'pptx':
        default:
          await _saveGenericFile(context, file);
      }
    } catch (e) {
      debugPrint('Error in saveFile: $e');
      AppSnackBar.show(context, message: 'Failed to save file: ${e.toString()}');
    }
  }

  /// Save DOCX document file to Toolkit folder
  static Future<void> _saveDocumentFile(BuildContext context, File docFile) async {
    try {
      // Check if we can access storage
      bool hasPermission = await checkAndRequestStoragePermission(context);

      if (hasPermission) {
        // Try to create the Toolkit folder
        final toolkitDir = await _createToolkitFolder();

        if (toolkitDir == null) {
          // If folder creation failed, use default save mechanism
          await _saveFileWithDialog(context, docFile, 'docx');
          return;
        }

        // Generate a unique filename
        String baseFileName = path.basenameWithoutExtension(docFile.path);
        String uniqueFileName = '${baseFileName}_${DateTime.now().millisecondsSinceEpoch}.docx';

        // Create destination file path in Toolkit folder
        final destinationPath = '${toolkitDir.path}/$uniqueFileName';

        // Copy the file to the Toolkit folder
        await docFile.copy(destinationPath);

        AppSnackBar.show(context, message: 'Document saved to ${toolkitDir.path}');
      } else {
        await showPermissionHelperDialog(context);
      }
    } on PlatformException catch (e) {
      debugPrint('Platform Exception in saving document file: ${e.message}');
      AppSnackBar.show(context, message: 'Failed to save document: ${e.message}');
    } catch (e) {
      debugPrint('Error saving document file: $e');
      AppSnackBar.show(context, message: 'Failed to save document: ${e.toString()}');
    }
  }

  /// Save PDF file to Toolkit folder
  static Future<void> _savePdfFile(BuildContext context, File pdfFile) async {
    try {
      // Check if we can access storage
      bool hasPermission = await checkAndRequestStoragePermission(context);

      if (hasPermission) {
        // Try to create the Toolkit folder
        final toolkitDir = await _createToolkitFolder();

        if (toolkitDir == null) {
          // If folder creation failed, use default save mechanism
          await _saveFileWithDialog(context, pdfFile, 'pdf');
          return;
        }

        // Generate a unique filename
        String baseFileName = path.basenameWithoutExtension(pdfFile.path);
        String uniqueFileName = '${baseFileName}_${DateTime.now().millisecondsSinceEpoch}.pdf';

        // Create destination file path in Toolkit folder
        final destinationPath = '${toolkitDir.path}/$uniqueFileName';

        // Copy the file to the Toolkit folder
        await pdfFile.copy(destinationPath);

        AppSnackBar.show(context, message: 'PDF saved to ${toolkitDir.path}');
      } else {
        await showPermissionHelperDialog(context);
      }
    } on PlatformException catch (e) {
      debugPrint('Platform Exception in saving PDF file: ${e.message}');
      AppSnackBar.show(context, message: 'Failed to save PDF: ${e.message}');
    } catch (e) {
      debugPrint('Error saving PDF file: $e');
      AppSnackBar.show(context, message: 'Failed to save PDF: ${e.toString()}');
    }
  }

  /// Generic file saving method for other file types to Toolkit folder
  static Future<void> _saveGenericFile(BuildContext context, File file) async {
    try {
      bool hasPermission = await checkAndRequestStoragePermission(context);

      if (hasPermission) {
        // Try to create the Toolkit folder
        final toolkitDir = await _createToolkitFolder();

        if (toolkitDir == null) {
          // If folder creation failed, use default save mechanism
          await _saveFileWithDialog(context, file, path.extension(file.path).replaceAll('.', ''));
          return;
        }

        // Generate a unique filename
        String baseFileName = path.basename(file.path);
        final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        String uniqueFileName =
            '${path.basenameWithoutExtension(baseFileName)}_$timestamp${path.extension(baseFileName)}';

        // Create destination file path in Toolkit folder
        final destinationPath = '${toolkitDir.path}/$uniqueFileName';

        // Copy the file to the Toolkit folder
        await file.copy(destinationPath);

        AppSnackBar.show(context, message: 'File saved to ${toolkitDir.path}');
      } else {
        await showPermissionHelperDialog(context);
      }
    } catch (e) {
      debugPrint('Error saving generic file: $e');
      AppSnackBar.show(context, message: 'Failed to save file: ${e.toString()}');
    }
  }

  /// Fallback method to save files using system dialog if Toolkit folder creation fails
  static Future<void> _saveFileWithDialog(
      BuildContext context, File file, String fileType) async {
    try {
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
        AppSnackBar.show(context, message: 'File saved successfully');
      } else {
        AppSnackBar.show(context, message: 'File saving canceled');
      }
    } catch (e) {
      debugPrint('Error in _saveFileWithDialog: $e');
      AppSnackBar.show(context, message: 'Failed to save file: ${e.toString()}');
    }
  }
}