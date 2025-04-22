import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:toolkit/provider/certification_provider.dart';
import 'package:toolkit/provider/education_provider.dart';
import 'package:toolkit/provider/language_provider.dart';
import 'package:toolkit/provider/saved_cv_provider.dart';
import 'package:toolkit/provider/skills_provider.dart';
import 'package:toolkit/provider/template_provider.dart';
import 'package:toolkit/provider/template_provider.dart';
import 'package:toolkit/provider/user_provider.dart';
import 'package:toolkit/provider/work_experience_provider.dart';
import 'package:toolkit/screens/cv_maker_screens/certifications_screen.dart';
import 'package:toolkit/screens/cv_maker_screens/cv_maker_screen.dart';
import 'package:toolkit/screens/cv_maker_screens/education_details_screen.dart';
import 'package:toolkit/screens/cv_maker_screens/personal_info_screen.dart';
import 'package:toolkit/screens/cv_maker_screens/skills_screen.dart';
import 'package:toolkit/screens/cv_maker_screens/work_experience_screen.dart';

import 'package:toolkit/screens/home_screen.dart';
import 'package:toolkit/screens/onboarding_screen.dart';
import 'package:toolkit/widgets/cv_templates/template_1.dart';
import 'package:toolkit/widgets/cv_templates/template_2.dart';
import 'package:toolkit/widgets/cv_templates/template_3.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TemplateProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => WorkExperienceProvider()),
        ChangeNotifierProvider(create: (context) => EducationProvider()),
        ChangeNotifierProvider(create: (context) => CertificationProvider()),
        ChangeNotifierProvider(create: (_) => SkillsProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => SavedCVProvider()),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToolKit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF00BFA5),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:OnboardingScreen(),
    );
  }
}
