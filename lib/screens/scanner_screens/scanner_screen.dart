import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image/image.dart' as image;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_colors.dart';
import '../../widgets/scanner_widgets/batch_scan.dart';
import '../../widgets/scanner_widgets/camera_appbar.dart';
import '../../widgets/scanner_widgets/document_crop_frame.dart';
import '../../widgets/scanner_widgets/single_scan.dart';
import 'batch_result_screen.dart';
import 'document_edit_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> cameras = [];
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  File? _imageFile;
  String _errorMessage = '';
  bool _isLoading = true;
  String? _selectedScanType = 'Batch'; // default selected

  // Recent images list - to show in place of image icon
  List<File> _recentImages = [];

  // List to store batch mode images
  List<File> _batchImages = [];

  // Batch mode status
  bool _isBatchModeActive = false;

  // For bottom container height tracking
  final GlobalKey _bottomContainerKey = GlobalKey();
  double _bottomContainerHeight = 150;

  // Added for new features
  bool _isFlashOn = false;
  bool _isGridVisible = true;
  final ImagePicker _imagePicker = ImagePicker();

  // Document type crop dimensions
  static const double businessCardCropWidth = 324;
  static const double businessCardCropHeight = 194;

  static const double passportCropWidth = 304;
  static const double passportCropHeight = 304;

  static const double legalCropWidth = 350;
  static const double legalCropHeight = 572;

  static const double letterCropWidth = 324;
  static const double letterCropHeight = 421;

  static const double idCardCropWidth = 304;
  static const double idCardCropHeight = 194;

  // ID Card scanning state
  List<File> _idCardImages = [];

  Rect? _currentCropRect;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestCameraPermission();

    // Add post-frame callback to measure container height
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureBottomContainerHeight();
    });
  }

  void _measureBottomContainerHeight() {
    if (_bottomContainerKey.currentContext != null) {
      final RenderBox box =
          _bottomContainerKey.currentContext!.findRenderObject() as RenderBox;
      setState(() {
        _bottomContainerHeight = box.size.height;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeControllerAfterPermission();
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _isCameraPermissionGranted = status.isGranted;
      _isLoading = false;
    });

    if (status.isGranted) {
      _initializeControllerAfterPermission();
    } else {
      setState(() {
        _errorMessage = 'Camera permission is required to use the scanner';
      });
    }
  }

  Future<void> _initializeControllerAfterPermission() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      cameras = await availableCameras();

      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras found on device';
          _isLoading = false;
        });
        return;
      }

      _controller = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();

      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Camera initialization failed: ${e.toString()}';
        _isLoading = false;
      });
      print('Error initializing camera: $e');
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      setState(() {
        _isFlashOn = !_isFlashOn;
      });

      await _controller!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to toggle flash: ${e.toString()}';
      });
      print('Error toggling flash: $e');
    }
  }

  void _toggleGrid() {
    setState(() {
      _isGridVisible = !_isGridVisible;
    });
  }

  Future<void> _pickImageFromGallery() async {
    if (_selectedScanType == 'Batch') {
      final List<XFile>? pickedFiles = await _imagePicker.pickMultiImage();

      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        List<File> selectedImages =
            pickedFiles.map((file) => File(file.path)).toList();

        if (_isBatchModeActive) {
          setState(() {
            _batchImages.addAll(selectedImages);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Added ${selectedImages.length} images to batch. Total: ${_batchImages.length}'),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          setState(() {
            _batchImages = selectedImages;
            _isBatchModeActive = true;
          });

          _navigateToBatchPreviewScreen();
        }
      }
    } else if (_selectedScanType == 'Id Card') {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        setState(() {
          _idCardImages.add(imageFile);
          _recentImages.insert(0, imageFile);
        });
        _navigateToIdCardPreviewScreen();
      }
    } else {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        setState(() {
          _imageFile = imageFile;
          _recentImages.insert(0, imageFile);
        });

        _navigateToPreviewScreen(imageFile);
      }
    }
  }

  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      if (_selectedScanType == 'Id Card') {
        await _captureIdCardImage();
        return;
      }

      final XFile photo = await _controller!.takePicture();
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(photo.path);
      final File savedImage =
          await File(photo.path).copy('${directory.path}/$fileName');

      File finalImage = savedImage;

      // If in document mode with crop rect, crop the image
      if (_currentCropRect != null &&
          (_selectedScanType == 'Business Card' ||
              _selectedScanType == 'Passport' ||
              _selectedScanType == 'Legal' ||
              _selectedScanType == 'Letter' ||
              _selectedScanType == 'Id Card')) {
        finalImage = await _cropImageToRect(savedImage, _currentCropRect!);
      }

      setState(() {
        _recentImages.insert(0, finalImage);
      });

      if (_selectedScanType == 'Batch') {
        setState(() {
          _batchImages.add(finalImage);
          _isBatchModeActive = true;
        });
      } else {
        setState(() {
          _imageFile = finalImage;
        });
        _navigateToPreviewScreen(finalImage);
      }
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  Future<void> _captureIdCardImage() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _controller!.takePicture();
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(photo.path);
      final File savedImage =
          await File(photo.path).copy('${directory.path}/$fileName');

      File finalImage = savedImage;

      if (_currentCropRect != null) {
        finalImage = await _cropImageToRect(savedImage, _currentCropRect!);
      }

      setState(() {
        _idCardImages.add(finalImage);
        _recentImages.insert(0, finalImage);
      });

      _navigateToIdCardPreviewScreen();
    } catch (e) {
      print('Error capturing ID card image: $e');
    }
  }

  Future<File> _cropImageToRect(File originalImage, Rect cropRect) async {
    final bytes = await originalImage.readAsBytes();
    final decodedImage = await decodeImageFromList(bytes);

    // Get the correct preview dimensions
    final previewWidth = MediaQuery.of(context).size.width;
    final previewHeight = _getPreviewHeight();
    final previewTopOffset = _getPreviewTopOffset();

    // Calculate aspect ratios
    final previewAspect = previewWidth / previewHeight;
    final imageAspect = decodedImage.width / decodedImage.height;

    // Calculate effective preview size (accounting for letterboxing)
    double effectivePreviewWidth, effectivePreviewHeight;
    double offsetX = 0, offsetY = 0;

    if (previewAspect > imageAspect) {
      // Letterbox on sides
      effectivePreviewHeight = previewHeight;
      effectivePreviewWidth = previewHeight * imageAspect;
      offsetX = (previewWidth - effectivePreviewWidth) / 2;
    } else {
      // Letterbox on top/bottom
      effectivePreviewWidth = previewWidth;
      effectivePreviewHeight = previewWidth / imageAspect;
      offsetY = (previewHeight - effectivePreviewHeight) / 2;
    }

    // Adjust crop rect coordinates to account for:
    // 1. Letterboxing (offsetX/Y)
    // 2. App bar (previewTopOffset)
    final adjustedCropRect = Rect.fromLTWH(
      cropRect.left - offsetX,
      cropRect.top - offsetY - previewTopOffset,
      cropRect.width,
      cropRect.height,
    );

    // Calculate scale factors
    final scaleX = decodedImage.width / effectivePreviewWidth;
    final scaleY = decodedImage.height / effectivePreviewHeight;

    // Calculate final crop coordinates
    final actualLeft = (adjustedCropRect.left * scaleX).round();
    final actualTop = (adjustedCropRect.top * scaleY).round();
    final actualWidth = (adjustedCropRect.width * scaleX).round();
    final actualHeight = (adjustedCropRect.height * scaleY).round();

    // Clamp values to image bounds
    final adjustedLeft = actualLeft.clamp(0, decodedImage.width);
    final adjustedTop = actualTop.clamp(0, decodedImage.height);
    final adjustedWidth =
        actualWidth.clamp(1, decodedImage.width - adjustedLeft);
    final adjustedHeight =
        actualHeight.clamp(1, decodedImage.height - adjustedTop);

    debugPrint(
        'Adjusted crop rect: $adjustedLeft,$adjustedTop $adjustedWidth×$adjustedHeight');

    return await _cropImage(
      originalImage,
      adjustedLeft,
      adjustedTop,
      adjustedWidth,
      adjustedHeight,
    );
  }

  Future<File> _cropImage(
    File imageFile,
    int x,
    int y,
    int width,
    int height,
  ) async {
    final image.Image? originalImage =
        image.decodeImage(await imageFile.readAsBytes());

    if (originalImage == null) {
      throw Exception('Failed to decode image');
    }

    final image.Image croppedImage = image.copyCrop(
      originalImage,
      x: x,
      y: y,
      width: width,
      height: height,
    );

    final directory = await getApplicationDocumentsDirectory();
    final String croppedFileName = 'cropped_${path.basename(imageFile.path)}';
    final File croppedFile = File('${directory.path}/$croppedFileName');

    await croppedFile.writeAsBytes(image.encodeJpg(croppedImage));

    return croppedFile;
  }

  double _getPreviewTopOffset() {
    return MediaQuery.of(context).padding.top + kToolbarHeight;
  }

  double _getPreviewHeight() {
    return MediaQuery.of(context).size.height -
        _bottomContainerHeight -
        _getPreviewTopOffset();
  }

  void _navigateToPreviewScreen(File imageFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentEditScreen(
          imageFile: imageFile,
          isBatchMode: false,
          isBusinessCard: _selectedScanType == 'Business Card',
          isPassport: _selectedScanType == 'Passport',
          isLegal: _selectedScanType == 'Legal',
          isLetter: _selectedScanType == 'Letter',
          isIdCard: _selectedScanType == 'Id Card',
          cropRect: _currentCropRect,
        ),
      ),
    );
  }

  void _navigateToIdCardPreviewScreen() {
    if (_idCardImages.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentEditScreen(
          imageFile: _idCardImages[0],
          isBatchMode: false,
          isIdCard: true,
          cropRect: _currentCropRect,
        ),
      ),
    );
  }

  void _navigateToBatchPreviewScreen() {
    if (_batchImages.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentEditScreen(
          imageFile: _batchImages[0],
          isBatchMode: true,
          batchImages: _batchImages,
          currentIndex: 0,
        ),
      ),
    );
  }

  void _viewRecentImage() {
    if (_recentImages.isNotEmpty) {
      if (_selectedScanType == 'Id Card' && _idCardImages.isNotEmpty) {
        _navigateToIdCardPreviewScreen();
      } else {
        _navigateToPreviewScreen(_recentImages[0]);
      }
    }
  }

  void _completeBatchCapture() {
    if (_batchImages.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BatchResultScreen(
            batchImages: _batchImages,
          ),
        ),
      );
    }
  }

  void _selectScanType(String scanType) {
    if (_selectedScanType == 'Batch' &&
        scanType != 'Batch' &&
        _batchImages.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Batch?'),
          content: const Text(
              'Changing scan type will discard your current batch of images. '
              'Do you want to continue?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel',
                  style: GoogleFonts.inter(color: AppColors.primary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _selectedScanType = scanType;
                  _batchImages = [];
                  _isBatchModeActive = false;
                  _idCardImages = [];
                });
              },
              child: Text('Discard',
                  style: GoogleFonts.inter(color: AppColors.primary)),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        _selectedScanType = scanType;
        if (scanType == 'Batch') {
          _isBatchModeActive = false;
          _batchImages = [];
        } else if (scanType == 'Id Card') {
          _idCardImages = [];
        }
      });
    }
  }

  Widget _buildScanTypeButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectScanType(label),
      child: Text(
        label,
        style: GoogleFonts.inter(
            color: isSelected ? AppColors.primary : AppColors.saveDateColor,
            fontWeight: FontWeight.w500,
            fontSize: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isCameraPermissionGranted) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.camera_alt, size: 100, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                _errorMessage.isEmpty
                    ? 'Camera permission not granted'
                    : _errorMessage,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _requestCameraPermission,
                child: const Text('Grant Camera Permission'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isCameraInitialized) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: Text('Initializing camera...'),
        ),
      );
    }

    return Scaffold(
      appBar: CameraAppBar(
        isFlashOn: _isFlashOn,
        isGridVisible: _isGridVisible,
        onClosePressed: () => Navigator.pop(context),
        onFlashPressed: _toggleFlash,
        onGridPressed: _toggleGrid,
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate the document crop rectangle based on selected type
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight - _bottomContainerHeight;

            double cropWidth;
            double cropHeight;

            switch (_selectedScanType) {
              case 'Business Card':
                cropWidth = businessCardCropWidth;
                cropHeight = businessCardCropHeight;
                break;
              case 'Passport':
                cropWidth = passportCropWidth;
                cropHeight = passportCropHeight;
                break;
              case 'Legal':
                cropWidth = legalCropWidth;
                cropHeight = legalCropHeight;
                break;
              case 'Letter':
                cropWidth = letterCropWidth;
                cropHeight = letterCropHeight;
                break;
              case 'Id Card':
                cropWidth = idCardCropWidth;
                cropHeight = idCardCropHeight;
                break;
              default:
                cropWidth = 0;
                cropHeight = 0;
            }

            // Calculate the position to center the crop area
            final left = (screenWidth - cropWidth) / 2;
            final top = (screenHeight - cropHeight) / 2;

            _currentCropRect = Rect.fromLTWH(
              left,
              top,
              cropWidth,
              cropHeight,
            );

            return Stack(
              children: [
                // Camera preview
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: CameraPreview(_controller!),
                ),

                // Show the appropriate scan type overlay
                if (_selectedScanType == 'Business Card')
                  DocumentCropFrame(
                    width: businessCardCropWidth,
                    height: businessCardCropHeight,
                    left: left,
                    top: top,
                    documentType: 'business_card',
                  )
                else if (_selectedScanType == 'Passport')
                  DocumentCropFrame(
                    width: passportCropWidth,
                    height: passportCropHeight,
                    left: left,
                    top: top,
                    documentType: 'passport',
                  )
                else if (_selectedScanType == 'Legal')
                  DocumentCropFrame(
                    width: legalCropWidth,
                    height: legalCropHeight,
                    left: left,
                    top: top,
                    documentType: 'legal',
                  )
                else if (_selectedScanType == 'Letter')
                  DocumentCropFrame(
                    width: letterCropWidth,
                    height: letterCropHeight,
                    left: left,
                    top: top,
                    documentType: 'letter',
                  )
                else if (_selectedScanType == 'Id Card')
                  DocumentCropFrame(
                    width: idCardCropWidth,
                    height: idCardCropHeight,
                    left: left,
                    top: top,
                    documentType: 'id_card',
                  )
                else if (_selectedScanType == 'Batch')
                  BatchScan(
                    isGridVisible: _isGridVisible,
                    bottomPadding: _bottomContainerHeight,
                  )
                else if (_selectedScanType == 'Single')
                  SingleScan(
                    isGridVisible: _isGridVisible,
                    bottomPadding: _bottomContainerHeight,
                  ),

                // Bottom controls container
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    key: _bottomContainerKey,
                    height: 150,
                    padding:
                        const EdgeInsets.only(top: 16, left: 16, right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: AppColors.primary,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Scan types
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _buildScanTypeButton('Business Card',
                                  _selectedScanType == 'Business Card'),
                              const SizedBox(width: 18),
                              _buildScanTypeButton(
                                  'Single', _selectedScanType == 'Single'),
                              const SizedBox(width: 18),
                              _buildScanTypeButton(
                                  'Batch', _selectedScanType == 'Batch'),
                              const SizedBox(width: 18),
                              _buildScanTypeButton(
                                  'Id Card', _selectedScanType == 'Id Card'),
                              const SizedBox(width: 18),
                              _buildScanTypeButton(
                                  'Passport', _selectedScanType == 'Passport'),
                              const SizedBox(width: 18),
                              _buildScanTypeButton(
                                  'Legal', _selectedScanType == 'Legal'),
                              const SizedBox(width: 18),
                              _buildScanTypeButton(
                                  'Letter', _selectedScanType == 'Letter'),
                            ],
                          ),
                        ),
                        // Camera controls
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 4, left: 22, right: 22),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Gallery option
                              IconButton(
                                icon: SvgPicture.asset(
                                  'assets/icons/gallery_option_icon.svg',
                                  height: 26,
                                  width: 26,
                                ),
                                onPressed: _pickImageFromGallery,
                              ),
                              // Capture button
                              GestureDetector(
                                onTap: _captureImage,
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.primary, width: 3),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(3.0),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Show recent image thumbnail or placeholder if none available
                              GestureDetector(
                                onTap: _isBatchModeActive
                                    ? _completeBatchCapture
                                    : _viewRecentImage,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: _isBatchModeActive
                                      ? Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              child: Image.file(
                                                _batchImages.last,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              top: 0,
                                              right: 0,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(2),
                                                decoration: const BoxDecoration(
                                                  color: AppColors.primary,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Text(
                                                  '${_batchImages.length}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : (_recentImages.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(7),
                                              child: Image.file(
                                                _recentImages[0],
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.image,
                                              color: AppColors.primary,
                                              size: 24,
                                            )),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
