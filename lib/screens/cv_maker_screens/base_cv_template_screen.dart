import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:provider/provider.dart';
import '../../provider/certification_provider.dart';
import '../../provider/education_provider.dart';
import '../../provider/language_provider.dart';
import '../../provider/saved_cv_provider.dart';
import '../../provider/skills_provider.dart';
import '../../provider/template_provider.dart';
import '../../provider/user_provider.dart';
import '../../provider/work_experience_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/buttons/template_action_btn.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/cv_templates/template4.dart';
import '../../widgets/cv_templates/template_1.dart';
import '../../widgets/cv_templates/template_2.dart';
import '../../widgets/cv_templates/template_3.dart';
import '../../widgets/cv_widgets/template_selection_dialog.dart';
import '../../services/notification_service.dart';
import 'create_cv_screen.dart';

class BaseCVTemplateScreen extends StatefulWidget {
  final Widget cvContent;
  final List<GlobalKey> pageKeys;
  final int totalPages;

  const BaseCVTemplateScreen({
    Key? key,
    required this.cvContent,
    required this.pageKeys,
    required this.totalPages,
  }) : super(key: key);

  @override
  State<BaseCVTemplateScreen> createState() => _BaseCVTemplateScreenState();
}

class _BaseCVTemplateScreenState extends State<BaseCVTemplateScreen> {
  @override
  void initState() {
    super.initState();
    // Remove automatic notification initialization
    // Notifications will be initialized only when user enables them in settings
  }

  Future<Map<String, dynamic>> _collectAllFormData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final workExpProvider =
    Provider.of<WorkExperienceProvider>(context, listen: false);
    final educationProvider =
    Provider.of<EducationProvider>(context, listen: false);
    final certificationProvider =
    Provider.of<CertificationProvider>(context, listen: false);
    final skillsProvider = Provider.of<SkillsProvider>(context, listen: false);
    final languageProvider =
    Provider.of<LanguageProvider>(context, listen: false);
    final templateProvider =
    Provider.of<TemplateProvider>(context, listen: false);

    // Convert websites to serializable format
    final websites = userProvider.websites
        .map((website) => {
      'name': website.name,
      'url': website.url,
    })
        .toList();

    return {
      'personalInfo': {
        'fullName': userProvider.userData.fullName,
        'designation': userProvider.userData.designation,
        'email': userProvider.userData.email,
        'phoneNumber': userProvider.userData.phoneNumber,
        'profileImagePath': userProvider.userData.profileImagePath,
      },
      'careerObjective': userProvider.userData.careerObjective,
      'education':
      educationProvider.educationItems.map((e) => e.toMap()).toList(),
      'workExperience':
      workExpProvider.workExperienceItems.map((e) => e.toMap()).toList(),
      'certifications': certificationProvider.certificationItems
          .map((e) => e.toMap())
          .toList(),
      'skills': skillsProvider.skillItems.map((e) => e.toMap()).toList(),
      'languages': languageProvider.languages.map((e) => e.toMap()).toList(),
      'websites': websites,
      'templateId': templateProvider.selectedTemplateId,
    };
  }

  Future<void> _exportAsPdf({required bool openAfterExport}) async {
    try {
      // Show loading dialog
      _showLoadingDialog();

      // Only show notifications if they are enabled in settings
      bool notificationsEnabled = await NotificationService.areNotificationsEnabled();
      if (notificationsEnabled) {
        await NotificationService.showExportStartNotification();
      }

      final formData = await _collectAllFormData();
      final pdf = pw.Document();
      List<Uint8List> pageImages = [];

      // Capture pages as images
      for (final key in widget.pageKeys) {
        final imageBytes = await _capturePageAsImage(key);
        if (imageBytes != null && imageBytes.isNotEmpty) {
          pageImages.add(imageBytes);
          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4,
              build: (pw.Context context) {
                return pw.Center(child: pw.Image(pw.MemoryImage(imageBytes)));
              },
            ),
          );
        }
      }

      if (pageImages.isEmpty) {
        throw Exception('Failed to capture any pages');
      }

      // Save PDF
      final toolkitDir = await _getToolkitDirectory();
      if (toolkitDir == null) throw Exception('Could not access storage');

      await toolkitDir.create(recursive: true);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'CV_$timestamp.pdf';
      final filePath = '${toolkitDir.path}/$fileName';

      await File(filePath).writeAsBytes(await pdf.save());

      // Create thumbnail (handle potential errors)
      Uint8List? thumbnailBytes;
      try {
        thumbnailBytes = await _createThumbnail(pageImages.first);
      } catch (e) {
        debugPrint('Error creating thumbnail: $e');
      }

      // Save to provider and wait for completion
      final savedCVProvider =
      Provider.of<SavedCVProvider>(context, listen: false);
      await savedCVProvider.addSavedCV(
        fileName: fileName,
        filePath: filePath,
        thumbnailBytes: thumbnailBytes,
        templateId: formData['templateId'] ?? 1,
        formData: formData,
      );

      // Wait a moment to ensure the provider has updated
      await Future.delayed(const Duration(milliseconds: 100));

      // Show success notification only if notifications are enabled
      if (notificationsEnabled) {
        await NotificationService.cancelExportProgressNotification();
        await NotificationService.showExportNotification();
      }

      if (mounted) {
        // Close loading dialog
        Navigator.pop(context);

        AppSnackBar.show(context, message: 'PDF saved successfully');
        if (openAfterExport) {
          await OpenFile.open(filePath);
        }

        // Clear data and navigate
        _clearAllData();
      }
    } catch (e) {
      debugPrint('Export error: $e');

      // Show error notification only if notifications are enabled
      bool notificationsEnabled = await NotificationService.areNotificationsEnabled();
      if (notificationsEnabled) {
        await NotificationService.cancelExportProgressNotification();
        await NotificationService.showErrorNotification(e.toString());
      }

      if (mounted) {
        // Close loading dialog if it exists
        Navigator.pop(context);
        AppSnackBar.show(context, message: 'Export failed: ${e.toString()}');
      }
      rethrow;
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Exporting CV..."),
            ],
          ),
        );
      },
    );
  }

  // Updated _handleExportAction method
  Future<void> _handleExportAction(bool openAfterExport) async {
    Navigator.pop(context); // Close the dialog first

    try {
      await _exportAsPdf(openAfterExport: openAfterExport);

      if (mounted) {
        // Clear the entire navigation stack and go to CreateCvScreen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const CreateCvScreen()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Error: ${e.toString()}',
        );
      }
    }
  }

  // Helper method to get toolkit directory
  Future<Directory?> _getToolkitDirectory() async {
    try {
      Directory? baseDir;

      if (Platform.isAndroid) {
        // Try external storage first
        baseDir = Directory('/storage/emulated/0/Download');
        if (!await baseDir.exists()) {
          // Fallback to external storage directory
          baseDir = await getExternalStorageDirectory();
        }
        if (baseDir == null) {
          // Final fallback to application documents directory
          baseDir = await getApplicationDocumentsDirectory();
        }
      } else if (Platform.isIOS) {
        baseDir = await getApplicationDocumentsDirectory();
      } else {
        return null;
      }

      final toolkitDir = Directory('${baseDir.path}/Toolkit');
      return toolkitDir;
    } catch (e) {
      debugPrint('Error getting Toolkit directory: $e');
      return null;
    }
  }

  Future<Uint8List?> _capturePageAsImage(GlobalKey key) async {
    try {
      final RenderRepaintBoundary boundary =
      key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        return byteData.buffer.asUint8List();
      }
      return null;
    } catch (e) {
      print('Error capturing page as image: $e');
      return null;
    }
  }

  Future<Uint8List> _createThumbnail(Uint8List imageBytes) async {
    try {
      final codec = await ui.instantiateImageCodec(
        imageBytes,
        targetWidth: 200,
      );
      final frame = await codec.getNextFrame();
      final byteData =
      await frame.image.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error creating thumbnail: $e');
      throw e;
    }
  }

  void _clearAllData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final workExpProvider =
    Provider.of<WorkExperienceProvider>(context, listen: false);
    final educationProvider =
    Provider.of<EducationProvider>(context, listen: false);
    final certificationProvider =
    Provider.of<CertificationProvider>(context, listen: false);
    final skillsProvider = Provider.of<SkillsProvider>(context, listen: false);
    final languageProvider =
    Provider.of<LanguageProvider>(context, listen: false);

    userProvider.clearUserData();
    workExpProvider.clearWorkExperienceItems();
    educationProvider.clearEducationItems();
    certificationProvider.clearCertificationItems();
    skillsProvider.clearSkillItems();
    languageProvider.clearLanguages();
  }

  void _showExportOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Export CV"),
          content: Text("What would you like to do with your CV?"),
          actions: [
            // Export PDF button
            TextButton(
              onPressed: () => _handleExportAction(false),
              child: Text(
                "Export PDF",
                style: TextStyle(color: AppColors.primary),
              ),
            ),
            // Open PDF button
            TextButton(
              onPressed: () => _handleExportAction(true),
              child: Text(
                "Open PDF",
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showTemplateSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TemplateSelectionDialog(),
    ).then((selectedTemplateId) {
      if (selectedTemplateId != null) {
        _changeTemplate(selectedTemplateId);
      }
    });
  }

  void _changeTemplate(int templateId) {
    final templateProvider =
    Provider.of<TemplateProvider>(context, listen: false);
    templateProvider.setTemplate(templateId, 'Template $templateId');

    final websites = Provider.of<UserProvider>(context, listen: false).websites;

    Widget templateScreen;

    switch (templateId) {
      case 1:
        templateScreen = Template1(websites: websites);
        break;
      case 2:
        templateScreen = Template2(websites: websites);
        break;
      case 3:
        templateScreen = Template3(websites: websites);
        break;
      case 4:
        templateScreen = Template4(websites: websites);
        break;
      default:
        templateScreen = Template1(websites: websites);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => templateScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
          title: 'CV',
          onBackPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateCvScreen()),
          )),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(children: [
                  const SizedBox(height: 80),
                  widget.cvContent,
                ]),
              ),
            ),
            _buildTemplateButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateButtons() {
    return TemplateActionButtons(
      onChangeTemplate: () => _showTemplateSelectionDialog(context),
      onExport: () => _showExportOptions(context),
    );
  }
}