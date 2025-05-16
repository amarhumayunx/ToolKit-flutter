import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/save_zip_png_service.dart';
import '../../utils/app_colors.dart'; // Make sure to import your AppColors

class SaveFileButton extends StatelessWidget {
  final File file;
  final String fileType; // 'png', 'zip', 'docx', etc.
  final String buttonText;
  final double? width;

  const SaveFileButton({
    Key? key,
    required this.file,
    required this.fileType,
    this.buttonText = 'Save',
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 48,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.gradientStart,
              AppColors.gradientEnd,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ElevatedButton(
          onPressed: () => SaveFileService.saveFile(context, file, fileType),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
          child: Text(
            buttonText,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}