import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:archive/archive.dart'; // Import archive package for handling zip files

import '../../utils/app_colors.dart';
import '../../widgets/buttons/save_document_btn.dart';
import '../../widgets/buttons/save_zip_png_btn.dart';
import '../../widgets/tools/animated_loaded_container.dart';

class PdfSaveScreen extends StatefulWidget {
  final File selectedPdf;
  final File convertedFile;
  final String selectedFormat;

  const PdfSaveScreen({
    super.key,
    required this.selectedPdf,
    required this.convertedFile,
    required this.selectedFormat,
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
  List<File> _extractedImageFiles = []; // Store extracted image files
  bool _isZipFile = false;
  bool _isSinglePageImage = false;
  int _currentImageIndex = 0; // For navigating between images

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

        // Determine file type for proper handling
        _determineFileType();
      }
    });

    // Get original filename without extension
    final originalName =
        widget.selectedPdf.path.split('/').last.split('.').first;
    currentFileName = originalName;

    // Start the animation
    _animationController.forward();
  }

  void _determineFileType() {
    if (widget.selectedFormat == 'Image') {
      // Check if it's a single page PNG or a ZIP with multiple images
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
    // Clean up extracted temporary files
    for (var file in _extractedImageFiles) {
      if (file.existsSync()) {
        try {
          file.deleteSync();
        } catch (e) {
          print('Error deleting temporary file: $e');
        }
      }
    }
    super.dispose();
  }

  // Extract zip file and create temporary image files for preview
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

      print('Extracted ${_extractedImageFiles.length} image files from ZIP');
    } catch (e) {
      print('Error extracting ZIP file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to extract images: ${e.toString()}')),
        );
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
        return _isSinglePageImage
            ? 'png'
            : 'zip'; // Return png for single-page, zip for multi-page
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
          // For zip files, show a preview dialog with extracted images
          _showImagePreviewDialog();
        } else if (_isSinglePageImage) {
          // For single page PNG image, use OpenFile
          final result = await OpenFile.open(widget.convertedFile.path);
          if (result.type != ResultType.done && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cannot open image: ${result.message}')),
            );
          }
        } else {
          // For other file types, use OpenFile
          final result = await OpenFile.open(widget.convertedFile.path);
          if (result.type != ResultType.done && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cannot open file: ${result.message}')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error opening file: ${e.toString()}')),
          );
        }
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File not found or not yet converted')),
      );
    }
  }

  void _showImagePreviewDialog() {
    if (_extractedImageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No preview images available')),
      );
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

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOptionItem(context, 'Rename', Icons.edit, () {
                Navigator.pop(context);
                _showEditFileNameDialog(context);
              }),
              const Divider(),
              _buildOptionItem(context, 'Share', Icons.share, () async {
                Navigator.pop(context);
                if (widget.convertedFile.existsSync()) {
                  try {
                    await Share.shareXFiles(
                      [XFile(widget.convertedFile.path)],
                      text:
                          'Check out this ${widget.selectedFormat} file: $fileName',
                    );
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Error sharing file: ${e.toString()}')),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('File not available for sharing')),
                  );
                }
              }),
              if (_isZipFile && _extractedImageFiles.isNotEmpty)
                Column(
                  children: [
                    const Divider(),
                    _buildOptionItem(context, 'Preview Images', Icons.image,
                        () {
                      Navigator.pop(context);
                      _showImagePreviewDialog();
                    }),
                  ],
                ),
              if (_isSinglePageImage)
                Column(
                  children: [
                    const Divider(),
                    _buildOptionItem(context, 'Preview Image', Icons.image, () {
                      Navigator.pop(context);
                      _openFile();
                    }),
                  ],
                ),
              const Divider(),
              _buildOptionItem(context, 'Delete', Icons.delete, () {
                Navigator.pop(context);
                _showDeleteConfirmationDialog(context);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionItem(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Row(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditFileNameDialog(BuildContext context) {
    final controller = TextEditingController(text: currentFileName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename File'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter new file name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  currentFileName = controller.text;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete File'),
          content: const Text('Are you sure you want to delete this file?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                try {
                  if (widget.convertedFile.existsSync()) {
                    widget.convertedFile.deleteSync();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('File deleted successfully')),
                    );
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to previous screen
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete file: $e')),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Get file type for saving
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isConverting ? 'Converting PDF' : 'Converted File',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          if (!isConverting)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            if (isConverting || _animationCompleted) _buildLoadingContainer(),
            const SizedBox(height: 30),
            if (isCompleted) _buildFileDetails(),
            const Spacer(),
            if (isCompleted)
              SaveFileButton(
                file: widget.convertedFile,
                fileType: fileTypeForSaving,
                buttonText: 'Save',
              ),
            const SizedBox(height: 20),
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

  Widget _buildFileDetails() {
    return GestureDetector(
      onTap: _openFile,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: _buildStandardFileDetails(),
      ),
    );
  }

  Widget _buildStandardFileDetails() {
    return IntrinsicHeight(
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 50,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey.shade100,
              ),
              child: Center(
                child: SvgPicture.asset(
                  _getFormatIcon(),
                  width: 28,
                  height: 32,
                ),
              ),
            ),
          ),
          Container(width: 1, color: Colors.grey.shade300),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    fileName,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$formattedDate | $formattedTime | $fileSize MB',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              size: 16,
              color: Colors.grey[600],
            ),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
    );
  }

  String _getFormatIcon() {
    switch (widget.selectedFormat) {
      case 'Word':
        return 'assets/icons/word_icon.svg';
      case 'Excel':
        return 'assets/icons/excel_icon.svg';
      case 'PowerPoint':
        return 'assets/icons/powerpoint_icon.svg';
      case 'Image':
        return _isSinglePageImage
            ? 'assets/icons/image_icon.svg'
            : 'assets/icons/convert_img_icon.svg';
      default:
        return 'assets/icons/image_icon.svg';
    }
  }
}
