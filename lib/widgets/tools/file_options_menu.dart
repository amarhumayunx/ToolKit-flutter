import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../utils/app_colors.dart';

class FileOptionsMenu extends StatelessWidget {
  final String filePath;
  final Function()? onDelete;
  final Function(String)? onFileRenamed;

  const FileOptionsMenu({
    super.key,
    required this.filePath,
    this.onDelete,
    this.onFileRenamed,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert,
        color: AppColors.t3SubHeading,
        size: 18,
      ),
      onSelected: (value) async {
        switch (value) {
          // case 'edit':
          //   _showRenameDialog(context);
          //   break;
          case 'share':
            await _shareFile(context);
            break;
          case 'delete':
            _showDeleteConfirmation(context);
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          // _buildMenuItem(
          //   value: 'edit',
          //   text: 'Edit',
          // ),
          // // Custom divider with padding and custom color
          // const PopupMenuItem<String>(
          //   enabled: false,
          //   height: 2,
          //   padding: EdgeInsets.zero,
          //   child: Center(
          //     child: Padding(
          //       padding: EdgeInsets.symmetric(horizontal: 16),
          //       child: Divider(
          //         height: 1,
          //         thickness: 1,
          //         color: AppColors.dividerColor,
          //       ),
          //     ),
          //   ),
          // ),
          _buildMenuItem(
            value: 'share',
            text: 'Share',
          ),
          // Custom divider with padding and custom color
          const PopupMenuItem<String>(
            enabled: false,
            height: 10,
            padding: EdgeInsets.zero,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.dividerColor,
                ),
              ),
            ),
          ),
          _buildMenuItem(
            value: 'delete',
            text: 'Delete',
          ),
        ];
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      elevation: 4,
    );
  }

  PopupMenuItem<String> _buildMenuItem({
    required String value,
    required String text,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: const Color(0xFF8E8E93),
          ),
        ),
      ),
    );
  }

  Future<void> _shareFile(BuildContext context) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        _showErrorSnackBar(context, 'File not found');
        return;
      }

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Sharing document from OCR Tool',
        subject: 'Document from OCR Tool',
      );
    } catch (e) {
      _showErrorSnackBar(context, 'Error sharing file: $e');
    }
  }

  void _showRenameDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final String currentFileName = filePath.split('/').last;
    controller.text = currentFileName.split('.').first;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 5,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rename File',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary // Primary color
                      ),
                ),
                const SizedBox(height: 10),
              ],
            ),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter new filename',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              autofocus: true,
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(color: Colors.grey[700]),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (controller.text.isNotEmpty) {
                          try {
                            final file = File(filePath);
                            if (!await file.exists()) {
                              _showErrorSnackBar(context, 'File not found');
                              Navigator.of(context).pop();
                              return;
                            }

                            final directory = file.parent;
                            final extension = filePath.split('.').last;
                            final newFilePath =
                                '${directory.path}/${controller.text}.$extension';

                            // Check if file already exists
                            if (await File(newFilePath).exists()) {
                              _showErrorSnackBar(context,
                                  'A file with this name already exists');
                              return;
                            }

                            // Rename the file
                            await file.rename(newFilePath);

                            if (onFileRenamed != null) {
                              onFileRenamed!(newFilePath);
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('File renamed successfully')),
                            );

                            Navigator.of(context).pop();
                          } catch (e) {
                            _showErrorSnackBar(
                                context, 'Error renaming file: $e');
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Rename',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 5,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delete File',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
            content: Text(
              'Are you sure you want to delete this file?',
              style: GoogleFonts.inter(),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(color: Colors.grey[700]),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          final file = File(filePath);
                          if (await file.exists()) {
                            await file.delete();

                            if (onDelete != null) {
                              onDelete!();
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('File deleted successfully')),
                            );
                          }
                          Navigator.of(context).pop();
                        } catch (e) {
                          _showErrorSnackBar(
                              context, 'Error deleting file: $e');
                          Navigator.of(context).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Delete',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
