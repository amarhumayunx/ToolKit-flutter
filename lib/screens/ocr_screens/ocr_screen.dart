import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import '../../widgets/buttons/gradient_btn.dart';
import '../../widgets/tools/custom_svg_image.dart';
import '../../widgets/tools/dotted_file_drop.dart';
import '../../widgets/tools/info_card.dart';
import '../../widgets/tools/ocr_file_selection.dart';
import '../../widgets/tools/tools_app_bar.dart';
import 'extracted_text_screen.dart';
import 'ocr_camera_screen.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  final List<File> _selectedImages = []; // Changed to list of files
  final ImagePicker _picker = ImagePicker();
  String _extractedText = '';

  Future<void> _pickImages(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        // Navigate to our custom camera screen
        final List<File>? capturedImages = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const OcrCameraScreen(),
          ),
        );

        if (capturedImages != null && capturedImages.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(capturedImages);
          });
        }
      } else {
        // Original gallery code
        final List<XFile> pickedFiles = await _picker.pickMultiImage();
        if (pickedFiles.isNotEmpty) {
          setState(() {
            _selectedImages
                .addAll(pickedFiles.map((file) => File(file.path)).toList());
          });
        }
      }
    } catch (e) {
      // SnackBar removed
    }
  }

  Future<void> _extractTextFromImages() async {
    if (_selectedImages.isEmpty) {
      return;
    }

    setState(() {
      _extractedText = ''; // Clear previous text
    });

    try {
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      StringBuffer combinedText = StringBuffer();

      for (var imageFile in _selectedImages) {
        final inputImage = InputImage.fromFilePath(imageFile.path);
        final RecognizedText recognizedText =
            await textRecognizer.processImage(inputImage);

        if (recognizedText.text.isNotEmpty) {
          combinedText.writeln(recognizedText.text);
          combinedText.writeln(); // Add space between different images
        }
      }

      await textRecognizer.close();

      setState(() {
        _extractedText = combinedText.toString();
      });

      if (_extractedText.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ExtractedTextScreen(extractedText: _extractedText),
          ),
        );
      }
    } catch (e) {
      setState(() {});
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const ToolsAppBar(
        title: 'OCR',
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [


                  const CustomSvgImage(imagePath: 'assets/images/ocr_image.svg'),
                  const SizedBox(height: 30),
                  const InfoCard(
                    title: 'Extract text from files',
                    description:
                        'Seamlessly extract text copy from multiple images or documents instantly.',
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
                        // File selection section
                        FileSelectionSection(
                          sectionTitle: 'Choose File',
                          onSelectFiles: () => _pickImages(ImageSource.gallery),
                          onScanNew: () => _pickImages(ImageSource.camera),
                        ),
                        // Dotted file drop zone
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 16),
                          child: DottedFileDropZone(
                            selectedImages: _selectedImages,
                            onTap: () => _pickImages(ImageSource.gallery),
                            onRemoveImage: _removeImage,
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
              text: 'Extract Text',
              onPressed: _extractTextFromImages,
            ),
          ),
        ],
      ),
    );
  }
}
