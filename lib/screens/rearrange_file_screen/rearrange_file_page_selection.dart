import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:toolkit/screens/rearrange_file_screen/pdf_rearrange_service.dart';
import '../../widgets/buttons/gradient_btn.dart';
import '../../widgets/custom_appbar.dart';
import '../split_screen/docxService.dart';
import 'rearrange_file_result_screen.dart';
import 'package:pdf/widgets.dart' as pw;

class RearrangeFilePageSelection extends StatefulWidget {
  final File selectedFile; // Add this parameter

  const RearrangeFilePageSelection({
    super.key,
    required this.selectedFile, // Required parameter
  });

  @override
  State<RearrangeFilePageSelection> createState() => _RearrangeFilePageSelectionState();
}

class _RearrangeFilePageSelectionState extends State<RearrangeFilePageSelection> {
  File? _docxFile;
  List<bool> _selectedPages = [];
  List<int> _pageSelectionOrder = []; // New: Track selection order
  String _fileName = '';
  bool _isLoading = true; // Start with loading state
  bool _isPdfFile = false;
  List<pw.Document> _pdfPages = [];

  @override
  void initState() {
    super.initState();
    // Process the file that was passed in
    _processSelectedFile();
  }

  Future<void> _processSelectedFile() async {
    try {
      _docxFile = widget.selectedFile;
      _fileName = path.basename(_docxFile!.path);

      // Check if it's a PDF file
      final fileExtension = path.extension(_docxFile!.path).toLowerCase();
      _isPdfFile = fileExtension == '.pdf';

      if (_isPdfFile) {
        // Handle PDF file
        final pdfService = PdfRearrangeService();
        final pageCount = await pdfService.getPageCount(_docxFile!);
        _pdfPages = await pdfService.extractPages(_docxFile!);

        setState(() {
          _selectedPages = List<bool>.filled(pageCount, true);
          // Initialize selection order for all pages (initially selected)
          _pageSelectionOrder = List.generate(pageCount, (index) => index);
          _isLoading = false;
        });
      } else {
        // Handle DOCX file (existing logic)
        final docxService = DocxSplitterService();
        final pages = await docxService.extractPages(_docxFile!);
        setState(() {
          _selectedPages = List<bool>.filled(pages.length, true);
          // Initialize selection order for all pages (initially selected)
          _pageSelectionOrder = List.generate(pages.length, (index) => index);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing file: ${e.toString()}')),
        );
      }
    }
  }

  void _togglePage(int index) {
    setState(() {
      if (_selectedPages[index]) {
        // Deselecting page - remove from order
        _selectedPages[index] = false;
        _pageSelectionOrder.remove(index);
      } else {
        // Selecting page - add to end of order
        _selectedPages[index] = true;
        _pageSelectionOrder.add(index);
      }
    });
  }

  // Get the display number for a page based on its selection order
  int _getPageDisplayNumber(int pageIndex) {
    if (!_selectedPages[pageIndex]) return 0;
    return _pageSelectionOrder.indexOf(pageIndex) + 1;
  }

  void _navigateToResults() {
    if (_docxFile == null) return;

    // Use the selection order as the new page order
    final newOrder = List<int>.from(_pageSelectionOrder);

    if (newOrder.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one page')),
      );
      return;
    }

    // Navigate to result screen with file type information
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RearrangeFileResultScreen(
          originalFile: _docxFile!,
          newPageOrder: newOrder,
          isPdfFile: _isPdfFile, // Pass this parameter
          pdfPages: _isPdfFile ? _pdfPages : null, // Pass PDF pages if it's a PDF
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = _selectedPages.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Rearrange Pages'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading)
                const LinearProgressIndicator()
              else ...[
                Text(
                  'Selected: $_fileName',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: totalPages,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _togglePage(index),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _selectedPages[index]
                                      ? const Color(0xFF009688)
                                      : Colors.grey.shade300,
                                  width: _selectedPages[index] ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: Image.asset(
                                        'assets/images/doc.png',
                                        fit: BoxFit.cover,
                                        height: 110,
                                        width: 110,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            'assets/images/doc.png',
                                            color: Colors.grey.shade400,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: _selectedPages[index]
                                      ? const Color(0xFF009688)
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _selectedPages[index]
                                        ? Colors.transparent
                                        : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                ),
                                child: _selectedPages[index]
                                    ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                                    : null,
                              ),
                            ),
                            if (_selectedPages[index])
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF009688),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${_getPageDisplayNumber(index)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CustomGradientButton(
                    text: 'Save',
                    onPressed: _navigateToResults,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}