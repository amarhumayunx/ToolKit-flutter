import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import '../../services/document_scanner_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_snackbar.dart';
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
  final List<File> _recentImages = [];

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

  // Document type crop dimensions - used for frame visualization only
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
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage();

      if (pickedFiles.isNotEmpty) {
        List<File> selectedImages =
            pickedFiles.map((file) => File(file.path)).toList();

        if (_isBatchModeActive) {
          setState(() {
            _batchImages.addAll(selectedImages);
          });

          AppSnackBar.show(context,
              message:
                  'Added ${selectedImages.length} images to batch. Total: ${_batchImages.length}');
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

// In your _ScannerScreenState class, modify the _captureImage method:
  Future<void> _captureImage() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _controller!.takePicture();
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(photo.path);
      final File originalImage = File(photo.path);

      // Get screen dimensions
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight =
          MediaQuery.of(context).size.height - _bottomContainerHeight;

      // Handle different document types
      if (_selectedScanType == 'Business Card' ||
          _selectedScanType == 'Passport' ||
          _selectedScanType == 'Legal' ||
          _selectedScanType == 'Letter' ||
          _selectedScanType == 'Id Card') {
        double frameWidth, frameHeight;

        switch (_selectedScanType) {
          case 'Business Card':
            frameWidth = businessCardCropWidth;
            frameHeight = businessCardCropHeight;
            break;
          case 'Passport':
            frameWidth = passportCropWidth;
            frameHeight = passportCropHeight;
            break;
          case 'Legal':
            frameWidth = legalCropWidth;
            frameHeight = legalCropHeight;
            break;
          case 'Letter':
            frameWidth = letterCropWidth;
            frameHeight = letterCropHeight;
            break;
          case 'Id Card':
            frameWidth = idCardCropWidth;
            frameHeight = idCardCropHeight;
            break;
          default:
            frameWidth = 0;
            frameHeight = 0;
        }

        // Capture within frame
        final File? framedImage = await FrameCaptureService.captureWithinFrame(
          originalImage: originalImage,
          frameWidth: frameWidth,
          frameHeight: frameHeight,
          screenWidth: screenWidth,
          screenHeight: screenHeight,
        );

        if (framedImage == null) {
          throw Exception('Failed to capture within frame');
        }

        // Enhance the document image
        final File? enhancedImage =
            await FrameCaptureService.enhanceDocumentImage(framedImage);
        final File savedImage = enhancedImage ?? framedImage;

        // Save to permanent storage
        final File permanentFile =
            await savedImage.copy('${directory.path}/$fileName');

        setState(() {
          _recentImages.insert(0, permanentFile);
        });

        if (_selectedScanType == 'Id Card') {
          setState(() {
            _idCardImages.add(permanentFile);
          });
          _navigateToIdCardPreviewScreen();
        } else {
          setState(() {
            _imageFile = permanentFile;
          });
          _navigateToPreviewScreen(permanentFile);
        }
      } else if (_selectedScanType == 'Batch') {
        final File savedImage =
            await originalImage.copy('${directory.path}/$fileName');
        setState(() {
          _batchImages.add(savedImage);
          _isBatchModeActive = true;
          _recentImages.insert(0, savedImage);
        });
      } else {
        final File savedImage =
            await originalImage.copy('${directory.path}/$fileName');
        setState(() {
          _imageFile = savedImage;
          _recentImages.insert(0, savedImage);
        });
        _navigateToPreviewScreen(savedImage);
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

      setState(() {
        _idCardImages.add(savedImage);
        _recentImages.insert(0, savedImage);
      });

      _navigateToIdCardPreviewScreen();
    } catch (e) {
      print('Error capturing ID card image: $e');
    }
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
          cropRect: null, // Removed cropRect passing
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
          cropRect: null, // Removed cropRect passing
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
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
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
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text('Initializing camera...'),
        ),
      );
    }

    return Scaffold(
      appBar: CameraAppBar(
        isFlashOn: _isFlashOn,
        isGridVisible: _isGridVisible,
        showGridIcon:
            _selectedScanType == 'Single' || _selectedScanType == 'Batch',
        // Only show for Single and Batch
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
            String documentType = 'single';

            // Set frame dimensions based on document type (for visual guidance only)
            switch (_selectedScanType) {
              case 'Business Card':
                cropWidth = businessCardCropWidth;
                cropHeight = businessCardCropHeight;
                documentType = 'business_card';
                break;
              case 'Passport':
                cropWidth = passportCropWidth;
                cropHeight = passportCropHeight;
                documentType = 'passport';
                break;
              case 'Legal':
                cropWidth = legalCropWidth;
                cropHeight = legalCropHeight;
                documentType = 'legal';
                break;
              case 'Letter':
                cropWidth = letterCropWidth;
                cropHeight = letterCropHeight;
                documentType = 'letter';
                break;
              case 'Id Card':
                cropWidth = idCardCropWidth;
                cropHeight = idCardCropHeight;
                documentType = 'id_card';
                break;
              default:
                cropWidth = 0;
                cropHeight = 0;
            }

            // Calculate the position to center the crop area
            final left = (screenWidth - cropWidth) / 2;
            final top = (screenHeight - cropHeight) / 2;

            return Stack(
              children: [
                // Camera preview - with adjusted height to end at bottom container
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: _bottomContainerHeight - 20,
                  child: CameraPreview(_controller!),
                ),

                // Show the appropriate scan type overlay
                if (_selectedScanType == 'Business Card' ||
                    _selectedScanType == 'Passport' ||
                    _selectedScanType == 'Legal' ||
                    _selectedScanType == 'Letter' ||
                    _selectedScanType == 'Id Card')
                  DocumentCropFrame(
                    width: cropWidth,
                    height: cropHeight,
                    left: left,
                    top: top,
                    documentType: documentType,
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
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: AppColors.primary,
                          width: 1,
                        ),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
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

                              (_isBatchModeActive && _batchImages.isNotEmpty) ||
                                      _recentImages.isNotEmpty
                                  ? GestureDetector(
                                      onTap: _isBatchModeActive
                                          ? _completeBatchCapture
                                          : _viewRecentImage,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: AppColors.primary
                                                .withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: _isBatchModeActive
                                            ? Stack(
                                                fit: StackFit.expand,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            7),
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
                                                          const EdgeInsets.all(
                                                              2),
                                                      decoration:
                                                          const BoxDecoration(
                                                        color:
                                                            AppColors.primary,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Text(
                                                        '${_batchImages.length}',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                                child: Image.file(
                                                  _recentImages[0],
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                      ),
                                    )
                                  : const SizedBox(width: 40, height: 40),
                              // Maintain layout spacing
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
