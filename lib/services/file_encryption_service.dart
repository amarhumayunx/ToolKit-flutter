import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../utils/app_exceptions.dart';
import '../utils/app_logger.dart';

class FileEncryptionService {
  static const String _encryptedFolderName = 'encrypted_files';

  // Generate a secure encryption key
  static String _generateEncryptionKey() {
    final key = Key.fromSecureRandom(32);
    return key.base64;
  }

  // Get or create encryption key for the app
  static Future<String> _getOrCreateKey() async {
    final appDir = await getApplicationDocumentsDirectory();
    final keyFile = File('${appDir.path}/encryption_key.txt');

    if (await keyFile.exists()) {
      return await keyFile.readAsString();
    } else {
      final newKey = _generateEncryptionKey();
      await keyFile.writeAsString(newKey);
      return newKey;
    }
  }

  // Get encrypted files directory
  static Future<Directory> _getEncryptedDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final encryptedDir = Directory('${appDir.path}/$_encryptedFolderName');

    if (!await encryptedDir.exists()) {
      await encryptedDir.create(recursive: true);
    }

    return encryptedDir;
  }

  // Encrypt and move file to encrypted directory
  static Future<String?> encryptAndMoveFile(String originalFilePath) async {
    if (originalFilePath.isEmpty) {
      throw EncryptionException(
        'Invalid file path provided for encryption',
        operation: 'encrypt',
        code: 'invalid-file-path',
      );
    }

    File? originalFile;
    try {
      originalFile = File(originalFilePath);
      if (!await originalFile.exists()) {
        throw EncryptionException(
          'Original file does not exist',
          operation: 'encrypt',
          filePath: originalFilePath,
          code: 'file-not-found',
        );
      }

      // Check file size (prevent memory issues with very large files)
      final fileSize = await originalFile.length();
      const maxFileSize = 100 * 1024 * 1024; // 100MB limit
      if (fileSize > maxFileSize) {
        throw EncryptionException(
          'File is too large to encrypt (max 100MB)',
          operation: 'encrypt',
          filePath: originalFilePath,
          code: 'file-too-large',
        );
      }

      // Read original file
      final originalBytes = await originalFile.readAsBytes();
      if (originalBytes.isEmpty) {
        throw EncryptionException(
          'File is empty and cannot be encrypted',
          operation: 'encrypt',
          filePath: originalFilePath,
          code: 'file-empty',
        );
      }

      // Get encryption key
      String keyString;
      try {
        keyString = await _getOrCreateKey();
      } catch (e, stackTrace) {
        throw EncryptionException(
          'Failed to retrieve encryption key',
          operation: 'encrypt',
          originalError: e,
          stackTrace: stackTrace,
          code: 'key-retrieval-failed',
        );
      }

      Key key;
      try {
        key = Key.fromBase64(keyString);
      } catch (e, stackTrace) {
        throw EncryptionException(
          'Invalid encryption key format',
          operation: 'encrypt',
          originalError: e,
          stackTrace: stackTrace,
          code: 'invalid-key-format',
        );
      }

      final iv = IV.fromSecureRandom(16);
      final encrypter = Encrypter(AES(key));

      // Encrypt file content
      final encrypted = encrypter.encryptBytes(originalBytes, iv: iv);

      // Create encrypted file data (IV + encrypted content)
      final encryptedData = Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);

      // Get encrypted directory
      Directory encryptedDir;
      try {
        encryptedDir = await _getEncryptedDirectory();
      } catch (e, stackTrace) {
        throw EncryptionException(
          'Failed to access encrypted directory',
          operation: 'encrypt',
          originalError: e,
          stackTrace: stackTrace,
          code: 'directory-access-failed',
        );
      }

      // Generate unique encrypted filename
      final originalFileName = path.basename(originalFilePath);
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final encryptedFileName = 'enc_${timestamp}_$originalFileName.encrypted';
      final encryptedFilePath = '${encryptedDir.path}/$encryptedFileName';

      // Write encrypted file
      final encryptedFile = File(encryptedFilePath);
      try {
        await encryptedFile.writeAsBytes(encryptedData);
      } catch (e, stackTrace) {
        throw EncryptionException(
          'Failed to write encrypted file',
          operation: 'encrypt',
          filePath: encryptedFilePath,
          originalError: e,
          stackTrace: stackTrace,
          code: 'write-failed',
        );
      }

      // Delete original file only after successful encryption
      try {
        await originalFile.delete();
      } catch (e, stackTrace) {
        AppLogger.warning(
          'Failed to delete original file after encryption: $e',
          'FileEncryptionService',
          e,
          stackTrace,
        );
        // Don't fail the operation if original file deletion fails
      }

      AppLogger.info(
        'File encrypted successfully: $originalFilePath -> $encryptedFilePath',
        'FileEncryptionService',
      );

      return encryptedFilePath;
    } on EncryptionException {
      rethrow;
    } on FileSystemException catch (e, stackTrace) {
      AppLogger.error(
        'File system error during encryption',
        tag: 'FileEncryptionService',
        error: e,
        stackTrace: stackTrace,
      );
      throw EncryptionException(
        'File system error: ${e.message}',
        operation: 'encrypt',
        filePath: originalFilePath,
        originalError: e,
        stackTrace: stackTrace,
        code: 'filesystem-error',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error encrypting file',
        tag: 'FileEncryptionService',
        error: e,
        stackTrace: stackTrace,
      );
      throw EncryptionException(
        'An unexpected error occurred during encryption',
        operation: 'encrypt',
        filePath: originalFilePath,
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Decrypt and restore file to its original location
  static Future<String?> decryptAndRestoreFile(String encryptedFilePath, String originalPath) async {
    if (encryptedFilePath.isEmpty || originalPath.isEmpty) {
      throw EncryptionException(
        'Invalid file paths provided for decryption',
        operation: 'decrypt',
        code: 'invalid-file-path',
      );
    }

    File? encryptedFile;
    try {
      encryptedFile = File(encryptedFilePath);
      if (!await encryptedFile.exists()) {
        throw EncryptionException(
          'Encrypted file does not exist',
          operation: 'decrypt',
          filePath: encryptedFilePath,
          code: 'file-not-found',
        );
      }

      // Read encrypted file
      Uint8List encryptedData;
      try {
        encryptedData = await encryptedFile.readAsBytes();
      } catch (e, stackTrace) {
        throw EncryptionException(
          'Failed to read encrypted file',
          operation: 'decrypt',
          filePath: encryptedFilePath,
          originalError: e,
          stackTrace: stackTrace,
          code: 'read-failed',
        );
      }

      if (encryptedData.length < 16) {
        throw EncryptionException(
          'Encrypted file is corrupted (too small to contain IV)',
          operation: 'decrypt',
          filePath: encryptedFilePath,
          code: 'file-corrupted',
        );
      }

      // Extract IV and encrypted content
      IV iv;
      Uint8List encryptedContent;
      try {
        iv = IV(encryptedData.sublist(0, 16));
        encryptedContent = Uint8List.fromList(encryptedData.sublist(16));
      } catch (e, stackTrace) {
        throw EncryptionException(
          'Failed to extract IV from encrypted file',
          operation: 'decrypt',
          filePath: encryptedFilePath,
          originalError: e,
          stackTrace: stackTrace,
          code: 'iv-extraction-failed',
        );
      }

      // Get encryption key
      String keyString;
      try {
        keyString = await _getOrCreateKey();
      } catch (e, stackTrace) {
        throw EncryptionException(
          'Failed to retrieve encryption key',
          operation: 'decrypt',
          originalError: e,
          stackTrace: stackTrace,
          code: 'key-retrieval-failed',
        );
      }

      Key key;
      try {
        key = Key.fromBase64(keyString);
      } catch (e, stackTrace) {
        throw EncryptionException(
          'Invalid encryption key format',
          operation: 'decrypt',
          originalError: e,
          stackTrace: stackTrace,
          code: 'invalid-key-format',
        );
      }

      final encrypter = Encrypter(AES(key));

      // Decrypt content
      Uint8List decryptedBytes;
      try {
        final encrypted = Encrypted(encryptedContent);
        decryptedBytes = Uint8List.fromList(encrypter.decryptBytes(encrypted, iv: iv));
      } catch (e, stackTrace) {
        throw EncryptionException(
          'Decryption failed - invalid key or corrupted data',
          operation: 'decrypt',
          filePath: encryptedFilePath,
          originalError: e,
          stackTrace: stackTrace,
          code: 'decryption-failed',
        );
      }

      // Ensure original directory exists
      final originalDir = Directory(path.dirname(originalPath));
      if (!await originalDir.exists()) {
        try {
          await originalDir.create(recursive: true);
        } catch (e, stackTrace) {
          throw EncryptionException(
            'Failed to create directory for decrypted file',
            operation: 'decrypt',
            filePath: originalPath,
            originalError: e,
            stackTrace: stackTrace,
            code: 'directory-creation-failed',
          );
        }
      }

      // Write decrypted file to original location
      final restoredFile = File(originalPath);
      try {
        await restoredFile.writeAsBytes(decryptedBytes);
      } catch (e, stackTrace) {
        throw EncryptionException(
          'Failed to write decrypted file',
          operation: 'decrypt',
          filePath: originalPath,
          originalError: e,
          stackTrace: stackTrace,
          code: 'write-failed',
        );
      }

      // Delete encrypted file only after successful decryption
      try {
        await encryptedFile.delete();
      } catch (e, stackTrace) {
        AppLogger.warning(
          'Failed to delete encrypted file after decryption: $e',
          'FileEncryptionService',
          e,
          stackTrace,
        );
        // Don't fail the operation if encrypted file deletion fails
      }

      AppLogger.info(
        'File decrypted successfully: $encryptedFilePath -> $originalPath',
        'FileEncryptionService',
      );

      return originalPath;
    } on EncryptionException {
      rethrow;
    } on FileSystemException catch (e, stackTrace) {
      AppLogger.error(
        'File system error during decryption',
        tag: 'FileEncryptionService',
        error: e,
        stackTrace: stackTrace,
      );
      throw EncryptionException(
        'File system error: ${e.message}',
        operation: 'decrypt',
        filePath: encryptedFilePath,
        originalError: e,
        stackTrace: stackTrace,
        code: 'filesystem-error',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error decrypting file',
        tag: 'FileEncryptionService',
        error: e,
        stackTrace: stackTrace,
      );
      throw EncryptionException(
        'An unexpected error occurred during decryption',
        operation: 'decrypt',
        filePath: encryptedFilePath,
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Check if file is encrypted (helper method)
  static bool isEncryptedFile(String filePath) {
    return filePath.contains(_encryptedFolderName) && filePath.endsWith('.encrypted');
  }

  // Get all encrypted files
  static Future<List<File>> getEncryptedFiles() async {
    try {
      final encryptedDir = await _getEncryptedDirectory();
      if (!await encryptedDir.exists()) {
        return [];
      }

      final files = await encryptedDir.list().where((entity) =>
      entity is File && entity.path.endsWith('.encrypted')
      ).cast<File>().toList();

      return files;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error getting encrypted files',
        tag: 'FileEncryptionService',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  // Clean up orphaned encrypted files (optional maintenance method)
  static Future<void> cleanUpOrphanedEncryptedFiles() async {
    try {
      final encryptedFiles = await getEncryptedFiles();
      // Add your logic here to clean up files that are no longer referenced in Hive
      AppLogger.info(
        'Cleaned up ${encryptedFiles.length} encrypted files',
        'FileEncryptionService',
      );
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error cleaning up encrypted files',
        tag: 'FileEncryptionService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}