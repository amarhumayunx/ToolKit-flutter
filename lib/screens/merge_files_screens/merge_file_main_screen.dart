import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/buttons/gradient_btn.dart';
import '../../widgets/tools/custom_svg_image.dart';
import '../../widgets/tools/info_card.dart';
import '../../widgets/tools/tools_app_bar.dart';
import 'merge_result_screen.dart';

class MergeFileMainScreen extends StatefulWidget {
  const MergeFileMainScreen({super.key});

  @override
  State<MergeFileMainScreen> createState() => _MergeFileMainScreenState();
}

class _MergeFileMainScreenState extends State<MergeFileMainScreen> {
  final List<File> _selectedPdfs = [];
  String? _errorMessage;

  Future<void> _pickPdfs() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null) {
        List<File> newFiles = [];
        for (var file in result.files) {
          if (file.extension?.toLowerCase() != 'pdf') {
            setState(() {
              _errorMessage = 'Please select PDF files only';
            });
            continue;
          }

          if (file.path != null) {
            bool isDuplicate = _selectedPdfs
                .any((existingFile) => existingFile.path == file.path);
            if (!isDuplicate) {
              newFiles.add(File(file.path!));
            }
          }
        }

        setState(() {
          _selectedPdfs.addAll(newFiles);
          if (newFiles.isNotEmpty) {
            _errorMessage = null;
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error selecting PDFs: $e';
      });
    }
  }

  void _removePdf(int index) {
    setState(() {
      _selectedPdfs.removeAt(index);
    });
  }

  void _reorderPdfs(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final File item = _selectedPdfs.removeAt(oldIndex);
      _selectedPdfs.insert(newIndex, item);
    });
  }

  Future<void> _mergePdfs() async {
    if (_selectedPdfs.length < 2) {
      AppSnackBar.show(context, message: 'Please select at least 2 PDF files');
      return;
    }

    try {
      final PdfDocument outputDocument = PdfDocument();

      for (File file in _selectedPdfs) {
        final List<int> bytes = await file.readAsBytes();
        final PdfDocument inputDocument = PdfDocument(inputBytes: bytes);

        for (int i = 0; i < inputDocument.pages.count; i++) {
          outputDocument.pages.add().graphics.drawPdfTemplate(
                inputDocument.pages[i].createTemplate(),
                const Offset(0, 0),
              );
        }

        inputDocument.dispose();
      }

      final List<int> mergedBytes = outputDocument.saveSync();
      outputDocument.dispose();

      final dir = await getTemporaryDirectory();
      final mergedFile = File('${dir.path}/merged_output.pdf');
      await mergedFile.writeAsBytes(mergedBytes);

      // Navigate to MergeResultScreen with callback
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MergeResultScreen(
            mergedFilePath: mergedFile.path,
            onSaveAndReturn: () {
              // Clear the selected PDFs when returning
              setState(() {
                _selectedPdfs.clear();
              });
            },
          ),
        ),
      );
    } catch (e) {
      AppSnackBar.show(context, message: 'Failed to merge PDFs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const ToolsAppBar(title: 'Merge PDFs'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CustomSvgImage(imagePath: 'assets/images/merge_file_img.svg'),
                  const SizedBox(height: 30),
                  const InfoCard(
                    title: 'Merge PDF Files',
                    description:
                        'Effortlessly merge PDF Files for easier sharing, storage, and organization.',
                  ),
                  const SizedBox(height: 24),
                  _buildPdfSelectionContainer(),
                  if (_selectedPdfs.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSelectedPdfsList(),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 10),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            child: CustomGradientButton(
              text: 'Merge Files',
              onPressed: _mergePdfs,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfSelectionContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 14, top: 14),
              child: Text(
                'Select Files',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: _pickPdfs,
              child: DottedBorder(
                color: AppColors.primary,
                strokeWidth: 1.5,
                dashPattern: const [5, 4],
                borderType: BorderType.RRect,
                radius: const Radius.circular(8),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 100),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.bgBoxColor,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/upload_file_icon.svg',
                        height: 28,
                        width: 36,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Click to add PDF files',
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedPdfsList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 14, top: 14, bottom: 8),
              child: Text(
                'Selected Files (${_selectedPdfs.length})',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedPdfs.length,
            onReorder: _reorderPdfs,
            itemBuilder: (context, index) {
              final pdfFile = _selectedPdfs[index];
              final fileName = pdfFile.path.split('/').last;

              return Container(
                key: Key('pdf_$index'),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.bgBoxColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    fileName,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'Page order: ${index + 1}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  trailing: GestureDetector(
                    onTap: () => _removePdf(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
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
              );
            },
          ),
        ],
      ),
    );
  }
}
