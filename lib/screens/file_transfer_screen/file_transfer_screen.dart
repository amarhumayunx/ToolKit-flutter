import 'package:flutter/material.dart';
import '../../widgets/tools/custom_svg_image.dart';
import '../../widgets/tools/info_card.dart';
import '../../widgets/tools/tools_app_bar.dart';

class FileTransferScreen extends StatefulWidget {
  const FileTransferScreen({super.key});

  @override
  State<FileTransferScreen> createState() => _FileTransferScreenState();
}

class _FileTransferScreenState extends State<FileTransferScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const ToolsAppBar(
        title: 'File Transfer',
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [


                  const CustomSvgImage(imagePath: 'assets/images/file_transfer_image.svg'),
                  const SizedBox(height: 30),
                  const InfoCard(
                    title: 'Easy Transfer File',
                    description:
                    'Transfer files instantly while keeping quality, resolution, and clarity intact.',
                  ),
                  const SizedBox(height: 24),
                  // Combined container with shadow
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
                    child: const Column(
                      children: [
                        // File selection section
                        // FileSelectionSection(
                        //   sectionTitle: 'Choose File',
                        //   onSelectFiles: () => _pickImages(ImageSource.gallery),
                        //   onScanNew: () => _pickImages(ImageSource.camera),
                        // ),
                        // Dotted file drop zone
                        Padding(
                          padding: EdgeInsets.only(
                              left: 16, right: 16, bottom: 16),
                          // child: DottedFileDropZone(
                          //   selectedImages: _selectedImages,
                          //   onTap: () => _pickImages(ImageSource.gallery),
                          //   onRemoveImage: _removeImage,
                          // ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding:
            EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            // child: CustomGradientButton(
            //   text: 'Extract Text',
            //   onPressed: _extractTextFromImages,
            // ),
          ),
        ],
      ),
    );
  }

}
