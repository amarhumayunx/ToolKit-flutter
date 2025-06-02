import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:toolkit/screens/compress_files_screen/file_drop_compress.dart';
import 'package:toolkit/utils/app_colors.dart';
import 'package:toolkit/utils/app_snackbar.dart';
import '../../widgets/buttons/gradient_btn.dart';
import '../../widgets/tools/custom_svg_image.dart';
import '../../widgets/tools/info_card.dart';
import '../../widgets/tools/tools_app_bar.dart';
import 'compress_file_result_screen.dart';
import 'compression_result_class.dart';
import 'file_compression_service.dart';

class CompressFileScreen extends StatefulWidget {
  const CompressFileScreen({super.key});

  @override
  State<CompressFileScreen> createState() => _CompressFileScreenState();
}

class _CompressFileScreenState extends State<CompressFileScreen> {
  String? _fileErrorText;

  final List<File> _selectedFiles = [];
  bool _isCompressing = false;
  double _compressionQuality = 85;


  // Helper method to format file size
  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.media,
      );

      if (result != null && result.paths.isNotEmpty) {
        final validExtensions = ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'jpg', 'jpeg', 'png'];
        const int minFileSizeMB = 1;
        const int minFileSizeBytes = minFileSizeMB * 1024 * 1024; // 1MB in bytes

        List<File> pickedFiles = result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();

        List<File> validFiles = [];
        List<String> rejectedFiles = [];
        List<String> invalidExtensionFiles = [];

        for (File file in pickedFiles) {
          final ext = file.path.split('.').last.toLowerCase();

          // Check if file extension is valid
          if (!validExtensions.contains(ext)) {
            invalidExtensionFiles.add(file.path.split('/').last);
            continue;
          }

          // Check file size - now files must be LARGER than 1MB
          try {
            final fileSize = await file.length();
            if (fileSize < minFileSizeBytes) {
              rejectedFiles.add('${file.path.split('/').last} (${_formatFileSize(fileSize)})');
            } else {
              validFiles.add(file);
            }
          } catch (e) {
            // If we can't read file size, treat it as invalid
            invalidExtensionFiles.add(file.path.split('/').last);
          }
        }

        if (mounted) {
          setState(() {
            _selectedFiles.addAll(validFiles);

            // Set appropriate error message
            _fileErrorText = rejectedFiles.isNotEmpty && invalidExtensionFiles.isNotEmpty
                ? 'Invalid: Small files ${minFileSizeMB}MB & wrong formats'
                : rejectedFiles.isNotEmpty
                ? 'File must be larger than ${minFileSizeMB}MB'
                : invalidExtensionFiles.isNotEmpty
                ? 'Invalid file formats'
                : validFiles.isEmpty && pickedFiles.isNotEmpty
                ? 'No valid files selected'
                : null;
          });

          // Show snackbar for rejected files
          if (rejectedFiles.isNotEmpty) {
            AppSnackBar.show(
              context,
              message: '${rejectedFiles.length} file(s) skipped - File size must be larger than ${minFileSizeMB}MB',
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _fileErrorText = 'Error selecting files: $e';
        });
      }
    }
  }

  Future<void> _compressFiles() async {
    if (_selectedFiles.isEmpty) {
      if (mounted) {
        AppSnackBar.show(context, message: 'Please select at least one file first');
      }
      return;
    }

    if (!mounted) return;

    setState(() {
      _isCompressing = true;
    });

    try {
      // Perform actual compression using our FileCompressor utility
      List<CompressionResult> compressionResults = await FileCompressor.compressBatchWithStatus(
        _selectedFiles,
        quality: _compressionQuality.round(),
      );
      List<File> compressedFiles = compressionResults.map((result) => result.file).toList();

      // Check if widget is still mounted before proceeding
      if (!mounted) return;

      // Update state first
      setState(() {
        _isCompressing = false;
      });

      // Navigate to results screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => CompressedFileResultScreen(
            originalFiles: _selectedFiles,
            compressedFiles: compressedFiles,
            compressionResults: compressionResults,
          ),
        ),
      );

    } catch (e) {
      // Check if widget is still mounted before updating state or showing messages
      if (!mounted) return;

      setState(() {
        _isCompressing = false;
      });

      AppSnackBar.show(context, message: 'Error compressing files: $e');
    }
  }

  void _removeFile(int index) {
    if (mounted) {
      setState(() {
        _selectedFiles.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const ToolsAppBar(
        title: ('Compress File'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CustomSvgImage(
                      imagePath: 'assets/images/compress_file_image.svg'),
                  const SizedBox(height: 30),
                  InfoCard(
                    title: ('Reduce File Size'),
                    description:
                    ('reduce_file_size_description'.tr),
                  ),
                  const SizedBox(height: 24),
                  // Combined container with shadow

                  Container(
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
                        Padding(
                          padding: const EdgeInsets.only(top: 10, left: 16, bottom: 10),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              ('select_file'.tr),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                          child: DottedFileDropZoneCompress(
                            selectedFiles: _selectedFiles,
                            onTap: _pickFiles,
                            onRemoveFile: _removeFile,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_fileErrorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _fileErrorText!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),

                  // Add compression quality slider
                  if (_selectedFiles.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Compression Quality',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Maximum\nCompression'),
                              Expanded(
                                child: Slider(
                                  value: _compressionQuality,
                                  min: 25,
                                  max: 100,
                                  divisions: 3,
                                  label: _compressionQuality.round().toString(),
                                  activeColor: AppColors.primary,
                                  onChanged: (double value) {
                                    if (mounted) {
                                      setState(() {
                                        _compressionQuality = value;
                                      });
                                    }
                                  },
                                ),
                              ),
                              const Text('Maximum\nQuality'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            child: CustomGradientButton(
              text: _isCompressing ? 'Compressing...' : 'Compress',
              onPressed: _isCompressing ? null : _compressFiles,
            ),
          ),
        ],
      ),
    );
  }
}