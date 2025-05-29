import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:toolkit/screens/scanner_screens/result_screen.dart';
import '../../services/word_images_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/batch_app_bar.dart';
import '../../widgets/scanner_widgets/document_preview.dart';
import 'package:provider/provider.dart';
import '../../widgets/scanner_widgets/filter_selector.dart';

// Filter provider to manage filter state
class FilterProvider extends ChangeNotifier {
  String _selectedFilter = 'Original';
  final Map<String, File> _filterCache = {};

  String get selectedFilter => _selectedFilter;

  Map<String, File> get filterCache => _filterCache;

  void setFilter(String filterName) {
    _selectedFilter = filterName;
    notifyListeners();
  }

  void addToCache(String filterName, File imageFile) {
    _filterCache[filterName] = imageFile;
  }

  void clearCache() {
    _filterCache.clear();
  }
}

class DocumentEditScreen extends StatefulWidget {
  final File imageFile;
  final bool isBatchMode;
  final List<File>? batchImages;
  final int? currentIndex;
  final bool isBusinessCard;
  final bool isPassport;
  final bool isLegal;
  final bool isLetter;
  final bool isIdCard;
  final Rect? cropRect;

  const DocumentEditScreen({
    super.key,
    required this.imageFile,
    this.isBatchMode = false,
    this.batchImages,
    this.currentIndex,
    this.isBusinessCard = false,
    this.cropRect,
    this.isPassport = false,
    this.isLegal = false,
    this.isLetter = false,
    this.isIdCard = false,
  });

  @override
  State<DocumentEditScreen> createState() => _DocumentEditScreenState();
}

class _DocumentEditScreenState extends State<DocumentEditScreen>
    with SingleTickerProviderStateMixin {
  File? _processedImage;
  bool _isRotating = false;
  bool _isFiltering = false;
  double _rotationAngle = 0;
  bool _hasChanges = false;

  // Animation controller for filter scanning effect
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isApplyingFilter = false;

  // Current image index for batch mode
  late int _currentIndex;

  // Edit history stack for undo/redo functionality
  List<File> _editHistory = [];
  int _currentHistoryIndex = 0;

  // Filter options
  final List<String> _filterOptions = [
    'Original',
    'Cool Tone',
    'Warm Tone',
    'Grayscale',
    'Blue Light',
    'Sepia',
    'Soft Pastel'
  ];

  // Pre-computed filter thumbnails
  final Map<String, File> _filterPreviews = {};
  bool _previewsReady = false;

  late FilterProvider _filterProvider;

  @override
  void initState() {
    super.initState();
    _processedImage = widget.imageFile;
    _currentIndex = widget.currentIndex ?? 0;
    _filterProvider = FilterProvider();

    // Add original image to history
    _editHistory.add(widget.imageFile);

    // Initialize animation controller with fixed duration
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Exactly 2 seconds
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        // When animation completes, ensure we update the UI
        if (status == AnimationStatus.completed) {
          setState(() {
            _isApplyingFilter = false;
          });
        }
      });

    // Pre-compute filter previews in the background
    _preGenerateFilterPreviews();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _cropImage() async {
    if (_processedImage == null) return;

    setState(() {
      _isRotating = true; // Reuse the rotating indicator for cropping
    });

    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _processedImage!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        maxWidth: 3000,
        maxHeight: 3000,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Document',
            toolbarWidgetColor: AppColors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: false,
            backgroundColor: Colors.white,
            activeControlsWidgetColor: AppColors.primary,
            dimmedLayerColor: AppColors.scannerBackground,
            cropFrameColor: AppColors.primary,
            cropFrameStrokeWidth: 4,
            showCropGrid: false,
          ),
          IOSUiSettings(
            title: 'Crop Document',
            aspectRatioLockEnabled: false,
            resetAspectRatioEnabled: true,
            aspectRatioPickerButtonHidden: true,
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: false,
            hidesNavigationBar: false,
            minimumAspectRatio: 0.5,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _processedImage = File(croppedFile.path);
          _hasChanges = true;
        });

        // Add to edit history
        _addToHistory(File(croppedFile.path));

        // Clear filter cache as cropped image needs new filter previews
        _filterProvider.clearCache();
        _preGenerateFilterPreviews();
      }
    } catch (e) {
      debugPrint('Error cropping image: $e');
      if (mounted) {
        AppSnackBar.show(context, message: 'Failed to crop image');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRotating = false;
        });
      }
    }
  }

  Future<void> _preGenerateFilterPreviews() async {
    for (String filter in _filterOptions) {
      File preview = await _generateFilterPreview(filter);
      _filterPreviews[filter] = preview;
    }

    if (mounted) {
      setState(() {
        _previewsReady = true;
      });
    }
  }

  Future<void> _rotateImage() async {
    setState(() {
      _isRotating = true;
    });

    try {
      // Load the image
      final imageBytes = await _processedImage!.readAsBytes();
      final image = img.decodeImage(imageBytes)!;

      // Rotate the image
      final rotatedImage = img.copyRotate(image, angle: 90);

      // Save the rotated image
      final newPath = await _saveTempImage(rotatedImage);

      setState(() {
        _rotationAngle += 90;
        _processedImage = File(newPath);
        _hasChanges = true;
      });

      // Add to edit history (trim future history if navigating back)
      _addToHistory(File(newPath));

      // Clear filter cache as rotated image needs new filter previews
      _filterProvider.clearCache();
      _preGenerateFilterPreviews();
    } catch (e) {
      // Handle any errors
      print('Error rotating image: $e');
    } finally {
      setState(() {
        _isRotating = false;
      });
    }
  }

  void _addToHistory(File imageFile) {
    // Remove any forward history if we're not at the end
    if (_currentHistoryIndex < _editHistory.length - 1) {
      _editHistory = _editHistory.sublist(0, _currentHistoryIndex + 1);
    }

    // Add new edit to history
    _editHistory.add(imageFile);
    _currentHistoryIndex = _editHistory.length - 1;
  }

  void _undo() {
    if (_currentHistoryIndex > 0) {
      _currentHistoryIndex--;
      setState(() {
        _processedImage = _editHistory[_currentHistoryIndex];
        _hasChanges = true;
      });
    }
  }

  void _redo() {
    if (_currentHistoryIndex < _editHistory.length - 1) {
      _currentHistoryIndex++;
      setState(() {
        _processedImage = _editHistory[_currentHistoryIndex];
        _hasChanges = true;
      });
    }
  }

  Future<void> _applyFilter(String filterName) async {
    // Set selected filter immediately
    _filterProvider.setFilter(filterName);

    // Skip animation for Original filter
    if (filterName != 'Original') {
      // Start scanning animation
      setState(() {
        _isApplyingFilter = true;
      });
      _animationController.reset();
      _animationController.forward();
    }

    // Check if we already have this filter cached
    if (_filterProvider.filterCache.containsKey(filterName)) {
      setState(() {
        _processedImage = _filterProvider.filterCache[filterName];
        _hasChanges = true;
      });

      // Add to edit history
      _addToHistory(_filterProvider.filterCache[filterName]!);

      // Skip animation for Original filter
      if (filterName == 'Original') {
        setState(() {
          _isApplyingFilter = false;
        });
      }
      return;
    }

    // If not cached, generate it
    try {
      // Load the original image from history (first item)
      final originalImageBytes = await _editHistory.first.readAsBytes();
      var image = img.decodeImage(originalImageBytes)!;

      // Apply rotation if any
      if (_rotationAngle != 0) {
        image = img.copyRotate(image, angle: _rotationAngle.toInt());
      }

      // Apply selected filter with enhanced contrast for text
      switch (filterName) {
        case 'Sepia':
          image = img.sepia(image);
          image = img.adjustColor(image, contrast: 1.3);
          break;
        case 'Cool Tone':
          image = img.colorOffset(image, blue: 20, green: 10);
          image = img.adjustColor(image, contrast: 1.2, gamma: 1.0);
          break;
        case 'Warm Tone':
          image = img.colorOffset(image, red: 20, green: 10);
          image = img.adjustColor(image, contrast: 1.2, gamma: 1.0);
          break;
        case 'Grayscale':
          image = img.grayscale(image);
          image = img.adjustColor(image, contrast: 1.4);
          break;
        case 'Blue Light':
          image = img.colorOffset(image, blue: 30);
          image = img.adjustColor(image, contrast: 1.25);
          break;
        case 'Soft Pastel':
          image = img.adjustColor(image, saturation: 0.5, contrast: 1.1);
          break;
        case 'Original':
        default:
        // Use original image with current rotation
          image = img.adjustColor(image, contrast: 1.1);
          break;
      }

      // Save the filtered image
      final newPath = await _saveTempImage(image);
      File filteredImage = File(newPath);

      // Cache the result
      _filterProvider.addToCache(filterName, filteredImage);

      setState(() {
        _processedImage = filteredImage;
        _hasChanges = true;
      });

      // Add to edit history
      _addToHistory(filteredImage);

      // For Original filter, immediately set applying to false
      if (filterName == 'Original') {
        setState(() {
          _isApplyingFilter = false;
        });
      }
    } catch (e) {
      print('Error applying filter: $e');
      setState(() {
        _isApplyingFilter = false;
      });
    }
  }

  Future<String> _saveTempImage(img.Image image) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newPath = '${directory.path}/filtered_$timestamp.jpg';
    await File(newPath).writeAsBytes(img.encodeJpg(image));
    return newPath;
  }

  void _saveDocument() async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newPath = '${directory.path}/edited_document_$timestamp.jpg';

    // Save the processed image
    await _processedImage!.copy(newPath);

    // Navigate back with the saved document
    if (mounted) {
      Navigator.pop(context, File(newPath));
    }
  }

  void _retakePhoto() {
    Navigator.pop(context, null); // Return null to indicate retake
  }

  void _toggleFilterView() {
    setState(() {
      _isFiltering = !_isFiltering;
    });
  }

  // Update the _handleSave method in DocumentEditScreen
  void _handleSave() async {
    if (_isFiltering) {
      setState(() {
        _isFiltering = false;
      });
    } else {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Get all images to include in the document
        List<File> imagesToSave = [];
        if (widget.isBatchMode && widget.batchImages != null) {
          imagesToSave = widget.batchImages!;
        } else if (_processedImage != null) {
          imagesToSave = [_processedImage!];
        }

        // Create Word document
        final wordFile =
        await WordImagesService.createWordDocument(imagesToSave);

        // Navigate to result screen
        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(wordDocument: wordFile),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading dialog

          AppSnackBar.show(context, message: 'Failed to create document: $e');
        }
      }
    }
  }

  Future<File> _generateFilterPreview(String filterName) async {
    // Load the original image from history (first item)
    final originalImageBytes = await _editHistory.first.readAsBytes();
    var image = img.decodeImage(originalImageBytes)!;

    // Resize for thumbnail
    image = img.copyResize(image, width: 100);

    // Apply selected filter
    switch (filterName) {
      case 'Sepia':
        image = img.sepia(image);
        break;
      case 'Cool Tone':
        image = img.colorOffset(image, blue: 20, green: 10);
        break;
      case 'Warm Tone':
        image = img.colorOffset(image, red: 20, green: 10);
        break;
      case 'Grayscale':
        image = img.grayscale(image);
        break;
      case 'Blue Light':
        image = img.colorOffset(image, blue: 30);
        break;
      case 'Soft Pastel':
        image = img.adjustColor(image, saturation: 0.5, contrast: 0.9);
        break;
      case 'Original':
      default:
      // No filter applied
        break;
    }

    // Save the filtered image
    final directory = await getTemporaryDirectory();
    final newPath =
        '${directory.path}/preview_${filterName}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(newPath).writeAsBytes(img.encodeJpg(image));
    return File(newPath);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _filterProvider,
      child: Scaffold(
        backgroundColor: AppColors.scannerBackground,
        appBar: BatchAppBar(
          onNextPressed: _handleSave,
          onBackPressed: () {
            if (_isFiltering) {
              setState(() {
                _isFiltering = false;
              });
            } else {
              Navigator.pop(context);
            }
          },
          actionText: 'Done',
        ),
        body: Column(
          children: [
            // Document preview area
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Document image with rotation
                  if (_processedImage != null)
                    Center(
                      child: DocumentPreview(
                        image: _processedImage!,
                      ),
                    ),

                  // Undo/Redo buttons under the image
                  Positioned(
                    bottom: 38,
                    child: Container(
                      height: 32,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: _currentHistoryIndex > 0 ? _undo : null,
                            child: SvgPicture.asset(
                              'assets/icons/undo_icon.svg',
                              width: 16,
                              height: 16,
                              color: _currentHistoryIndex > 0
                                  ? AppColors.primary
                                  : Colors.grey.shade400,
                            ),
                          ),
                          GestureDetector(
                            onTap:
                            _currentHistoryIndex < _editHistory.length - 1
                                ? _redo
                                : null,
                            child: SvgPicture.asset(
                              'assets/icons/redo_icon.svg',
                              width: 16,
                              height: 16,
                              color:
                              _currentHistoryIndex < _editHistory.length - 1
                                  ? AppColors.primary
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Filter animation overlay
                  if (_isApplyingFilter)
                    Positioned.fill(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            height: constraints.maxHeight * 0.03,
                            width: constraints.maxWidth,
                            margin: EdgeInsets.only(
                              top: constraints.maxHeight * (_animation.value),
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.primary.withOpacity(0.8),
                                  AppColors.primary.withOpacity(0.0),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // Loading indicator for rotation
                  if (_isRotating)
                    Container(
                      color: Colors.black26,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            ),

            // Edit tools area
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Conditional content - show either filters or edit tools
                  if (_isFiltering)
                    Expanded(
                      child: FilterSelector(
                        filterOptions: _filterOptions,
                        onFilterSelected: _applyFilter,
                        filterPreviews: _filterPreviews,
                        previewsReady: _previewsReady,
                      ),
                    )
                  else
                  // Default edit tool buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildEditToolButton(
                            assetPath: 'assets/icons/retake_icon.svg',
                            label: 'Retake',
                            onTap: _retakePhoto,
                          ),
                          _buildEditToolButton(
                            assetPath: 'assets/icons/filters_icon.svg',
                            label: 'Filters',
                            isActive: _isFiltering,
                            onTap: _toggleFilterView,
                          ),
                          _buildEditToolButton(
                            assetPath: 'assets/icons/crop_icon.svg',
                            label: 'Crop',
                            onTap: _cropImage,
                          ),
                          _buildEditToolButton(
                            assetPath: 'assets/icons/rotate_icon.svg',
                            label: 'Rotate',
                            onTap: _rotateImage,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditToolButton({
    required String assetPath,
    required String label,
    bool isActive = false,
    bool disabled = false,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Opacity(
        opacity: disabled ? 0.5 : 1.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? AppColors.primary : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Center(
                child: SvgPicture.asset(
                  assetPath,
                  width: 22,
                  height: 22,
                  color: disabled ? Colors.grey : null,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: disabled ? Colors.grey : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
