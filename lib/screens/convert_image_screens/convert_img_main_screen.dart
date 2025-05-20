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

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages
              .addAll(pickedFiles.map((file) => File(file.path)).toList());
        });
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting images: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _convertImages() async {
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

      // Pass all selected images to SelectFormatScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SelectFormatScreen(selectedImages: _selectedImages),
        ),
      );
    } catch (e) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing images: $e')),
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
                    'Easily convert multiple images to various formats while maintaining quality, resolution and clarity.',
                  ),
                  const SizedBox(height: 24),
                  // Combined container with shadow
                  FileSelectionContainer(
                    title: 'Select Images',
                    emptyStateText: 'click to choose file',
                    selectedFiles: _selectedImages,
                    onTap: _pickImages,
                    onRemoveFile: _removeImage,
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
              text: 'Next',
              onPressed: _convertImages,
            ),
          ),
        ],
      ),
    );
  }
}