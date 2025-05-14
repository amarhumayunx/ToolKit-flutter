import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/save_document_service.dart';
import 'gradient_btn.dart';

class SaveDocumentButton extends StatelessWidget {
  final File documentFile;
  final String buttonText;
  final double? width;
  final EdgeInsetsGeometry? padding;

  const SaveDocumentButton({
    Key? key,
    required this.documentFile,
    this.buttonText = 'Save',
    this.width,
    this.padding,
  }) : super(key: key);

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
    await SaveDocumentService.saveDocument(context, documentFile);
  }
}