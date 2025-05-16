import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../widgets/buttons/gradient_btn.dart';
import '../../widgets/tools/custom_svg_image.dart';
import '../../widgets/tools/file_selection_container.dart';
import '../../widgets/tools/info_card.dart';
import '../../widgets/tools/tools_app_bar.dart';
import 'format_selection_screen.dart';

class ConvertImgMainScreen extends StatefulWidget {
  const ConvertImgMainScreen({super.key});

  @override
  State<ConvertImgMainScreen> createState() => _ConvertImgMainScreenState();
}

class _ConvertImgMainScreenState extends State<ConvertImgMainScreen> {
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _convertImage() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one image first')),
      );
      return;
    }

    setState(() {});

    try {
      // Simulate short delay
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {});

      // Navigate to format selection screen with the first image
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SelectFormatScreen(selectedImage: _selectedImages.first),
        ),
      );
    } catch (e) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ToolsAppBar(
        title: 'Convert Image',
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomSvgImage(imagePath: 'assets/images/convert_image.svg'),
                  const SizedBox(height: 30),
                  InfoCard(
                    title: 'Convert Image Format',
                    description:
                        'Easily convert images to various formats while maintaining quality, resolution and clarity.',
                  ),
                  const SizedBox(height: 24),
                  // Combined container with shadow
                  FileSelectionContainer(
                    title: 'Select File',
                    emptyStateText: 'Click to choose file',
                    selectedFiles: _selectedImages,
                    onTap: _pickImage,
                    onRemoveFile: _removeImage,
                    isMultipleSelection: false,
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
              onPressed: _convertImage,
            ),
          ),
        ],
      ),
    );
  }
}
