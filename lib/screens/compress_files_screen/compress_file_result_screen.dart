import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:toolkit/screens/compress_files_screen/compression_result_class.dart';
import 'package:toolkit/screens/home_screen.dart';
import 'package:toolkit/widgets/tools/document_container.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/buttons/save_document_btn.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/tools/animated_loaded_container.dart';
import 'compress_file_screen.dart';
import 'file_compression_service.dart';

class CompressedFileResultScreen extends StatefulWidget {
  final List<File> originalFiles;
  final List<File> compressedFiles;
  final List<CompressionResult>? compressionResults;

  const CompressedFileResultScreen({
    super.key,
    required this.originalFiles,
    required this.compressedFiles,
    this.compressionResults,
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

    for (var result in widget.compressionResults ?? []) {
      originalSize += result.originalSize.toDouble();
      compressedSize += result.compressedSize.toDouble();
    }

    if (originalSize > 0) {
      double reduction = ((originalSize - compressedSize) / originalSize) * 100;
      return reduction < 0 ? 0 : reduction; // Return 0 if negative
    }
    return 0;
  }

  String get totalSpaceSaved {
    double originalSize = 0;
    double compressedSize = 0;

    for (var result in widget.compressionResults ?? []) {
      originalSize += result.originalSize.toDouble();
      compressedSize += result.compressedSize.toDouble();
    }

    double savedBytes = originalSize - compressedSize;
    return FileCompressor.getReadableFileSize(savedBytes < 0 ? 0 : savedBytes.toInt());

  }

  Future<void> _openFile(File file) async {
    try {
      if (!await file.exists()) {

        AppSnackBar.show(context, message: 'File not Found');
        return;
      }

      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        AppSnackBar.show(context, message: 'Cannot open file: ${result.message}');
      }
    } catch (e) {
      AppSnackBar.show(context, message: 'Error opening document');
    }
  }

  void _handleFileDeleted() async {
    // Early return if widget is not mounted
    if (!mounted) return;

    try {
      // Store references to avoid accessing context multiple times
      final navigator = Navigator.of(context);
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      // Check mounted status again before navigation
      if (!mounted) return;

      // Navigate back
      navigator.pop();

      // Check mounted status before showing snackbar
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('File deleted successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Always check mounted status before showing error
      if (mounted) {
        AppSnackBar.show(
            context,
            message: 'Error during deletion: ${e.toString()}'
        );
      }
    }
  }


  Widget _buildCompressionStatus() {
    if (widget.compressionResults == null) return const SizedBox.shrink();

    final notCompressedFiles = widget.compressionResults!
        .where((result) => !result.wasCompressed)
        .toList();

    if (notCompressedFiles.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 5),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Compression Summary",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.amber[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              ...notCompressedFiles.map((result) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  "File is not able to compress Because it already compressed or not supported.",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.amber[800],
                  ),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
      // Replace below with actual navigation to your CompressFilesScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CompressFileScreen()),
      );
      return false; // prevent default back behavior
    },
    child: Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Compression Results'),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildLoadingContainer(),
                if (_animationCompleted) ...[
                  const SizedBox(height: 25),
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
                  const SizedBox(height: 16),
                  _buildCompressionStatus(),
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
                ],
              ],
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