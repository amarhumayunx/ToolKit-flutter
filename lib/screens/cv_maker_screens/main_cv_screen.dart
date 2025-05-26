import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolkit/screens/cv_maker_screens/personal_info_screen.dart';
import 'package:toolkit/screens/cv_maker_screens/skills_screen.dart';
import 'package:toolkit/screens/cv_maker_screens/website_screen.dart';
import 'package:toolkit/screens/cv_maker_screens/work_experience_screen.dart';
import '../../models/certification_model.dart';
import '../../models/education_item_model.dart';
import '../../models/language_model.dart';
import '../../models/skills_model.dart';
import '../../models/website_model.dart';
import '../../models/work_experience_model.dart';
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
  final dynamic editData;
  final bool isEditing;
  final GlobalKey<PersonalInfoPageState> personalInfoKey = GlobalKey();

  MainCVScreen({
    Key? key,
    required this.templateId,
    required this.templateName,
    this.editData,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<MainCVScreen> createState() => _MainCVScreenState();
}

class _MainCVScreenState extends State<MainCVScreen> {
  int currentStep = 1;
  final PageController _pageController = PageController(initialPage: 0);
  bool _isLoadingEditData = false;

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
  void initState() {
    super.initState();
    // Load edit data into providers if editing
    if (widget.isEditing && widget.editData != null) {
      _loadEditDataIntoProviders();
    }
  }



  void _loadEditDataIntoProviders() async {
    if (_isLoadingEditData) return;
    _isLoadingEditData = true;

    final convertedData = _convertToStringMap(widget.editData);
    if (convertedData == null) {
      _isLoadingEditData = false;
      return;
    }

    try {
      // Wait for the next frame to ensure the widget tree is built
      await Future.delayed(Duration.zero);

      if (!mounted) {
        _isLoadingEditData = false;
        return;
      }

      // Personal Info
      final personalInfo = _convertToStringMap(convertedData['personalInfo']);
      if (personalInfo != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.updateUserData(
          fullName: personalInfo['fullName'],
          designation: personalInfo['designation'],
          email: personalInfo['email'],
          phoneNumber: personalInfo['phoneNumber'],
          profileImagePath: personalInfo['profileImagePath'],
        );

        if (convertedData['careerObjective'] != null) {
          userProvider.updateCareerObjective(convertedData['careerObjective']);
        }
      }

      // Use a small delay between provider updates to prevent conflicts
      await _loadEducationData(convertedData);
      await _loadWorkExperienceData(convertedData);
      await _loadCertificationData(convertedData);
      await _loadSkillsData(convertedData);
      await _loadLanguagesData(convertedData);
      await _loadWebsitesData(convertedData);
    } catch (e) {
      debugPrint('Error loading edit data: $e');
    } finally {
      _isLoadingEditData = false;
    }
  }

  Future<void> _loadEducationData(Map<String, dynamic> convertedData) async {
    await Future.delayed(Duration(milliseconds: 50));
    if (!mounted) return;

    final educationData = _getNestedListData('education');
    if (educationData != null) {
      final educationProvider =
      Provider.of<EducationProvider>(context, listen: false);
      educationProvider.clearEducationItems();

      for (var item in educationData) {
        educationProvider.addEducationItem(EducationItem(
          degree: item['degree'] ?? '',
          institute: item['institute'] ?? '',
          startDate: item['startDate'] ?? '',
          endDate: item['endDate'] ?? '',
          description: item['description'] ?? '',
          isCompleted: item['isCompleted'] ?? false,
        ));
      }
    }
  }

  Future<void> _loadWorkExperienceData(
      Map<String, dynamic> convertedData) async {
    await Future.delayed(Duration(milliseconds: 50));
    if (!mounted) return;

    final workExpData = _getNestedListData('workExperience');
    if (workExpData != null) {
      final workExpProvider =
      Provider.of<WorkExperienceProvider>(context, listen: false);
      workExpProvider.clearWorkExperienceItems();

      for (var item in workExpData) {
        workExpProvider.addWorkExperience(WorkExperienceItem(
          position: item['position'] ?? '',
          company: item['company'] ?? '',
          startDate: item['startDate'] ?? '',
          endDate: item['endDate'] ?? '',
          projects: List<String>.from(item['projects'] ?? []),
          projectUrls: List<String>.from(item['projectUrls'] ?? []),
          description: item['description'] ?? '',
          isCurrent: item['isCurrent'] ?? false,
        ));
      }
    }
  }

  Future<void> _loadCertificationData(
      Map<String, dynamic> convertedData) async {
    await Future.delayed(Duration(milliseconds: 50));
    if (!mounted) return;

    final certData = _getNestedListData('certifications');
    if (certData != null) {
      final certProvider =
      Provider.of<CertificationProvider>(context, listen: false);
      certProvider.clearCertificationItems();

      for (var item in certData) {
        certProvider.addCertificationItem(CertificationItem(
          certificationName: item['certificationName'] ?? '',
          organizationName: item['organizationName'] ?? '',
          startDate: item['startDate'] ?? '',
          endDate: item['endDate'] ?? '',
          description: item['description'] ?? '',
          isCompleted: item['isCompleted'] ?? false,
        ));
      }
    }
  }

  Future<void> _loadSkillsData(Map<String, dynamic> convertedData) async {
    await Future.delayed(Duration(milliseconds: 50));
    if (!mounted) return;

    final skillsData = _getNestedListData('skills');
    if (skillsData != null) {
      final skillsProvider =
      Provider.of<SkillsProvider>(context, listen: false);
      skillsProvider.clearSkillItems();

      for (var item in skillsData) {
        skillsProvider.addSkill(Skill(name: item['name'] ?? ''));
      }
    }
  }

  Future<void> _loadLanguagesData(Map<String, dynamic> convertedData) async {
    await Future.delayed(Duration(milliseconds: 50));
    if (!mounted) return;

    final languageData = _getNestedListData('languages');
    if (languageData != null) {
      final languageProvider =
      Provider.of<LanguageProvider>(context, listen: false);
      languageProvider.clearLanguages();

      for (var item in languageData) {
        languageProvider.addLanguage(Language(name: item['name'] ?? ''));
      }
    }
  }
// Replace the existing _loadWebsitesData method in MainCVScreen with this improved version:

  Future<void> _loadWebsitesData(Map<String, dynamic> convertedData) async {
    await Future.delayed(Duration(milliseconds: 50));
    if (!mounted) return;

    debugPrint('Loading websites data...');
    debugPrint('Converted data keys: ${convertedData.keys}');

    // Check for both possible keys
    final websitesData = convertedData['websites'] ?? convertedData['website'];
    debugPrint('Websites data: $websitesData');

    if (websitesData != null) {
      debugPrint('Processing websites data...');

      List<Website> websites = [];

      if (websitesData is List) {
        // Handle list format
        for (var item in websitesData) {
          final websiteMap = _convertToStringMap(item);
          if (websiteMap != null) {
            websites.add(Website(
              name: websiteMap['name'] ?? 'Website',
              url: websiteMap['url'] ?? '',
            ));
          }
        }
      } else if (websitesData is Map) {
        // Handle single website (legacy format)
        final websiteMap = _convertToStringMap(websitesData);
        if (websiteMap != null) {
          websites.add(Website(
            name: websiteMap['name'] ?? 'Website',
            url: websiteMap['url'] ?? websiteMap['websiteUrl'] ?? '',
          ));
        }
      }

      debugPrint('Loaded ${websites.length} websites');
      if (websites.isNotEmpty) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.updateWebsites(websites);
        debugPrint('Websites updated in provider');
      }
    } else {
      debugPrint('No websites data found');
    }
  }

// Also, make sure your _getNestedListData method has proper debugging:
  List<Map<String, dynamic>>? _getNestedListData(String key) {
    final convertedData = _convertToStringMap(widget.editData);
    debugPrint('_getNestedListData called for key: $key');
    debugPrint('Converted data: $convertedData');

    if (convertedData == null) {
      debugPrint('Converted data is null');
      return null;
    }

    final nestedData = convertedData[key];
    debugPrint('Nested data for $key: $nestedData');
    debugPrint('Nested data type: ${nestedData.runtimeType}');

    if (nestedData is List) {
      debugPrint('Processing list with ${nestedData.length} items');
      final result = nestedData.map<Map<String, dynamic>>((item) {
        debugPrint('Processing item: $item (${item.runtimeType})');
        if (item is Map) {
          final converted = Map<String, dynamic>.from(item as Map);
          debugPrint('Converted item: $converted');
          return converted;
        }
        debugPrint('Item is not a Map, returning empty map');
        return <String, dynamic>{};
      }).toList();

      debugPrint('Final result for $key: $result');
      return result;
    }

    debugPrint('Nested data is not a List');
    return null;
  }

  Map<String, dynamic>? _convertToStringMap(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      try {
        return Map<String, dynamic>.from(
            data.map((key, value) => MapEntry(key.toString(), value)));
      } catch (e) {
        debugPrint('Error converting map: $e');
        return <String, dynamic>{};
      }
    }
    return null;
  }

  Map<String, dynamic>? _getNestedData(String key) {
    final convertedData = _convertToStringMap(widget.editData);
    if (convertedData == null) return null;

    final nestedData = convertedData[key];
    return _convertToStringMap(nestedData);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void goToNextPage() {
    if (currentStep < stepTitles.length) {
      // Save current page data before moving to next
      _saveCurrentPageData();

      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void goToPreviousPage() {
    if (currentStep > 1) {
      // Save current page data before moving to previous
      _saveCurrentPageData();

      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _saveCurrentPageData() {
    // Save data for the current page
    switch (currentStep) {
      case 1:
      // Personal Info - data is automatically saved via saveCurrentDataToProvider
        widget.personalInfoKey.currentState?.saveCurrentDataToProvider();
        break;
    // Add cases for other pages as needed
    }
  }

  void _navigateToTemplate(BuildContext context) {
    final templateProvider =
    Provider.of<TemplateProvider>(context, listen: false);
    final templateId = templateProvider.selectedTemplateId;
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
      MaterialPageRoute(builder: (context) => templateScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentStep > 1) {
          goToPreviousPage();
          return false;
        }
        return true;
      },
      child: Scaffold(
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
                  PersonalInfoPage(
                    key: widget.personalInfoKey,
                    templateId: widget.templateId,
                    templateName: widget.templateName,
                    initialData: _getNestedData('personalInfo'),
                  ),
                  CareerObjectivesPage(),
                  EducationDetailPage(
                    initialData: _getNestedListData('education'),
                  ),
                  WorkExperiencePage(
                    initialData: _getNestedListData('workExperience'),
                  ),
                  CertificationPage(
                    initialData: _getNestedListData('certifications'),
                  ),
                  SkillsPage(
                    initialData: _getNestedListData('skills'),
                  ),
                  LanguagesPage(
                    initialData: _getNestedListData('languages'),
                  ),
                  WebsitePage(
                    initialData: _getNestedListData('websites'),
                  ),
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
            text: widget.isEditing
                ? 'Update'
                : (currentStep == stepTitles.length ? 'Add' : 'Next'),
            onPressed: () {
              if (currentStep == 1) {
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
      ),
    );
  }
}