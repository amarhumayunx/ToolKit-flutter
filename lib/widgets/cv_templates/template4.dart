import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;

import '../../models/education_item_model.dart';
import '../../models/language_model.dart';
import '../../models/skills_model.dart';
import '../../models/user_model_1.dart';
import '../../models/website_model.dart';
import '../../provider/certification_provider.dart';
import '../../provider/education_provider.dart';
import '../../provider/language_provider.dart';
import '../../provider/saved_cv_provider.dart';
import '../../provider/skills_provider.dart';
import '../../provider/user_provider.dart';
import '../../provider/work_experience_provider.dart';
import '../../screens/cv_maker_screens/cv_maker_screen.dart';
import '../../utils/app_colors.dart';
import '../buttons/template_action_btn.dart';
import '../custom_appbar.dart';

class Template4 extends StatefulWidget {
  final List<Website> websites;

  const Template4({Key? key, this.websites = const []}) : super(key: key);

  @override
  State<Template4> createState() => _Template4State();
}

class _Template4State extends State<Template4> {
  int _currentPage = 1;
  int _totalPages = 1;
  final List<List<Widget>> _mainColumnContent = [];
  final List<List<Widget>> _sideColumnContent = [];
  final double _pageContentHeight = 482.0;
  List<GlobalKey> _pageKeys = [];
  bool _contentMeasured = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_contentMeasured) {
      setState(() {
        _contentMeasured = false;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _distributeContent();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.websites.isNotEmpty) {
        Provider.of<UserProvider>(context, listen: false).updateWebsites(widget.websites);
      }
    });
  }

  void _distributeContent() {
    final userData = Provider.of<UserProvider>(context, listen: false).userData;
    final workExperienceProvider = Provider.of<WorkExperienceProvider>(context, listen: false);
    final workExperienceItems = workExperienceProvider.workExperienceItems;
    final educationProvider = Provider.of<EducationProvider>(context, listen: false);
    final educationItems = educationProvider.educationItems;
    final certificationProvider = Provider.of<CertificationProvider>(context, listen: false);
    final certificationItems = certificationProvider.certificationItems;
    final skillItems = Provider.of<SkillsProvider>(context, listen: false).skillItems;
    final languageItems = Provider.of<LanguageProvider>(context, listen: false).languages;

    // Clear previous content
    _mainColumnContent.clear();
    _sideColumnContent.clear();

    // Initialize first pages for both columns
    _mainColumnContent.add([]);
    _sideColumnContent.add([]);

    // Current heights for both columns
    double currentMainHeight = 0;
    double currentSideHeight = 0;

    // Max available height after accounting for header
    double maxAvailableHeight = _pageContentHeight - 130;

    // Helper function to add content to main column
    void addMainContent(Widget widget, double estimatedHeight) {
      // Check if we need to add a new page
      if (currentMainHeight + estimatedHeight > maxAvailableHeight) {
        _mainColumnContent.add([]);
        currentMainHeight = 0;
      }

      _mainColumnContent.last.add(widget);
      currentMainHeight += estimatedHeight;
    }

    // Helper function to add content to side column
    void addSideContent(Widget widget, double estimatedHeight) {
      // Check if we need to add a new page
      if (currentSideHeight + estimatedHeight > maxAvailableHeight) {
        _sideColumnContent.add([]);
        currentSideHeight = 0;
      }

      _sideColumnContent.last.add(widget);
      currentSideHeight += estimatedHeight;
    }

    // Add profile section to main column if there's content
    if (userData.careerObjective != null && userData.careerObjective!.isNotEmpty) {
      addMainContent(_buildProfileSection(userData), 80);
      addMainContent(const SizedBox(height: 10), 10);
    }

    // Add work experience section to main column if there are items
    if (workExperienceItems.isNotEmpty) {
      addMainContent(_buildSectionTitle('WORK EXPERIENCE'), 20);
      addMainContent(const SizedBox(height: 8), 8);

      for (var item in workExperienceItems) {
        String dateRange = item.isCurrent
            ? "${item.startDate} - Present"
            : "${item.startDate} - ${item.endDate}";

        // Estimate height based on content
        double itemHeight = 40; // Base height
        if (item.description.isNotEmpty) {
          itemHeight += 20; // Add space for description
        }
        if (item.projects.isNotEmpty) {
          itemHeight += item.projects.length * 10; // Add space for each project
        }

        addMainContent(
          _buildExperienceItem(
            item.position,
            item.company,
            item.description,
            dateRange,
            bulletPoints: item.projects.isNotEmpty ? item.projects : null,
          ),
          itemHeight,
        );

        addMainContent(const SizedBox(height: 15), 10);
      }
    }

    // Add certifications section to main column if there are items
    if (certificationItems.isNotEmpty) {
      addMainContent(_buildSectionTitle('CERTIFICATIONS'), 20);
      addMainContent(const SizedBox(height: 8), 8);

      for (var item in certificationItems) {
        String dateRange = item.isCompleted ? "${item.startDate}" : "${item.startDate}";

        addMainContent(
          _buildCertificationItem(
            item.certificationName,
            item.description,
            dateRange,
          ),
          50,
        );
        addMainContent(const SizedBox(height: 10), 10);
      }
    }

    // Add contact section to side column if there's content
    bool hasContactInfo = userData.phoneNumber != null && userData.phoneNumber!.isNotEmpty ||
        userData.email != null && userData.email!.isNotEmpty ||
        widget.websites.isNotEmpty;

    if (hasContactInfo) {
      addSideContent(_buildContactSection(userData), 60);
      addSideContent(const SizedBox(height: 16), 16);
      addSideContent(_buildSidebarDivider(), 1);
      addSideContent(const SizedBox(height: 16), 16);
    }

    // Add education section to side column if there are items
    if (educationItems.isNotEmpty) {
      addSideContent(_buildEducationSection(educationItems), 120);
      addSideContent(const SizedBox(height: 16), 16);
      addSideContent(_buildSidebarDivider(), 1);
      addSideContent(const SizedBox(height: 16), 16);
    }

    // Add skills section to side column if there are items
    if (skillItems.isNotEmpty) {
      addSideContent(_buildSkillsSection(skillItems), 60);
      addSideContent(const SizedBox(height: 16), 16);
      addSideContent(_buildSidebarDivider(), 1);
      addSideContent(const SizedBox(height: 16), 16);
    }

    // Add languages section to side column if there are items
    if (languageItems.isNotEmpty) {
      addSideContent(_buildLanguagesSection(languageItems), 30);
    }

    // Calculate total pages needed
    _totalPages = math.max(_mainColumnContent.length, _sideColumnContent.length);

    // Ensure both columns have the same number of pages by adding empty pages if needed
    while (_mainColumnContent.length < _totalPages) {
      _mainColumnContent.add([]);
    }
    while (_sideColumnContent.length < _totalPages) {
      _sideColumnContent.add([]);
    }

    _pageKeys = List.generate(_totalPages, (index) => GlobalKey());

    setState(() {
      _contentMeasured = true;
    });
  }

  Widget _buildGreyDivider() {
    return Container(
      height: 1,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(vertical: 8),
    );
  }

  Future<void> _saveCv(BuildContext context) async {
    try {
      final userData = Provider.of<UserProvider>(context, listen: false).userData;
      final fileName = '${userData.fullName?.replaceAll(' ', '_') ?? 'cv'}_resume.pdf';

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

      final pdf = pw.Document();
      List<Uint8List> pageImages = [];

      for (int i = 0; i < _pageKeys.length; i++) {
        final imageBytes = await _capturePageAsImage(_pageKeys[i]);
        if (imageBytes != null) {
          pageImages.add(imageBytes);
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
      }

      Uint8List? thumbnailBytes = pageImages.isNotEmpty ? pageImages[0] : null;
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      final savedCVProvider = Provider.of<SavedCVProvider>(context, listen: false);
      await savedCVProvider.addSavedCV(fileName, filePath, thumbnailBytes);

      Provider.of<UserProvider>(context, listen: false).clearUserData();
      Navigator.of(context).pop();

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
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const CvMakerScreen()),
                  );
                },
                child: Text('OK', style: GoogleFonts.inter()),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
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
                onPressed: () => Navigator.pop(context),
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
      final userData = Provider.of<UserProvider>(context, listen: false).userData;
      final fileName = '${userData.fullName?.replaceAll(' ', '_') ?? 'cv'}_resume.pdf';

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

      final pdf = pw.Document();
      for (int i = 0; i < _pageKeys.length; i++) {
        final imageBytes = await _capturePageAsImage(_pageKeys[i]);
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
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      Provider.of<UserProvider>(context, listen: false).clearUserData();
      Navigator.pop(context);

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
                  Navigator.pop(context);
                },
                child: Text('Close', style: GoogleFonts.inter()),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  OpenFile.open(filePath);
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
      if (Navigator.canPop(context)) Navigator.pop(context);
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
                onPressed: () => Navigator.pop(context),
                child: Text('OK', style: GoogleFonts.inter()),
              ),
            ],
          );
        },
      );
    }
  }

  Future<Uint8List?> _capturePageAsImage(GlobalKey key) async {
    try {
      RenderRepaintBoundary? boundary =
      key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('Error capturing page as image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'CV',
        onBackPressed: () => Navigator.pop(context),
        actions: [
          TextButton(
            onPressed: () => _saveCv(context),
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                color: Colors.red,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    if (!_contentMeasured)
                      const Center(
                        child: CircularProgressIndicator(),
                      )
                    else
                      for (int i = 0; i < _totalPages; i++) ...[
                        RepaintBoundary(
                          key: _pageKeys[i],
                          child: _buildPage(i + 1),
                        ),
                        if (i < _totalPages - 1) const SizedBox(height: 30),
                      ]
                  ],
                ),
              ),
            ),
            _buildTemplateButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int pageIndex) {
    // Get content for this page (0-based index)
    List<Widget> mainContent = pageIndex <= _mainColumnContent.length
        ? _mainColumnContent[pageIndex - 1]
        : [];
    List<Widget> sideContent = pageIndex <= _sideColumnContent.length
        ? _sideColumnContent[pageIndex - 1]
        : [];

    final userData = Provider.of<UserProvider>(context, listen: false).userData;

    return Container(
      constraints: const BoxConstraints(
          maxWidth: 340, minWidth: 340, minHeight: 482, maxHeight: 482),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          // Header section is always on first page
          if (pageIndex == 1) _buildHeader(userData),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Main column (left)
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: mainContent,
                      ),
                    ),
                  ),
                ),

                // Side column (right)
                Container(
                  width: 130,
                  color: Colors.grey.shade100,
                  padding: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: sideContent,
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

  Widget _buildSidebarDivider() {
    return Container(
      height: 1,
      color: const Color(0xFFA81919),
    );
  }

  Widget _buildHeader(UserModel userData) {
    return Stack(
      children: [
        // Make the SVG fill the entire width
        Positioned.fill(
          child: SvgPicture.asset(
            'assets/images/templates/template4_bg.svg',
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              // Profile picture
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
                child: userData.profileImagePath != null
                    ? ClipOval(
                  child: Image.file(
                    File(userData.profileImagePath!),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                )
                    : Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(width: 15),

              // Name and title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (userData.fullName != null && userData.fullName!.isNotEmpty)
                      Text(
                        userData.fullName!.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (userData.designation != null && userData.designation!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        userData.designation!,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(UserModel userData) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final List<Website> websites = userProvider.websites;

    bool hasPhone = userData.phoneNumber != null && userData.phoneNumber!.isNotEmpty;
    bool hasEmail = userData.email != null && userData.email!.isNotEmpty;
    bool hasWebsites = websites.isNotEmpty;

    // Only show section if there's at least one contact info
    if (!hasPhone && !hasEmail && !hasWebsites) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONTACT',
          style: GoogleFonts.poppins(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFA81919),
          ),
        ),
        const SizedBox(height: 6),
        if (hasPhone)
          Row(
            children: [
              Icon(
                Icons.phone,
                size: 6,
                color: const Color(0xFFA81919),
              ),
              const SizedBox(width: 4),
              Text(
                userData.phoneNumber!,
                style: GoogleFonts.poppins(
                  fontSize: 6,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        if (hasEmail) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.email,
                size: 6,
                color: const Color(0xFFA81919),
              ),
              const SizedBox(width: 4),
              Text(
                userData.email!,
                style: GoogleFonts.poppins(
                  fontSize: 6,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
        if (hasWebsites) ...[
          for (Website website in websites) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.link,
                  size: 6,
                  color: const Color(0xFFA81919),
                ),
                const SizedBox(width: 4),
                Text(
                  website.url,
                  style: GoogleFonts.poppins(
                    fontSize: 6,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ]
        ],
      ],
    );
  }

  Widget _buildEducationSection(List<EducationItem> educationItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EDUCATION',
          style: GoogleFonts.poppins(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFA81919),
          ),
        ),
        const SizedBox(height: 6),
        ...educationItems
            .map((item) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.degree ?? '',
              style: GoogleFonts.poppins(
                fontSize: 7,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFA81919),
              ),
            ),
            Text(
              'Major | Grade',
              style: GoogleFonts.poppins(
                fontSize: 6,
                color: Colors.black,
              ),
            ),
            Text(
              item.institute ?? '',
              style: GoogleFonts.poppins(
                fontSize: 6,
                color: Colors.black,
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(
              '${item.startDate} - ${item.isCompleted ? item.endDate : "Present"}',
              style: GoogleFonts.poppins(
                fontSize: 6,
                color: Colors.black,
              ),
            ),
            if (item != educationItems.last) const SizedBox(height: 8),
          ],
        ))
            .toList(),
      ],
    );
  }

  Widget _buildSkillsSection(List<Skill> skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SKILLS & INTERESTS',
          style: GoogleFonts.poppins(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFA81919),
          ),
        ),
        const SizedBox(height: 6),
        ...skills.map((skill) => _buildSkillItem(skill.name)).toList(),
      ],
    );
  }

  Widget _buildSkillItem(String skill) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text(
            '• ',
            style: GoogleFonts.poppins(
              fontSize: 6,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFA81919),
            ),
          ),
          Expanded(
            child: Text(
              skill,
              style: GoogleFonts.poppins(
                fontSize: 6,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagesSection(List<Language> languages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LANGUAGES',
          style: GoogleFonts.poppins(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFA81919),
          ),
        ),
        const SizedBox(height: 6),
        ...languages.map((language) => _buildSkillItem(language.name)).toList(),
      ],
    );
  }

  Widget _buildProfileSection(UserModel userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROFILE',
          style: GoogleFonts.poppins(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFA81919),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          userData.careerObjective ?? '',
          style: GoogleFonts.inter(
            fontSize: 6,
            color: Colors.black,
          ),
        ),
        _buildGreyDivider(), // Add grey divider after profile section
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFA81919),
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceItem(
      String title, String company, String description, String dateRange,
      {List<String>? bulletPoints}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 7,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFA81919),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          company,
          style: GoogleFonts.poppins(
            fontSize: 7,
            color: Colors.black87,
          ),
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 6,
              color: Colors.black,
            ),
          ),
        ],
        if (bulletPoints != null && bulletPoints.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Projects:',
            style: GoogleFonts.poppins(
              fontSize: 6,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          ...bulletPoints
              .map(
                (point) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 6,
                      color: const Color(0xFFA81919),
                    )),
                Expanded(
                  child: Text(
                    point,
                    style: GoogleFonts.inter(
                      fontSize: 6,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          )
              .toList(),
        ]
      ],
    );
  }

  Widget _buildCertificationItem(
      String title, String description, String dateRange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 7,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFA81919),
                ),
              ),
            ),
            Text(
              dateRange,
              style: GoogleFonts.poppins(
                fontSize: 6,
                color: Colors.black,
              ),
            ),
          ],
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 6,
              color: Colors.black,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTemplateButtons() {
    return TemplateActionButtons(
      onChangeTemplate: () {
        // Handle template change
      },
      onExport: _exportToPdf,
    );
  }
}