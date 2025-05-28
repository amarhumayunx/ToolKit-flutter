import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:toolkit/widgets/tools/document_container.dart';
import '../../widgets/buttons/save_document_btn.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/tools/animated_loaded_container.dart';
import 'file_compression_service.dart';

class CompressedFileResultScreen extends StatefulWidget {
  final List<File> originalFiles;
  final List<File> compressedFiles;

  const CompressedFileResultScreen({
    super.key,
    required this.originalFiles,
    required this.compressedFiles,
  });

  @override
  State<CompressedFileResultScreen> createState() => _CompressedFileResultScreenState();
}

class _CompressedFileResultScreenState extends State<CompressedFileResultScreen>
    with SingleTickerProviderStateMixin {
  bool _animationCompleted = false;
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
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

    _animationController.forward();
  }

  void _handleLoadingComplete() {
    setState(() {
      _animationCompleted = true;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Calculate total size reduction
  double get totalSizeReduction {
    double originalSize = 0;
    double compressedSize = 0;

    for (var file in widget.originalFiles) {
      if (file.existsSync()) {
        originalSize += file.lengthSync().toDouble();
      }
    }

    for (var file in widget.compressedFiles) {
      if (file.existsSync()) {
        compressedSize += file.lengthSync().toDouble();
      }
    }

    if (originalSize > 0) {
      return ((originalSize - compressedSize) / originalSize) * 100;
    }
    return 0;
  }


  // Calculate total saved space
  String get totalSpaceSaved {
    double originalSize = 0;
    double compressedSize = 0;

    for (var file in widget.originalFiles) {
      if (file.existsSync()) {
        originalSize += file.lengthSync().toDouble();
      }
    }

    for (var file in widget.compressedFiles) {
      if (file.existsSync()) {
        compressedSize += file.lengthSync().toDouble();
      }
    }

    double savedBytes = originalSize - compressedSize;
    return FileCompressor.getReadableFileSize(savedBytes.toInt());
  }


  Future<void> _openFile(File file) async {
    try {
      if (!await file.exists()) {
        _showSnackBar('File not found');
        return;
      }

      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        _showSnackBar('Cannot open file: ${result.message}');
      }
    } catch (e) {
      print('Error opening file: $e');
      _showSnackBar('Error opening document');
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

  void _handleFileDeleted() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Compression Results'),
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
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 10,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total Reduction:",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "${totalSizeReduction.toStringAsFixed(1)}%",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Space Saved:",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                totalSpaceSaved,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Compressed Files:',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.compressedFiles.length,
                      itemBuilder: (context, index) {
                        final compressedFile = widget.compressedFiles[index];
                        return DocumentContainer(
                          filePath: compressedFile.path,
                          onTap: () => _openFile(compressedFile),
                          onDelete: _handleFileDeleted,
                        );
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 300),
                  ],
                ],
              ),
            ),
          ),
          if (_animationCompleted)
            Positioned(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 20,
              child: SaveDocumentButton(
                documentFile: widget.compressedFiles.first,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
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