import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:async';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../../utils/app_colors.dart';
import '../../widgets/buttons/gradient_btn.dart';

class SaveScreen extends StatefulWidget {
  final File selectedImage;
  final String selectedFormat;

  const SaveScreen({
    super.key,
    required this.selectedImage,
    required this.selectedFormat,
  });

  @override
  State<SaveScreen> createState() => _SaveScreenState();
}

class _SaveScreenState extends State<SaveScreen> {
  bool isConverting = true;
  bool isCompleted = false;
  double conversionProgress = 0.0;
  Timer? _timer;
  File? convertedFile;
  String currentFileName = '';

  @override
  void initState() {
    super.initState();
    // Set initial file name
    final originalName =
        widget.selectedImage.path.split('/').last.split('.').first;
    currentFileName = originalName;
    // Actually convert the file
    _convertFile();
  }

  Future<void> _convertFile() async {
    // Start showing progress
    _startProgressAnimation();

    try {
      if (widget.selectedFormat == 'PDF') {
        // Create a PDF document
        final pdf = pw.Document();

        // Load the image
        final imageBytes = await widget.selectedImage.readAsBytes();
        final image = pw.MemoryImage(imageBytes);

        // Add image to the PDF
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(image),
              );
            },
          ),
        );

        // Save the PDF to a file
        final output = await getTemporaryDirectory();
        final pdfPath = '${output.path}/$currentFileName.pdf';
        final file = File(pdfPath);
        await file.writeAsBytes(await pdf.save());

        // Update state with the converted file
        setState(() {
          convertedFile = file;
          isConverting = false;
          isCompleted = true;
          conversionProgress = 1.0;
        });

        // Cancel the progress timer if it's still running
        _timer?.cancel();
      } else {
        // For other formats, implement their conversion logic here
        // For now, just simulate conversion with a delay
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          isConverting = false;
          isCompleted = true;
          conversionProgress = 1.0;
        });
        _timer?.cancel();
      }
    } catch (e) {
      // Handle errors
      setState(() {
        isConverting = false;
        isCompleted = false;
      });
      _timer?.cancel();

      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error converting file: ${e.toString()}')),
        );
      }
    }
  }

  void _startProgressAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        // Progress more slowly to give time for actual conversion
        conversionProgress += 0.005;
        if (conversionProgress >= 0.95) {
          // Cap at 95% until the actual conversion is done
          conversionProgress = 0.95;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Get file information
  String get fileName {
    return '$currentFileName.${_getFormatExtension()}';
  }

  String _getFormatExtension() {
    switch (widget.selectedFormat) {
      case 'Word':
        return 'docx';
      case 'Excel':
        return 'xlsx';
      case 'PowerPoint':
        return 'pptx';
      case 'PDF':
        return 'pdf';
      default:
        return 'docx';
    }
  }

  String get fileSize {
    if (convertedFile != null) {
      return (convertedFile!.lengthSync() / (1024 * 1024)).toStringAsFixed(2);
    }
    return (widget.selectedImage.lengthSync() / (1024 * 1024))
        .toStringAsFixed(2);
  }

  String get formattedDate {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year.toString().substring(2)}';
  }

  String get formattedTime {
    final now = DateTime.now();
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')}${now.hour < 12 ? 'am' : 'pm'}';
  }

  // Method to open the PDF file
  Future<void> _openPdf() async {
    if (convertedFile != null) {
      try {
        final result = await OpenFile.open(convertedFile!.path);
        if (result.type != ResultType.done) {
          // If OpenFile fails
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cannot open PDF: ${result.message}')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error opening PDF: ${e.toString()}')),
          );
        }
      }
    }
  }

  // Show file options menu
  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOptionItem(context, 'Edit', Icons.edit, () {
                Navigator.pop(context);
                _showEditFileNameDialog(context);
              }),
              const Divider(),
              _buildOptionItem(context, 'Export', Icons.download, () {
                Navigator.pop(context);
                // Implement export functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Export functionality will be implemented')),
                );
              }),
              const Divider(),
              _buildOptionItem(context, 'Delete', Icons.delete, () {
                Navigator.pop(context);
                _showDeleteConfirmationDialog(context);
              }),
              const Divider(),
              _buildOptionItem(context, 'Lock', Icons.lock, () {
                Navigator.pop(context);
                // Implement lock functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Lock functionality will be implemented')),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionItem(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Row(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show dialog to edit file name
  void _showEditFileNameDialog(BuildContext context) {
    final TextEditingController controller =
        TextEditingController(text: currentFileName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit File Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter new file name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    currentFileName = controller.text;
                  });

                  // If file exists, rename it
                  if (convertedFile != null) {
                    final directory = convertedFile!.parent;
                    final newPath =
                        '${directory.path}/$currentFileName.${_getFormatExtension()}';

                    // Save with new name on next save operation
                    // We won't actually rename the temp file here
                  }
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete File'),
          content: const Text('Are you sure you want to delete this file?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Delete the file
                if (convertedFile != null && convertedFile!.existsSync()) {
                  try {
                    convertedFile!.deleteSync();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('File deleted successfully')),
                    );
                    // Go back to home screen
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Error deleting file: ${e.toString()}')),
                    );
                  }
                }
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isConverting ? 'Converting file' : 'Converted File',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          if (!isConverting)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // Show progress indicator or success icon
            isConverting
                ? _buildConversionProgress()
                : _buildConversionComplete(),

            const SizedBox(height: 40),

            // File details
            if (isCompleted) _buildFileDetails(),

            const Spacer(),

            // Action buttons - Only Save button now
            if (isCompleted)
              CustomGradientButton(
                text: 'Save',
                onPressed: () async {
                  // Save to a more permanent location if needed
                  if (convertedFile != null) {
                    try {
                      final appDocDir =
                          await getApplicationDocumentsDirectory();
                      final savedFile = await convertedFile!
                          .copy('${appDocDir.path}/${fileName}');

                      // Show success message and return to home
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('File saved successfully!')),
                        );
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      }
                    } catch (e) {
                      // Show error
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Error saving file: ${e.toString()}')),
                        );
                      }
                    }
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversionProgress() {
    return Column(
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: conversionProgress,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                Text(
                  '${(conversionProgress * 100).toInt()}%',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Converting your file',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please wait',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildConversionComplete() {
    return Column(
      children: [
        Container(
          width: 262,
          height: 248,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 145,
              height: 145,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.check_circle,
                size: 60,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Conversion Complete',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFileDetails() {
    return GestureDetector(
      onTap: () {
        if (widget.selectedFormat == 'PDF' && convertedFile != null) {
          _openPdf();
        }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Document thumbnail
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 50,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey.shade100,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      _getFormatIcon(),
                      width: 28,
                      height: 32,
                    ),
                  ),
                ),
              ),

              // Vertical Divider
              Container(
                width: 1,
                color: Colors.grey.shade300,
              ),

              const SizedBox(width: 12),

              // File info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        fileName,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$formattedDate | $formattedTime | $fileSize MB',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // More Options icon
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  size: 16,
                  color: Colors.grey[600],
                ),
                onPressed: () => _showOptionsMenu(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFormatIcon() {
    switch (widget.selectedFormat) {
      case 'Word':
        return 'assets/icons/word_icon.svg';
      case 'Excel':
        return 'assets/icons/excel_icon.svg';
      case 'PowerPoint':
        return 'assets/icons/powerpoint_icon.svg';
      case 'PDF':
        return 'assets/icons/convert_img_icon.svg';
      default:
        return 'assets/icons/word_icon.svg';
    }
  }
}
