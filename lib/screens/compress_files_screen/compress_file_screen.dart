import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/buttons/gradient_btn.dart';
import '../../widgets/tools/custom_svg_image.dart';
import '../../widgets/tools/dotted_file_drop.dart';
import '../../widgets/tools/file_selection_container.dart';
import '../../widgets/tools/info_card.dart';
import '../../widgets/tools/tools_app_bar.dart';
import 'compress_file_result_screen.dart';
import 'file_compression_service.dart'; // Import our file compressor

class CompressFileScreen extends StatefulWidget {
  const CompressFileScreen({super.key});

  @override
  State<CompressFileScreen> createState() => _CompressFileScreenState();
}

class _CompressFileScreenState extends State<CompressFileScreen> {
  List<File> _selectedFiles = [];
  bool _isCompressing = false;
  double _compressionQuality = 85; // Default compression quality

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'ppt',
          'pptx',
          'jpg',
          'jpeg',
          'png'
        ],
        allowMultiple: true,
      );

      if (result != null && result.paths.isNotEmpty) {
        setState(() {
          _selectedFiles.addAll(
            result.paths
                .where((path) => path != null)
                .map((path) => File(path!))
                .toList(),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting files: $e')),
      );
    }
  }

  Future<void> _compressFiles() async {
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one file first')),
      );
      return;
    }

    setState(() {
      _isCompressing = true;
    });

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  const Text('Compressing files...'),
                  const SizedBox(height: 10),
                  Text('${_selectedFiles.length} files being processed'),
                ],
              ),
            ),
          );
        },
      );

      // Perform actual compression using our FileCompressor utility
      List<File> compressedFiles = await FileCompressor.compressBatch(
        _selectedFiles,
        quality: _compressionQuality.round(),
      );

      // Close the loading dialog
      Navigator.of(context).pop();

      setState(() {
        _isCompressing = false;
      });

      // Navigate to results screen with compressed files
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompressedFileResultScreen(
            originalFiles: _selectedFiles,
            compressedFiles: compressedFiles,
          ),
        ),
      );
    } catch (e) {
      // Close the loading dialog if open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      setState(() {
        _isCompressing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error compressing files: $e')),
      );
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ToolsAppBar(
        title: 'Compress File',
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomSvgImage(
                      imagePath: 'assets/images/compress_file_image.svg'),
                  const SizedBox(height: 30),
                  InfoCard(
                    title: 'Reduce file size',
                    description:
                    'Reduce the size of PDFs, documents, and images while preserving original quality.',
                  ),
                  const SizedBox(height: 24),
                  // Combined container with shadow
                  FileSelectionContainer(
                    title: 'Select Files',
                    emptyStateText: 'Click to browse files',
                    selectedFiles: _selectedFiles,
                    onTap: _pickFiles,
                    onRemoveFile: _removeFile,
                    isMultipleSelection: true,
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
                                  min: 30,
                                  max: 100,
                                  divisions: 7,
                                  label: _compressionQuality.round().toString(),
                                  onChanged: (double value) {
                                    setState(() {
                                      _compressionQuality = value;
                                    });
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