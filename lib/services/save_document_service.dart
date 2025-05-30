import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../models/file_model.dart';

import '../models/file_model_adapter.dart';
import '../utils/app_snackbar.dart';

class SaveDocumentService {
  static const String _filesBoxName = 'filesBox';
  static const String toolkitFolderName = 'Toolkit';

  /// Initialize Hive box for files
  static Future<Box<FileModel>> initFilesBox() async {
    if (!Hive.isAdapterRegistered(1)) { // Match the typeId
      Hive.registerAdapter(FileModelAdapter());
    }
    return await Hive.openBox<FileModel>(_filesBoxName);
  }

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

  /// Fallback method to save files using system dialog if Toolkit folder creation fails
  static Future<String?> _saveFileWithDialog(
      BuildContext context, File documentFile) async {
    try {
      String baseFileName = path.basename(documentFile.path);
      if (!baseFileName.toLowerCase().endsWith('.docx')) {
        baseFileName = 'Document.docx';
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String uniqueFileName =
          '${path.basenameWithoutExtension(baseFileName)}_$timestamp${path.extension(baseFileName)}';

      final params = SaveFileDialogParams(
        sourceFilePath: documentFile.path,
        fileName: uniqueFileName,
      );

      final savedFilePath = await FlutterFileDialog.saveFile(params: params);

      if (savedFilePath != null) {
        AppSnackBar.show(context, message: 'Document saved successfully');
        return savedFilePath;
      } else {
        AppSnackBar.show(context, message: 'Document saving canceled');
        return null;
      }
    } catch (e) {
      debugPrint('Error in _saveFileWithDialog: $e');
      AppSnackBar.show(context, message: 'Failed to save document: ${e.toString()}');
      return null;
    }
  }

  /// Main method to save a document file to Toolkit folder
  static Future<bool?> saveDocument(BuildContext context, File documentFile) async {
    try {
      bool canAccessStorage = await checkAndRequestStoragePermission(context);

      if (canAccessStorage) {
        // Try to create the Toolkit folder
        final toolkitDir = await _createToolkitFolder();
        String? savedFilePath;

        if (toolkitDir != null) {
          // Save to Toolkit folder
          String baseFileName = path.basename(documentFile.path);
          if (!baseFileName.toLowerCase().endsWith('.docx')) {
            baseFileName = 'Document.docx';
          }

          final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
          String uniqueFileName = '${path.basenameWithoutExtension(baseFileName)}_$timestamp${path.extension(baseFileName)}';

          // Create destination file path in Toolkit folder
          final destinationPath = '${toolkitDir.path}/$uniqueFileName';

          // Copy the file to the Toolkit folder
          await documentFile.copy(destinationPath);
          savedFilePath = destinationPath;

          AppSnackBar.show(context, message: 'Document saved to ${toolkitDir.path}');
        } else {
          // If folder creation failed, use default save mechanism
          savedFilePath = await _saveFileWithDialog(context, documentFile);
          if (savedFilePath == null) {
            return false; // User canceled or error occurred
          }
        }

        // Save to Hive if we have a saved file path
        if (savedFilePath != null) {
          final filesBox = await initFilesBox();
          final fileSize = (await documentFile.length()) / (1024 * 1024); // MB

          await filesBox.add(FileModel(
            name: path.basename(savedFilePath),
            path: savedFilePath,
            date: DateTime.now(),
            size: '${fileSize.toStringAsFixed(1)} MB',
          ));

          return true;
        }

        return false;
      } else {
        showPermissionHelperDialog(context);
        return null;
      }
    } on PlatformException catch (e) {
      print('Platform Exception in saving file: ${e.message}');
      AppSnackBar.show(context, message: 'Failed to save document: ${e.message}');
      return null;
    } catch (e) {
      print('Error saving file: $e');
      AppSnackBar.show(context, message: 'Failed to save document: $e');
      return null;
    }
  }
}