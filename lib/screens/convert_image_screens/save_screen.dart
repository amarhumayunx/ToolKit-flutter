import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:async';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../services/word_img_service.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/tools/animated_loaded_container.dart';
import '../../widgets/tools/document_container.dart';
import '../../widgets/buttons/save_document_btn.dart';

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

class _SaveScreenState extends State<SaveScreen>
    with SingleTickerProviderStateMixin {
  bool _animationCompleted = false;
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  File? convertedFile;
  String currentFileName = '';

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
    _progressAnimation.addListener(() => setState(() {}));
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleLoadingComplete();
      }
    });

    final originalName =
        widget.selectedImage.path.split('/').last.split('.').first;
    currentFileName = originalName;

    _convertFile();
    _animationController.forward();
  }

  Future<void> _handleLoadingComplete() async {
    setState(() {
      _animationCompleted = true;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _convertFile() async {
    try {
      if (widget.selectedFormat == 'Word') {
        final wordService = WordImageService();
        final wordFilePath =
            await wordService.createWordDocumentWithImage(widget.selectedImage);
        setState(() {
          convertedFile = File(wordFilePath);
        });
      } else if (widget.selectedFormat == 'PDF') {
        final pdf = pw.Document();
        final image = pw.MemoryImage(
          widget.selectedImage.readAsBytesSync(),
        );

        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(image),
              );
            },
          ),
        );

        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/$currentFileName.pdf';
        final file = File(path);
        await file.writeAsBytes(await pdf.save());

        setState(() {
          convertedFile = file;
        });
      } else {
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          convertedFile = widget.selectedImage;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error converting file: ${e.toString()}')),
        );
      }
    }
  }

  String get fileName => '$currentFileName.${_getFormatExtension()}';

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
        return 'png';
    }
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
        return 'assets/icons/convert_pdf.svg';
      default:
        return 'assets/icons/image_icon.svg';
    }
  }

  Future<void> _openFile() async {
    if (convertedFile != null && convertedFile!.existsSync()) {
      try {
        final result = await OpenFile.open(convertedFile!.path);
        if (result.type != ResultType.done && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cannot open file: ${result.message}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error opening file: ${e.toString()}')),
          );
        }
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File not found or not yet converted')),
      );
    }
  }

  void _handleFileDeleted() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File deleted successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Convert Image'),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildLoadingContainer(),
                  if (_animationCompleted && convertedFile != null) ...[
                    const SizedBox(height: 36),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Converted File:',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DocumentContainer(
                      filePath: convertedFile!.path,
                      onTap: _openFile,
                      onDelete: _handleFileDeleted,
                    ),
                  ],
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 300),
                ],
              ),
            ),
          ),
          if (_animationCompleted && convertedFile != null)
            Positioned(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 20,
              child: SaveDocumentButton(
                documentFile: convertedFile!,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
