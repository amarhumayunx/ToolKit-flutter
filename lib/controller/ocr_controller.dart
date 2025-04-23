
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/ocr_model.dart';


class OcrController {
  final OcrModel model = OcrModel();
  final ImagePicker _picker = ImagePicker();

  Future<void> selectFile(BuildContext context) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        model.selectedFilePath = pickedFile.path;
        // You could trigger processing here or in the view
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting file: $e')),
      );
    }
  }

  Future<void> scanNewFile(BuildContext context) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        model.selectedFilePath = pickedFile.path;
        // You could trigger processing here or in the view
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning: $e')),
      );
    }
  }
}