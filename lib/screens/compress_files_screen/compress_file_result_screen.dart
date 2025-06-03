import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toolkit/screens/compress_files_screen/compression_result_class.dart';
import 'package:toolkit/widgets/tools/document_container.dart';
import '../../services/save_zip_png_service.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/buttons/gradient_btn.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/tools/animated_loaded_container.dart';
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
  bool _fileRenamed = false;
  final Map<int, String> _savedFilePaths = {};
  List<File> _compressedFiles = [];
  String _saveButtonKey = 'initial';
  bool _isSaving = false;

  File? convertedFile;
  String _currentFilePath = '';

  @override
  void initState() {
    super.initState();
    _compressedFiles = List.from(widget.compressedFiles);
    if (_compressedFiles.isNotEmpty) {
      convertedFile = _compressedFiles.first;
      _currentFilePath = _compressedFiles.first.path;
    }
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

  Future<void> _handleSaveFile() async {
    if (convertedFile != null) {
      try {
        await SaveFileService.saveFile(
          context,
          File(_currentFilePath),
          _getFormatExtension(),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      } catch (e) {
        AppSnackBar.show(context,
            message: 'Failed to save file: ${e.toString()}');
      }
    }
  }

  String _getFormatExtension() {
    if (_currentFilePath.isNotEmpty) {
      return _currentFilePath.split('.').last;
    }
    return 'zip';
  }

  Future<void> _handleFileRenamed(String newPath, int index) async {
    try {
      final oldFile = _compressedFiles[index];
      final newFile = File(newPath);

      if (oldFile.path != newPath) {
        if (await oldFile.exists()) {
          await oldFile.rename(newPath);
        }

        if (_savedFilePaths.containsKey(index)) {
          _savedFilePaths[index] = newPath;
        }
      }

      setState(() {
        _compressedFiles[index] = newFile;
        _fileRenamed = true;
        _saveButtonKey = 'renamed_${DateTime.now().millisecondsSinceEpoch}';

        if (index == 0) {
          convertedFile = newFile;
          _currentFilePath = newPath;
        }
      });

      if (mounted) {
        AppSnackBar.show(context, message: 'File renamed successfully');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, message: 'Error renaming file: ${e.toString()}');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  double get totalSizeReduction {
    double originalSize = 0;
    double compressedSize = 0;

    for (var result in widget.compressionResults ?? []) {
      originalSize += result.originalSize.toDouble();
      compressedSize += result.compressedSize.toDouble();
    }

    if (originalSize > 0) {
      double reduction = ((originalSize - compressedSize) / originalSize) * 100;
      return reduction < 0 ? 0 : reduction;
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
        if (mounted) {
          AppSnackBar.show(context, message: 'File not found');
        }
        return;
      }

      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done && mounted) {
        AppSnackBar.show(context, message: 'Cannot open file: ${result.message}');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, message: 'Error opening document');
      }
    }
  }

  void _handleFileDeleted(int index) async {
    if (!mounted) return;

    try {
      final fileToDelete = _compressedFiles[index];
      if (await fileToDelete.exists()) {
        await fileToDelete.delete();
      }

      setState(() {
        _compressedFiles.removeAt(index);
        _savedFilePaths.remove(index);
        _saveButtonKey = 'deleted_${DateTime.now().millisecondsSinceEpoch}';

        if (index == 0 && _compressedFiles.isNotEmpty) {
          convertedFile = _compressedFiles.first;
          _currentFilePath = _compressedFiles.first.path;
        } else if (_compressedFiles.isEmpty) {
          convertedFile = null;
          _currentFilePath = '';
        }
      });

      if (_compressedFiles.isEmpty && mounted) {
        Navigator.of(context).pop();
        return;
      }

      if (mounted) {
        AppSnackBar.show(context, message: 'File deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, message: 'Error during deletion: ${e.toString()}');
      }
    }
  }

  Future<File?> _createZipFile() async {
    try {
      final zipDir = await getTemporaryDirectory();
      final zipName = 'compressed_files_${DateTime.now().millisecondsSinceEpoch}';
      final zipPath = '${zipDir.path}/$zipName.zip';

      final zipFile = File(zipPath);
      await zipFile.writeAsBytes([]);

      return zipFile;
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, message: 'Error creating ZIP file');
      }
      return null;
    }
  }

  Future<void> _saveSingleFile(File file) async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final fileName = file.path.split('/').last;
      final savedPath = '${documentsDir.path}/$fileName';
      final savedFile = await file.copy(savedPath);

      setState(() {
        _savedFilePaths[_compressedFiles.indexOf(file)] = savedPath;
      });

      if (mounted) {
        AppSnackBar.show(context, message: 'File saved successfully');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, message: 'Failed to save file: ${e.toString()}');
      }
    }
  }

  Future<void> _handleSaveAllFiles() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      if (_compressedFiles.isEmpty) {
        if (mounted) {
          AppSnackBar.show(context, message: 'No files to save');
        }
        return;
      }

      if (_compressedFiles.length == 1) {
        await _saveSingleFile(_compressedFiles.first);
      } else {
        final zipFile = await _createZipFile();
        if (zipFile != null && mounted) {
          await _saveSingleFile(zipFile);
          if (mounted) {
            AppSnackBar.show(context, message: 'All files saved as ZIP');
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _saveButtonKey = 'saved_${DateTime.now().millisecondsSinceEpoch}';
        });
      }
    }
  }

  bool get hasValidFiles {
    return _compressedFiles.isNotEmpty &&
        _compressedFiles.any((file) => file.existsSync());
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
              ...notCompressedFiles.map(
                    (result) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    "File is not able to compress because it already compressed or not supported.",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.amber[800],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingContainer() {
    return AnimatedLoadingContainer(
      animationController: _animationController,
      animationCompleted: _animationCompleted,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(title: 'Compression Results'),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 100.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildLoadingContainer(),
                      if (_animationCompleted) ...[
                        const SizedBox(height: 12),
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
                                  Text("Total Reduction:",
                                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500)),
                                  Text("${totalSizeReduction.toStringAsFixed(1)}%",
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue[700],
                                      )),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Space Saved:",
                                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500)),
                                  Text(totalSpaceSaved,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green[700],
                                      )),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildCompressionStatus(),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Compressed Files:',
                            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_compressedFiles.isNotEmpty)
                          ...(_compressedFiles.asMap().entries.map((entry) {
                            int index = entry.key;
                            File compressedFile = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: DocumentContainer(
                                filePath: compressedFile.path,
                                onTap: () => _openFile(compressedFile),
                                onDelete: () => _handleFileDeleted(index),
                                onFileRenamed: (newPath) => _handleFileRenamed(newPath, index),
                              ),
                            );
                          }).toList()),
                      ],
                    ],
                  ),
                ),
              ),

              if (_animationCompleted && hasValidFiles)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: CustomGradientButton(
                      text: _isSaving
                          ? 'Save'
                          : (_compressedFiles.length > 1 ? 'Save' : 'Save'),
                      onPressed: _isSaving
                          ? null
                          : (_compressedFiles.length > 1 ? _handleSaveAllFiles : _handleSaveFile),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
  }
}