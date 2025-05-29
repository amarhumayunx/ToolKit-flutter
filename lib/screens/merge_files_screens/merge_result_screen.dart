import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/buttons/save_zip_png_btn.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/tools/animated_loaded_container.dart';
import '../../widgets/tools/document_container.dart';

class MergeResultScreen extends StatefulWidget {
  final String mergedFilePath;
  final VoidCallback? onSaveAndReturn;

  const MergeResultScreen({
    super.key,
    required this.mergedFilePath,
    this.onSaveAndReturn,
  });

  @override
  State<MergeResultScreen> createState() => _MergeResultScreenState();
}

class _MergeResultScreenState extends State<MergeResultScreen>
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

    final originalName = widget.mergedFilePath.split('/').last.split('.').first;
    currentFileName = originalName;
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String get fileName {
    return widget.mergedFilePath.split('/').last;
  }

  String get fileSize {
    final file = File(widget.mergedFilePath);
    return (file.lengthSync() / (1024 * 1024)).toStringAsFixed(2);
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
    final file = File(widget.mergedFilePath);
    if (file.existsSync()) {
      try {
        final result = await OpenFile.open(widget.mergedFilePath);
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
      AppSnackBar.show(context, message: 'File not found or not yet processed');
    }
  }

  void _handleFileDeleted() {
    if (widget.onSaveAndReturn != null) {
      widget.onSaveAndReturn!(); // Call the callback to clear selected PDFs
    }
    Navigator.of(context).pop();
    Navigator.of(context).pop();// Navigate back
    AppSnackBar.show(context, message: 'File deleted successfully');
  }

  void _handleSaveCompleted() {
    if (widget.onSaveAndReturn != null) {
      widget.onSaveAndReturn!(); // Call the callback if provided
    }
    Navigator.of(context).pop();

    Navigator.of(context).pop();// Navigate back
    AppSnackBar.show(context, message: 'File saved successfully');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Merge',
        onBackPressed: () {
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
                        'Merged PDF File:',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DocumentContainer(
                      filePath: widget.mergedFilePath,
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
                file: File(widget.mergedFilePath),
                fileType: 'pdf',
                buttonText: 'Save',
                onSaveCompleted: _handleSaveCompleted,
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
