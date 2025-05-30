import 'dart:io';
import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusion;
import 'package:toolkit/screens/split_screen/split_screen.dart';
import 'package:toolkit/widgets/tools/document_container.dart';
import 'package:path/path.dart' as path;
import '../../utils/app_snackbar.dart';
import '../../widgets/buttons/save_document_btn.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/tools/animated_loaded_container.dart';
import 'document_item.dart';
import 'docxService.dart';

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
  bool _animationCompleted = false;
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  double _progress = 0.0;
  File? _outputFile;
  final String _resultText = '';

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
          _animationCompleted = true;
          _textController.text = _resultText;
        });
      }
    });

    _animationController.forward();
    _startSplitting();
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
      AppSnackBar.show(context, message: 'File saved successfully as $fileName');

    } catch (e) {
      print('Error saving file: $e');
      AppSnackBar.show(context, message: 'Error saving file: ${e.toString()}');
    }
  }

  // void _showSnackBar(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       behavior: SnackBarBehavior.floating,
  //       duration: const Duration(seconds: 2),
  //     ),
  //   );
  // }

  Future<void> _startSplitting() async {
    // Simulate initial progress updates
    for (int i = 0; i <= 10; i += 5) {
      if (mounted) {
        setState(() {
          _progress = i / 100;
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
      });
    }
  }

  void _updateStatus(String message) {
    if (mounted) {
      setState(() {
      });
    }
  }

// This is your original function modified to support the new approach
  Future<void> _processPdfFile(String outputPath) async {
    _updateStatus("Creating PDF with selected pages...");

    final pdfData = await widget.document.file.readAsBytes();
    final originalDoc = syncfusion.PdfDocument(inputBytes: pdfData);

    // Get selected page indices (0-based)
    final selectedIndices = <int>[];
    for (int i = 0; i < widget.selectedPages.length; i++) {
      if (widget.selectedPages[i]) {
        selectedIndices.add(i);
      }
    }

    if (selectedIndices.isEmpty) {
      originalDoc.dispose();
      throw Exception("No pages selected");
    }

    // Create a new PDF with all selected pages
    final mergedDoc = syncfusion.PdfDocument();

    for (int i = 0; i < selectedIndices.length; i++) {
      final pageIndex = selectedIndices[i];
      if (pageIndex >= originalDoc.pages.count) continue;

      final page = originalDoc.pages[pageIndex];
      final pageTemplate = page.createTemplate();

      // Add new page and draw the template
      final newPage = mergedDoc.pages.add();
      newPage.graphics.drawPdfTemplate(pageTemplate, const Offset(0, 0));

      // Update progress
      if (mounted) {
        setState(() => _progress = (i + 1) / selectedIndices.length * 0.9);
      }
    }

    originalDoc.dispose();

    // Save the single output PDF
    _outputFile = File(outputPath);
    final bytes = mergedDoc.saveSync();
    await _outputFile!.writeAsBytes(bytes);
    mergedDoc.dispose();

    if (mounted) {
      setState(() => _progress = 1.0);
    }
    _updateStatus("PDF with selected pages created successfully!");
  }


  Future<void> _openFile() async {
    try {
      if (_outputFile == null) {
        AppSnackBar.show(context, message: 'No document available to open');
        return;
      }

      if (!await _outputFile!.exists()) {
        AppSnackBar.show(context, message: 'File not found');
        return;
      }

      // Use OpenFile package to open the file with the default app
      final result = await OpenFile.open(_outputFile!.path);

      if (result.type != ResultType.done) {
        // If opening fails, show error message
        AppSnackBar.show(context, message: 'Cannot open file: ${result.message}');

        // For zip files, we might need to tell the user
        if (_outputFile!.path.toLowerCase().endsWith('.zip')) {
          AppSnackBar.show(context, message: 'This is a ZIP file. You may need a ZIP extractor app to view its contents.');
        }
      }
    } catch (e) {
      print('Error opening file: $e');
      AppSnackBar.show(context, message: 'Error opening document');
    }
  }

  void _handleFileDeleted() {
    // Just go back to the previous screen (split screen)
    Navigator.of(context).pop();
    Navigator.of(context).pop();

    // Show success message
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        AppSnackBar.show(context, message: 'File deleted successfully!');
      }
    });
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
    return WillPopScope(
        onWillPop: () async {
      // Replace below with actual navigation to your CompressFilesScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SplitScreen()),
      );
      return false; // prevent default back behavior
    },
    child: Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: ('split_document'.tr)),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildLoadingContainer(),
                if (_animationCompleted) ...[
                  const SizedBox(height: 36),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      ('split_file_progress_screen'.tr),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DocumentContainer(
                    filePath: _outputFile!.path,
                    onTap: _openFile,
                    onDelete: _handleFileDeleted,
                  ),
                ],
                SizedBox(height: MediaQuery.of(context).padding.bottom + 250),
              ],
            ),
          ),
          if (_animationCompleted)
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
    ),
    );
  }

  Widget _buildLoadingContainer() {
    return AnimatedLoadingContainer(
      animationController: _animationController,
      animationCompleted: _animationCompleted,
    );
  }
}
