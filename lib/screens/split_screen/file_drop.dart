import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class DottedFileDropZoneone extends StatelessWidget {
  final List<File> selectedFiles;
  final VoidCallback onTap;
  final Function(int) onRemoveFile;

  const DottedFileDropZoneone({
    super.key,
    required this.selectedFiles,
    required this.onTap,
    required this.onRemoveFile,
  });

  // Helper function to get file icon based on extension
  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  // Get file name from path
  String _getFileName(String filePath) {
    return path.basename(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: const Color(0xFF00BCD4), // AppColors.primary
      strokeWidth: 1.5,
      dashPattern: const [5, 4],
      borderType: BorderType.RRect,
      radius: const Radius.circular(8),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: 128,
          maxHeight: selectedFiles.isNotEmpty ? 300 : 128,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF00BCD4).withOpacity(0.05),
        ),
        child: selectedFiles.isNotEmpty
            ? SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedFiles.asMap().entries.map((entry) {
                    final index = entry.key;
                    final file = entry.value;
                    final extension = path.extension(file.path);

                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getFileIcon(extension),
                                size: 40,
                                color: const Color(0xFF00BCD4),
                              ),
                              const SizedBox(height: 5),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  _getFileName(file.path),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () => onRemoveFile(index),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: onTap,
              child: SvgPicture.asset(
                'assets/icons/upload_file_icon.svg',
                height: 28,
                width: 36,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Drag & Drop or click to choose file',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}