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

class CompressFileScreen extends StatefulWidget {
  const CompressFileScreen({super.key});

  @override
  State<CompressFileScreen> createState() => _CompressFileScreenState();
}

class _CompressFileScreenState extends State<CompressFileScreen> {
  List<File> _selectedFiles = [];
  bool _isCompressing = false;

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
      // Simulate compression process
      await Future.delayed(const Duration(seconds: 2));

      // Here you would implement actual file compression logic
      // For each file in _selectedFiles, compress it and save the result

      setState(() {
        _isCompressing = false;
      });

      // Navigate to results screen with compressed files
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompressedFileResultScreen(
            originalFiles: _selectedFiles,
            // In a real implementation, you would pass compressed files here
            compressedFiles: _selectedFiles,
          ),
        ),
      );
    } catch (e) {
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
                ],
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            child: CustomGradientButton(
              text: 'Compress',
              onPressed: _compressFiles,
            ),
          ),
        ],
      ),
    );
  }
}
