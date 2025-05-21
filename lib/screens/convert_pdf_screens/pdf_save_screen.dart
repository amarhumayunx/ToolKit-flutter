import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:archive/archive.dart';
import '../../utils/app_snackbar.dart'; // Added import
import '../../widgets/buttons/save_zip_png_btn.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/tools/animated_loaded_container.dart';
import '../../widgets/tools/document_container.dart';

class PdfSaveScreen extends StatefulWidget {
  final File selectedPdf;
  final File convertedFile;
  final String selectedFormat;
  final VoidCallback? onFileDeleted;

  const PdfSaveScreen({
    super.key,
    required this.selectedPdf,
    required this.convertedFile,
    required this.selectedFormat,
    this.onFileDeleted,
  });

  @override
  State<PdfSaveScreen> createState() => _PdfSaveScreenState();
}

class _PdfSaveScreenState extends State<PdfSaveScreen>
    with SingleTickerProviderStateMixin {
  bool isConverting = true;
  bool isCompleted = false;
  String currentFileName = '';
  bool _animationCompleted = false;
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  List<File> _extractedImageFiles = [];
  bool _isZipFile = false;
  bool _isSinglePageImage = false;
  int _currentImageIndex = 0;

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
    _progressAnimation.addListener(() => setState(() {}));
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isConverting = false;
          _animationCompleted = true;
          isCompleted = true;
        });
        _determineFileType();
      }
    });

    final originalName =
        widget.selectedPdf.path.split('/').last.split('.').first;
    currentFileName = originalName;
    _animationController.forward();
  }

  void _determineFileType() {
    if (widget.selectedFormat == 'Image') {
      _isSinglePageImage =
      !widget.convertedFile.path.toLowerCase().endsWith('.zip');
      _isZipFile = widget.convertedFile.path.toLowerCase().endsWith('.zip');

      if (_isZipFile) {
        _extractZipFile();
      }
    } else {
      _isZipFile = widget.convertedFile.path.toLowerCase().endsWith('.zip');
      if (_isZipFile) {
        _extractZipFile();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var file in _extractedImageFiles) {
      if (file.existsSync()) {
        try {
          file.deleteSync();
        } catch (e) {
          debugPrint('Error deleting temporary file: $e');
        }
      }
    }
    super.dispose();
  }

  Future<void> _extractZipFile() async {
    try {
      if (!widget.convertedFile.existsSync()) {
        return;
      }

      final bytes = await widget.convertedFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final tempDir = await getTemporaryDirectory();

      for (final file in archive) {
        if (file.isFile && _isImageFile(file.name)) {
          final extractedFile = File('${tempDir.path}/${file.name}');
          await extractedFile.writeAsBytes(file.content as List<int>);
          setState(() {
            _extractedImageFiles.add(extractedFile);
          });
        }
      }
    } catch (e) {
      debugPrint('Error extracting ZIP file: $e');
      if (mounted) {
        AppSnackBar.show(context,
            message: 'Failed to extract images: ${e.toString()}');
      }
    }
  }

  bool _isImageFile(String filename) {
    final extension = filename.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension);
  }

  String get fileName {
    if (_isSinglePageImage && widget.selectedFormat == 'Image') {
      return '$currentFileName.png';
    }
    return '$currentFileName.${_getFormatExtension()}';
  }

  String _getFormatExtension() {
    switch (widget.selectedFormat) {
      case 'Word':
        return 'docx';
      case 'Excel':
        return 'xlsx';
      case 'PowerPoint':
        return 'pptx';
      case 'Image':
        return _isSinglePageImage ? 'png' : 'zip';
      default:
        return 'jpg';
    }
  }

  String get fileSize {
    return (widget.convertedFile.lengthSync() / (1024 * 1024))
        .toStringAsFixed(2);
  }

  String get formattedDate {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year.toString().substring(2)}';
  }

  String get formattedTime {
    final now = DateTime.now();
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')}${now.hour < 12 ? 'am' : 'pm'}';
  }

  Future<void> _openFile() async {
    if (widget.convertedFile.existsSync()) {
      try {
        if (_isZipFile) {
          _showImagePreviewDialog();
        } else if (_isSinglePageImage) {
          final result = await OpenFile.open(widget.convertedFile.path);
          if (result.type != ResultType.done && mounted) {
            AppSnackBar.show(context,
                message: 'Cannot open image: ${result.message}');
          }
        } else {
          final result = await OpenFile.open(widget.convertedFile.path);
          if (result.type != ResultType.done && mounted) {
            AppSnackBar.show(context,
                message: 'Cannot open file: ${result.message}');
          }
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

  void _showImagePreviewDialog() {
    if (_extractedImageFiles.isEmpty) {
      AppSnackBar.show(context, message: 'No preview images available');
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Image Preview',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(),
              SizedBox(
                height: 300,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      children: [
                        Expanded(
                          child: _extractedImageFiles.isNotEmpty
                              ? Image.file(
                            _extractedImageFiles[_currentImageIndex],
                            fit: BoxFit.contain,
                          )
                              : const Center(
                            child: Text('No images available'),
                          ),
                        ),
                        if (_extractedImageFiles.length > 1)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back_ios),
                                  onPressed: () {
                                    setState(() {
                                      _currentImageIndex =
                                          (_currentImageIndex - 1) %
                                              _extractedImageFiles.length;
                                      if (_currentImageIndex < 0) {
                                        _currentImageIndex =
                                            _extractedImageFiles.length - 1;
                                      }
                                    });
                                  },
                                ),
                                Text(
                                  '${_currentImageIndex + 1}/${_extractedImageFiles.length}',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward_ios),
                                  onPressed: () {
                                    setState(() {
                                      _currentImageIndex =
                                          (_currentImageIndex + 1) %
                                              _extractedImageFiles.length;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'This archive contains ${_extractedImageFiles.length} image(s)',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleFileDeleted() {
    widget.onFileDeleted?.call();
    // Pop twice to go back two screens
    Navigator.of(context).pop(); // First pop (current screen)
    Navigator.of(context).pop(); // Second pop (previous screen)

    // Show a success message
    AppSnackBar.show(context, message: 'File deleted successfully');
  }

  String get fileTypeForSaving {
    if (widget.selectedFormat == 'Image') {
      return _isSinglePageImage ? 'png' : 'zip';
    } else {
      switch (widget.selectedFormat) {
        case 'Word':
          return 'docx';
        case 'Excel':
          return 'xlsx';
        case 'PowerPoint':
          return 'pptx';
        default:
          return 'unknown';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Convert PDF',
        onBackPressed: () {
          // Just pop without any data clearing flag (false)
          Navigator.of(context).pop(false);
        },
      ),
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
                  if (_animationCompleted) ...[
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
                      filePath: widget.convertedFile.path,
                      onTap: _openFile,
                      onDelete: _handleFileDeleted,
                    ),
                  ],
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 300),
                ],
              ),
            ),
          ),
          if (_animationCompleted)
            Positioned(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 20,
              child: SaveFileButton(
                file: widget.convertedFile,
                fileType: fileTypeForSaving,
                buttonText: 'Save',
                onSaveCompleted: () {
                  // Navigate back to ConvertPdfMainScreen
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
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