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
  final bool skipTimestamp;

  const SaveDocumentButton({
    super.key,
    required this.documentFile,
    this.buttonText = 'Save',
    this.width,
    this.padding,
    this.onSaveCompleted,
    this.skipTimestamp = true,
  });

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
      // Debug: Print current file path
      print('Saving file: ${documentFile.path}');
      print('File exists: ${await documentFile.exists()}');

      final result = await SaveDocumentService.saveDocument(
        context,
        documentFile,
        skipTimestamp: skipTimestamp,
      );

      if (!context.mounted) return;

      if (result == true) {
        if (onSaveCompleted != null) {
          onSaveCompleted!();
        }
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }}