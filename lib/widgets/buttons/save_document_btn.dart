// save_document_button.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/save_document_service.dart';
import 'gradient_btn.dart';

class SaveDocumentButton extends StatelessWidget {
  final File documentFile;
  final String buttonText;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onSaveCompleted;

  const SaveDocumentButton({
    super.key,
    required this.documentFile,
    this.buttonText = 'Save',
    this.width,
    this.padding,
    this.onSaveCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
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
    final result = await SaveDocumentService.saveDocument(context, documentFile);

    // If save was successful or canceled, navigate back to OCR screen
    if (result != null) {
      // Call the callback if provided
      if (onSaveCompleted != null) {
        onSaveCompleted!();
      }

      // Navigate back to OCR screen and pass true to indicate data should be cleared
      Navigator.of(context).pop(true);
      Navigator.of(context).pop(true);
      Navigator.of(context).pop(true);
    }
  }
}