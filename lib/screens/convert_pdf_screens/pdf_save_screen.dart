import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

import '../../utils/app_colors.dart';
import '../../widgets/buttons/gradient_btn.dart';
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
      }
    });

    // Get original filename without extension
    final originalName =
        widget.selectedPdf.path.split('/').last.split('.').first;
    currentFileName = originalName;

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
        final result = await OpenFile.open(widget.convertedFile.path);
        if (result.type != ResultType.done && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cannot open file: ${result.message}')),
          );
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
                if (controller.text.isNotEmpty) {
                  setState(() {
                    currentFileName = controller.text;
                  });
                }
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
                if (widget.convertedFile.existsSync()) {
                  try {
                    widget.convertedFile.deleteSync();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('File deleted successfully')),
                      );
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Error deleting file: ${e.toString()}')),
                    );
                  }
                }
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
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
              CustomGradientButton(
                text: 'Save',
                onPressed: () async {
                  try {
                    final appDocDir = await getApplicationDocumentsDirectory();
                    final savedFilePath = '${appDocDir.path}/$fileName';
                    await widget.convertedFile.copy(savedFilePath);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('File saved successfully!')),
                      );
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Error saving file: ${e.toString()}')),
                      );
                    }
                  }
                },
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
        ),
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
      default:
        return 'assets/icons/convert_img_icon.svg';
    }
  }
}
