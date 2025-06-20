import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class WordToImageService {

  /// Converts a Word document to an image file
  Future<File> convertWordToImage(File wordFile, {
    int width = 800,
    int height = 1200,
    int fontSize = 16,
    String outputFormat = 'png',
  }) async {
    try {
      // Read the Word file
      final bytes = await wordFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Extract text content from the Word document
      String textContent = await _extractTextFromDocx(archive);

      // Create an image with the text content
      final image = img.Image(width: width, height: height);
      img.fill(image, color: img.ColorRgb8(255, 255, 255)); // White background

      // Process and render text
      await _renderTextOnImage(image, textContent, fontSize, width, height);

      // Create output file path
      final outputDir = await getTemporaryDirectory();
      final fileName = wordFile.path.split('/').last.replaceAll('.docx', '.${outputFormat}');
      final outputFile = File('${outputDir.path}/$fileName');

      // Encode and save image
      List<int> imageBytes;
      if (outputFormat.toLowerCase() == 'jpg' || outputFormat.toLowerCase() == 'jpeg') {
        imageBytes = img.encodeJpg(image, quality: 90);
      } else {
        imageBytes = img.encodePng(image);
      }

      await outputFile.writeAsBytes(imageBytes);

      return outputFile;

    } catch (e) {
      throw Exception('Failed to convert Word to Image: $e');
    }
  }

  /// Converts Word document to multiple images (one per page simulation)
  Future<List<File>> convertWordToMultipleImages(File wordFile, {
    int width = 800,
    int height = 1200,
    int fontSize = 16,
    int linesPerPage = 50,
  }) async {
    try {
      final bytes = await wordFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      String textContent = await _extractTextFromDocx(archive);
      final lines = _wrapText(textContent, width ~/ (fontSize * 0.6).round());

      List<File> imageFiles = [];
      final outputDir = await getTemporaryDirectory();
      final baseFileName = wordFile.path.split('/').last.replaceAll('.docx', '');

      // Split text into pages
      for (int pageIndex = 0; pageIndex < lines.length; pageIndex += linesPerPage) {
        final pageLines = lines.skip(pageIndex).take(linesPerPage).toList();

        // Create image for this page
        final image = img.Image(width: width, height: height);
        img.fill(image, color: img.ColorRgb8(255, 255, 255));

        await _renderLinesOnImage(image, pageLines, fontSize);

        // Save page image
        final pageFileName = '${baseFileName}_page_${(pageIndex ~/ linesPerPage) + 1}.png';
        final pageFile = File('${outputDir.path}/$pageFileName');

        final imageBytes = img.encodePng(image);
        await pageFile.writeAsBytes(imageBytes);

        imageFiles.add(pageFile);
      }

      return imageFiles;

    } catch (e) {
      throw Exception('Failed to convert Word to multiple images: $e');
    }
  }

  /// Extracts all embedded images from Word document
  Future<List<File>> extractImagesFromWord(File wordFile) async {
    try {
      final bytes = await wordFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      List<File> extractedImages = [];
      final outputDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Find all media files (images) in the archive
      for (final file in archive) {
        if (file.name.startsWith('word/media/') && file.isFile) {
          final extension = _getFileExtension(file.name);
          if (_isImageFile(extension)) {
            final imageName = 'extracted_${timestamp}_${extractedImages.length + 1}.$extension';
            final imagePath = '${outputDir.path}/$imageName';

            final imageFile = File(imagePath);
            await imageFile.writeAsBytes(file.content as List<int>);
            extractedImages.add(imageFile);
          }
        }
      }

      return extractedImages;
    } catch (e) {
      throw Exception('Failed to extract images from Word: $e');
    }
  }

  /// Shares the converted image document
  Future<void> shareDocument(File imageFile) async {
    try {
      await Share.shareXFiles(
        [XFile(imageFile.path)],
        text: 'Converted Image from Word Document',
      );
    } catch (e) {
      throw Exception('Failed to share image: $e');
    }
  }

  /// Shares multiple image files
  Future<void> shareMultipleDocuments(List<File> imageFiles) async {
    try {
      final xFiles = imageFiles.map((file) => XFile(file.path)).toList();
      await Share.shareXFiles(
        xFiles,
        text: 'Converted Images from Word Document',
      );
    } catch (e) {
      throw Exception('Failed to share images: $e');
    }
  }

  /// Gets the file size in a readable format
  String getFormattedFileSize(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Gets total size of multiple files
  String getFormattedTotalSize(List<File> files) {
    final totalBytes = files.fold<int>(0, (sum, file) => sum + file.lengthSync());
    if (totalBytes < 1024) return '$totalBytes B';
    if (totalBytes < 1024 * 1024) return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
    return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Private helper methods

  Future<String> _extractTextFromDocx(Archive archive) async {
    // Find document.xml
    for (final file in archive) {
      if (file.name == 'word/document.xml') {
        final xmlContent = utf8.decode(file.content as List<int>);
        final document = XmlDocument.parse(xmlContent);

        // Extract text from all <w:t> elements
        final textElements = document.findAllElements('w:t');
        final textBuffer = StringBuffer();

        for (final element in textElements) {
          textBuffer.write(element.innerText);
          textBuffer.write(' ');
        }

        return textBuffer.toString().trim();
      }
    }

    return 'No text content found in document';
  }

  Future<void> _renderTextOnImage(img.Image image, String text, int fontSize, int width, int height) async {
    final lines = _wrapText(text, width ~/ (fontSize * 0.6).round());
    await _renderLinesOnImage(image, lines, fontSize);
  }

  Future<void> _renderLinesOnImage(img.Image image, List<String> lines, int fontSize) async {
    int y = 50;
    final lineHeight = fontSize + 8;
    final textColor = img.ColorRgb8(0, 0, 0); // Black text

    for (final line in lines) {
      if (y + lineHeight > image.height - 50) break; // Don't overflow

      // Simple text rendering using rectangles (basic implementation)
      _drawTextLine(image, line, 50, y, fontSize, textColor);
      y += lineHeight;
    }
  }

  void _drawTextLine(img.Image image, String text, int x, int y, int fontSize, img.Color color) {
    // This is a basic text representation using rectangles
    // For production use, consider using a proper text rendering library

    final charWidth = (fontSize * 0.6).round();
    int currentX = x;

    for (int i = 0; i < text.length && currentX < image.width - 50; i++) {
      final char = text[i];
      if (char != ' ') {
        // Draw a simple rectangle for each character
        _drawCharacter(image, char, currentX, y, fontSize, color);
      }
      currentX += charWidth;
    }
  }

  void _drawCharacter(img.Image image, String char, int x, int y, int fontSize, img.Color color) {
    // Very basic character representation
    // In production, you'd want to use actual font rendering

    final charWidth = (fontSize * 0.6).round();
    final charHeight = fontSize;

    // Draw different patterns based on character type
    if (char.contains(RegExp(r'[A-Z]'))) {
      // Capital letters - taller rectangle
      img.fillRect(image, x1: x, y1: y, x2: x + charWidth, y2: y + charHeight, color: color);
    } else if (char.contains(RegExp(r'[a-z]'))) {
      // Lowercase letters - shorter rectangle
      img.fillRect(image, x1: x, y1: y + (charHeight ~/ 4), x2: x + charWidth, y2: y + charHeight, color: color);
    } else if (char.contains(RegExp(r'[0-9]'))) {
      // Numbers - medium rectangle
      img.fillRect(image, x1: x, y1: y + (charHeight ~/ 6), x2: x + charWidth, y2: y + charHeight, color: color);
    } else {
      // Special characters - small rectangle
      img.fillRect(image, x1: x, y1: y + (charHeight ~/ 2), x2: x + charWidth, y2: y + charHeight, color: color);
    }
  }

  List<String> _wrapText(String text, int maxCharsPerLine) {
    final words = text.split(' ');
    final lines = <String>[];
    StringBuffer currentLine = StringBuffer();

    for (final word in words) {
      if (currentLine.length + word.length + 1 <= maxCharsPerLine) {
        if (currentLine.isNotEmpty) currentLine.write(' ');
        currentLine.write(word);
      } else {
        if (currentLine.isNotEmpty) {
          lines.add(currentLine.toString());
          currentLine = StringBuffer();
        }
        currentLine.write(word);
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine.toString());
    }

    return lines;
  }

  String _getFileExtension(String filename) {
    return filename.split('.').last.toLowerCase();
  }

  bool _isImageFile(String extension) {
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff', 'webp'].contains(extension);
  }
}

// Usage example:
/*
void main() async {
  final service = WordToImageService();
  final wordFile = File('path/to/document.docx');

  // Convert to single image
  final imageFile = await service.convertWordToImage(wordFile);
  print('Converted to: ${imageFile.path}');

  // Convert to multiple images (pages)
  final multipleImages = await service.convertWordToMultipleImages(wordFile);
  print('Created ${multipleImages.length} page images');

  // Extract embedded images
  final extractedImages = await service.extractImagesFromWord(wordFile);
  print('Extracted ${extractedImages.length} images');

  // Share the converted image
  await service.shareDocument(imageFile);
}
*/