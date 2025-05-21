import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/save_zip_png_service.dart';
import '../../utils/app_snackbar.dart';
import 'gradient_btn.dart';

class SaveDocumentButton extends StatelessWidget {
  final File documentFile;
  final String buttonText;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onSaveCompleted;

  const SaveDocumentButton({
    Key? key,
    required this.documentFile,
    this.buttonText = 'Save',
    this.width,
    this.padding,
    this.onSaveCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: SizedBox(
        width: width ?? double.infinity,
        child: CustomGradientButton(
          onPressed: () => _handleSave(context),
          text: buttonText,
        ),
      ),
    );
  }

  Future<void> _handleSave(BuildContext context) async {
    try {
      // Determine file extension (assuming it's a DOCX file by default)
      String fileExtension = 'docx';
      if (documentFile.path.contains('.')) {
        fileExtension = documentFile.path.split('.').last.toLowerCase();
      }

      // Save the file using SaveFileService
      await SaveFileService.saveFile(context, documentFile, fileExtension);

      // Call the callback if provided
      if (onSaveCompleted != null) {
        onSaveCompleted!();
      }

      // Navigate back and pass true to indicate data should be cleared
      Navigator.of(context).pop(true);
    } catch (e) {
      debugPrint('Error saving document: $e');
      AppSnackBar.show(context,
          message: 'Failed to save document: ${e.toString()}');
    }
  }
}
