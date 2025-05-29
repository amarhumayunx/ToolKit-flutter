import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart'; // Updated import for Get
import 'package:hive_ce_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:toolkit/provider/certification_provider.dart';
import 'package:toolkit/provider/education_provider.dart';
import 'package:toolkit/provider/file_provider.dart';
import 'package:toolkit/provider/language_provider.dart';
import 'package:toolkit/provider/saved_cv_provider.dart';
import 'package:toolkit/provider/skills_provider.dart';
import 'package:toolkit/provider/template_provider.dart';
import 'package:toolkit/provider/user_provider.dart';
import 'package:toolkit/provider/work_experience_provider.dart';
import 'package:toolkit/screens/home_screen.dart';
import 'package:toolkit/services/notification_service.dart';
import 'controllers/language_controller.dart';
import 'localization/language.dart'; // Add your languages file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  // Initialize Hive
  await Hive.initFlutter();


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
        ChangeNotifierProvider(create: (_) => FileProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Toolkit App',
      debugShowCheckedModeBanner: false,

      // Localization setup
      translations: Language(), // Your Translations class
      locale: Get.deviceLocale, // Uses the device locale
      fallbackLocale: const Locale('en', 'US'), // Fallback locale

      theme: ThemeData(
        primaryColor: const Color(0xFF00BFA5),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      home: const AppInitializer(), // Your app's initial screen
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize notifications
      await NotificationService.initialize(context);
    } catch (e) {
      debugPrint('Error initializing app: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}