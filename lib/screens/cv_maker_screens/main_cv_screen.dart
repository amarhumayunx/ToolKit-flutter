import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolkit/screens/cv_maker_screens/personal_info_screen.dart';
import 'package:toolkit/screens/cv_maker_screens/skills_screen.dart';
import 'package:toolkit/screens/cv_maker_screens/website_screen.dart';
import 'package:toolkit/screens/cv_maker_screens/work_experience_screen.dart';
import '../../widgets/buttons/gradient_btn.dart';
import '../../widgets/cv_progress_indicator.dart';
import '../../widgets/custom_appbar.dart';
import '../../provider/template_provider.dart';
import '../../widgets/cv_templates/template_1.dart';
import '../../widgets/cv_templates/template_2.dart';
import '../../widgets/cv_templates/template_3.dart';
import '../../widgets/cv_templates/template4.dart';
import 'career_objectives_screen.dart';
import 'certifications_screen.dart';
import 'education_details_screen.dart';
import 'language_screen.dart';

class MainCVScreen extends StatefulWidget {
  final int templateId;
  final String templateName;
  final GlobalKey<PersonalInfoPageState> personalInfoKey = GlobalKey();

  MainCVScreen({
    super.key,
    required this.templateId,
    required this.templateName,
  });

  @override
  State<MainCVScreen> createState() => _MainCVScreenState();
}

class _MainCVScreenState extends State<MainCVScreen> {
  int currentStep = 1;
  final PageController _pageController = PageController(initialPage: 0);

  final List<String> stepTitles = [
    'Personal Information',
    'Career Objectives',
    'Education Details',
    'Work Experience',
    'Certification and Training',
    'Skills',
    'Languages',
    'Website and Social Link',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void goToNextPage() {
    if (currentStep < stepTitles.length) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void goToPreviousPage() {
    if (currentStep > 1) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Navigate to appropriate template based on selected template ID
  void _navigateToTemplate(BuildContext context) {
    // You can either use the widget.templateId directly or get it from the TemplateProvider
    // Let's use the TemplateProvider approach for consistency with WebsiteScreen
    final templateProvider =
        Provider.of<TemplateProvider>(context, listen: false);
    final templateId = templateProvider.selectedTemplateId;

    Widget templateScreen;

    switch (templateId) {
      case 1:
        templateScreen = const Template1();
        break;
      case 2:
        templateScreen = const Template2();
        break;
      case 3:
        templateScreen = const Template3();
        break;
      case 4:
        templateScreen = const Template4();
        break;
      default:
        // Fallback to Template1 if templateId doesn't match any case
        templateScreen = const Template1();
    }

    // Navigate to the selected template
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => templateScreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: stepTitles[currentStep - 1],
        onBackPressed: () {
          if (currentStep > 1) {
            goToPreviousPage();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 26, left: 26, top: 30),
            child: CVProgressIndicator(currentStep: currentStep),
          ),
          const SizedBox(height: 20),

          // Main content area with PageView
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  currentStep = index + 1;
                });
              },
              children: [
                // Your different screen contents as pages
                PersonalInfoPage(
                  key: widget.personalInfoKey,
                  templateId: widget.templateId,
                  templateName: widget.templateName,
                ),
                const CareerObjectivesPage(),
                const EducationDetailPage(),
                const WorkExperiencePage(),
                const CertificationPage(),
                const SkillsPage(),
                const LanguagesPage(),
                const WebsitePage(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          bottom: 28.0,
          left: 28.0,
          right: 28.0,
          top: 10.0,
        ),
        child: CustomGradientButton(
          text: currentStep == stepTitles.length ? 'Add' : 'Next',
          onPressed: () {
            if (currentStep == 1) {
              // For PersonalInfoPage
              final isValid =
                  widget.personalInfoKey.currentState?.validate() ?? false;
              if (isValid) {
                goToNextPage();
              }
            } else if (currentStep < stepTitles.length) {
              goToNextPage();
            } else {
              _navigateToTemplate(context);
            }
          },
        ),
      ),
    );
  }
}
