import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_snackbar.dart';

class ResultDocumentContainer extends StatelessWidget {
  final String documentName;
  final String date;
  final String time;
  final String size;
  final bool isFavorite;
  final bool isLocked;
  final String filePath;
  final VoidCallback onFavoriteToggle;
  final VoidCallback? onDelete;
  final Function(String)? onFileRenamed;
  final Function()? onLockToggle;
  final String documentImage;
  final bool isSelectable;
  final bool isSelected;
  final VoidCallback? onTap;

  const ResultDocumentContainer({
    super.key,
    required this.documentName,
    required this.date,
    required this.time,
    required this.size,
    required this.isFavorite,
    required this.isLocked,
    required this.filePath,
    required this.onFavoriteToggle,
    this.onDelete,
    this.onFileRenamed,
    this.onLockToggle,
    this.documentImage = 'assets/images/doc.png',
    this.isSelectable = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 3,
              offset: const Offset(0, 0),
            ),
          ],
          // Only show border when selectable AND selected
          border: (isSelectable && isSelected)
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 50,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Stack(
                      children: [
                        Image.asset(
                          documentImage,
                          fit: BoxFit.fill,
                        ),
                        if (isLocked)
                          const Positioned(
                            bottom: 2,
                            right: 2,
                            child: Icon(
                              Icons.lock,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: 1,
                color: Colors.grey.shade300,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      documentName,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$date | $time | $size',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isSelectable) ...[
                GestureDetector(
                  onTap: onFavoriteToggle,
                  child: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: isFavorite ? Colors.amber : Colors.grey,
                    size: 24,
                  ),
                ),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: SvgPicture.asset(
                    'assets/icons/more_icon.svg',
                    height: 20,
                    width: 20,
                  ),
                  onSelected: (value) async {
                    switch (value) {
                      case 'edit':
                        await _showRenameDialog(context);
                        break;
                      case 'share':
                        await _shareFile(context);
                        break;
                      case 'lock':
                        if (onLockToggle != null) onLockToggle!();
                        break;
                      case 'delete':
                        if (onDelete != null) onDelete!();
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      _buildMenuItem(
                        value: 'edit',
                        text: 'Rename',
                      ),
                      const PopupMenuItem<String>(
                        enabled: false,
                        height: 10,
                        padding: EdgeInsets.zero,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.dividerColor,
                            ),
                          ),
                        ),
                      ),
                      _buildMenuItem(
                        value: 'share',
                        text: 'Share',
                      ),
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
                        value: 'lock',
                        text: isLocked ? 'Unlock' : 'Lock',
                      ),
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
                  elevation: 0.4,
                ),
              ] else ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.check_circle,
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  size: 24,
                ),
              ],
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
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

  Future<bool> _fileExistsInDirectory(
      String directoryPath, String fileName) async {
    try {
      final newFilePath = path.join(directoryPath, fileName);
      return await File(newFilePath).exists();
    } catch (e) {
      return false;
    }
  }

  Future<void> _showRenameDialog(BuildContext context) async {
    if (onFileRenamed == null) return;

    final fileName = File(filePath).uri.pathSegments.last;
    final fileNameWithoutExt = path.basenameWithoutExtension(fileName);
    final fileExtension = path.extension(fileName);
    final controller = TextEditingController(text: fileNameWithoutExt);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        String? errorMessage;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 5,
                    offset: const Offset(0, 5),
                  )
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
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Theme(
                      data: Theme.of(context).copyWith(
                        textSelectionTheme: TextSelectionThemeData(
                          cursorColor: AppColors.primary,
                          selectionColor: AppColors.primary.withOpacity(0.2),
                          selectionHandleColor: AppColors.primary,
                        ),
                        primaryColor: AppColors.primary,
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: AppColors.primary,
                        ),
                      ),
                      child: TextField(
                        controller: controller,
                        cursorColor: AppColors.primary,
                        selectionControls: MaterialTextSelectionControls(),
                        style: GoogleFonts.inter(
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: errorMessage != null
                                  ? Colors.red
                                  : AppColors.dividerColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: errorMessage != null
                                  ? Colors.red
                                  : AppColors.primary,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: errorMessage != null
                                  ? Colors.red
                                  : AppColors.dividerColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        style: GoogleFonts.inter(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
                actions: [
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                              final newName = controller.text.trim();
                              if (newName.isEmpty) {
                                setDialogState(() {
                                  errorMessage = 'Please enter a valid name';
                                });
                                return;
                              }

                              setDialogState(() {
                                errorMessage = null;
                              });

                              final file = File(filePath);
                              final newFileName = '$newName$fileExtension';
                              final directoryPath = path.dirname(filePath);

                              final fileExists = await _fileExistsInDirectory(
                                  directoryPath, newFileName);

                              if (fileExists) {
                                setDialogState(() {
                                  errorMessage = 'File name already exists.';
                                });
                                return;
                              }

                              final newPath =
                              path.join(directoryPath, newFileName);
                              await file.rename(newPath);

                              if (onFileRenamed != null) {
                                onFileRenamed!(newPath);
                              }

                              Navigator.of(context).pop();
                              AppSnackBar.show(context,
                                  message: 'File renamed successfully');
                            } catch (e) {
                              setDialogState(() {
                                errorMessage = 'Error renaming file: $e';
                              });
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
      },
    );
  }
}