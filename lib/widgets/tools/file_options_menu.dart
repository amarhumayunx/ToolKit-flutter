import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_snackbar.dart';

class FileOptionsMenu extends StatelessWidget {
  final String filePath;
  final Function()? onDelete;

  const FileOptionsMenu({
    Key? key,
    required this.filePath,
    this.onDelete,
  }) : super(key: key);

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
          _buildMenuItem(
            value: 'share',
            text: 'Share',
          ),
          // Custom divider with padding and custom color
          PopupMenuItem<String>(
            enabled: false,
            height: 10,
            padding: EdgeInsets.zero,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
            color: Color(0xFF8E8E93),
          ),
        ),
      ),
    );
  }

  Future<void> _shareFile(BuildContext context) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        AppSnackBar.show(context, message: 'File not found');
        return;
      }

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Sharing document from OCR Tool',
        subject: 'Document from OCR Tool',
      );
    } catch (e) {
      AppSnackBar.show(context, message: 'Error sharing file: $e');
    }
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

                            AppSnackBar.show(context,
                                message: 'File deleted successfully');
                          }
                          Navigator.of(context).pop();
                        } catch (e) {
                          AppSnackBar.show(context,
                              message: 'Error deleting file: $e');
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
}
