import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:toolkit/controllers/language_controller.dart';
import 'package:toolkit/provider/certification_provider.dart';
import 'package:toolkit/provider/education_provider.dart';
import 'package:toolkit/provider/file_provider.dart';
import 'package:toolkit/provider/language_provider.dart';
import 'package:toolkit/provider/profile_provider.dart';
import 'package:toolkit/provider/saved_cv_provider.dart';
import 'package:toolkit/provider/skills_provider.dart';
import 'package:toolkit/provider/template_provider.dart';
import 'package:toolkit/provider/user_provider.dart';
import 'package:toolkit/provider/work_experience_provider.dart';
import 'package:toolkit/screens/splash_screen/splash_screen.dart';
import 'package:toolkit/services/notification_service.dart';
import 'package:toolkit/services/ad_service.dart';
import 'package:toolkit/utils/ad_manager.dart';
import 'package:toolkit/utils/app_open_ad_manager.dart';
import 'package:toolkit/utils/app_lifecycle_reactor.dart';
import 'localization/language.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:developer' as developer;

// Override debugPrint to reduce verbose logging
void _overrideDebugPrint() {
  // Filter out verbose system logs
  // Note: MediaCodec/BufferQueue logs are Android system logs from Google Ads SDK
  // They appear in logcat but can be filtered using: adb logcat | grep -v "BufferQueue\|MediaCodec"
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message == null) return;

    // Skip verbose logs from Android system and Dart VM
    final lowerMessage = message.toLowerCase();
    if (lowerMessage.contains('mediacodec') ||
        lowerMessage.contains('bufferqueue') ||
        lowerMessage.contains('setrequestedframerate') ||
        lowerMessage.contains('dequeuebuffer') ||
        lowerMessage.contains('dartvm') ||
        lowerMessage.contains('waitforfreeslotthenrelock') ||
        lowerMessage.contains('bufferqueueproducer') ||
        lowerMessage.contains('mediacodec.release')) {
      return; // Suppress these logs
    }

    // Only log important messages
    developer.log(
      message,
      name: 'App',
      level: 800, // INFO level - only show important logs
    );
  };
}

void main() async {
  // Override debugPrint before initializing to reduce verbose logs
  _overrideDebugPrint();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

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
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
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
      translations: Language(),
      locale: _getStoredLocale(),
      fallbackLocale: const Locale('en', 'US'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: child!,
        );
      },
      theme: ThemeData(
        primaryColor: const Color(0xFF00BFA5),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AppInitializer(),
    );
  }

  Locale? _getStoredLocale() {
    try {
      final controller = Get.put(LanguageController());
      return controller.currentLocale.value;
    } catch (e) {
      return null;
    }
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  late AppOpenAdManager _appOpenAdManager;
  late AppLifecycleReactor _appLifecycleReactor;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _appLifecycleReactor.stopListening();
    _appOpenAdManager.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize ads
      await AdService.initialize();

      // Initialize App Open Ad Manager
      _appOpenAdManager = AppOpenAdManager();
      _appOpenAdManager.loadAd(); // Load first app open ad

      // Initialize App Lifecycle Reactor to listen for foreground events
      _appLifecycleReactor = AppLifecycleReactor(
        appOpenAdManager: _appOpenAdManager,
      );
      _appLifecycleReactor.listenToAppStateChanges();

      // Note: App open ad will be shown from SplashScreen after splash completes
      // This ensures smooth user experience - ad shows after splash, not during

      await AdManager.preloadInterstitials();
      await AdManager.preloadRewardedAds();
      await AdManager.preloadNewInterstitials();

      await NotificationService.initialize(context);

      await _checkOnboardingStatus();
    } catch (e) {
      debugPrint('Error initializing app: $e');
    }
  }

  Future<void> _checkOnboardingStatus() async {
    // Onboarding status is handled in SplashScreen
    // This method can be used for future initialization needs
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
