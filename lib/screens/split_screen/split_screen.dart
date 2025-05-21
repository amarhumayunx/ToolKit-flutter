import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncfusion;
import 'package:toolkit/screens/split_screen/page_selection_screen.dart';
import 'package:toolkit/screens/split_screen/split_progress_screen.dart';
import 'package:toolkit/widgets/buttons/gradient_btn.dart';
import '../../widgets/tools/info_card.dart';
import '../../widgets/tools/tools_app_bar.dart';
import 'document_item.dart';
import 'file_drop.dart'; // <- Ensure this is imported

class SplitScreen extends StatefulWidget {
  const SplitScreen({super.key});

  @override
  State<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends State<SplitScreen> {
  final List<File> _selectedDocuments = [];
  final String _processedResult = '';
  final bool _isProcessing = false;
  String _documentErrorText = '';
  final DocxSplitterService _docxService = DocxSplitterService(); // <- Added

  void _removeDocument(int index) {
    setState(() {
      if (index >= 0 && index < _selectedDocuments.length) {
        _selectedDocuments.removeAt(index);
      }
    });
  }

  Future<void> _pickLocalDocuments() async {
    try {
      // Reset error text when trying to pick new files
      setState(() {
        _documentErrorText = "";
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
        withData: false,
        withReadStream: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final validExtensions = ['pdf', 'doc', 'docx'];

        List<File> pickedFiles = result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();

        List<File> validFiles = pickedFiles.where((file) {
          final ext = file.path.split('.').last.toLowerCase();
          return validExtensions.contains(ext);
        }).toList();

        setState(() {
          _selectedDocuments.addAll(validFiles);
          _documentErrorText = validFiles.length == pickedFiles.length
              ? ''
              : 'Please select only PDF, DOC or DOCX files';
        });
      }
    } catch (e) {
      setState(() {
        _documentErrorText = 'Error selecting documents: ${e.toString()}';
      });
      print('Error in file picker: $e');
    }
  }

  Future<bool> _processAndSplitDocuments() async {
    if (_selectedDocuments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one document')),
      );
      return false;
    }

    try {
      final firstFile = _selectedDocuments.first;
      final extension = path.extension(firstFile.path).toLowerCase();

      if (_selectedDocuments.length > 1) {
        final allSameType = _selectedDocuments.every(
              (file) => path.extension(file.path).toLowerCase() == extension,
        );

        if (!allSameType) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Please select files of the same type (all PDF, all DOCX, or all DOC)')),
          );
          return false;
        }

        if (extension == '.pdf') {
          // For multiple PDFs, create a merged document and go directly to progress screen
          final tempDir = await getTemporaryDirectory();
          final mergedFileName = 'merged_${DateTime.now().millisecondsSinceEpoch}.pdf';
          final mergedFilePath = path.join(tempDir.path, mergedFileName);

          int totalPages = 0;
          for (var file in _selectedDocuments) {
            final pdfData = await file.readAsBytes();
            final document = syncfusion.PdfDocument(inputBytes: pdfData);
            totalPages += document.pages.count;
            document.dispose();
          }

          final document = DocumentItem(
            name: path.basename(mergedFilePath),
            date: DateTime.now(),
            sizeInMB: await firstFile.length() / (1024 * 1024), // Approximate size
            file: firstFile, // Temporary - actual file will be created in progress screen
          );

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SplitProgressScreen(
                document: document,
                selectedPages: List<bool>.filled(totalPages, true),
                isMultipleFiles: true,
                documents: _selectedDocuments.map((file) => DocumentItem(
                  name: path.basename(file.path),
                  date: DateTime.now(),
                  sizeInMB: file.lengthSync() / (1024 * 1024),
                  file: file,
                )).toList(),
              ),
            ),
          );
          return true;
        } else if (extension == '.docx' || extension == '.doc') {
          // Existing DOCX merging logic remains the same
          final documents = _selectedDocuments.map((file) => DocumentItem(
            name: path.basename(file.path),
            date: DateTime.now(),
            sizeInMB: file.lengthSync() / (1024 * 1024),
            file: file,
          )).toList();

          final tempDir = await getTemporaryDirectory();
          final outputPath = path.join(tempDir.path, 'merged_${DateTime.now().millisecondsSinceEpoch}$extension');
          await _processMultipleWordFiles(documents, outputPath);
          final mergedFile = File(outputPath);

          final combinedDoc = DocumentItem(
            name: path.basename(outputPath),
            date: DateTime.now(),
            sizeInMB: mergedFile.lengthSync() / (1024 * 1024),
            file: mergedFile,
          );

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SplitProgressScreen(
                document: combinedDoc,
                selectedPages: const [true],
                isMultipleFiles: true,
                documents: documents,
              ),
            ),
          );
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unsupported file type')),
          );
          return false;
        }
      } else {
        // Single File Case remains unchanged
        final document = DocumentItem(
          name: path.basename(firstFile.path),
          date: DateTime.now(),
          sizeInMB: firstFile.lengthSync() / (1024 * 1024),
          file: firstFile,
        );

        if (extension == '.pdf') {
          final pageCount = await _getPdfPageCount(firstFile);

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PageSelectionScreen(
                selectedDocument: document,
                initialPageCount: pageCount,
                isWordDocument: false,
              ),
            ),
          );
          return true;
        } else if (extension == '.docx' || extension == '.doc') {
          final pages = await _docxService.extractPages(firstFile);

          if (pages.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No pages found in Word document')),
            );
            return false;
          }

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PageSelectionScreen(
                selectedDocument: document,
                initialPageCount: pages.length,
                isWordDocument: true,
              ),
            ),
          );
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unsupported file type')),
          );
          return false;
        }
      }
    } catch (e) {
      print('Error processing documents: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing files: ${e.toString()}')),
      );
      return false;
    }
  }

  Future<File?> _processMultipleWordFiles(List<DocumentItem> documents, String outputPath) async {
    try {
      final allPages = <DocxPage>[];
      for (final doc in documents) {
        final pages = await _docxService.extractPages(doc.file);
        allPages.addAll(pages);
      }

      final baseFile = documents.first.file;
      final bytes = await baseFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final newArchive = Archive();

      for (final file in archive.files) {
        if (!file.isFile) continue;
        if (file.name == 'word/document.xml') continue;
        newArchive.addFile(ArchiveFile(file.name, file.size, file.content));
      }

      final combinedXml = _docxService.combinePages(allPages);
      newArchive.addFile(ArchiveFile('word/document.xml', combinedXml.length, combinedXml.codeUnits));

      final zipBytes = ZipEncoder().encode(newArchive);
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(zipBytes!);

      return outputFile;
    } catch (e) {
      print('DOCX merge error: $e');
      return null;
    }
  }


  Future<int> _getPdfPageCount(File file) async {
    try {
      final pdfData = await file.readAsBytes();
      final document = syncfusion.PdfDocument(inputBytes: pdfData);
      final pageCount = document.pages.count;
      document.dispose();
      return pageCount;
    } catch (e) {
      print('Error getting PDF page count: $e');
      return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const ToolsAppBar(title: 'Split'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: SvgPicture.asset(
                      'assets/images/split_image.svg',
                      height: 176,
                      width: 186,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const InfoCard(
                    title: 'Split Pages In File',
                    description:
                    'Effortlessly separate pages from files while keeping everything clear and intact.',
                  ),
                  const SizedBox(height: 24),
                  // Styled file selection container
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
                        const Padding(
                          padding: EdgeInsets.only(top: 10, left: 16, bottom: 10),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Select File',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                          child: DottedFileDropZoneone(
                            selectedFiles: _selectedDocuments,
                            onTap: _pickLocalDocuments,
                            onRemoveFile: _removeDocument,
                          ),
                        ),

                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Center(
                      child: Text(
                        _documentErrorText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
            child: Column(
              children: [
                _isProcessing
                    ? const CircularProgressIndicator()
                    : CustomGradientButton(
                  text: 'Split Document',
                  onPressed: _processAndSplitDocuments,
                ),
                if (_processedResult.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _processedResult,
                      style: const TextStyle(
                        color: Colors.green,
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
  }

}