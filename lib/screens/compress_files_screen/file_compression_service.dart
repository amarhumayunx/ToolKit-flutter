import 'dart:io';
import 'dart:typed_data';
import 'package:aspose_words_cloud/aspose_words_cloud.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:pdf/pdf.dart';
import 'package:archive/archive.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import 'package:pdfx/pdfx.dart' as pdfx;

class FileCompressor {

  static final _asposeConfig = Configuration(
    "137d1b4a-71de-436a-bec5-8ebfab22631b", // Replace with your App SID
    "0552d6d00589255acd503e1207238a60",  // Replace with your App Key
  );
  static final _wordsApi = WordsApi(_asposeConfig);

  // Main compression function that handles different file types
  static Future<File?> compressFile(File file, {int quality = 85}) async {
    final extension = path.extension(file.path).toLowerCase();

    try {
      switch (extension) {
        case '.jpg':
        case '.jpeg':
        case '.png':
          return await _compressImageforimg(file, quality: quality);
        case '.pdf':
          return await compressPdf(file, quality: quality);
        case '.doc':
        case '.docx':
          return await _compressWordDocument(file);
        case '.ppt':
        case '.pptx':
          return await _compressPptx(file, file.path);
        default:
          return file;
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

  // Image compression using flutter_image_compress
  static Future<File> _compressImageforimg(File file, {int quality = 85}) async {
    // First check if file exists
    if (!file.existsSync()) {
      print('File does not exist: ${file.path}');
      throw FileSystemException('File not found', file.path);
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
        return file; // Return original if compression fails
      }

      // Verify the compressed file exists and has content
      final resultFile = File(result.path);
      if (!resultFile.existsSync() || resultFile.lengthSync() <= 0) {
        print('Compressed file is empty or does not exist: ${result.path}');
        return file;
      }

      // Compare sizes and return the smaller one
      if (resultFile.lengthSync() < file.lengthSync()) {
        print('Successfully compressed: ${file.path}');
        print('Original: ${getReadableFileSize(file.lengthSync())} → Compressed: ${getReadableFileSize(resultFile.lengthSync())}');
        return resultFile;
      } else {
        print('Compression did not reduce file size for: ${file.path}');
        // Remove the compressed file since it's larger
        await resultFile.delete();
        return file;
      }
    } catch (e) {
      print('Error compressing image: $e');
      // More detailed error logging
      if (e is FileSystemException) {
        print('File system error: ${e.message}, ${e.path}');
      }
      return file; // Return original on error
    }
  }

  // PDF compression functionality while preserving original content
  static Future<File> compressPdf(File file, {int quality = 85}) async {
    if (!file.existsSync()) {
      print('PDF file does not exist: ${file.path}');
      throw FileSystemException('File not found', file.path);
    }

    final dir = await getTemporaryDirectory();
    final filename = path.basenameWithoutExtension(file.path);
    final targetPath = path.join(dir.path, 'compressed_${filename}_$quality.pdf');

    try {
      // Open the PDF document using pdfx
      final pdfDocument = await pdfx.PdfDocument.openFile(file.path);

      // Create a new PDF document with compression settings
      final pdf = pw.Document();

      // Process each page of the original document
      for (int i = 0; i < pdfDocument.pagesCount; i++) {
        final page = await pdfDocument.getPage(i + 1);
        final pageImage = await page.render(
          width: page.width,
          height: page.height,
          format: pdfx.PdfPageImageFormat.jpeg,
          backgroundColor: '#FFFFFF',
          // quality is between 0 and 100 in pdfx
          quality: quality,
        );

        if (pageImage != null) {
          // Create a page from the compressed image
          final image = pw.MemoryImage(pageImage.bytes);
          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat(
                page.width,
                page.height,
                marginAll: 0,
              ),
              build: (pw.Context context) {
                return pw.Center(
                  child: pw.Image(image, fit: pw.BoxFit.contain),
                );
              },
            ),
          );
        }
      }

      // Save the compressed PDF
      final compressedPdfBytes = await pdf.save();
      final resultFile = File(targetPath);
      await resultFile.writeAsBytes(compressedPdfBytes);

      // Compare file sizes
      final originalSize = file.lengthSync();
      final compressedSize = resultFile.lengthSync();

      print('PDF compression results:');
      print('Original: ${getReadableFileSize(originalSize)}');
      print('Compressed: ${getReadableFileSize(compressedSize)}');

      // Check if compression was effective
      if (compressedSize < originalSize) {
        print('Successfully compressed PDF: ${((originalSize - compressedSize) / originalSize * 100).toStringAsFixed(2)}% reduction');
        return resultFile;
      } else {
        print('Compression did not reduce file size, using original');
        await resultFile.delete();
        return file;
      }
    } catch (e) {
      print('Error compressing PDF: $e');
      return file; // Return original on error
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

  // Helper function to format file sizes
  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static Future<File> _compressWordDocument(File file) async {
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

      print('Word document compression results:');
      print('Original: ${_formatSizefordocx(originalSize)}');
      print('Compressed: ${_formatSizefordocx(compressedSize)}');
      print('Reduction: ${((originalSize - compressedSize) / originalSize * 100).toStringAsFixed(1)}%');

      if (compressedSize < originalSize) {
        return resultFile;
      } else {
        await resultFile.delete();
        return file;
      }
    } catch (e) {
      print('Error compressing Word document: $e');
      return file;
    }
  }

  // Helper function to check if a file is an image
  static bool _isImageFilefordocx(String filename) {
    final lower = filename.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg');
  }

  // Helper function to compress images
  static Uint8List _compressImage(Uint8List imageData, {int quality = 75}) {
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

  // PPTX Compression
  static Future<File> _compressPptx(File file, String targetPath) async {
    try {
      // Read the PPTX file
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final optimized = Archive();

      // Process each file in the PPTX archive
      for (final file in archive.files) {
        if (file.isFile) {
          // Compress images within the presentation
          if (file.name.startsWith('ppt/media/')) {
            final compressed = await _compressImageBytes(file.content as Uint8List);
            optimized.addFile(ArchiveFile(file.name, compressed.length, compressed));
          } else {
            // Add other files as-is
            optimized.addFile(file);
          }
        }
      }

      // Save the optimized PPTX
      final compressedBytes = ZipEncoder().encode(optimized);
      final resultFile = File(targetPath);
      await resultFile.writeAsBytes(compressedBytes!);
      return resultFile;
    } catch (e) {
      print('PPTX compression error: $e');
      return file;
    }
  }

  static Future<File> _compressOfficeFile(
      File file,
      String targetPath,
      String mediaPath,
      ) async {
    try {
      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final optimized = Archive();

      for (final file in archive.files) {
        if (file.isFile) {
          // Compress images in the media directory
          if (file.name.startsWith(mediaPath)) {
            final compressed = await _compressImageBytes(file.content as Uint8List);
            optimized.addFile(ArchiveFile(
              file.name,
              compressed.length,
              compressed,
            ));
          } else {
            // Add other files unchanged
            optimized.addFile(file);
          }
        }
      }

      final compressedBytes = ZipEncoder().encode(optimized);
      return await File(targetPath).writeAsBytes(compressedBytes!);
    } catch (e) {
      print('Office file compression error: $e');
      return file;
    }
  }

  // For legacy .doc files (requires external conversion)
  static Future<File> _compressLegacyWordDoc(File file, String targetPath) async {
    try {
      // Convert to DOCX first
      final docxBytes = await _convertDocToDocx(file);
      if (docxBytes != null) {
        final tempPath = '${targetPath}x'; // Add 'x' to make it .docx
        final tempFile = File(tempPath);
        await tempFile.writeAsBytes(docxBytes);

        // Now compress as DOCX
        final result = await _compressOfficeFile(tempFile, targetPath, 'word/media/');

        // Clean up temporary file
        await tempFile.delete();

        return result;
      }
      return file;
    } catch (e) {
      print('Legacy DOC compression error: $e');
      return file;
    }
  }

  // For legacy .ppt files (requires external conversion)
  static Future<File> _compressLegacyPowerPoint(File file, String targetPath) async {
    try {
      // Convert to PPTX first (requires external library or service)
      final pptxBytes = await _convertPptToPptx(file);
      if (pptxBytes != null) {
        final tempPptx = File('${targetPath}x');
        await tempPptx.writeAsBytes(pptxBytes);
        return await _compressPptx(tempPptx, targetPath);
      }
      return file;
    } catch (e) {
      print('Legacy PPT compression error: $e');
      return file;
    }
  }


  static Future<Uint8List?> _convertDocToDocx(File file) async {
    return null;
  }


  static Future<Uint8List?> _convertPptToPptx(File file) async {

    return null;
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