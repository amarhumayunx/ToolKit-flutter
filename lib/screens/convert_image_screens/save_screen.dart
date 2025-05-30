import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:async';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:toolkit/widgets/buttons/gradient_btn.dart';
import '../../services/save_zip_png_service.dart';
import '../../services/word_images_service.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/tools/animated_loaded_container.dart';
import '../../widgets/tools/document_container.dart';

class SaveScreen extends StatefulWidget {
  final List<File> selectedImages;
  final String selectedFormat;

  const SaveScreen({
    super.key,
    required this.selectedImages,
    required this.selectedFormat,
  });

  @override
  State<SaveScreen> createState() => _SaveScreenState();
}

class _SaveScreenState extends State<SaveScreen>
    with SingleTickerProviderStateMixin {
  bool _animationCompleted = false;
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  File? convertedFile;
  String currentFileName = '';
  late String _currentFilePath; // Track current file path

  @override
  void initState() {
    super.initState();
    // Use the first image's name as the base name
    final originalName =
        widget.selectedImages.first.path.split('/').last.split('.').first;
    currentFileName = originalName;
    _currentFilePath = ''; // Initialize empty, will be set in _convertFile

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _progressAnimation.addListener(() => setState(() {}));
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleLoadingComplete();
      }
    });

    _convertFile();
    _animationController.forward();
  }

  Future<void> _handleLoadingComplete() async {
    setState(() {
      _animationCompleted = true;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _convertFile() async {
    try {
      if (widget.selectedFormat == 'Word') {
        final wordFile =
            await WordImagesService.createWordDocument(widget.selectedImages);
        setState(() {
          convertedFile = wordFile;
          _currentFilePath = wordFile.path;
        });
      } else if (widget.selectedFormat == 'PDF') {
        await _createPDFWithMultipleImages();
      } else {
        // For other formats, just use the first image for now
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          convertedFile = widget.selectedImages.first;
          _currentFilePath = widget.selectedImages.first.path;
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context,
            message: 'Error converting file: ${e.toString()}');
      }
    }
  }

  Future<void> _createPDFWithMultipleImages() async {
    final pdf = pw.Document();

    // Create memory images from all selected files
    List<pw.MemoryImage> images = [];
    for (File imageFile in widget.selectedImages) {
      images.add(pw.MemoryImage(imageFile.readAsBytesSync()));
    }

    // Option 1: All images on one page (if you have few images)
    if (widget.selectedImages.length <= 2) {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: images
                    .map((image) => pw.Container(
                          margin: const pw.EdgeInsets.symmetric(vertical: 20),
                          width: 400,
                          height: 300,
                          child: pw.Center(
                            child: pw.Image(
                              image,
                              fit: pw.BoxFit.contain,
                              width: 400,
                              height: 300,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            );
          },
        ),
      );
    }
    // Option 2: One image per page for better quality and centering
    else {
      for (pw.MemoryImage image in images) {
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Container(
                  width: 500,
                  height: 400,
                  child: pw.Center(
                    child: pw.Image(
                      image,
                      fit: pw.BoxFit.contain,
                      width: 500,
                      height: 400,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }
    }

    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/$currentFileName.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());

    setState(() {
      convertedFile = file;
      _currentFilePath = file.path;
    });
  }

  String get fileName => '$currentFileName.${_getFormatExtension()}';

  String _getFormatExtension() {
    switch (widget.selectedFormat) {
      case 'Word':
        return 'docx';
      case 'Excel':
        return 'xlsx';
      case 'PowerPoint':
        return 'pptx';
      case 'PDF':
        return 'pdf';
      default:
        return 'png';
    }
  }

  Future<void> _openFile() async {
    if (convertedFile != null && convertedFile!.existsSync()) {
      try {
        final result = await OpenFile.open(_currentFilePath);
        if (result.type != ResultType.done && mounted) {
          AppSnackBar.show(context,
              message: 'Cannot open file: ${result.message}');
        }
      } catch (e) {
        if (mounted) {
          AppSnackBar.show(context,
              message: 'Error opening file: ${e.toString()}');
        }
      }
    } else if (mounted) {
      AppSnackBar.show(context, message: 'File not found or not yet converted');
    }
  }

  void _handleFileDeleted() {
    Navigator.of(context).pop(true);
    Navigator.of(context).pop(true);
    AppSnackBar.show(context, message: 'File deleted successfully');
  }

  void _handleFileRenamed(String newPath) {
    setState(() {
      _currentFilePath = newPath;
      convertedFile = File(newPath);
    });
  }

  Future<void> _handleSaveFile() async {
    if (convertedFile != null) {
      try {
        await SaveFileService.saveFile(
          context,
          File(_currentFilePath),
          _getFormatExtension(),
        );
        // Navigate back to home after saving
        Navigator.of(context).popUntil((route) => route.isFirst);
      } catch (e) {
        AppSnackBar.show(context,
            message: 'Failed to save file: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Convert Images'),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildLoadingContainer(),
                  if (_animationCompleted && convertedFile != null) ...[
                    const SizedBox(height: 36),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Converted File:',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DocumentContainer(
                      filePath: _currentFilePath,
                      onTap: _openFile,
                      onDelete: _handleFileDeleted,
                      onFileRenamed: _handleFileRenamed,
                    ),
                  ],
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 300),
                ],
              ),
            ),
          ),
          if (_animationCompleted && convertedFile != null)
            Positioned(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 20,
              child: CustomGradientButton(
                text: 'Save',
                onPressed: _handleSaveFile,
              ),
            ),
        ],
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
