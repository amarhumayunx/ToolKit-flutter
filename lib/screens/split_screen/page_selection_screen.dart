import 'package:flutter/material.dart';
import 'package:toolkit/screens/split_screen/split_progress_screen.dart';
import 'package:toolkit/widgets/buttons/gradient_btn.dart';
import 'package:toolkit/widgets/custom_appbar.dart';

import 'document_item.dart';

class PageSelectionScreen extends StatefulWidget {
  final DocumentItem selectedDocument;
  final int initialPageCount;
  final bool isWordDocument;

  const PageSelectionScreen({
    super.key,
    required this.selectedDocument,
    this.initialPageCount = 1,
    this.isWordDocument= false,
  });

  @override
  State<PageSelectionScreen> createState() => _PageSelectionScreenState();
}

class _PageSelectionScreenState extends State<PageSelectionScreen> {
  // Default page count that can be adjusted by user
  late int totalPages;
  late List<bool> selectedPages;
  final TextEditingController _pageCountController = TextEditingController(text: '6');

  @override
  void initState() {
    super.initState();
    totalPages = widget.initialPageCount;
    selectedPages = List.generate(totalPages, (index) => false);
  }

  @override
  void dispose() {
    _pageCountController.dispose();
    super.dispose();
  }

  void _togglePage(int pageIndex) {
    setState(() {
      selectedPages[pageIndex] = !selectedPages[pageIndex];
    });
  }






  void _onSplitPressed() {
    final anySelected = selectedPages.any((s) => s);
    if (!anySelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one page')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SplitProgressScreen(
          document: widget.selectedDocument,
          selectedPages: selectedPages,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'Split'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page grid only (Removed heading and page count input)
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
                                color: selectedPages[index]
                                    ? const Color(0xFF009688)
                                    : Colors.grey.shade300,
                                width: selectedPages[index] ? 2 : 1,
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
                          // Checkbox in the corner
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: selectedPages[index]
                                    ? const Color(0xFF009688)
                                    : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selectedPages[index]
                                      ? Colors.transparent
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child: selectedPages[index]
                                  ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                                  : null,
                            ),
                          ),
                          // Selected number indicator
                          if (selectedPages[index])
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
                                    '${selectedPages.take(index).where((selected) => selected).length + 1}',
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
              // Split button using the full width
              SizedBox(
                width: double.infinity,
                child: CustomGradientButton(
                  text: 'Split',
                  onPressed: _onSplitPressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}