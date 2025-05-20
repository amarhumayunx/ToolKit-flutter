import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/buttons/gradient_btn.dart';
import '../../widgets/tools/custom_svg_image.dart';
import '../../widgets/tools/info_card.dart';
import '../../widgets/tools/tools_app_bar.dart';
import '../../widgets/tools/dotted_file_drop.dart';
import '../../widgets/tools/ocr_file_selection.dart';
import '../scanner_screens/batch_result_screen.dart';
import '../ocr_screens/ocr_camera_screen.dart';

class EditFileScreen extends StatefulWidget {
  const EditFileScreen({super.key});

  @override
  State<EditFileScreen> createState() => _EditFileScreenState();
}

class _EditFileScreenState extends State<EditFileScreen> {
  List<File> _selectedFiles = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true, // Allow multiple file selection
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFiles
              .addAll(result.files.map((file) => File(file.path!)).toList());
        });
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting files: $e')),
      );
    }
  }

  Future<void> _scanNewDocument() async {
    try {
      // Navigate to the camera screen for scanning new documents
      final List<File>? capturedImages = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OcrCameraScreen(),
        ),
      );

      if (capturedImages != null && capturedImages.isNotEmpty) {
        setState(() {
          _selectedFiles.addAll(capturedImages);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing document: $e')),
      );
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Future<void> _editFiles() async {
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one file')),
      );
      return;
    }

    // Navigate to BatchResultScreen with the selected files
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BatchResultScreen(
          batchImages: _selectedFiles,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ToolsAppBar(
        title: 'Edit Files',
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
                    imagePath: 'assets/images/edit_file_img.svg',
                  ),
                  const SizedBox(height: 30),
                  InfoCard(
                    title: 'Edit Files',
                    description:
                    'Make changes to your files easily. Upload and modify multiple PDFs, images, and documents for a seamless experience.',
                  ),
                  const SizedBox(height: 24),
                  // Combined container with shadow (same as OCR screen)
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
                        // File selection section
                        FileSelectionSection(
                          sectionTitle: 'Choose Files',
                          onSelectFiles: _pickFiles,
                          onScanNew: _scanNewDocument,
                        ),
                        // Dotted file drop zone
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 16),
                          child: DottedFileDropZone(
                            selectedImages: _selectedFiles,
                            onTap: _pickFiles,
                            onRemoveImage: _removeFile,
                            emptyStateText: 'Click to choose files or drag and drop',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            child: CustomGradientButton(
              text: 'Next',
              onPressed: _editFiles,
            ),
          ),
        ],
      ),
    );
  }
}