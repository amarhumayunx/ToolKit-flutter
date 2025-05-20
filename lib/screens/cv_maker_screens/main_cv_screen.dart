import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolkit/screens/cv_maker_screens/personal_info_screen.dart';
import 'package:toolkit/screens/cv_maker_screens/skills_screen.dart';
import 'package:toolkit/screens/cv_maker_screens/website_screen.dart';
import 'package:toolkit/screens/cv_maker_screens/work_experience_screen.dart';
import '../../provider/certification_provider.dart';
import '../../provider/education_provider.dart';
import '../../provider/language_provider.dart';
import '../../provider/skills_provider.dart';
import '../../provider/user_provider.dart';
import '../../provider/work_experience_provider.dart';
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
    Key? key,
    required this.templateId,
    required this.templateName,
  }) : super(key: key);

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
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void goToPreviousPage() {
    if (currentStep > 1) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // In MainCVScreen.dart
// Update the _navigateToTemplate method
  void _navigateToTemplate(BuildContext context) {
    final templateProvider = Provider.of<TemplateProvider>(context, listen: false);
    final templateId = templateProvider.selectedTemplateId;

    // Get all the data from providers
    final userData = Provider.of<UserProvider>(context, listen: false).userData;
    final workExperienceItems = Provider.of<WorkExperienceProvider>(context, listen: false).workExperienceItems;
    final educationItems = Provider.of<EducationProvider>(context, listen: false).educationItems;
    final certificationItems = Provider.of<CertificationProvider>(context, listen: false).certificationItems;
    final skillItems = Provider.of<SkillsProvider>(context, listen: false).skillItems;
    final languageItems = Provider.of<LanguageProvider>(context, listen: false).languages;
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
              physics: NeverScrollableScrollPhysics(),
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
                CareerObjectivesPage(),
                EducationDetailPage(),
                WorkExperiencePage(),
                CertificationPage(),
                SkillsPage(),
                LanguagesPage(),
                WebsitePage(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
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
