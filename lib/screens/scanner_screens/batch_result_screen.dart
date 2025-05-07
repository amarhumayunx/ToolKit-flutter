import 'package:flutter/material.dart';
import 'dart:io';
import '../../widgets/batch_app_bar.dart';
import '../../widgets/scanner_widgets/document_preview.dart';
import '../../widgets/scanner_widgets/gallery_thumbnail.dart';
import 'document_edit_screen.dart';
class BatchResultScreen extends StatefulWidget {
  final List<File> batchImages;

  const BatchResultScreen({
    Key? key,
    required this.batchImages,
  }) : super(key: key);

  @override
  State<BatchResultScreen> createState() => _BatchResultScreenState();
}

class _BatchResultScreenState extends State<BatchResultScreen> {
  List<File> _processedImages = [];
  bool _isProcessing = false;
  bool _isExporting = false;
  int _selectedImageIndex = 0;
  bool _canScrollLeft = false;
  bool _canScrollRight = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _processedImages = List.from(widget.batchImages);
    _processImages();
    _scrollController.addListener(_updateScrollButtons);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollButtons);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _processImages() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isProcessing = false);
  }

  void _navigateToEditScreen() {
    if (_processedImages.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentEditScreen(
          imageFile: _processedImages[_selectedImageIndex],
          isBatchMode: true,
          batchImages: _processedImages,
          currentIndex: _selectedImageIndex,
        ),
      ),
    ).then((result) {
      if (result != null && result is File) {
        setState(() {
          _processedImages[_selectedImageIndex] = result;
        });
      }
    });
  }

  void _selectImage(int index) {
    setState(() {
      _selectedImageIndex = index;
      _canScrollLeft = index > 0;
      _canScrollRight = index < _processedImages.length - 1;
    });
  }

  void _updateScrollButtons() {
    if (_scrollController.hasClients) {
      setState(() {
        _canScrollLeft = _scrollController.offset > 0;
        _canScrollRight = _scrollController.offset <
            _scrollController.position.maxScrollExtent;
      });
    }
  }

  void _scrollLeft() {
    if (_scrollController.hasClients && _canScrollLeft) {
      final double newPosition = _scrollController.offset - 150;
      _scrollController.animateTo(
        newPosition < 0 ? 0 : newPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_selectedImageIndex > 0) {
      _selectImage(_selectedImageIndex - 1);
    }
  }

  void _scrollRight() {
    if (_scrollController.hasClients && _canScrollRight) {
      final double newPosition = _scrollController.offset + 150;
      _scrollController.animateTo(
        newPosition > _scrollController.position.maxScrollExtent
            ? _scrollController.position.maxScrollExtent
            : newPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_selectedImageIndex < _processedImages.length - 1) {
      _selectImage(_selectedImageIndex + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEECEC),
      appBar: BatchAppBar(
        onNextPressed: _navigateToEditScreen,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          // Main document preview
          Expanded(
            child: DocumentPreview(
              image: _processedImages[_selectedImageIndex],
            ),
          ),
          // Thumbnail gallery
          ThumbnailGallery(
            images: _processedImages,
            selectedIndex: _selectedImageIndex,
            onImageSelected: _selectImage,
            scrollController: _scrollController,
            onScrollLeft: _scrollLeft,
            onScrollRight: _scrollRight,
            canScrollLeft: _canScrollLeft,
            canScrollRight: _canScrollRight,
          ),
        ],
      ),
    );
  }
}