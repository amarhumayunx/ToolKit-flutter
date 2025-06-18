import 'dart:async';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toolkit/screens/settings_screens/password_verification_screen.dart';
import 'package:toolkit/screens/settings_screens/phone_recovery_screen.dart';
import 'package:toolkit/screens/settings_screens/set_password_screen.dart';
import 'package:toolkit/utils/app_colors.dart';
import '../../controllers/language_controller.dart';
import '../../provider/profile_provider.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/settings_widgets/settings_appbar.dart';
import '../../widgets/settings_widgets/settings_tile.dart';
import '../../widgets/settings_widgets/settings_toggle_tile.dart';
import 'locked_files_Screen.dart';
import 'continue_with_google_screen.dart'; // Add this import

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  bool _isGeneralExpanded = false;
  bool _isConfidentialExpanded = false;
  bool _isPasswordSet = false;
  bool _isUserAuthenticated = false; // Add this
  final String _selectedLanguage = 'English';
  final String _selectedRecoveryOption = 'email'.tr;
  final AuthService _authService = AuthService();
  StreamSubscription? _authSubscription;

  // List of available languages
  final List<String> _languages = [
    'English',
    'UK',
    'US',
    'German',
    'Chinese',
    'Urdu'
  ];

  // List of recovery options
  final List<String> _recoveryOptions = ['Email', 'Phone Number'];

  @override
  void initState() {
    super.initState();
    _loadNotificationStatus();
    _initializeLanguageController();
    _loadPasswordStatus();
    _loadProfileData();
    _setupAuthListener();
    _loadCurrentLanguage();
  }

  @override
  void dispose() {
    _authSubscription?.cancel(); // Cancel the subscription
    super.dispose();
  }

  void _setupAuthListener() {
    _authSubscription = _authService.authStateChanges.listen((user) {
      if (mounted) {
        setState(() {
          _isUserAuthenticated = user != null;
          if (!_isUserAuthenticated) {
            _isPasswordSet = false; // Reset password status when logged out
          }
        });
        if (_isUserAuthenticated) {
          _loadPasswordStatus(); // Reload password status when logged in
        }
      }
    });
  }

  void _loadCurrentLanguage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final languageController = Get.find<LanguageController>();
      languageController.loadSavedLanguage();
    });
  }

  Future<void> _loadPasswordStatus() async {
    try {
      bool isSet = await _authService.isPasswordSet();
      setState(() {
        _isPasswordSet = isSet;
      });
    } catch (e) {
      setState(() {
        _isPasswordSet = false;
      });
    }
  }

  void _initializeLanguageController() {
    try {
      Get.find<LanguageController>();
    } catch (e) {
      Get.put(LanguageController());
    }
  }

  Future<void> _loadProfileData() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final userData = await _authService.getUserData(user.uid);
        final profileProvider =
            Provider.of<ProfileProvider>(context, listen: false);

        if (userData != null) {
          profileProvider.loadProfileData(
            avatar: userData.avatarId ?? '6',
            username: userData.displayName,
            email: userData.email,
            gender: userData.gender,
            dateOfBirth: userData.dateOfBirth,
          );
        } else {
          profileProvider.loadProfileData(
            avatar: profileProvider.selectedAvatar ?? '6',
            username: user.displayName ?? 'Not set',
            email: user.email ?? 'Not set',
            gender: 'Not set',
            dateOfBirth: 'Not set',
          );
        }
      }
    } catch (e) {
      print('Error loading profile data in settings: $e');
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      if (profileProvider.selectedAvatar == null) {
        profileProvider.loadProfileData(
          avatar: '6',
          username: 'Not set',
          email: 'Not set',
          gender: 'Not set',
          dateOfBirth: 'Not set',
        );
      }
    }
  }

  // Show authentication required dialog
  void _showAuthenticationRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sign in Required',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Please sign in to secure your documents.',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to Google sign-in screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ContinueWithGoogleScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Sign in',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToSetPasswordScreen() async {
    // Check authentication first
    if (!_isUserAuthenticated) {
      _showAuthenticationRequiredDialog();
      return;
    }

    // Check if password is already set
    final isPasswordSet = await _authService.isPasswordSet();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SetPasswordScreen(
          isChanging: isPasswordSet,
        ),
      ),
    );

    if (result == true) {
      setState(() {
        _isPasswordSet = true;
      });
    }
  }

  void _navigateToLockedFiles() async {
    // Check authentication first
    if (!_isUserAuthenticated) {
      _showAuthenticationRequiredDialog();
      return;
    }

    // Check if password is set
    if (_isPasswordSet) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PasswordVerificationScreen(
            destinationScreen: LockedFilesScreen(),
            title: 'Enter Password',
          ),
        ),
      );
    } else {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SetPasswordScreen(),
        ),
      );

      if (result == true) {
        _savePasswordStatus(true);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PasswordVerificationScreen(
              destinationScreen: LockedFilesScreen(),
              title: 'Enter Password',
            ),
          ),
        );
      }
    }
  }

  void _savePasswordStatus(bool isSet) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_password_set', isSet);
      setState(() {
        _isPasswordSet = isSet;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _loadNotificationStatus() async {
    try {
      bool enabled = await NotificationService.areNotificationsEnabled();
      setState(() {
        _notificationsEnabled = enabled;
      });
    } catch (e) {
      setState(() {
        _notificationsEnabled = false;
      });
    }
  }

  Future<void> _handleNotificationToggle(bool newValue) async {
    if (newValue) {
      try {
        await NotificationService.initialize(context);
        bool permissionGranted = await NotificationService.requestPermissions();

        if (permissionGranted) {
          await NotificationService.setNotificationEnabled(true);
          setState(() {
            _notificationsEnabled = true;
          });
          AppSnackBar.show(context, message: 'notification_enabled'.tr);
        } else {
          await NotificationService.setNotificationEnabled(false);
          setState(() {
            _notificationsEnabled = false;
          });
          AppSnackBar.show(context, message: 'notification_permission'.tr);
        }
      } catch (e) {
        await NotificationService.setNotificationEnabled(false);
        setState(() {
          _notificationsEnabled = false;
        });
        AppSnackBar.show(context, message: 'Error enabling notifications: $e');
      }
    } else {
      try {
        await NotificationService.setNotificationEnabled(false);
        setState(() {
          _notificationsEnabled = false;
        });
        AppSnackBar.show(context, message: 'notification_disabled');
      } catch (e) {
        AppSnackBar.show(context, message: 'notification_error_disabling'.tr);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackgroundWidget(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 0),
            SettingsAppBar(
              title: 'settings'.tr,
              onBackPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, left: 26, right: 26),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildGeneralSection(),
                      const SizedBox(height: 4),
                      _buildConfidentialDocumentsSection(),
                      const SizedBox(height: 4),
                      SettingTile(
                        title: 'Locked Files',
                        onTap: () {
                          _navigateToLockedFiles();
                        },
                      ),
                      const SizedBox(height: 4),
                      SettingToggleTile(
                        title: 'notifications_and_alerts'.tr,
                        value: _notificationsEnabled,
                        onChanged: _handleNotificationToggle,
                      ),
                      SettingTile(
                          title: 'support_and_feedback'.tr, onTap: () {}),
                      const SizedBox(height: 4),
                      SettingTile(title: 'privacy_policy'.tr, onTap: () {}),
                      const SizedBox(height: 4),
                      SettingTile(title: 'rate_us'.tr, onTap: () {}),
                      const SizedBox(height: 4),
                      SettingTile(title: 'share'.tr, onTap: () {}),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSection() {
    final languageController = Get.find<LanguageController>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isGeneralExpanded = !_isGeneralExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'general'.tr,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Transform.rotate(
                    angle: _isGeneralExpanded ? 1.5708 : 0,
                    child: SvgPicture.asset(
                      'assets/icons/next_page_icon.svg',
                      height: 12,
                      width: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isGeneralExpanded)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.bgBoxColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Obx(() => DropdownButton2<String>(
                  value: languageController.currentLanguage.value,
                  iconStyleData: IconStyleData(
                    icon: SvgPicture.asset(
                      'assets/icons/arrow_up_down_icon.svg',
                      height: 16,
                      width: 16,
                    ),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    elevation: 16,
                    width: MediaQuery.of(context).size.width * 0.79,
                    useSafeArea: true,
                    offset: const Offset(-10, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                  ),
                  isExpanded: true,
                  underline: Container(),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.gradientEnd,
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      final selected = languageController.languageOptions
                          .firstWhere((lang) => lang['name'] == newValue);
                      languageController.changeLanguage(
                        selected['code']!,
                        selected['country']!,
                        selected['name']!,
                      );
                    }
                  },
                  items: languageController.languageOptions
                      .map<DropdownMenuItem<String>>((lang) {
                    return DropdownMenuItem<String>(
                      value: lang['name'],
                      child: Text(lang['name']!,),

                    );
                  }).toList(),
                )),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConfidentialDocumentsSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isConfidentialExpanded = !_isConfidentialExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'confidential_documents'.tr,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Transform.rotate(
                    angle: _isConfidentialExpanded ? 1.5708 : 0,
                    child: SvgPicture.asset(
                      'assets/icons/next_page_icon.svg',
                      height: 12,
                      width: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isConfidentialExpanded)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: _isPasswordSet ? 12 : 0),
                    child: InkWell(
                      onTap: () {
                        _navigateToSetPasswordScreen();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _isPasswordSet
                                  ? 'Change Password'
                                  : 'Set Password',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                            SvgPicture.asset(
                              'assets/icons/next_page_icon.svg',
                              height: 12,
                              width: 12,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_isPasswordSet)
                    // In the _buildConfidentialDocumentsSection method, update the email recovery section

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 0),
                          )
                        ],
                      ),
                      child: InkWell(
                        onTap: () {
                          if (_isUserAuthenticated) {
                            // Get user email from profile provider
                            final profileProvider =
                                Provider.of<ProfileProvider>(context,
                                    listen: false);
                            final userEmail = profileProvider.email;

                            if (userEmail != null && userEmail.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PhoneRecoveryScreen(),
                                ),
                              );
                            } else {
                              AppSnackBar.show(context,
                                  message: 'No email found for this account');
                            }
                          } else {
                            _showAuthenticationRequiredDialog();
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'code_recovery_options'.tr,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.bgBoxColor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.1)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Forgot password?',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.gradientEnd,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: AppColors.gradientEnd,
                                  ),
                                ],
                              ),
                            ),
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
}
