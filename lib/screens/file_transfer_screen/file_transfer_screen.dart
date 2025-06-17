import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/file_model.dart';
import '../../widgets/buttons/gradient_btn.dart';
import '../../widgets/tools/custom_svg_image.dart';
import '../../widgets/tools/file_transfer_dropzone.dart';
import '../../widgets/tools/info_card.dart';
import '../../widgets/tools/tools_app_bar.dart';
import '../../widgets/tools/file_transfer_selection.dart';
import '../files_screens/files_main_screen.dart';

class FileTransferScreen extends StatefulWidget {
  const FileTransferScreen({super.key});

  @override
  State<FileTransferScreen> createState() => _FileTransferScreenState();
}

class _FileTransferScreenState extends State<FileTransferScreen> {
  FileModel? _selectedFile;
  bool _shouldClearFile = false;
  bool _isGeneratingQR = false;

  Future<void> _navigateToFileSelection() async {
    final List<FileModel>? selectedFiles = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FilesMainScreen(isSelectingFiles: true),
      ),
    );

    if (selectedFiles != null && selectedFiles.isNotEmpty) {
      setState(() {
        _selectedFile = selectedFiles.first;
        _shouldClearFile = false;
      });
    }
  }

  Future<void> _generateQRCode() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('select_at_least_one_file'.tr),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isGeneratingQR = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isGeneratingQR = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('qr_code_generated_successfully'.tr),
          backgroundColor: Colors.green,
        ),
      );

      _clearSelectedFile();
    } catch (e) {
      setState(() {
        _isGeneratingQR = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'error_generating_qr_code'.trParams({'error': e.toString()})),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  void _clearSelectedFile() {
    setState(() {
      _selectedFile = null;
      _shouldClearFile = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ToolsAppBar(
        title: 'file_transfer'.tr,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CustomSvgImage(
                    imagePath: 'assets/images/file_transfer_image.svg',
                  ),
                  const SizedBox(height: 30),
                  InfoCard(
                    title: 'easy_transfer_file'.tr,
                    description: 'easy_file_transfer_description'.tr,
                  ),
                  const SizedBox(height: 24),
                  Container(
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
                        FileTransferSelectionSection(
                          sectionTitle: 'choose_file'.tr,
                          onSelectFiles: _navigateToFileSelection,
                          onImportFile: _navigateToFileSelection,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                          child: FileTransferDropZone(
                            selectedFile: _selectedFile,
                            onTap: _navigateToFileSelection,
                            onRemoveFile: _removeFile,
                            isEmpty: _shouldClearFile || _selectedFile == null,
                            emptyStateText: 'Generate QR Code'.tr,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            child: CustomGradientButton(
              text: _isGeneratingQR
                  ? 'Generating QR Code'.tr
                  : 'Generate QR Code'.tr,
              onPressed: _isGeneratingQR ? null : _generateQRCode,
            ),
          ),
        ],
      ),
    );
  }
}