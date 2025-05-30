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
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>> _collectAllFormData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final workExpProvider = Provider.of<WorkExperienceProvider>(context, listen: false);
    final educationProvider = Provider.of<EducationProvider>(context, listen: false);
    final certificationProvider = Provider.of<CertificationProvider>(context, listen: false);
    final skillsProvider = Provider.of<SkillsProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final templateProvider = Provider.of<TemplateProvider>(context, listen: false);

    final websites = userProvider.websites.map((website) => {
      'name': website.name,
      'url': website.url,
    }).toList();

    return {
      'personalInfo': {
        'fullName': userProvider.userData.fullName,
        'designation': userProvider.userData.designation,
        'email': userProvider.userData.email,
        'phoneNumber': userProvider.userData.phoneNumber,
        'profileImagePath': userProvider.userData.profileImagePath,
      },
      'careerObjective': userProvider.userData.careerObjective,
      'education': educationProvider.educationItems.map((e) => e.toMap()).toList(),
      'workExperience': workExpProvider.workExperienceItems.map((e) => e.toMap()).toList(),
      'certifications': certificationProvider.certificationItems.map((e) => e.toMap()).toList(),
      'skills': skillsProvider.skillItems.map((e) => e.toMap()).toList(),
      'languages': languageProvider.languages.map((e) => e.toMap()).toList(),
      'websites': websites,
      'templateId': templateProvider.selectedTemplateId,
    };
  }

  Future<void> _exportAsPdf({required bool openAfterExport}) async {
    if (_isExporting) return;
    _isExporting = true;

    try {
      _showLoadingDialog();

      bool notificationsEnabled = await NotificationService.areNotificationsEnabled();
      if (notificationsEnabled) {
        await NotificationService.showExportStartNotification();
      }

      final formData = await _collectAllFormData();
      final pdf = pw.Document();
      List<Uint8List> pageImages = [];

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

      final toolkitDir = await _getToolkitDirectory();
      if (toolkitDir == null) throw Exception('Could not access storage');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'CV_$timestamp.pdf';
      final filePath = '${toolkitDir.path}/$fileName';

      await File(filePath).writeAsBytes(await pdf.save());

      Uint8List? thumbnailBytes;
      try {
        thumbnailBytes = await _createThumbnail(pageImages.first);
      } catch (e) {
        debugPrint('Error creating thumbnail: $e');
      }

      final savedCVProvider = Provider.of<SavedCVProvider>(context, listen: false);
      await savedCVProvider.addSavedCV(
        fileName: fileName,
        filePath: filePath,
        thumbnailBytes: thumbnailBytes,
        templateId: formData['templateId'] ?? 1,
        formData: formData,
      );

      if (notificationsEnabled) {
        await NotificationService.cancelExportProgressNotification();
        await NotificationService.showExportNotification();
      }

      if (mounted) {
        Navigator.pop(context);
        AppSnackBar.show(context, message: 'PDF saved successfully');

        if (openAfterExport) {
          await OpenFile.open(filePath);
        }

        _clearAllData();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const CreateCvScreen()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      debugPrint('Export error: $e');

      bool notificationsEnabled = await NotificationService.areNotificationsEnabled();
      if (notificationsEnabled) {
        await NotificationService.cancelExportProgressNotification();
        await NotificationService.showErrorNotification(e.toString());
      }

      if (mounted) {
        Navigator.pop(context);
        AppSnackBar.show(context, message: 'Export failed: ${e.toString()}');
      }
    } finally {
      _isExporting = false;
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

  Future<void> _handleExportAction(bool openAfterExport) async {
    Navigator.pop(context);
    await _exportAsPdf(openAfterExport: openAfterExport);
  }

  Future<Directory?> _getToolkitDirectory() async {
    try {
      Directory? baseDir;

      if (Platform.isAndroid) {
        baseDir = Directory('/storage/emulated/0/Download');
        if (!await baseDir.exists()) {
          baseDir = await getExternalStorageDirectory();
        }
        if (baseDir == null) {
          baseDir = await getApplicationDocumentsDirectory();
        }
      } else if (Platform.isIOS) {
        baseDir = await getApplicationDocumentsDirectory();
      } else {
        return null;
      }

      final toolkitDir = Directory('${baseDir.path}/Toolkit');
      if (!await toolkitDir.exists()) {
        await toolkitDir.create(recursive: true);
      }

      final toolkitResumeDir = Directory('${toolkitDir.path}/Toolkit_Resume');
      if (!await toolkitResumeDir.exists()) {
        await toolkitResumeDir.create(recursive: true);
      }

      return toolkitResumeDir;
    } catch (e) {
      debugPrint('Error getting Toolkit directory: $e');
      return null;
    }
  }

  Future<Uint8List?> _capturePageAsImage(GlobalKey key) async {
    try {
      final RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing page as image: $e');
      return null;
    }
  }

  Future<Uint8List> _createThumbnail(Uint8List imageBytes) async {
    try {
      final codec = await ui.instantiateImageCodec(imageBytes, targetWidth: 200);
      final frame = await codec.getNextFrame();
      final byteData = await frame.image.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error creating thumbnail: $e');
      throw e;
    }
  }

  void _clearAllData() {
    final providers = [
      Provider.of<UserProvider>(context, listen: false),
      Provider.of<WorkExperienceProvider>(context, listen: false),
      Provider.of<EducationProvider>(context, listen: false),
      Provider.of<CertificationProvider>(context, listen: false),
      Provider.of<SkillsProvider>(context, listen: false),
      Provider.of<LanguageProvider>(context, listen: false),
    ];

    for (final provider in providers) {
      if (provider is UserProvider) {
        provider.clearUserData();
      } else if (provider is WorkExperienceProvider) {
        provider.clearWorkExperienceItems();
      } else if (provider is EducationProvider) {
        provider.clearEducationItems();
      } else if (provider is CertificationProvider) {
        provider.clearCertificationItems();
      } else if (provider is SkillsProvider) {
        provider.clearSkillItems();
      } else if (provider is LanguageProvider) {
        provider.clearLanguages();
      }
    }
  }

  void _showExportOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Export CV"),
          content: const Text("What would you like to do with your CV?"),
          actions: [
            TextButton(
              onPressed: () => _handleExportAction(false),
              child: const Text("Export PDF", style: TextStyle(color: AppColors.primary)),
            ),
            TextButton(
              onPressed: () => _handleExportAction(true),
              child: const Text("Open PDF", style: TextStyle(color: AppColors.primary)),
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
    final templateProvider = Provider.of<TemplateProvider>(context, listen: false);
    templateProvider.setTemplate(templateId, 'Template $templateId');

    final websites = Provider.of<UserProvider>(context, listen: false).websites;

    Widget templateScreen = switch (templateId) {
      1 => Template1(websites: websites),
      2 => Template2(websites: websites),
      3 => Template3(websites: websites),
      4 => Template4(websites: websites),
      _ => Template1(websites: websites),
    };

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
          MaterialPageRoute(builder: (context) => const CreateCvScreen()),
        ),
      ),
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