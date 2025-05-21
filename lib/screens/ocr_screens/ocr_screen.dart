import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import '../../utils/app_snackbar.dart';
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
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  String _extractedText = '';
  bool _shouldClearImages = false;

  Future<void> _pickImages(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        final List<File>? capturedImages = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OcrCameraScreen(),
          ),
        );

        if (capturedImages != null && capturedImages.isNotEmpty) {
          setState(() {
            _selectedImages.addAll(capturedImages);
            _shouldClearImages = false;
          });
        }
      } else {
        final List<XFile> pickedFiles = await _picker.pickMultiImage();
        if (pickedFiles.isNotEmpty) {
          setState(() {
            _selectedImages
                .addAll(pickedFiles.map((file) => File(file.path)).toList());
            _shouldClearImages = false;
          });
        }
      }
    } catch (e) {
      print("Error picking images: $e");
    }
  }

  Future<void> _extractTextFromImages() async {
    if (_selectedImages.isEmpty) {
      AppSnackBar.show(context, message: 'Please select at least one image');

      return;
    }

    setState(() {
      _extractedText = '';
    });

    try {
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      StringBuffer combinedText = StringBuffer();
      bool textFound = false;

      for (var imageFile in _selectedImages) {
        final inputImage = InputImage.fromFilePath(imageFile.path);
        final RecognizedText recognizedText =
            await textRecognizer.processImage(inputImage);

        if (recognizedText.text.isNotEmpty) {
          textFound = true;
          combinedText.writeln(recognizedText.text);
          combinedText.writeln();
        }
      }

      await textRecognizer.close();

      setState(() {
        _extractedText = combinedText.toString();
      });

      if (textFound) {
        final shouldClear = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ExtractedTextScreen(extractedText: _extractedText),
          ),
        );

        if (shouldClear == true) {
          _clearSelectedImages();
        }
      } else {
        AppSnackBar.show(context,
            message: 'No text could be found in the selected images');
      }
    } catch (e) {
      print("Error in OCR: $e");
      AppSnackBar.show(context, message: 'Error processing images: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _clearSelectedImages() {
    setState(() {
      _selectedImages.clear();
      _extractedText = '';
      _shouldClearImages = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ToolsAppBar(
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
                  CustomSvgImage(imagePath: 'assets/images/ocr_image.svg'),
                  const SizedBox(height: 30),
                  InfoCard(
                    title: 'Extract text from files',
                    description:
                        'Seamlessly extract text copy from multiple images or documents instantly.',
                  ),
                  const SizedBox(height: 24),
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
                        FileSelectionSection(
                          sectionTitle: 'Choose File',
                          onSelectFiles: () => _pickImages(ImageSource.gallery),
                          onScanNew: () => _pickImages(ImageSource.camera),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 16),
                          child: DottedFileDropZone(
                            selectedImages: _selectedImages,
                            onTap: () => _pickImages(ImageSource.gallery),
                            onRemoveImage: _removeImage,
                            isEmpty:
                                _shouldClearImages || _selectedImages.isEmpty,
                            emptyStateText: 'Click to choose files',
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
