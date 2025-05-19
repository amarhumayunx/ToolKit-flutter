import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';

class FileCompressor {
  // Main compression function that handles different file types
  static Future<File?> compressFile(File file, {int quality = 85}) async {
    // Get file extension
    final extension = path.extension(file.path).toLowerCase();

    try {
      // Process based on file type
      switch (extension) {
        case '.jpg':
        case '.jpeg':
        case '.png':
          return await _compressImage(file, quality: quality);
        case '.pdf':
          return await _compressWithGzip(file);
        case '.doc':
        case '.docx':
        case '.ppt':
        case '.pptx':
          return await _compressWithGzip(file);
        default:
          return file; // Return original if not supported
      }
    } catch (e) {
      print('Error compressing file: $e');
      return null;
    }
  }

  // Compress batch of files and return results
  static Future<List<File>> compressBatch(List<File> files, {int quality = 85}) async {
    List<File> compressedFiles = [];

    for (var file in files) {
      File? compressedFile = await compressFile(file, quality: quality);
      if (compressedFile != null) {
        compressedFiles.add(compressedFile);
      } else {
        // If compression fails, add original file
        compressedFiles.add(file);
      }
    }

    return compressedFiles;
  }

  // Image compression using flutter_image_compress
  static Future<File> _compressImage(File file, {int quality = 85}) async {
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(dir.path, 'compressed_${path.basename(file.path)}');

    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
      // You can add more parameters based on your needs
      // minHeight: 1080,
      // minWidth: 1080,
    );

    if (result != null) {
      // Compare sizes and return the smaller one
      if (File(result.path).lengthSync() < file.lengthSync()) {
        return File(result.path);
      }
    }

    // If compression didn't work or didn't reduce size, return original
    return file;
  }

  // Generic GZip compression for documents
  static Future<File> _compressWithGzip(File file) async {
    final dir = await getTemporaryDirectory();
    final filename = path.basename(file.path);
    final targetPath = path.join(dir.path, 'compressed_$filename');

    try {
      // Read the file as bytes
      List<int> fileBytes = await file.readAsBytes();

      // Use GZip compression
      final compressed = GZipEncoder().encode(fileBytes);

      if (compressed != null) {
        // Write the compressed bytes to a new file
        final compressedFile = File(targetPath);
        await compressedFile.writeAsBytes(compressed);

        // Always verify that compression actually reduced the size
        if (compressedFile.lengthSync() < file.lengthSync()) {
          return compressedFile;
        }
      }

      // Return original if compression didn't work or didn't reduce size
      return file;
    } catch (e) {
      print('Compression error: $e');
      return file;
    }
  }

  // Get a human-readable file size
  static String getReadableFileSize(int bytes) {
    if (bytes <= 0) return "0 B";

    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    int i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return "${size.toStringAsFixed(2)} ${suffixes[i]}";
  }
}