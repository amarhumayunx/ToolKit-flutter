// extracted_text_screen.dart (updated with copy functionality)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for clipboard
import 'package:google_fonts/google_fonts.dart';
import 'package:open_file/open_file.dart';
import 'package:toolkit/widgets/custom_appbar.dart';
import '../../services/word_document_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/buttons/save_document_btn.dart';
import '../../widgets/tools/animated_loaded_container.dart';
import '../../widgets/tools/document_container.dart';

class ExtractedTextScreen extends StatefulWidget {
  final String extractedText;
  final String? detectedLanguage;

  const ExtractedTextScreen({
    super.key,
    required this.extractedText,
    this.detectedLanguage,
  });

  @override
  State<ExtractedTextScreen> createState() => _ExtractedTextScreenState();
}

class _ExtractedTextScreenState extends State<ExtractedTextScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = true;
  bool _animationCompleted = false;
  bool _isSaving = false;
  String? _savedFilePath;
  bool _fileRenamed = false; // Track if file was renamed
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  final WordDocumentService _wordDocumentService = WordDocumentService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _progressAnimation.addListener(() {
      setState(() {});
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleLoadingComplete();
      }
    });

    _animationController.forward();
  }

  Future<void> _handleLoadingComplete() async {
    setState(() {
      _isLoading = false;
      _animationCompleted = true;
      _textController.text = widget.extractedText;
    });

    await _saveAsWord();
  }

  @override
  void dispose() {
    _textController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveAsWord() async {
    try {
      setState(() {
        _isSaving = true;
      });

      final filePath =
      await _wordDocumentService.createWordDocument(_textController.text);

      setState(() {
        _isSaving = false;
        _savedFilePath = filePath;
      });
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      AppSnackBar.show(context, message: 'Error saving file: $e');
    }
  }

  Future<void> _handleFileDeleted() async {
    try {
      if (_savedFilePath != null) {
        final file = File(_savedFilePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      if (mounted) {
        Navigator.of(context).pop(true);
        Navigator.of(context).pop(true);
        AppSnackBar.show(context, message: 'File deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, message: 'Error deleting file: $e');
      }
    }
  }

  Future<void> _openDocument() async {
    if (_savedFilePath == null) return;

    try {
      final result = await OpenFile.open(_savedFilePath!);
      if (result.type != ResultType.done) {
        AppSnackBar.show(context,
            message: 'Could not open file: ${result.message}');
      }
    } catch (e) {
      AppSnackBar.show(context, message: 'Error opening file: $e');
    }
  }

  void _handleFileRenamed(String newPath) {
    setState(() {
      _savedFilePath = newPath;
      _fileRenamed = true;
    });
  }

  Future<void> _copyToClipboard() async {
    try {
      await Clipboard.setData(ClipboardData(text: _textController.text));
      if (mounted) {
        AppSnackBar.show(context, message: 'Text copied to clipboard');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, message: 'Error copying text: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'OCR',
        onBackPressed: () {
          Navigator.of(context).pop(false);
        },
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop(false);
          return false;
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    if (_isLoading || _animationCompleted)
                      _buildLoadingContainer(),
                    const SizedBox(height: 36),
                    if (!_isLoading) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Extracted Text File:',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_savedFilePath != null)
                        DocumentContainer(
                          filePath: _savedFilePath!,
                          onTap: _openDocument,
                          onDelete: _handleFileDeleted,
                          onFileRenamed: _handleFileRenamed,
                        ),
                      if (_savedFilePath == null)
                        Container(
                          width: double.infinity,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'No file available',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      // Updated section with copy button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Extracted Text:',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                        ],
                      ),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height * 0.4,
                        ),
                        child: Column(
                          children: [
                            _buildTextContainer(),
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 20),
                  ],
                ),
              ),
            ),
            if (!_isLoading && _savedFilePath != null)
              Positioned(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).padding.bottom + 20,
                child: SaveDocumentButton(
                  documentFile: File(_savedFilePath!),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  skipTimestamp: _fileRenamed, // Pass skipTimestamp if file was renamed
                  onSaveCompleted: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: Stack(
        children: [
          TextField(
            controller: _textController,
            maxLines: null,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(right: 40),
            ),
          ),
          Positioned(
            top: -2,
            right: 0,
            child: IconButton(
              onPressed: _copyToClipboard,
              icon: const Icon(
                Icons.content_copy,
                size: 25,
              ),
              style: IconButton.styleFrom(
                foregroundColor: AppColors.primary,
                animationDuration: const Duration(milliseconds: 300),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContainer() {
    return AnimatedLoadingContainer(
      animationController: _animationController,
      animationCompleted: _animationCompleted,
    );
  }
}