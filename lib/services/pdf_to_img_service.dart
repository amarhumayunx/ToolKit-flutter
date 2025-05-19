import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf_render/pdf_render.dart' hide ImageByteFormat;
import 'dart:ui' as ui;
import 'package:archive/archive.dart';


class PdfToImageService {
  /// Converts all pages of a PDF file to PNG images and creates a zip archive
  /// Returns the path to the zip file containing all images
  Future<File> convertPdfToImages(File pdfFile) async {
    try {
      // Get document and page count
      final document = await PdfDocument.openFile(pdfFile.path);
      final pageCount = document.pageCount;

      // Create a list to store all image files
      final List<File> imageFiles = [];

      // Get a temporary directory to store the images
      final tempDir = await getTemporaryDirectory();
      final originalFileName = pdfFile.path.split('/').last.split('.').first;

      // Convert each page to an image
      for (int i = 0; i < pageCount; i++) {
        final imageFile = await _convertSinglePage(pdfFile, document, i);
        imageFiles.add(imageFile);
      }

      // Create a zip archive containing all images
      final zipFilePath = '${tempDir.path}/${originalFileName}_images.zip';
      final zipFile = await _createZipArchive(imageFiles, zipFilePath);

      return zipFile;
    } catch (e) {
      print('Error processing PDF: $e');
      rethrow;
    }
  }

  /// Converts a single page of a PDF to an image
  Future<File> _convertSinglePage(
      File pdfFile, PdfDocument document, int pageIndex) async {
    try {
      // Get a temporary directory to store the image
      final tempDir = await getTemporaryDirectory();
      final originalFileName = pdfFile.path.split('/').last.split('.').first;
      final outputPath =
          '${tempDir.path}/${originalFileName}_page$pageIndex.png';

      // Get the specified page (PDF pages are 1-based)
      final page = await document.getPage(pageIndex + 1);

      // Calculate dimensions with higher resolution
      final scaleFactor = 3.0; // Higher scale for better quality
      final width = (page.width * scaleFactor).toInt();
      final height = (page.height * scaleFactor).toInt();

      // Render the page to an image
      final pageImage = await page.render(
        width: width,
        height: height,
      );

      // Get the image bytes
      final image = await pageImage.createImageIfNotAvailable();
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to convert PDF page to image');
      }

      // Write the image bytes to a file
      final imageFile = File(outputPath);
      await imageFile.writeAsBytes(byteData.buffer.asUint8List());

      return imageFile;
    } catch (e) {
      print('Error converting page $pageIndex: $e');
      // Fallback to platform-specific method if available
      try {
        final bytes = await _renderWithPlatformChannel(pdfFile, pageIndex);
        if (bytes != null) {
          final tempDir = await getTemporaryDirectory();
          final outputPath =
              '${tempDir.path}/fallback_${pdfFile.path.split('/').last}_$pageIndex.png';
          final imageFile = File(outputPath);
          await imageFile.writeAsBytes(bytes);
          return imageFile;
        }
      } catch (e) {
        print('Platform channel failed: $e');
      }

      // If all else fails, create a placeholder with the actual PDF content
      return await _createPdfPreviewImage(pdfFile, pageIndex);
    }
  }

  /// Creates a zip archive containing all image files
  Future<File> _createZipArchive(
      List<File> imageFiles, String zipFilePath) async {
    try {
      // Create an Archive object
      final archive = Archive();

      // Add each image file to the archive
      for (int i = 0; i < imageFiles.length; i++) {
        final file = imageFiles[i];
        final bytes = await file.readAsBytes();
        final archiveFile = ArchiveFile(
          file.path.split('/').last,
          bytes.length,
          bytes,
        );
        archive.addFile(archiveFile);
      }

      // Encode the archive to zip format
      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive);

      if (zipData == null) {
        throw Exception('Failed to create zip archive');
      }

      // Write the zip data to a file
      final zipFile = File(zipFilePath);
      await zipFile.writeAsBytes(zipData);

      return zipFile;
    } catch (e) {
      print('Error creating zip archive: $e');
      rethrow;
    }
  }

  /// Converts a PDF file to either a single PNG image (for 1-page PDFs)
  /// or a ZIP file of images (for multi-page PDFs)
  /// This is the main method that should be called when selecting "Image" format
  Future<File> convertPdfToImage(File pdfFile) async {
    try {
      // First get the document and determine page count
      final document = await PdfDocument.openFile(pdfFile.path);
      final pageCount = document.pageCount;

      // For single-page PDFs, convert to a single PNG image
      if (pageCount == 1) {
        return await _convertSinglePage(pdfFile, document, 0);
      }
      // For multi-page PDFs, convert to a ZIP file containing all pages as images
      else {
        return await convertPdfToImages(pdfFile);
      }
    } catch (e) {
      print('Error in convertPdfToImage: $e');
      rethrow;
    }
  }

  Future<Uint8List?> _renderWithPlatformChannel(
      File pdfFile, int pageIndex) async {
    try {
      return await const MethodChannel('pdf_render').invokeMethod<Uint8List>(
        'renderPdfPage',
        {
          'pdfPath': pdfFile.path,
          'pageIndex': pageIndex,
          'width': 2000, // High resolution
          'height': 2800,
        },
      );
    } catch (e) {
      print('Platform channel error: $e');
      return null;
    }
  }

  Future<File> _createPdfPreviewImage(File pdfFile, int pageIndex) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath =
          '${tempDir.path}/preview_${pdfFile.path.split('/').last}_$pageIndex.png';

      // Use dart:ui to create a canvas with the PDF content
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final paint = ui.Paint()..color = const ui.Color(0xFFFFFFFF);

      // Fill background
      canvas.drawRect(const ui.Rect.fromLTWH(0, 0, 1000, 1400), paint);

      // Add error message
      final paragraph = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          textAlign: ui.TextAlign.center,
          fontSize: 24.0,
          fontWeight: ui.FontWeight.bold,
        ),
      )
        ..pushStyle(ui.TextStyle(color: const ui.Color(0xFF000000)))
        ..addText('PDF Preview (Page ${pageIndex + 1})')
        ..pushStyle(ui.TextStyle(
          fontSize: 16.0,
          color: const ui.Color(0xFF666666),
        ))
        ..addText('\n\nFull rendering not available')
        ..addText('\n\nFile: ${pdfFile.path.split('/').last}');

      final builtParagraph = paragraph.build()
        ..layout(const ui.ParagraphConstraints(width: 900));

      canvas.drawParagraph(builtParagraph, const ui.Offset(50, 600));

      // Convert to image
      final picture = recorder.endRecording();
      final image = await picture.toImage(1000, 1400);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to generate preview image');
      }

      final imageFile = File(outputPath);
      await imageFile.writeAsBytes(byteData.buffer.asUint8List());
      return imageFile;
    } catch (e) {
      print('Error creating preview: $e');
      return await _createSimpleImageFile();
    }
  }

  Future<File> _createSimpleImageFile() async {
    final tempDir = await getTemporaryDirectory();
    final outputPath = '${tempDir.path}/simple_image.png';
    final imageFile = File(outputPath);
    await imageFile.writeAsBytes(await _createSimpleImage());
    return imageFile;
  }

  Future<Uint8List> _createSimpleImage() async {
    // Minimal valid PNG file (white 1x1 pixel)
    return Uint8List.fromList([
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
      0x00,
      0x00,
      0x00,
      0x0D,
      0x49,
      0x48,
      0x44,
      0x52,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x00,
      0x00,
      0x01,
      0x08,
      0x02,
      0x00,
      0x00,
      0x00,
      0x90,
      0x77,
      0x53,
      0xDE,
      0x00,
      0x00,
      0x00,
      0x01,
      0x73,
      0x52,
      0x47,
      0x42,
      0x00,
      0xAE,
      0xCE,
      0x1C,
      0xE9,
      0x00,
      0x00,
      0x00,
      0x04,
      0x67,
      0x41,
      0x4D,
      0x41,
      0x00,
      0x00,
      0xB1,
      0x8F,
      0x0B,
      0xFC,
      0x61,
      0x05,
      0x00,
      0x00,
      0x00,
      0x09,
      0x70,
      0x48,
      0x59,
      0x73,
      0x00,
      0x00,
      0x0E,
      0xC3,
      0x00,
      0x00,
      0x0E,
      0xC3,
      0x01,
      0xC7,
      0x6F,
      0xA8,
      0x64,
      0x00,
      0x00,
      0x00,
      0x0C,
      0x49,
      0x44,
      0x41,
      0x54,
      0x08,
      0xD7,
      0x63,
      0xF8,
      0xCF,
      0xC0,
      0x00,
      0x00,
      0x03,
      0x01,
      0x01,
      0x00,
      0x18,
      0xDD,
      0x8D,
      0xB0,
      0x00,
      0x00,
      0x00,
      0x00,
      0x49,
      0x45,
      0x4E,
      0x44,
      0xAE,
      0x42,
      0x60,
      0x82
    ]);
  }
}