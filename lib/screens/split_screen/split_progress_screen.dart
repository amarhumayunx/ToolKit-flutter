import 'dart:io';
import 'dart:math';


import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusion;
import 'package:archive/archive.dart';
import 'package:toolkit/utils/app_colors.dart';
import 'package:xml/xml.dart';
import 'package:path/path.dart' as path;

import '../../widgets/buttons/gradient_btn.dart';
import '../../widgets/custom_appbar.dart';
import 'document_item.dart';

class SplitProgressScreen extends StatefulWidget {
  final DocumentItem document;
  final List<bool> selectedPages;
  final bool isMultipleFiles; // Add this property
  final List<DocumentItem> documents; // Add this property

  const SplitProgressScreen({
    super.key,
    required this.document,
    required this.selectedPages,
    this.isMultipleFiles = false, // Default to false
    this.documents = const [], // Default to empty list
  });

  @override
  State<SplitProgressScreen> createState() => _SplitProgressScreenState();
}

class _SplitProgressScreenState extends State<SplitProgressScreen> with SingleTickerProviderStateMixin {

  final TextEditingController _textController = TextEditingController();
  bool _isLoading = true;
  bool _animationCompleted = false;
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  bool _isCompleted = false;
  double _progress = 0.0;
  File? _outputFile;
  final String _resultText = '';
  String _statusMessage = "Initializing...";

  // DocxSplitterService to handle DOCX processing
  final DocxSplitterService _docxService = DocxSplitterService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _progressAnimation.addListener(() {
      setState(() {});
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isLoading = false;
          _animationCompleted = true;
          _textController.text = _resultText;
        });
      }
    });

    _animationController.forward();
    _startSplitting();
  }

  String _formatDateTime(DateTime dateTime) {
    final date = DateFormat('dd-MM-yy').format(dateTime);
    final time = DateFormat('h:mma').format(dateTime).toLowerCase();
    return '$date | $time';
  }


  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.save),
                title: const Text('Save Document'),
                onTap: () async {
                  Navigator.pop(context);
                  await _saveDocument();
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share Document'),
                onTap: () async {
                  Navigator.pop(context);
                  await _shareDocument();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> requestPermissionAndSaveFile(BuildContext context) async {
    try {
      // Check if output file exists
      if (_outputFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No document available to save'))
        );
        return;
      }

      if (!await _outputFile!.exists()) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Output file not found'))
        );
        return;
      }

      // Request appropriate permissions
      if (Platform.isAndroid) {
        // For Android 11+ (API 30+), we need MANAGE_EXTERNAL_STORAGE
        // For older versions, WRITE_EXTERNAL_STORAGE is sufficient
        bool hasPermission = false;

        if (await Permission.manageExternalStorage.isGranted) {
          hasPermission = true;
        } else if (await Permission.storage.isGranted) {
          hasPermission = true;
        } else {
          // Request permissions
          PermissionStatus status = await Permission.storage.request();
          if (status.isGranted) {
            hasPermission = true;
          } else {
            // Try for manage external storage on newer Android
            status = await Permission.manageExternalStorage.request();
            hasPermission = status.isGranted;
          }
        }

        if (!hasPermission) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Storage permission is required to save files'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ));
          return;
        }
      }

      // Pick destination folder using FilePicker
      String? directory = await FilePicker.platform.getDirectoryPath();
      if (directory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No folder selected'))
        );
        return;
      }

      // Create a meaningful filename that avoids conflicts
      final originalFileName = path.basename(_outputFile!.path);
      String fileName = originalFileName;

      // Check if file already exists and add a number if needed
      int counter = 1;
      File destinationFile = File('$directory/$fileName');
      while (await destinationFile.exists()) {
        final extension = path.extension(originalFileName);
        final nameWithoutExtension = path.basenameWithoutExtension(originalFileName);
        fileName = '$nameWithoutExtension($counter)$extension';
        destinationFile = File('$directory/$fileName');
        counter++;
      }

      // Ensure directory exists
      final saveDir = Directory(directory);
      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }

      // Copy the file
      print('Copying from: ${_outputFile!.path}');
      print('Copying to: ${destinationFile.path}');

      // Use alternative method for copying to ensure it works correctly
      final bytes = await _outputFile!.readAsBytes();
      await destinationFile.writeAsBytes(bytes);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('File saved successfully as $fileName'),
        duration: const Duration(seconds: 3),
      ));

    } catch (e) {
      print('Error saving file: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error saving file: ${e.toString()}'),
      ));
    }
  }

// Add these methods to handle save and share functionality
  Future<void> _saveDocument() async {
    try {
      if (_outputFile == null) {
        _showSnackBar('No document available to save');
        return;
      }

      // Get app document directory for saving
      final appDocDir = await getApplicationDocumentsDirectory();
      final savedFileName = 'saved_${widget.document.name}';
      final savedFilePath = '${appDocDir.path}/$savedFileName';

      // Copy the output file to the documents directory
      await _outputFile!.copy(savedFilePath);

      _showSnackBar('Document saved successfully');
    } catch (e) {
      print('Error saving document: $e');
      _showSnackBar('Error saving document');
    }
  }

  Future<void> _shareDocument() async {
    try {
      if (_outputFile == null) {
        _showSnackBar('No document available to share');
        return;
      }

      // Share the file using share_plus package
      await Share.shareXFiles(
        [XFile(_outputFile!.path)],
        text: 'Sharing split document: ${widget.document.name}',
      );
    } catch (e) {
      print('Error sharing document: $e');
      _showSnackBar('Error sharing document');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _startSplitting() async {
    // Simulate initial progress updates
    for (int i = 0; i <= 10; i += 5) {
      if (mounted) {
        setState(() {
          _progress = i / 100;
          _statusMessage = "Preparing document...";
        });
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }

    try {
      // Get temporary directory for output file
      final tempDir = await getTemporaryDirectory();
      final fileName = widget.document.name;
      final outputPath = '${tempDir.path}/split_$fileName';

      // Check if the file is PDF
      if (fileName.toLowerCase().endsWith('.pdf')) {
        await _processPdfFile(outputPath);
      }
      // Check if the file is DOCX
      else if (fileName.toLowerCase().endsWith('.docx')) {
        await _processDocxFile(outputPath);
      } else {
        _updateStatus("Processing generic document...");
        // For other file types, just copy the original for demo
        _outputFile = File(outputPath);
        await widget.document.file.copy(_outputFile!.path);

        // Update progress for file copy operation
        for (int i = 30; i <= 100; i += 10) {
          if (mounted) {
            setState(() {
              _progress = i / 100;
            });
          }
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
    } catch (e) {
      print('Error processing file: $e');
      _updateStatus("Error encountered, using fallback method...");

      // Fallback to simple file copy if processing fails
      final tempDir = await getTemporaryDirectory();
      _outputFile = File('${tempDir.path}/split_${widget.document.name}');
      await widget.document.file.copy(_outputFile!.path);

      // Update progress for fallback operation
      for (int i = _progress.toInt() * 100; i <= 100; i += 10) {
        if (mounted) {
          setState(() {
            _progress = i / 100;
          });
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    if (mounted) {
      setState(() {
        _isCompleted = true;
        _statusMessage = "Split completed successfully!";
      });
    }
  }

  void _updateStatus(String message) {
    if (mounted) {
      setState(() {
        _statusMessage = message;
      });
    }
  }

  Future<void> _processMultiplePdfFiles(List<DocumentItem> documents, String outputPath) async {
    final combinedPdf = syncfusion.PdfDocument();

    int totalPages = 0;
    int processedPages = 0;

    for (var docItem in documents) {
      totalPages += docItem.selectedPages.where((selected) => selected).length;
    }

    for (var docItem in documents) {
      final pdfData = await docItem.file.readAsBytes();
      final document = syncfusion.PdfDocument(inputBytes: pdfData);

      for (int i = 0; i < docItem.selectedPages.length; i++) {
        if (!docItem.selectedPages[i]) continue;

        int sourcePageIndex = i % document.pages.count;

        final pageTemplate = document.pages[sourcePageIndex].createTemplate();
        combinedPdf.pages.add().graphics.drawPdfTemplate(pageTemplate, const Offset(0, 0));

        processedPages++;
        if (mounted) {
          setState(() {
            _progress = processedPages / totalPages * 0.9;
          });
        }
      }
      document.dispose();
    }

    _outputFile = File(outputPath);
    final bytes = combinedPdf.saveSync();
    await _outputFile!.writeAsBytes(bytes);
    combinedPdf.dispose();

    if (mounted) {
      setState(() {
        _progress = 1.0;
      });
    }
    _updateStatus("Processing complete!");
  }


// This is your original function modified to support the new approach
  Future<void> _processPdfFile(String outputPath) async {
    if (widget.isMultipleFiles && widget.documents.length > 1) {
      // Case for multiple PDFs - merge them into one
      await _mergeMultiplePdfs(widget.documents, outputPath);
      return;
    }

    // Original single PDF splitting logic (creates ZIP when splitting pages)
    _updateStatus("Splitting PDF into individual files...");

    final pdfData = await widget.document.file.readAsBytes();
    final originalDoc = syncfusion.PdfDocument(inputBytes: pdfData);
    final selectedIndices = widget.selectedPages
        .asMap()
        .entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    // Only create ZIP if we're splitting into multiple pages
    if (selectedIndices.length > 1) {
      final archive = Archive();
      final tempDir = await getTemporaryDirectory();

      for (int i = 0; i < selectedIndices.length; i++) {
        final pageIndex = selectedIndices[i];
        if (pageIndex >= originalDoc.pages.count) continue;

        final splitDoc = syncfusion.PdfDocument();
        final pageTemplate = originalDoc.pages[pageIndex].createTemplate();
        splitDoc.pages.add().graphics.drawPdfTemplate(pageTemplate, const Offset(0, 0));

        final bytes = splitDoc.saveSync();
        final filename = 'page_${pageIndex + 1}.pdf';

        archive.addFile(ArchiveFile(filename, bytes.length, bytes));
        splitDoc.dispose();

        setState(() => _progress = (i + 1) / selectedIndices.length * 0.9);
      }

      originalDoc.dispose();

      _updateStatus("Compressing output into ZIP...");
      final zipBytes = ZipEncoder().encode(archive);
      _outputFile = File(outputPath.replaceAll('.pdf', '.zip'));
      await _outputFile!.writeAsBytes(zipBytes!);
    } else if (selectedIndices.length == 1) {
      // Single page case - just save as PDF
      final pageIndex = selectedIndices[0];
      final splitDoc = syncfusion.PdfDocument();
      final pageTemplate = originalDoc.pages[pageIndex].createTemplate();
      splitDoc.pages.add().graphics.drawPdfTemplate(pageTemplate, const Offset(0, 0));

      _outputFile = File(outputPath);
      final bytes = splitDoc.saveSync();
      await _outputFile!.writeAsBytes(bytes);
      splitDoc.dispose();
      originalDoc.dispose();
    }

    setState(() => _progress = 1.0);
    _updateStatus("Processing complete!");
  }

  Future<void> _mergeMultiplePdfs(List<DocumentItem> documents, String outputPath) async {
    _updateStatus("Merging multiple PDFs into one...");

    final mergedPdf = syncfusion.PdfDocument();
    int totalPages = 0;
    int processedPages = 0;

    // First count total pages for progress calculation
    for (var docItem in documents) {
      final pdfData = await docItem.file.readAsBytes();
      final document = syncfusion.PdfDocument(inputBytes: pdfData);
      totalPages += document.pages.count;
      document.dispose();
    }

    // Now merge all pages
    for (var docItem in documents) {
      final pdfData = await docItem.file.readAsBytes();
      final document = syncfusion.PdfDocument(inputBytes: pdfData);

      for (int i = 0; i < document.pages.count; i++) {
        final pageTemplate = document.pages[i].createTemplate();
        mergedPdf.pages.add().graphics.drawPdfTemplate(pageTemplate, const Offset(0, 0));

        processedPages++;
        if (mounted) {
          setState(() {
            _progress = processedPages / totalPages * 0.9;
          });
        }
      }
      document.dispose();
    }

    _outputFile = File(outputPath);
    final bytes = mergedPdf.saveSync();
    await _outputFile!.writeAsBytes(bytes);
    mergedPdf.dispose();

    if (mounted) {
      setState(() {
        _progress = 1.0;
      });
    }
    _updateStatus("Merging complete!");
  }

  Future<void> _processDocxFile(String outputPath) async {
    try {
      _updateStatus("Splitting DOCX into individual files...");

      final pages = await _docxService.extractPages(widget.document.file);
      final tempDir = await getTemporaryDirectory();
      final archive = Archive();
      final baseName = path.basenameWithoutExtension(widget.document.name);

      for (int i = 0; i < widget.selectedPages.length; i++) {
        if (!widget.selectedPages[i] || i >= pages.length) continue;

        final singlePageRange = [[i]];
        final results = await _docxService.splitDocxByRanges(widget.document.file, singlePageRange);
        if (results.isNotEmpty) {
          final filePath = results[0].filePath;
          final file = File(filePath);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            final fileName = '${baseName}_page_${i + 1}.docx';
            archive.addFile(ArchiveFile(fileName, bytes.length, bytes));
          }
        }

        setState(() => _progress = (i + 1) / widget.selectedPages.length * 0.9);
      }

      _updateStatus("Creating ZIP archive...");
      final zipBytes = ZipEncoder().encode(archive);
      _outputFile = File(outputPath.replaceAll('.docx', '.zip'));
      await _outputFile!.writeAsBytes(zipBytes!);

      setState(() => _progress = 1.0);
      _updateStatus("ZIP created with split DOCX pages!");
    } catch (e) {
      print("DOCX splitting error: $e");
      _updateStatus("Error occurred. Saving original file instead...");
      _outputFile = File(outputPath);
      await widget.document.file.copy(outputPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
          title: 'Split'),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Progress Animation Container
                if (_isLoading || _animationCompleted) _buildLoadingContainer(),

                const SizedBox(height: 30),

                // Document Info Card
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Split File:',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.16),
                        blurRadius: 4,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 50,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Center(
                              child: Image.asset(
                                widget.document.name.toLowerCase().endsWith('.pdf')
                                    ? 'assets/images/doc.png'
                                    : widget.document.name.toLowerCase().endsWith('.docx')
                                    ? 'assets/images/doc.png'
                                    : 'assets/images/doc.png',
                                width: 60,
                                height: 60,
                              )

                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.document.name,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_formatDateTime(widget.document.date)} | ${widget.document.sizeInMB.toInt()} MB',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[600],
                                ),
                              ),

                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showOptionsMenu(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.more_vert,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),


                // Extra padding for button
                SizedBox(height: MediaQuery.of(context).padding.bottom + 220),
              ],
            ),
          ),

          // Floating Save Button
          if (!_isLoading)
            Positioned(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 20,
              child: CustomGradientButton(
                onPressed: () => requestPermissionAndSaveFile(context),
                text: 'Save',
              )

            )
        ],
      ),
    );
  }

// Progress Animation Widget
  Widget _buildLoadingContainer() {
    final percentage = (_progressAnimation.value * 100).toInt();
    return Container(
      width: 262,
      height: 258,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _animationCompleted ? '' : 'Splitting Your File',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _animationCompleted ? Colors.black : Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            width: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [

                SizedBox(
                  height: 150,
                  width: 150,
                  child: CircularProgressIndicator(
                    value: _progressAnimation.value,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$percentage%',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      _animationCompleted ? 'Completed' : '',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _animationCompleted ? '' : 'Please Wait!',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _animationCompleted ? Colors.black : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

}

// Helper class for storing DOCX page information
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
  String _extractPreviewText(List<XmlElement> paragraphs) {
    String text = '';

    for (final paragraph in paragraphs) {
      final textElements = paragraph.findAllElements('w:t');
      for (final textElement in textElements) {
        text += textElement.text;
      }
    }

    // Limit preview length
    if (text.length > 50) {
      text = '${text.substring(0, 47)}...';
    }

    return text;
  }

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