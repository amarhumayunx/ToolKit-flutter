import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_colors.dart';

class DottedFileDropZone extends StatelessWidget {
  final List<File> selectedImages;
  final VoidCallback onTap;
  final Function(int) onRemoveImage;
  final String emptyStateText;

  const DottedFileDropZone({
    super.key,
    required this.selectedImages,
    required this.onTap,
    required this.onRemoveImage,
    this.emptyStateText = 'Click to choose files',
  });

  @override
  Widget build(BuildContext context) {
    return DottedBorder(
      color: AppColors.primary,
      strokeWidth: 1.5,
      dashPattern: const [5, 4],
      borderType: BorderType.RRect,
      radius: const Radius.circular(8),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          minHeight: 128,
          maxHeight: selectedImages.isNotEmpty ? 300 : 128,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF00BCD4).withOpacity(0.05),
        ),
        child: selectedImages.isNotEmpty
            ? SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedImages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final image = entry.value;
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () => onRemoveImage(index),
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
              emptyStateText,
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