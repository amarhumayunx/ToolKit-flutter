// Helper class for storing DOCX page information
import 'dart:io';
import 'dart:math';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

class DocxPage {
  final String pageXml;
  final String previewText;

  DocxPage({required this.pageXml, required this.previewText});
}

// Helper class for storing split document results
class SplitDocumentResult {
  final int startPage;
  final int endPage;
  final String filePath;
  final String previewText;

  SplitDocumentResult({
    required this.startPage,
    required this.endPage,
    required this.filePath,
    required this.previewText,
  });
}

// Service class to handle DOCX splitting functionality
class DocxSplitterService {
  /// Extracts pages from the DOCX file
  Future<List<DocxPage>> extractPages(File docxFile) async {
    try {
      // Read the file as bytes
      final bytes = await docxFile.readAsBytes();

      // Extract the ZIP archive
      final archive = ZipDecoder().decodeBytes(bytes);

      if (archive.files.isEmpty) {
        throw Exception(
            "Could not read the file as a ZIP archive. The file might be corrupted.");
      }

      // Find the document.xml file
      final documentEntry = archive.findFile('word/document.xml');
      if (documentEntry == null) {
        // Try to print what files are in the archive for debugging
        final filesList = archive.files.map((f) => f.name).join(', ');
        throw Exception(
            "Invalid DOCX file: document.xml not found. Files in archive: $filesList");
      }

      // Extract the document content
      final documentContent = documentEntry.content as List<int>;
      if (documentContent.isEmpty) {
        throw Exception("Document content is empty");
      }

      final documentString = String.fromCharCodes(documentContent);

      // Parse XML
      final xmlDocument = XmlDocument.parse(documentString);

      // Find body element
      final bodyElements = xmlDocument.findAllElements('w:body');
      if (bodyElements.isEmpty) {
        throw Exception("Invalid DOCX structure: w:body element not found");
      }

      final bodyElement = bodyElements.first;

      // Find all paragraphs
      final paragraphs = bodyElement.findAllElements('w:p').toList();
      if (paragraphs.isEmpty) {
        // If no paragraphs, try to find any text content for debugging
        final allText =
        xmlDocument.findAllElements('w:t').map((e) => e.text).join(' ');
        if (allText.isNotEmpty) {
          throw Exception(
              "No paragraphs found, but document contains text: ${allText.substring(0, min(50, allText.length))}...");
        } else {
          throw Exception(
              "No paragraphs or text content found in the document");
        }
      }

      // Group paragraphs into pages (for demonstration, we'll use page breaks or just split by a fixed number)
      List<DocxPage> pages = [];
      List<XmlElement> currentPageParagraphs = [];

      for (final paragraph in paragraphs) {
        currentPageParagraphs.add(paragraph);

        // Check if this paragraph contains a page break
        final pageBreaks = paragraph
            .findAllElements('w:br')
            .where((br) => br.getAttribute('w:type') == 'page')
            .toList();

        final hasPageBreak = pageBreaks.isNotEmpty;

        if (hasPageBreak ||
            // For demonstration, also split every 5 paragraphs
            (currentPageParagraphs.length >= 5 &&
                pages.length < paragraphs.length ~/ 5)) {
          // Create a new page
          final pageXml = _buildPageXml(currentPageParagraphs);
          final previewText = _extractPreviewText(currentPageParagraphs);

          pages.add(DocxPage(
            pageXml: pageXml,
            previewText: previewText,
          ));

          currentPageParagraphs = [];
        }
      }

      // Add any remaining paragraphs as the last page
      if (currentPageParagraphs.isNotEmpty) {
        final pageXml = _buildPageXml(currentPageParagraphs);
        final previewText = _extractPreviewText(currentPageParagraphs);

        pages.add(DocxPage(
          pageXml: pageXml,
          previewText: previewText,
        ));
      }

      // If we couldn't detect any pages, create a single page with all content
      if (pages.isEmpty && paragraphs.isNotEmpty) {
        final pageXml = _buildPageXml(paragraphs);
        final previewText = _extractPreviewText(paragraphs);

        pages.add(DocxPage(
          pageXml: pageXml,
          previewText: previewText,
        ));
      }

      return pages;
    } catch (e, stackTrace) {
      print("Error extracting pages: $e");
      print("Stack trace: $stackTrace");
      rethrow; // Re-throw to be caught by the UI layer
    }
  }

  Future<File> rearrangeDocxPages(File originalFile, List<int> newPageOrder) async {
    try {
      // Extract all pages first
      final pages = await extractPages(originalFile);

      // Validate page order
      if (newPageOrder.any((index) => index >= pages.length)) {
        throw Exception('Invalid page order - index out of bounds');
      }

      // Create page ranges based on new order
      final pageRanges = newPageOrder.map((index) => [index]).toList();

      // Process the document
      final results = await splitDocxByRanges(originalFile, pageRanges);

      if (results.isEmpty) {
        throw Exception('No pages were processed');
      }

      // Return the first (and only) result file
      return File(results.first.filePath);
    } catch (e) {
      print('Error rearranging DOCX pages: $e');
      rethrow;
    }
  }

  Future<File> createDocumentFromPages(List<dynamic> pages, String outputPath) async {
    // This is a placeholder implementation
    // In a real app, you would:
    // 1. Create a new DOCX file
    // 2. Add each page's content to it
    // 3. Save to the output path

    // Simulate document creation with a delay
    await Future.delayed(const Duration(seconds: 3));

    // Create a dummy output file
    final outputFile = File(outputPath);
    // Write something to it
    await outputFile.writeAsString('This is a rearranged document with ${pages.length} pages.');

    return outputFile;
  }


  String _extractPreviewText(List<XmlElement> paragraphs) {
    final buffer = StringBuffer();

    for (final paragraph in paragraphs) {
      for (final textElement in paragraph.findAllElements('w:t')) {
        buffer.write(textElement.text);
      }
      buffer.write(' ');
    }

    final fullText = buffer.toString().trim();
    return fullText.length > 50 ? '${fullText.substring(0, 47)}...' : fullText;
  }

  // Add this method to your existing DocxSplitterService class

  Future<File> createDocumentFromPagesWithOriginal(
      List<DocxPage> pages,
      String outputPath,
      File originalFile
      ) async {
    try {
      if (pages.isEmpty) {
        throw Exception("No pages provided for document creation");
      }

      final originalBytes = await originalFile.readAsBytes();
      final originalArchive = ZipDecoder().decodeBytes(originalBytes);
      final newArchive = Archive();

      // Copy all files except document.xml from original
      for (final file in originalArchive.files) {
        if (!file.isFile || file.name == 'word/document.xml') continue;
        newArchive.addFile(ArchiveFile(file.name, file.size, file.content));
      }

      // Create new document.xml with selected pages
      final combinedXml = combinePages(pages);
      final docFile = ArchiveFile(
        'word/document.xml',
        combinedXml.length,
        combinedXml.codeUnits,
      );
      newArchive.addFile(docFile);

      // Encode and save
      final docxBytes = ZipEncoder().encode(newArchive);
      if (docxBytes == null) {
        throw Exception("Failed to encode DOCX file");
      }

      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(docxBytes);

      // Verify file creation
      if (!await outputFile.exists()) {
        throw Exception("Output file was not created");
      }

      print("Successfully created DOCX: $outputPath");
      return outputFile;

    } catch (e) {
      print("Error creating document: $e");
      // Fallback: copy original file
      final outputFile = File(outputPath);
      await originalFile.copy(outputPath);
      return outputFile;
    }
  }

  /// Build XML content for a page
  String _buildPageXml(List<XmlElement> paragraphs) {
    // Instead of creating a new XML document with potentially conflicting namespace prefixes,
    // we'll construct a valid document structure while preserving the original paragraphs as-is

    // Start with a basic XML header and document structure
    const xmlHeader =
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n';
    const namespaces = '''
      xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
      xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
      xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
      xmlns:m="http://schemas.openxmlformats.org/wordprocessingml/2006/math"
      xmlns:v="urn:schemas-microsoft-com:vml"
      xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
      xmlns:w10="urn:schemas-microsoft-com:office:word"
      xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing"
      xmlns:wpg="http://schemas.microsoft.com/office/word/2010/wordprocessingGroup"
      xmlns:wpi="http://schemas.microsoft.com/office/word/2010/wordprocessingInk"
      xmlns:wne="http://schemas.microsoft.com/office/word/2006/wordml"
      xmlns:wps="http://schemas.microsoft.com/office/word/2010/wordprocessingShape"
    ''';

    const documentOpen = '<w:document $namespaces>\n';
    const documentClose = '</w:document>';
    const bodyOpen = '<w:body>\n';
    const bodyClose = '</w:body>\n';

    // Build the page content by concatenating strings instead of using XmlBuilder
    String pageContent = '';
    for (final paragraph in paragraphs) {
      // Use the original XML string representation instead of rebuilding it
      pageContent += '${paragraph.toXmlString()}\n';
    }

    // Assemble the complete document
    return xmlHeader +
        documentOpen +
        bodyOpen +
        pageContent +
        bodyClose +
        documentClose;
  }

  /// Extract preview text from paragraphs
  // String _extractPreviewText(List<XmlElement> paragraphs) {
  //   String text = '';
  //
  //   for (final paragraph in paragraphs) {
  //     final textElements = paragraph.findAllElements('w:t');
  //     for (final textElement in textElements) {
  //       text += textElement.text;
  //     }
  //   }
  //
  //   // Limit preview length
  //   if (text.length > 50) {
  //     text = '${text.substring(0, 47)}...';
  //   }
  //
  //   return text;
  // }

  /// Split the DOCX file by page ranges
  /// Each entry in rangesList is a list of consecutive page indices to include in one document
  Future<List<SplitDocumentResult>> splitDocxByRanges(
      File docxFile, List<List<int>> rangesList) async {
    try {
      // Get the document pages
      final pages = await extractPages(docxFile);

      // Read the original DOCX as an archive
      final bytes = await docxFile.readAsBytes();
      final originalArchive = ZipDecoder().decodeBytes(bytes);

      // Create output directory
      final outputDir = await _createOutputDirectory();
      final fileName = path.basenameWithoutExtension(docxFile.path);

      List<SplitDocumentResult> results = [];

      // For each range, create a new DOCX
      for (int i = 0; i < rangesList.length; i++) {
        final pageIndices = rangesList[i];
        if (pageIndices.isEmpty) continue;

        // Get start and end page numbers for this range (1-based for display)
        final startPage = pageIndices.first + 1;
        final endPage = pageIndices.last + 1;

        // Create new archive for this split
        final newArchive = Archive();

        // Copy all files from the original archive except document.xml
        for (final file in originalArchive.files) {
          if (!file.isFile) continue;

          if (file.name == 'word/document.xml') {
            // Skip the original document.xml, we'll create our own
            continue;
          }

          // Add the file to the new archive with the correct constructor parameters
          newArchive.addFile(ArchiveFile(
            file.name,
            file.size,
            file.content,
          ));
        }

        // Combine XML for all pages in this range
        final combinedPagesXml = combinePages(
          pageIndices.map((index) => pages[index]).toList(),
        );

        // Create new document.xml with the combined pages
        final docFile = ArchiveFile(
          'word/document.xml',
          combinedPagesXml.length,
          combinedPagesXml.codeUnits,
        );
        newArchive.addFile(docFile);

        // Encode the archive to bytes
        final newDocxBytes = ZipEncoder().encode(newArchive);
        if (newDocxBytes == null) {
          throw Exception("Failed to encode the new DOCX file");
        }

        // Save the new DOCX file
        final outputPath = path.join(
          outputDir.path,
          '${fileName}_pages_$startPage-$endPage.docx',
        );
        await File(outputPath).writeAsBytes(newDocxBytes);

        // Create a preview text that shows the page range
        String previewText = "Content from pages $startPage-$endPage";
        if (pageIndices.length == 1) {
          // If it's just one page, show a content preview
          previewText = pages[pageIndices[0]].previewText;
        } else {
          // For multiple pages, show a brief content preview from the first page
          previewText += ": ${pages[pageIndices[0]].previewText}";
        }

        // Add to results
        results.add(SplitDocumentResult(
          startPage: startPage,
          endPage: endPage,
          filePath: outputPath,
          previewText: previewText,
        ));
      }

      return results;
    } catch (e, stackTrace) {
      print("Error splitting document by ranges: $e");
      print("Stack trace: $stackTrace");
      rethrow;
    }
  }
  /// Combine multiple pages into a single document XML
  String combinePages(List<DocxPage> pages) {
    if (pages.isEmpty) {
      throw Exception("No pages to combine");
    }

    // Parse the first page to use as a template
    final firstPageXml = XmlDocument.parse(pages[0].pageXml);

    // Find the body element where we'll insert content from other pages
    final bodyElements = firstPageXml.findAllElements('w:body');
    if (bodyElements.isEmpty) {
      throw Exception("Invalid document structure: w:body element not found");
    }

    final bodyElement = bodyElements.first;

    // Clear the current body content
    bodyElement.children.clear();

    // For each page, extract paragraphs and add to the body
    for (int i = 0; i < pages.length; i++) {
      final page = pages[i];
      final pageDoc = XmlDocument.parse(page.pageXml);

      // Find paragraphs in this page
      final paragraphs = pageDoc.findAllElements('w:p');

      // Add each paragraph to the body
      for (final paragraph in paragraphs) {
        // Remove the paragraph from its original parent to avoid issues
        if (paragraph.parent != null) {
          paragraph.remove();
        }

        // Add to our new document body
        bodyElement.children.add(paragraph);
      }

      // Add a page break after each page except the last one
      if (i < pages.length - 1) {
        // Create a page break paragraph
        final pageBreakPara = XmlElement(
          XmlName('w:p'),
          [],
          [
            XmlElement(
              XmlName('w:r'),
              [],
              [
                XmlElement(
                  XmlName('w:br'),
                  [XmlAttribute(XmlName('w:type'), 'page')],
                  [],
                ),
              ],
            ),
          ],
        );

        bodyElement.children.add(pageBreakPara);
      }
    }

    // Return the combined document as a string
    return firstPageXml.toXmlString();
  }
  /// Create an output directory for split files
  Future<Directory> _createOutputDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final outputDir = Directory(path.join(
        tempDir.path, 'docx_splits_${DateTime.now().millisecondsSinceEpoch}'));

    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    return outputDir;
  }
}