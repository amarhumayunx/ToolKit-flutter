import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:pdf/pdf.dart';
import 'package:archive/archive.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import 'package:pdfx/pdfx.dart' as pdfx;

import 'compression_result_class.dart';

class FileCompressor {

  // Main compression function that handles different file types
  static Future<CompressionResult> compressFileWithStatus(File file, {int quality = 85}) async {
    final extension = path.extension(file.path).toLowerCase();

    try {
      switch (extension) {
        case '.jpg':
        case '.jpeg':
        case '.png':
          final result = await _compressImageWithStatus(file, quality: quality);
          return result;
        case '.pdf':
          final result = await compressPdfWithStatus(file, quality: quality);
          return result;
        case '.doc':
        case '.docx':
          final result = await _compressWordDocumentWithStatus(file);
          return result;
        case '.ppt':
        case '.pptx':
          final result = await _compressPptxWithStatus(file);
          return result;
        default:
          return CompressionResult(
              file: file,
              wasCompressed: false,
              message: 'File type not supported for compression',
              originalSize: 0,
              compressedSize: 0
          );
      }
    } catch (e) {
      print('Error compressing file: $e');
      return CompressionResult(
          file: file,
          wasCompressed: false,
          message: 'Error occurred during compression',
        compressedSize: 0,
        originalSize: 0
      );
    }
  }

  // Batch compression with status tracking
  static Future<List<CompressionResult>> compressBatchWithStatus(List<File> files, {int quality = 85}) async {
    List<CompressionResult> results = [];

    for (var file in files) {
      try {
        CompressionResult result = await compressFileWithStatus(file, quality: quality);
        results.add(result);
      } catch (e) {
        print('Error processing file ${file.path}: $e');
        results.add(CompressionResult(
            file: file,
            wasCompressed: false,
            message: 'Processing failed',
            compressedSize: 0,
            originalSize: 0
        ));
      }
    }

    return results;
  }

  // Compress batch of files and return results (legacy method)
  static Future<List<File>> compressBatch(List<File> files, {int quality = 85}) async {
    List<File> compressedFiles = [];

    for (var file in files) {
      try {
        File? compressedFile = await compressFile(file, quality: quality);
        if (compressedFile != null) {
          compressedFiles.add(compressedFile);
        } else {
          // If compression fails, add original file
          compressedFiles.add(file);
        }
      } catch (e) {
        // If an error occurs, just add the original file
        print('Error processing file ${file.path}: $e');
        compressedFiles.add(file);
      }
    }

    return compressedFiles;
  }

  // Legacy method for backward compatibility
  static Future<File?> compressFile(File file, {int quality = 85}) async {
    final result = await compressFileWithStatus(file, quality: quality);
    return result.file;
  }

  // Image compression with status tracking
  static Future<CompressionResult> _compressImageWithStatus(File file, {int quality = 85}) async {
    // First check if file exists
    if (!file.existsSync()) {
      print('File does not exist: ${file.path}');
      return CompressionResult(
          file: file,
          wasCompressed: false,
          message: 'File not found',
          originalSize: 0,
          compressedSize: 0,
      );
    }

    // Generate a unique filename to avoid conflicts
    final dir = await getTemporaryDirectory();
    final filename = path.basenameWithoutExtension(file.path);
    final extension = path.extension(file.path).toLowerCase();
    final targetPath = path.join(dir.path, 'compressed_${filename}_$quality$extension');

    try {
      // For PNG files, we need to specify the format
      final format = extension == '.png'
          ? CompressFormat.png
          : CompressFormat.jpeg;

      // More explicit compression with additional parameters
      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        format: format,
        minWidth: 1080, // Specify reasonable dimensions
        minHeight: 1080, // You can adjust these values
        rotate: 0,       // Don't rotate the image
      );

      if (result == null) {
        print('Compression returned null result for: ${file.path}');
        return CompressionResult(
            file: file,
            wasCompressed: false,
            message: 'Compression failed',
            originalSize: 0,
            compressedSize: 0,
        );
      }

      // Verify the compressed file exists and has content
      final resultFile = File(result.path);
      if (!resultFile.existsSync() || resultFile.lengthSync() <= 0) {
        print('Compressed file is empty or does not exist: ${result.path}');
        return CompressionResult(
            file: file,
            wasCompressed: false,
            message: 'Compression failed',
            originalSize: 0,
            compressedSize: 0
        );
      }

      // Compare sizes and return appropriate result
      final originalSize = file.lengthSync();
      final compressedSize = resultFile.lengthSync();
      final reduction = ((originalSize - compressedSize) / originalSize * 100);

      // Check if compression actually made the file smaller
      if (compressedSize >= originalSize) {
        print('Compression increased file size or no change: ${file.path}');
        await resultFile.delete(); // Delete the larger compressed file
        return CompressionResult(
            file: file, // Return original file
            wasCompressed: false,
            message: 'File is already compressed or optimized',
            compressedSize: originalSize, // Use original size for both
            originalSize: originalSize
        );
      }

      if (reduction > 5) { // Only consider as compressed if reduction > 5%
        print('Successfully compressed: ${file.path}');
        print('Original: ${getReadableFileSize(originalSize)} → Compressed: ${getReadableFileSize(compressedSize)}');
        return CompressionResult(
            file: resultFile,
            wasCompressed: true,
            message: 'Successfully compressed',
            compressedSize: compressedSize,
            originalSize: originalSize
        );
      } else {
        print('Image is already compressed: ${file.path}');
        await resultFile.delete();
        return CompressionResult(
            file: file,
            wasCompressed: false,
            message: 'File is already compressed',
            compressedSize: compressedSize,
          originalSize: originalSize
        );
      }
    } catch (e) {
      print('Error compressing image: $e');
      return CompressionResult(
          file: file,
          wasCompressed: false,
          message: 'Error occurred during compression',
        compressedSize: 0,
        originalSize: 0
      );
    }
  }
  // PDF compression with status tracking
  static Future<CompressionResult> compressPdfWithStatus(File file, {int quality = 85}) async {
    if (!file.existsSync()) {
      print('PDF file does not exist: ${file.path}');
      return CompressionResult(
          file: file,
          wasCompressed: false,
          message: 'File not found',
          compressedSize: 0,
          originalSize: 0
      );
    }

    final dir = await getTemporaryDirectory();
    final filename = path.basenameWithoutExtension(file.path);
    final targetPath = path.join(dir.path, 'compressed_${filename}_$quality.pdf');

    pdfx.PdfDocument? pdfDocument;

    try {
      pdfDocument = await pdfx.PdfDocument.openFile(file.path);

      // Create a new PDF document with maximum compression
      final pdf = pw.Document(compress: true);

      final originalSize = file.lengthSync();

      // Aggressive scaling for all file sizes
      double scale;
      int imageQuality;

      if (originalSize < 50 * 1024) { // < 50KB
        scale = 0.6; // More aggressive scaling
        imageQuality = (quality * 0.5).round(); // Much lower quality
      } else if (originalSize < 200 * 1024) { // < 200KB
        scale = 0.7;
        imageQuality = (quality * 0.6).round();
      } else if (originalSize < 1024 * 1024) { // < 1MB
        scale = 0.8;
        imageQuality = (quality * 0.7).round();
      } else {
        scale = quality / 100.0;
        imageQuality = quality;
      }

      // Ensure minimum quality values
      imageQuality = imageQuality.clamp(25, 95);

      print('Compressing with scale: $scale, quality: $imageQuality');

      // Process each page with aggressive compression
      for (int i = 0; i < pdfDocument.pagesCount; i++) {
        final page = await pdfDocument.getPage(i + 1);

        // Calculate render dimensions with aggressive scaling
        final renderWidth = (page.width * scale).round().clamp(200, 2000);
        final renderHeight = (page.height * scale).round().clamp(200, 2000);

        final pageImage = await page.render(
          width: renderWidth.toDouble(),
          height: renderHeight.toDouble(),
          format: pdfx.PdfPageImageFormat.jpeg, // Always use JPEG for better compression
          backgroundColor: '#FFFFFF',
          quality: imageQuality,
        );

        await page.close();

        if (pageImage != null) {
          // Further compress the image bytes if needed
          Uint8List compressedImageBytes = pageImage.bytes;

          // For very small files, apply additional image compression
          if (originalSize < 100 * 1024) {
            compressedImageBytes = await _aggressiveImageCompression(pageImage.bytes, imageQuality);
          }

          final image = pw.MemoryImage(compressedImageBytes);
          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat(page.width, page.height, marginAll: 0),
              build: (pw.Context context) {
                return pw.Center(
                  child: pw.Image(image, fit: pw.BoxFit.contain),
                );
              },
            ),
          );
        }
      }

      final compressedPdfBytes = await pdf.save();
      final resultFile = File(targetPath);
      await resultFile.writeAsBytes(compressedPdfBytes);

      final compressedSize = resultFile.lengthSync();
      final reduction = ((originalSize - compressedSize) / originalSize * 100);

      print('PDF compression results:');
      print('Original: ${getReadableFileSize(originalSize)}');
      print('Compressed: ${getReadableFileSize(compressedSize)}');
      print('Reduction: ${reduction.toStringAsFixed(2)}%');

      // Check if compression was significant

      if (compressedSize >= originalSize)
        {
          print('Compression increased file size, using original');
          await resultFile.delete();
          return CompressionResult(
              file: file,
              wasCompressed: false,
              message: 'File is already optimized',
              originalSize: originalSize,
              compressedSize: originalSize
          );
        }
      else if (reduction > 5) { // Only consider as compressed if reduction > 5%
        print('Successfully compressed PDF');
        return CompressionResult(
            file: resultFile,
            wasCompressed: true,
            message: 'Successfully compressed',
          originalSize: originalSize,
          compressedSize: compressedSize,
        );
      } else {
        print('PDF is already optimized');
        await resultFile.delete();
        return CompressionResult(
            file: file,
            wasCompressed: false,
            message: 'PDF is already optimized',
          originalSize: originalSize,
          compressedSize: compressedSize,
        );
      }
    } catch (e) {
      print('Error compressing PDF: $e');
      return CompressionResult(
          file: file,
          wasCompressed: false,
          message: 'Error occurred during compression',
          originalSize: 0,
          compressedSize: 0,
      );
    } finally {
      await pdfDocument?.close();
    }
  }

  // PDF compression functionality while preserving original content (legacy method)
  static Future<File> compressPdf(File file, {int quality = 85}) async {
    final result = await compressPdfWithStatus(file, quality: quality);
    return result.file;
  }

  // Word document compression with status tracking
  static Future<CompressionResult> _compressWordDocumentWithStatus(File file) async {
    final dir = await getTemporaryDirectory();
    final filename = path.basenameWithoutExtension(file.path);
    final extension = path.extension(file.path).toLowerCase();
    final targetPath = path.join(dir.path, 'compressed_$filename$extension');

    try {
      // 1. Read the original file
      final bytes = await file.readAsBytes();

      // 2. Unzip the DOCX
      final archive = ZipDecoder().decodeBytes(bytes);

      // 3. Create a new archive for modified content
      final newArchive = Archive();

      // 4. Process each file in the DOCX
      for (final fileEntry in archive.files) {
        if (fileEntry.isFile) {
          var content = fileEntry.content as List<int>;

          // 5. Compress images (default quality 75)
          if (fileEntry.name.toLowerCase().contains('media/') ||
              _isImageFile(fileEntry.name)) {
            content = _compressImagefordocx(Uint8List.fromList(content), quality: 75);
          }

          // Add file to new archive with modified content
          newArchive.addFile(ArchiveFile(
            fileEntry.name,
            fileEntry.size,
            content,
          ));
        } else {
          // Add directories as-is
          newArchive.addFile(fileEntry);
        }
      }

      // 6. Re-zip with maximum compression
      final compressed = ZipEncoder().encode(newArchive, level: 9);

      // 7. Save the compressed file
      final resultFile = File(targetPath);
      await resultFile.writeAsBytes(compressed!);

      // Verify compression results
      final originalSize = file.lengthSync();
      final compressedSize = resultFile.lengthSync();
      final reduction = ((originalSize - compressedSize) / originalSize * 100);

      print('Word document compression results:');
      print('Original: ${_formatSizefordocx(originalSize)}');
      print('Compressed: ${_formatSizefordocx(compressedSize)}');
      print('Reduction: ${reduction.toStringAsFixed(1)}%');

      if (reduction > 5) { // Only consider as compressed if reduction > 5%
        return CompressionResult(
            file: resultFile,
            wasCompressed: true,
            message: 'Successfully compressed',
          compressedSize: compressedSize,
          originalSize: originalSize,
        );
      } else {
        await resultFile.delete();
        return CompressionResult(
            file: file,
            wasCompressed: false,
            message: 'Document is already optimized',
          originalSize: originalSize,
          compressedSize: compressedSize
        );
      }
    } catch (e) {
      print('Error compressing Word document: $e');
      return CompressionResult(
          file: file,
          wasCompressed: false,
          message: 'Error occurred during compression',
        compressedSize: 0,
        originalSize: 0
      );
    }
  }

  // Word document compression (legacy method)
  static Future<File> _compressWordDocument(File file) async {
    final result = await _compressWordDocumentWithStatus(file);
    return result.file;
  }

  // PPTX compression with status tracking
  static Future<CompressionResult> _compressPptxWithStatus(File file) async {
    final dir = await getTemporaryDirectory();
    final filename = path.basenameWithoutExtension(file.path);
    final extension = path.extension(file.path).toLowerCase();
    final targetPath = path.join(dir.path, 'compressed_$filename$extension');

    try {
      // Read the PPTX file
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final optimized = Archive();

      // Process each file in the PPTX archive
      for (final archiveFile in archive.files) {
        if (archiveFile.isFile) {
          // Compress images within the presentation
          if (archiveFile.name.startsWith('ppt/media/')) {
            final compressed = await _compressImageBytes(archiveFile.content as Uint8List);
            optimized.addFile(ArchiveFile(archiveFile.name, compressed.length, compressed));
          } else {
            // Add other files as-is
            optimized.addFile(archiveFile);
          }
        }
      }

      // Save the optimized PPTX
      final compressedBytes = ZipEncoder().encode(optimized);
      final resultFile = File(targetPath);
      await resultFile.writeAsBytes(compressedBytes!);

      // Check compression results
      final originalSize = file.lengthSync();
      final compressedSize = resultFile.lengthSync();
      final reduction = ((originalSize - compressedSize) / originalSize * 100);

      print('PPTX compression results:');
      print('Original: ${getReadableFileSize(originalSize)}');
      print('Compressed: ${getReadableFileSize(compressedSize)}');
      print('Reduction: ${reduction.toStringAsFixed(1)}%');

      if (reduction > 5) { // Only consider as compressed if reduction > 5%
        return CompressionResult(
            file: resultFile,
            wasCompressed: true,
            message: 'Successfully compressed',
            compressedSize: compressedSize,
            originalSize: originalSize
        );
      } else {
        await resultFile.delete();
        return CompressionResult(
            file: file,
            wasCompressed: false,
            message: 'Presentation is already optimized',
            compressedSize: compressedSize,
            originalSize: originalSize
        );
      }
    } catch (e) {
      print('PPTX compression error: $e');
      return CompressionResult(
          file: file,
          wasCompressed: false,
          message: 'Error occurred during compression',
          compressedSize: 0,
          originalSize: 0
      );
    }
  }

  // PPTX Compression (legacy method)
  static Future<File> _compressPptx(File file, String targetPath) async {
    final result = await _compressPptxWithStatus(file);
    return result.file;
  }

  // Additional aggressive image compression for very small files
  static Future<Uint8List> _aggressiveImageCompression(Uint8List imageBytes, int quality) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return imageBytes;

      // Resize image more aggressively for small files
      final resizedImage = img.copyResize(
        image,
        width: (image.width * 0.7).round(),
        height: (image.height * 0.7).round(),
        interpolation: img.Interpolation.average,
      );

      // Encode with very low quality
      return Uint8List.fromList(img.encodeJpg(resizedImage, quality: quality.clamp(20, 60)));
    } catch (e) {
      print('Error in aggressive image compression: $e');
      return imageBytes;
    }
  }

  // Helper method to compress image bytes
  static Future<Uint8List> _compressImageBytes(Uint8List imageBytes, {int quality = 85}) async {
    try {
      // Decode the image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        return imageBytes;
      }

      // Compress the image based on quality
      // Lower quality = more compression
      final compressQuality = quality.clamp(1, 100);

      // If quality is very low, reduce image resolution
      img.Image processedImage = image;
      if (quality < 50) {
        // Reduce resolution for very low quality settings
        final scale = 0.5 + (quality / 100);
        processedImage = img.copyResize(
          image,
          width: (image.width * scale).round(),
          height: (image.height * scale).round(),
          interpolation: img.Interpolation.average,
        );
      }

      // Encode back to JPEG with the specified quality
      return Uint8List.fromList(img.encodeJpg(processedImage, quality: compressQuality));
    } catch (e) {
      print('Error processing image bytes: $e');
      return imageBytes; // Return original on error
    }
  }

  // Helper function to check if a file is an image
  static bool _isImageFile(String filename) {
    final lower = filename.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg');
  }

  // Helper function to compress images
  static Uint8List _compressImagefordocx(Uint8List imageData, {int quality = 75}) {
    try {
      final image = img.decodeImage(imageData);
      if (image == null) return imageData;

      return Uint8List.fromList(img.encodeJpg(image, quality: quality));
    } catch (e) {
      return imageData;
    }
  }

  static String _formatSizefordocx(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

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