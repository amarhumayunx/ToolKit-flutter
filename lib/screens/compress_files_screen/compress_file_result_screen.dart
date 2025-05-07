import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../../widgets/buttons/gradient_btn.dart';
import '../../widgets/custom_appbar.dart';
import '../../utils/app_colors.dart';

class CompressedFileResultScreen extends StatelessWidget {
  final List<File> originalFiles;
  final List<File> compressedFiles;

  const CompressedFileResultScreen({
    super.key,
    required this.originalFiles,
    required this.compressedFiles,
  });

  // Calculate total size reduction
  double get totalSizeReduction {
    double originalSize = 0;
    double compressedSize = 0;

    for (var file in originalFiles) {
      originalSize += file.lengthSync().toDouble();
    }

    for (var file in compressedFiles) {
      compressedSize += file.lengthSync().toDouble();
    }

    // Calculate percentage reduction
    if (originalSize > 0) {
      return ((originalSize - compressedSize) / originalSize) * 100;
    }

    return 0;
  }

  // Calculate total saved space
  String get totalSpaceSaved {
    double originalSize = 0;
    double compressedSize = 0;

    for (var file in originalFiles) {
      originalSize += file.lengthSync().toDouble();
    }

    for (var file in compressedFiles) {
      compressedSize += file.lengthSync().toDouble();
    }

    double savedBytes = originalSize - compressedSize;

    // Format saved space in KB, MB, or GB
    if (savedBytes < 1024) {
      return "${savedBytes.toStringAsFixed(2)} B";
    } else if (savedBytes < 1024 * 1024) {
      return "${(savedBytes / 1024).toStringAsFixed(2)} KB";
    } else if (savedBytes < 1024 * 1024 * 1024) {
      return "${(savedBytes / (1024 * 1024)).toStringAsFixed(2)} MB";
    } else {
      return "${(savedBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB";
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return "$bytes B";
    } else if (bytes < 1024 * 1024) {
      return "${(bytes / 1024).toStringAsFixed(2)} KB";
    } else if (bytes < 1024 * 1024 * 1024) {
      return "${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB";
    } else {
      return "${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB";
    }
  }

  // In a real app, this would save the file to a user-selected location
  void _saveFile(BuildContext context, File file) {
    // This is a placeholder for actual save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('File saved: ${path.basename(file.path)}')),
    );
  }

  void _shareFiles(BuildContext context) {
    // This is a placeholder for sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing compressed files')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Compression Results'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Success illustration
                  SvgPicture.asset(
                    'assets/images/success_image.svg',
                    height: 120,
                    width: 120,
                  ),
                  const SizedBox(height: 24),

                  // Results summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Compression Complete',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Compression stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(
                              '${totalSizeReduction.toStringAsFixed(1)}%',
                              'Size Reduction',
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.grey.withOpacity(0.3),
                            ),
                            _buildStatItem(
                              totalSpaceSaved,
                              'Space Saved',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Files list
                        ...List.generate(
                          compressedFiles.length,
                              (index) => _buildFileItem(
                            context,
                            originalFiles[index],
                            compressedFiles[index],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom actions
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                CustomGradientButton(
                  text: 'Save All Files',
                  onPressed: () {
                    for (var file in compressedFiles) {
                      _saveFile(context, file);
                    }
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => _shareFiles(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Share Files',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFileItem(BuildContext context, File originalFile, File compressedFile) {
    final fileName = path.basename(compressedFile.path);
    final originalSize = originalFile.lengthSync();
    final compressedSize = compressedFile.lengthSync();
    final reduction = ((originalSize - compressedSize) / originalSize * 100).toStringAsFixed(1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // File icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFileIcon(fileName),
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // File details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatFileSize(originalSize)} → ${_formatFileSize(compressedSize)} ($reduction% smaller)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.download, size: 20),
                color: AppColors.primary,
                onPressed: () => _saveFile(context, compressedFile),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                color: Colors.grey[600],
                onPressed: () {
                  // Copy file path to clipboard
                  Clipboard.setData(ClipboardData(text: compressedFile.path));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('File path copied to clipboard')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = path.extension(fileName).toLowerCase();

    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      case '.ppt':
      case '.pptx':
        return Icons.slideshow;
      case '.jpg':
      case '.jpeg':
      case '.png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
}