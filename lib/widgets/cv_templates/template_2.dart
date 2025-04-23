import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:provider/provider.dart';

import '../../models/website_model.dart';
import '../../provider/education_provider.dart';
import '../../provider/language_provider.dart';
import '../../provider/skills_provider.dart';
import '../../provider/user_provider.dart';
import '../../provider/work_experience_provider.dart';
import '../../provider/certification_provider.dart';
import '../../utils/app_colors.dart';
import '../buttons/template_action_btn.dart';
import '../custom_appbar.dart';

class Template2 extends StatefulWidget {
  final List<Website> websites;

  const Template2({Key? key, this.websites = const []}) : super(key: key);

  @override
  State<Template2> createState() => _Template2State();
}

class _Template2State extends State<Template2> {
  // Page keys for capturing images
  final GlobalKey _pageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'CV',
        onBackPressed: () {
          Navigator.pop(context);
        },
        actions: [
          TextButton(
            onPressed: () {
              // Save functionality
              _saveCv(context);
            },
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  // CV Page container with the same dimensions as Template1
                  RepaintBoundary(
                    key: _pageKey,
                    child: Container(
                      constraints: const BoxConstraints(
                          maxWidth: 340,
                          minWidth: 340,
                          minHeight: 482,
                          maxHeight: 482),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          final userData = userProvider.userData;
                          return _buildCvContent(userData);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _buildTemplateButtons(),
        ],
      ),
    );
  }

  Widget _buildCvContent(userData) {
    return Stack(
      children: [
        // Background gray design element
        Positioned(
          left: 0,
          top: 0,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(100),
              ),
            ),
          ),
        ),

        // Main content
        Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              // Header with profile image and name side by side
              _buildHeaderRow(userData),


              // Two column layout for the rest of the content
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column (narrower)
                    Expanded(
                      flex: 2,
                      child: _buildLeftColumn(userData),
                    ),

                    // Small space between columns
                    const SizedBox(width: 15),

                    // Right column (wider)
                    Expanded(
                      flex: 3,
                      child: _buildRightColumn(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderRow(userData) {
    return Row(
      children: [
        // Profile image with white outline and purple border
        Stack(
          children: [
            Container(
              width: 100, // Space for positioning
              height: 100,
            ),
            Positioned(
              top: 0, // Adjust to move image
              right: 0,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.Cv2PurpleColor,
                    width: 3,
                  ),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white, // White outline
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2), // Inner space
                    child: ClipOval(
                      child: userData.profileImagePath != null &&
                          userData.profileImagePath.isNotEmpty
                          ? Image.file(
                        File(userData.profileImagePath),
                        fit: BoxFit.cover,
                      )
                          : Container(
                        color: Colors.grey.shade400, // Placeholder
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),

        // Name and designation shifted slightly upward
        Expanded(
          child: Transform.translate(
            offset: const Offset(0, -14), // Move text up slightly
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (userData.fullName != null && userData.fullName.isNotEmpty)
                  Text(
                    userData.fullName.toUpperCase(),
                    style: GoogleFonts.inriaSerif(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.Cv2PurpleColor,
                      letterSpacing: 1.6,
                    ),
                  ),
                if (userData.designation != null &&
                    userData.designation.isNotEmpty)
                  Text(
                    userData.designation,
                    style: GoogleFonts.poly(
                      fontSize: 8,
                      color: const Color(0xFFA3A3A3),
                      letterSpacing: 1,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildLeftColumn(userData) {
    return Consumer3<EducationProvider, SkillsProvider, LanguageProvider>(
      builder: (context, educationProvider, skillsProvider, languageProvider,
          child) {
        final educationItems = educationProvider.educationItems;
        final skillItems = skillsProvider.skillItems;
        final languageItems = languageProvider.languages;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact section - only show if there's contact info
            if (userData.phoneNumber != null &&
                    userData.phoneNumber.isNotEmpty ||
                userData.email != null && userData.email.isNotEmpty ||
                userData.websiteUrl != null &&
                    userData.websiteUrl.isNotEmpty) ...[
              _buildSectionTitle(
                'CONTACT',
                AppColors.Cv2PurpleColor,
              ),
              const SizedBox(height: 6),

              // Show contact items only if they exist
              if (userData.phoneNumber != null &&
                  userData.phoneNumber.isNotEmpty)
                _buildContactItem(Icons.phone, userData.phoneNumber),

              if (userData.email != null && userData.email.isNotEmpty)
                _buildContactItem(Icons.email, userData.email),

              if (userData.websiteUrl != null && userData.websiteUrl.isNotEmpty)
                _buildContactItem(Icons.link, userData.websiteUrl),

              const SizedBox(height: 12),
            ],

            // Education section - only show if there are education items
            if (educationItems.isNotEmpty) ...[
              _buildSectionTitle(
                'EDUCATION',
                AppColors.Cv2PurpleColor,
              ),
              const SizedBox(height: 6),
              ...educationItems.map((item) {
                // Only build education item if data exists
                if (item.degree != null ||
                    item.institute != null ||
                    item.startDate != null ||
                    item.endDate != null) {
                  return Column(
                    children: [
                      _buildEducationItem(
                        item.degree?.toUpperCase() ?? '',
                        item.institute ?? '',
                        '${item.startDate ?? ''} ${item.endDate != null && item.endDate!.isNotEmpty ? '- ${item.endDate}' : ''}',
                        item.description ?? '',
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                } else {
                  return Container(); // Return empty container if no data
                }
              }).toList(),
              const SizedBox(height: 12),
            ],

            // Skills section - only show if there are skill items
            if (skillItems.isNotEmpty) ...[
              _buildSectionTitle(
                'SKILLS',
                AppColors.Cv2PurpleColor,
              ),
              const SizedBox(height: 6),
              ...skillItems
                  .where(
                      (skill) => skill.name != null && skill.name!.isNotEmpty)
                  .map((skill) => _buildBulletItem(skill.name!))
                  .toList(),
              const SizedBox(height: 12),
            ],

            // Languages section - only show if there are language items
            if (languageItems.isNotEmpty) ...[
              _buildSectionTitle(
                'LANGUAGES',
                AppColors.Cv2PurpleColor,
              ),
              const SizedBox(height: 6),
              ...languageItems
                  .where((language) =>
                      language.name != null && language.name!.isNotEmpty)
                  .map((language) => _buildBulletItem(language.name!))
                  .toList(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildRightColumn() {
    return Consumer4<UserProvider, WorkExperienceProvider,
        CertificationProvider, SkillsProvider>(
      builder: (context, userProvider, workExpProvider, certProvider,
          skillsProvider, child) {
        final userData = userProvider.userData;
        final workExperienceItems = workExpProvider.workExperienceItems;
        final certificationItems = certProvider.certificationItems;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Objective section - only show if there's an objective
              if (userData.careerObjective != null &&
                  userData.careerObjective!.isNotEmpty) ...[
                _buildSectionTitle(
                  'Objective',
                  AppColors.Cv2PurpleColor,
                ),
                const SizedBox(height: 6),
                Text(
                  userData.careerObjective!,
                  style: GoogleFonts.inter(
                    fontSize: 7,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Work Experience section - only show if there are work experiences
              if (workExperienceItems.isNotEmpty) ...[
                _buildSectionTitle(
                  'WORK EXPERIENCE',
                  AppColors.Cv2PurpleColor,
                ),
                const SizedBox(height: 6),
                ...workExperienceItems
                    .where((item) =>
                        item.position != null ||
                        item.company != null ||
                        item.description != null)
                    .map((item) {
                  return Column(
                    children: [
                      _buildExperienceItem(
                        item.position ?? '',
                        '${item.company ?? ''} ${item.startDate != null && item.startDate!.isNotEmpty ? '| ${item.startDate}' : ''} ${item.endDate != null && item.endDate!.isNotEmpty ? '- ${item.endDate}' : ''}',
                        item.description ?? '',
                        bulletPoints: item.projects ??
                            ''
                                ?.split('\n')
                                .where((point) => point.trim().isNotEmpty)
                                .toList() ??
                            [],
                      ),
                    ],
                  );
                }).toList(),
                const SizedBox(height: 12),
              ],

              // Certifications section - only show if there are certifications
              if (certificationItems.isNotEmpty) ...[
                _buildSectionTitle(
                  'CERTIFICATIONS',
                  AppColors.Cv2PurpleColor,
                ),
                const SizedBox(height: 6),
                ...certificationItems
                    .where((item) =>
                        item.certificationName != null ||
                        item.organizationName != null ||
                        item.description != null)
                    .map((item) {
                  return Column(
                    children: [
                      _buildCertificationItem(
                        item.certificationName?.toUpperCase() ?? '',
                        '${item.organizationName ?? ''} ${item.startDate != null && item.startDate!.isNotEmpty ? '| ${item.startDate}' : ''}',
                        item.description ?? '',
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                }).toList(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
            letterSpacing: 1,
          ),
        ),
        Container(
          height: 1,
          color:AppColors.dividerColor,
        ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 8, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 6,
                color: Colors.grey.shade700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationItem(
      String degree, String major, String institution, String years) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (degree.isNotEmpty)
          Text(
            degree,
            style: GoogleFonts.poppins(
              fontSize: 7,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        if (major.isNotEmpty)
          Text(
            major,
            style: GoogleFonts.poppins(
              fontSize: 6,
              color: Colors.grey.shade700,
            ),
          ),
        if (institution.isNotEmpty)
          Text(
            institution,
            style: GoogleFonts.poppins(
              fontSize: 6,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade700,
            ),
          ),
        if (years.trim().isNotEmpty)
          Text(
            years,
            style: GoogleFonts.poppins(
              fontSize: 6,
              color: Colors.grey.shade600,
            ),
          ),
      ],
    );
  }

  Widget _buildBulletItem(String text) {
    if (text.isEmpty) return Container();

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: GoogleFonts.poppins(
              fontSize: 6,
              color: Colors.grey.shade800,
            ),
          ),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 6,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceItem(String title, String company, String description,
      {List<String>? bulletPoints}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        if (company.trim().isNotEmpty)
          Text(
            company,
            style: GoogleFonts.poppins(
              fontSize: 7,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        if (title.isNotEmpty || company.trim().isNotEmpty)
          const SizedBox(height: 3),
        if (description.isNotEmpty)
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 6,
              color: Colors.grey.shade800,
              height: 1.4,
            ),
          ),
        if (bulletPoints != null && bulletPoints.isNotEmpty) ...[
          const SizedBox(height: 4),
          ...bulletPoints
              .map((point) {
                if (point.trim().isEmpty) return Container();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: GoogleFonts.poppins(
                          fontSize: 6,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          point,
                          style: GoogleFonts.poppins(
                            fontSize: 6,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              })
              .where((widget) => widget != Container())
              .toList(),
        ],
      ],
    );
  }

  Widget _buildCertificationItem(
      String title, String institution, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        if (institution.trim().isNotEmpty)
          Text(
            institution,
            style: GoogleFonts.poppins(
              fontSize: 7,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        if (title.isNotEmpty || institution.trim().isNotEmpty)
          const SizedBox(height: 3),
        if (description.isNotEmpty)
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 6,
              color: Colors.grey.shade800,
              height: 1.4,
            ),
          ),
      ],
    );
  }

  Widget _buildTemplateButtons() {
    return TemplateActionButtons(
      onChangeTemplate: () {
        // Handle template change
      },
      onExport: () {
        _exportToPdf();
      },
    );
  }

  Future<void> _saveCv(BuildContext context) async {
    try {
      final userData =
          Provider.of<UserProvider>(context, listen: false).userData;
      final fileName = userData.fullName != null &&
              userData.fullName!.isNotEmpty
          ? '${userData.fullName!.toLowerCase().replaceAll(' ', '_')}_resume.pdf'
          : 'resume.pdf';

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text('Saving CV...', style: GoogleFonts.inter()),
                ],
              ),
            ),
          );
        },
      );

      // Create a PDF document
      final pdf = pw.Document();

      // Convert page to an image and add to PDF
      final imageBytes = await _capturePageAsImage();
      if (imageBytes != null) {
        final image = pw.MemoryImage(imageBytes);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(image),
              );
            },
          ),
        );
      }

      // Save the PDF
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // Close the loading dialog
      Navigator.of(context).pop();

      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('CV Saved',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            content: Text('Your CV has been saved successfully.',
                style: GoogleFonts.inter()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Dismiss the alert dialog
                  Navigator.pop(context); // Go back to previous screen
                },
                child: Text('OK', style: GoogleFonts.inter()),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Close the loading dialog if it's open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            content: Text('Failed to save CV: ${e.toString()}',
                style: GoogleFonts.inter()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK', style: GoogleFonts.inter()),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _exportToPdf() async {
    try {
      final userData =
          Provider.of<UserProvider>(context, listen: false).userData;
      final fileName = userData.fullName != null &&
              userData.fullName!.isNotEmpty
          ? '${userData.fullName!.toLowerCase().replaceAll(' ', '_')}_resume.pdf'
          : 'resume.pdf';
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text('Generating PDF...', style: GoogleFonts.inter()),
                ],
              ),
            ),
          );
        },
      );

      // Create a PDF document
      final pdf = pw.Document();
      // Convert page to an image and add to PDF
      final imageBytes = await _capturePageAsImage();
      if (imageBytes != null) {
        final image = pw.MemoryImage(imageBytes);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(image),
              );
            },
          ),
        );
      }

      // Save the PDF
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      // Close the loading dialog
      Navigator.pop(context);

      // Show success dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('PDF Created',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            content: Text('Your CV has been exported as a PDF.',
                style: GoogleFonts.inter()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate back to form screen after exporting
                  Navigator.pop(context);
                },
                child: Text('Close', style: GoogleFonts.inter()),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  OpenFile.open(filePath);
                  // After opening the file, navigate back to form
                  Navigator.pop(context);
                },
                child: Text('Open PDF',
                    style: GoogleFonts.inter(color: AppColors.primary)),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Close the loading dialog if it's open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            content: Text('Failed to export PDF: ${e.toString()}',
                style: GoogleFonts.inter()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK', style: GoogleFonts.inter()),
              ),
            ],
          );
        },
      );
    }
  }

  Future<Uint8List?> _capturePageAsImage() async {
    try {
      final RenderRepaintBoundary boundary =
          _pageKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
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
}
