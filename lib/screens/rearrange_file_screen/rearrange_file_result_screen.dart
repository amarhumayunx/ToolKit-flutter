import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toolkit/screens/rearrange_file_screen/pdf_rearrange_service.dart';
import '../../widgets/buttons/save_document_btn.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/tools/animated_loaded_container.dart';
import '../../widgets/tools/document_container.dart';
import '../split_screen/docxService.dart';
import 'package:pdf/widgets.dart' as pw;

class RearrangeFileResultScreen extends StatefulWidget {
  final File originalFile;
  final List<int> newPageOrder;
  final bool isPdfFile; // Add this
  final List<pw.Document>? pdfPages; // Add this

  const RearrangeFileResultScreen({
    super.key,
    required this.originalFile,
    required this.newPageOrder,
    this.isPdfFile = false, // Default to false
    this.pdfPages,
  });

  @override
  State<RearrangeFileResultScreen> createState() => _RearrangeFileResultScreenState();
}

class _RearrangeFileResultScreenState extends State<RearrangeFileResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  bool _animationCompleted = false;

  double _progress = 0.0;
  File? _outputFile;
  bool _processingComplete = false;
  bool _errorOccurred = false;
  String _statusMessage = 'Processing document...';
  final List<File?> _rearrangedFiles = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
      setState(() {});
    });

    _animationController.forward().then((_) {
      setState(() {
        _animationCompleted = true;
      });
    });

    _rearrangeDocument();
  }

  Future<void> _rearrangeDocument() async {
    try {
      // Validate inputs first
      if (!await widget.originalFile.exists()) {
        throw Exception('Original file does not exist');
      }

      final fileSize = await widget.originalFile.length();
      if (fileSize == 0) {
        throw Exception('Original file is empty');
      }

      if (widget.newPageOrder.isEmpty) {
        throw Exception('No page order specified');
      }

      setState(() => _statusMessage = 'Reading document pages...');
      _updateProgress(0.2);

      if (widget.isPdfFile) {
        // Handle PDF rearrangement
        final pdfService = PdfRearrangeService();

        List<pw.Document> allPages;
        if (widget.pdfPages != null) {
          allPages = widget.pdfPages!;
        } else {
          allPages = await pdfService.extractPages(widget.originalFile);
        }

        if (allPages.isEmpty) {
          throw Exception('No pages found in PDF document');
        }

        // Validate page indices
        for (int index in widget.newPageOrder) {
          if (index < 0 || index >= allPages.length) {
            throw Exception('Invalid page index: $index. Document has ${allPages.length} pages.');
          }
        }

        _updateProgress(0.4);

        setState(() => _statusMessage = 'Rearranging PDF pages...');

        // Select pages in the new order
        final reorderedPages = widget.newPageOrder.map((index) => allPages[index]).toList();

        if (reorderedPages.isEmpty) {
          throw Exception('No pages selected for rearrangement');
        }

        _updateProgress(0.6);

        setState(() => _statusMessage = 'Creating new PDF document...');

        // Create output path
        final fileNameWithoutExt = path.basenameWithoutExtension(widget.originalFile.path);
        final timestamp = DateTime.now().millisecondsSinceEpoch;

        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String outputPath = path.join(
            appDocDir.path,
            '${fileNameWithoutExt}_rearranged_$timestamp.pdf'
        );

        // Ensure the directory exists
        await Directory(path.dirname(outputPath)).create(recursive: true);

        // Create new PDF with rearranged pages
        _outputFile = await pdfService.createPdfFromPages(reorderedPages, outputPath);

        _updateProgress(0.8);

      } else {
        // Handle DOCX rearrangement (existing logic)
        final docxService = DocxSplitterService();

        final allPages = await docxService.extractPages(widget.originalFile);

        if (allPages.isEmpty) {
          throw Exception('No pages found in document');
        }

        // Validate page indices
        for (int index in widget.newPageOrder) {
          if (index < 0 || index >= allPages.length) {
            throw Exception('Invalid page index: $index. Document has ${allPages.length} pages.');
          }
        }

        _updateProgress(0.4);

        setState(() => _statusMessage = 'Rearranging pages...');
        // Select pages in the new order
        final reorderedPages = widget.newPageOrder.map((index) => allPages[index]).toList();

        if (reorderedPages.isEmpty) {
          throw Exception('No pages selected for rearrangement');
        }

        _updateProgress(0.6);

        setState(() => _statusMessage = 'Creating new document...');

        // Create a unique filename to avoid conflicts
        final fileNameWithoutExt = path.basenameWithoutExtension(widget.originalFile.path);
        final fileExt = path.extension(widget.originalFile.path);
        final timestamp = DateTime.now().millisecondsSinceEpoch;

        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String outputPath = path.join(
            appDocDir.path,
            '${fileNameWithoutExt}_rearranged_$timestamp$fileExt'
        );

        // Ensure the directory exists
        await Directory(path.dirname(outputPath)).create(recursive: true);

        // Create DOCX from pages
        _outputFile = await docxService.createDocumentFromPages(
            reorderedPages,
            outputPath
        );

        _updateProgress(0.8);
      }

      // Validate the created file (common for both PDF and DOCX)
      if (_outputFile == null) {
        throw Exception('Failed to create output file');
      }

      if (!await _outputFile!.exists()) {
        throw Exception('Output file was not created successfully');
      }

      final outputSize = await _outputFile!.length();
      if (outputSize == 0) {
        throw Exception('Created file is empty - document processing may have failed');
      }

      print('Created ${widget.isPdfFile ? "PDF" : "DOCX"} file: ${_outputFile!.path}, size: $outputSize bytes');

      _rearrangedFiles.add(_outputFile);
      _updateProgress(0.9);

      setState(() {
        _statusMessage = 'Document rearranged successfully! ($outputSize bytes)';
        _processingComplete = true;
        _progress = 1.0;
      });

    } catch (e) {
      print('Error in _rearrangeDocument: $e');
      setState(() {
        _statusMessage = 'Error: ${e.toString()}';
        _errorOccurred = true;
        _processingComplete = false;
      });
    }
  }

  void _updateProgress(double value) {
    setState(() {
      _progress = value;
    });
  }

  Future<void> _saveFile() async {
    if (_outputFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file to save')),
      );
      return;
    }

    try {
      // Validate file before saving
      if (!await _outputFile!.exists()) {
        throw Exception('File does not exist');
      }

      final fileSize = await _outputFile!.length();
      if (fileSize == 0) {
        throw Exception('File is empty - cannot save');
      }

      final directory = await getDownloadsDirectory();
      if (directory == null) throw Exception('Could not access downloads directory');

      // Ensure downloads directory exists
      await directory.create(recursive: true);

      final fileName = path.basename(_outputFile!.path);
      final savePath = path.join(directory.path, fileName);

      // Copy the file
      await _outputFile!.copy(savePath);

      // Verify the copied file
      final copiedFile = File(savePath);
      if (!await copiedFile.exists()) {
        throw Exception('File was not copied successfully');
      }

      final copiedSize = await copiedFile.length();
      if (copiedSize == 0) {
        throw Exception('Copied file is empty');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File saved successfully to $savePath ($copiedSize bytes)')),
        );
      }

    } catch (e) {
      print('Error in _saveFile: $e'); // Debug log
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving file: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildLoadingContainer() {
    return AnimatedLoadingContainer(
      animationController: _animationController,
      animationCompleted: _animationCompleted,
    );
  }

  void _openFile(File file) async {
    try {
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('File is empty');
      }

      // Add logic to open file if needed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Opening file: ${file.path} ($fileSize bytes)')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot open file: ${e.toString()}')),
        );
      }
    }
  }

  void _handleFileDeleted() {
    // Add logic to handle file deletion if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Rearrange Results'),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildLoadingContainer(),
                if (_animationCompleted) ...[
                  const SizedBox(height: 36),
                  if (_errorOccurred) ...[
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error occurred',
                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      style: GoogleFonts.inter(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _errorOccurred = false;
                          _processingComplete = false;
                          _progress = 0.0;
                          _statusMessage = 'Processing document...';
                          _rearrangedFiles.clear();
                          _outputFile = null;
                        });
                        _rearrangeDocument();
                      },
                      child: const Text('Try Again'),
                    ),
                  ] else ...[
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Rearranged Files:',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_rearrangedFiles.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _rearrangedFiles.length,
                        itemBuilder: (context, index) {
                          final file = _rearrangedFiles[index];
                          if (file == null) return const SizedBox.shrink();
                          return DocumentContainer(
                            filePath: file.path,
                            onTap: () => _openFile(file),
                            onDelete: _handleFileDeleted,
                          );
                        },
                      )
                    else if (!_processingComplete)
                      Center(
                        child: Text(
                          'Processing document...',
                          style: GoogleFonts.inter(fontSize: 16),
                        ),
                      ),
                  ],
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 300),
                ],
              ],
            ),
          ),
          if (_animationCompleted && _outputFile != null && !_errorOccurred && _processingComplete)
            Positioned(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 20,
              child: SaveDocumentButton(
                documentFile: _outputFile!,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}