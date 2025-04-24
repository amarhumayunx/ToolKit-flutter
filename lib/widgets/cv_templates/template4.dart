import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

import '../../models/website_model.dart';
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
  final List<List<Widget>> _pageContent = [];
  final double _pageContentHeight = 482.0;
  List<GlobalKey> _pageKeys = [];
  bool _contentMeasured = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _distributeContent();
    });
  }

  void _distributeContent() {
    // Hardcoded dummy data
    final userData = {
      'fullName': 'SOPHIA WILLIAMS',
      'designation': 'Product Designer',
      'careerObjective':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam pharetra in ipsum quis lacus. Donec hendrerit ipsum eget est tempor, quis tempus duis elementum. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam pharetra in ipsum quis lacus. Donec hendrerit ipsum eget est tempor, quis tempus.',
      'phoneNumber': '+1 123 4567890',
      'email': 'sophia@example.com',
      'profileImagePath': null, // We'll use a placeholder
    };

    final workExperienceItems = [
      {
        'position': 'JOB TITLE / POSITION',
        'company': 'Company / MM / YY - MM / YY',
        'description':
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc ut diam sem nec risus egestas accumsan, in arcu nunc.',
        'projects': ['React.js', 'Vue.js', 'Angular'],
        'startDate': 'Jan 2022',
        'endDate': 'Present',
        'isCurrent': true,
      },
      {
        'position': 'JOB TITLE / POSITION',
        'company': 'Company / MM / YY - MM / YY',
        'description':
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc ut diam sem nec risus egestas accumsan, in arcu nunc.',
        'projects': ['React.js', 'Vue.js', 'Angular'],
        'startDate': 'Jan 2020',
        'endDate': 'Dec 2021',
        'isCurrent': false,
      },
    ];

    final educationItems = [
      {
        'degree': 'DEGREE / DIPLOMA NAME',
        'institute': 'Institution Name',
        'description': '',
        'startDate': '2017',
        'endDate': '2021',
        'isCompleted': true,
      },
      {
        'degree': 'DEGREE / DIPLOMA NAME',
        'institute': 'Institution Name',
        'description': '',
        'startDate': '2013',
        'endDate': '2017',
        'isCompleted': true,
      },
    ];

    final certificationItems = [
      {
        'certificationName': 'CERTIFICATION NAME',
        'description':
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc ut diam sem nec risus egestas accumsan, in arcu nunc.',
        'startDate': 'MM / YY - MM / YY',
        'isCompleted': true,
      },
    ];

    final skillItems = [
      'HTML5',
      'CSS3',
      'JavaScript (ES6+)',
      'React.js',
      'Vue.js',
      'Angular',
      'Tailwind CSS',
      'Node.js',
      'Material UI',
    ];

    final languageItems = [
      'Urdu',
      'English',
    ];

    _pageContent.clear();
    List<Widget> currentPageWidgets = [];
    double currentPageHeight = 0;
    double maxPageHeight = _pageContentHeight - 40;

    void addWidgetToPage(Widget widget, double estimatedHeight) {
      if (currentPageHeight + estimatedHeight > maxPageHeight &&
          currentPageWidgets.isNotEmpty) {
        _pageContent.add([...currentPageWidgets]);
        currentPageWidgets = [];
        currentPageHeight = 0;
      }

      currentPageWidgets.add(widget);
      currentPageHeight += estimatedHeight;
    }

    // Profile section
    final profileSection = _buildProfileSection(userData);
    addWidgetToPage(profileSection, 80);

    addWidgetToPage(const SizedBox(height: 10), 10);

    // Work Experience section
    final workSectionTitle = Column(
      children: [
        _buildSectionTitle('WORK EXPERIENCE'),
      ],
    );
    addWidgetToPage(workSectionTitle, 28);
    addWidgetToPage(const SizedBox(height: 8), 8);

    for (int i = 0; i < workExperienceItems.length; i++) {
      final item = workExperienceItems[i];
      String dateRange = item['isCurrent'] == true
          ? "${item['startDate']} - Present"
          : "${item['startDate']} - ${item['endDate']}";

      double itemHeight = 60;
      if (item['description'].toString().isNotEmpty) {
        itemHeight += (item['description'].toString().length / 50) * 10;
      }
      if ((item['projects'] as List).isNotEmpty) {
        itemHeight += (item['projects'] as List).length * 10;
      }

      final experienceItem = _buildExperienceItem(
        item['position'].toString(),
        item['company'].toString(),
        item['description'].toString(),
        dateRange,
        bulletPoints: (item['projects'] as List).cast<String>(),
      );

      addWidgetToPage(experienceItem, itemHeight);

      if (i < workExperienceItems.length - 1) {
        addWidgetToPage(const SizedBox(height: 15), 15);
      }
    }
    addWidgetToPage(_buildGreyDivider(), 8);

    // Certifications section
    final certSectionTitle = _buildSectionTitle('CERTIFICATIONS');
    addWidgetToPage(certSectionTitle, 20);
    addWidgetToPage(const SizedBox(height: 8), 8);

    for (int i = 0; i < certificationItems.length; i++) {
      final item = certificationItems[i];
      final certItem = _buildCertificationItem(
        item['certificationName'].toString(),
        item['description'].toString(),
        item['startDate'].toString(),
      );

      addWidgetToPage(certItem, 50);

      if (i < certificationItems.length - 1) {
        addWidgetToPage(const SizedBox(height: 10), 10);
      }
    }

    // Add remaining widgets to last page
    if (currentPageWidgets.isNotEmpty) {
      _pageContent.add([...currentPageWidgets]);
    }

    // If no content was added (empty CV), add an empty page
    if (_pageContent.isEmpty) {
      _pageContent.add([Container()]);
    }

    _totalPages = _pageContent.length;
    _pageKeys = List.generate(_totalPages, (index) => GlobalKey());

    setState(() {
      _contentMeasured = true;
    });
  }

  Widget _buildLeftDivider() {
    return Expanded(
      flex: 3,
      child: Container(
        height: 1,
        color: const Color(0xFFA81919),
      ),
    );
  }

  Widget _buildGreyDivider() {
    return Container(
      height: 1,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(vertical: 8),
    );
  }

  Future<void> _exportToPdf() async {
    try {
      final fileName = 'sophia_williams_resume.pdf';

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
                    style: GoogleFonts.inter(color: Colors.red)),
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
            onPressed: () {
              // Implementation for save function would go here
            },
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
    // Get content for this page
    List<Widget> pageContent =
        pageIndex <= _pageContent.length ? _pageContent[pageIndex - 1] : [];

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
          ),
        ],
      ),
      child: Column(
        children: [
          // Header section is always on first page
          if (pageIndex == 1) _buildHeader(),

          // Main content with left and right columns
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Right column (now on left) - Profile, Experience, Certifications
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: pageContent,
                      ),
                    ),
                  ),
                ),

                // Left column (now on right) - Contact, Education, Skills, Languages
                Container(
                  width: 130,
                  color: Colors.grey.shade100,
                  padding: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left sidebar content is only shown on first page
                        if (pageIndex == 1) ...[
                          _buildContactSection(),
                          const SizedBox(height: 16),
                          _buildSidebarDivider(), // Added sidebar divider
                          const SizedBox(height: 16),
                          _buildEducationSection(),
                          const SizedBox(height: 16),
                          _buildSidebarDivider(), // Added sidebar divider
                          const SizedBox(height: 16),
                          _buildSkillsSection(),
                          const SizedBox(height: 16),
                          _buildSidebarDivider(), // Added sidebar divider
                          const SizedBox(height: 16),
                          _buildLanguagesSection(),
                        ],
                      ],
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

  // Updated sidebar divider with red color
  Widget _buildSidebarDivider() {
    return Container(
      height: 1,
      color: const Color(0xFFA81919),
    );
  }

  Widget _buildHeader() {
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
                child: Icon(
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
                    Text(
                      'SOPHIA WILLIAMS',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Product Designer',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.white,
                      ),
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

  Widget _buildContactSection() {
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
        Row(
          children: [
            Icon(
              Icons.phone,
              size: 6,
              color: const Color(0xFFA81919),
            ),
            const SizedBox(width: 4),
            Text(
              '+1 123 4567890',
              style: GoogleFonts.poppins(
                fontSize: 6,
                color: Colors.black,
              ),
            ),
          ],
        ),
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
              'sophia@example.com',
              style: GoogleFonts.poppins(
                fontSize: 6,
                color: Colors.black,
              ),
            ),
          ],
        ),
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
              'LinkedIn Address',
              style: GoogleFonts.poppins(
                fontSize: 6,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEducationSection() {
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DEGREE / DIPLOMA NAME',
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
              'Institution Name',
              style: GoogleFonts.poppins(
                fontSize: 6,
                color: Colors.black,
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(
              '2017 - 2021',
              style: GoogleFonts.poppins(
                fontSize: 6,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DEGREE / DIPLOMA NAME',
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
              'Institution Name',
              style: GoogleFonts.poppins(
                fontSize: 6,
                color: Colors.black,
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(
              '2013 - 2017',
              style: GoogleFonts.poppins(
                fontSize: 6,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillsSection() {
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
        _buildSkillItem('HTML5'),
        _buildSkillItem('CSS3'),
        _buildSkillItem('JavaScript (ES6+)'),
        _buildSkillItem('React.js'),
        _buildSkillItem('Vue.js'),
        _buildSkillItem('Angular'),
        _buildSkillItem('Tailwind CSS'),
        _buildSkillItem('Node.js'),
        _buildSkillItem('Material UI'),
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
          Text(
            skill,
            style: GoogleFonts.poppins(
              fontSize: 6,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagesSection() {
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
        _buildSkillItem('Urdu'),
        _buildSkillItem('English'),
      ],
    );
  }

  Widget _buildProfileSection(Map<String, dynamic> userData) {
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
          userData['careerObjective'] ?? '',
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
