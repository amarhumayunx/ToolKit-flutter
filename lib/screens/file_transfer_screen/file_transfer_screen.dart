import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/file_model.dart';
import '../../widgets/buttons/gradient_btn.dart';
import '../../widgets/tools/custom_svg_image.dart';
import '../../widgets/tools/file_transfer_dropzone.dart';
import '../../widgets/tools/info_card.dart';
import '../../widgets/tools/tools_app_bar.dart';
import '../../widgets/tools/file_transfer_selection.dart';
import '../files_screens/files_main_screen.dart';
import '../settings_screens/continue_with_google_screen.dart';
import '../../services/auth_service.dart';

class FileTransferScreen extends StatefulWidget {
  const FileTransferScreen({super.key});

  @override
  State<FileTransferScreen> createState() => _FileTransferScreenState();
}

class _FileTransferScreenState extends State<FileTransferScreen> {
  FileModel? _selectedFile;
  bool _shouldClearFile = false;
  bool _isGeneratingQR = false;
  QrCode? _generatedQrCode;
  String? _qrData;
  String? _qrDocumentId;
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        // Clear previous QR code when new file is selected
        _generatedQrCode = null;
        _qrData = null;
        _qrDocumentId = null;
      });
    }
  }

  Future<void> _generateQRCode() async {
    // First check if user is logged in
    final user = _authService.currentUser;
    if (user == null) {
      _showLoginRequiredDialog();
      return;
    }

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
      // Get file extension to determine type
      final fileExtension = path.extension(_selectedFile!.name).toLowerCase();
      final fileType = _getFileTypeFromExtension(fileExtension);

      // Create file information for QR code
      final fileInfo = {
        'name': _selectedFile!.name,
        'size': _selectedFile!.size,
        'path': _selectedFile!.displayPath,
        'type': fileType,
        'extension': fileExtension,
        'date': _selectedFile!.date.toIso8601String(),
        'isEncrypted': _selectedFile!.isEncrypted,
        'isFavorite': _selectedFile!.isFavorite,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'userId': user.uid, // Add user ID for security
      };

      // Convert to JSON string
      final qrDataString = jsonEncode(fileInfo);

      // First store the file data in Firestore including the full QR data
      final qrDocRef = await _firestore.collection('qr_codes').add({
        ...fileInfo,
        'qrData': qrDataString, // Store the complete QR JSON data
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'scanned': false,
        'scannedBy': null,
        'scannedAt': null,
        'ownerId': user.uid,
        'ownerEmail': user.email,
      });

      // Generate QR code with document ID included
      final qrCodeData = {
        ...fileInfo,
        'qrId': qrDocRef.id, // Include the Firestore document ID
      };

      final finalQrDataString = jsonEncode(qrCodeData);

      // Generate QR code
      final qrCode = QrCode.fromData(
        data: finalQrDataString,
        errorCorrectLevel: QrErrorCorrectLevel.M,
      );

      // Update the Firestore document with the final QR data that includes the ID
      await qrDocRef.update({
        'qrData': finalQrDataString, // Update with the complete data including ID
      });

      // Add slight delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _generatedQrCode = qrCode;
        _qrData = finalQrDataString;
        _qrDocumentId = qrDocRef.id;
        _isGeneratingQR = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('qr_code_generated_successfully'.tr),
          backgroundColor: Colors.green,
        ),
      );

      // Show QR code dialog
      _showQRCodeDialog();
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

  Future<void> _updateQRCodeStatus(bool isActive) async {
    if (_qrDocumentId == null) return;

    try {
      await _firestore.collection('qr_codes').doc(_qrDocumentId).update({
        'isActive': isActive,
        if (!isActive) 'deactivatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating QR code status: $e');
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.qr_code,
                  color: Color(0xFF00BCD4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sign in Required'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Please sign in to generate QR codes for your files.'.tr,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel'.tr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContinueWithGoogleScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Sign in'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showQRCodeDialog() {
    if (_generatedQrCode == null || _qrDocumentId == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Generated QR Code'.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: PrettyQrView.data(
                    data: _qrData!,
                    decoration: const PrettyQrDecoration(
                      shape: PrettyQrSmoothSymbol(
                        color: Color(0xFF00BCD4),
                      ),
                      image: PrettyQrDecorationImage(
                        image: AssetImage('assets/images/app_icon.png'),
                        position: PrettyQrDecorationImagePosition.embedded,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedFile!.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  _selectedFile!.size,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Close'.tr,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showSaveOptions();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BCD4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Save QR'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSaveOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Save QR Code'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.image, color: Color(0xFF00BCD4)),
                title: Text('Save as Image'.tr),
                subtitle: Text('Save QR code to gallery'.tr),
                onTap: () {
                  Navigator.pop(context);
                  _saveQRAsImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Color(0xFF00BCD4)),
                title: Text('Share QR Code'.tr),
                subtitle: Text('Share QR code with others'.tr),
                onTap: () {
                  Navigator.pop(context);
                  _shareQRCode();
                },
              ),
              ListTile(
                leading: const Icon(Icons.link_off, color: Colors.red),
                title: Text('Deactivate QR Code'.tr),
                subtitle: Text('This will make the QR code unusable'.tr),
                onTap: () {
                  Navigator.pop(context);
                  _showDeactivateConfirmation();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showDeactivateConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Deactivate QR Code?'.tr),
          content: Text(
              'Are you sure you want to deactivate this QR code? It will no longer be usable.'
                  .tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'.tr),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deactivateQRCode();
              },
              child: Text(
                'Deactivate'.tr,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deactivateQRCode() async {
    try {
      await _updateQRCodeStatus(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('QR code deactivated successfully'.tr),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deactivating QR code: $e'.tr),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _saveQRAsImage() {
    // Implement save to gallery functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('QR code saved to gallery'.tr),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareQRCode() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing QR code...'.tr),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
      _generatedQrCode = null;
      _qrData = null;
      _qrDocumentId = null;
    });
  }

  void _clearSelectedFile() {
    setState(() {
      _selectedFile = null;
      _shouldClearFile = true;
      _generatedQrCode = null;
      _qrData = null;
      _qrDocumentId = null;
    });
  }

  String _getFileTypeFromExtension(String extension) {
    switch (extension.toLowerCase()) {
      case '.pdf':
        return 'PDF Document';
      case '.doc':
      case '.docx':
        return 'Word Document';
      case '.txt':
        return 'Text File';
      case '.jpg':
      case '.jpeg':
        return 'JPEG Image';
      case '.png':
        return 'PNG Image';
      case '.gif':
        return 'GIF Image';
      case '.mp4':
        return 'MP4 Video';
      case '.mp3':
        return 'MP3 Audio';
      case '.zip':
        return 'ZIP Archive';
      case '.rar':
        return 'RAR Archive';
      case '.xlsx':
      case '.xls':
        return 'Excel Spreadsheet';
      case '.pptx':
      case '.ppt':
        return 'PowerPoint Presentation';
      default:
        return 'Unknown File';
    }
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
                  // Show generated QR code preview if available
                  if (_generatedQrCode != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
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
                          Text(
                            'Generated QR Code'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: 150,
                            height: 150,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: PrettyQrView.data(
                              data: _qrData!,
                              decoration: const PrettyQrDecoration(
                                shape: PrettyQrSmoothSymbol(
                                  color: Color(0xFF00BCD4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _showQRCodeDialog,
                            child: Text(
                              'View Full Size'.tr,
                              style: const TextStyle(
                                color: Color(0xFF00BCD4),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
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