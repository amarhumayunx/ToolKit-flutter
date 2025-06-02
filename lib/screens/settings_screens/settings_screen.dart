import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toolkit/screens/settings_screens/phone_recovery_screen.dart';
import 'package:toolkit/utils/app_colors.dart';
import '../../controllers/language_controller.dart';
import '../../services/notification_service.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/settings_widgets/settings_tile.dart';
import '../../widgets/settings_widgets/settings_toggle_tile.dart';
import 'email_recovery_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  bool _isGeneralExpanded = false;
  bool _isConfidentialExpanded = false;
  final String _selectedLanguage = 'English';
  String _selectedRecoveryOption = 'email'.tr;

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
  }

  void _initializeLanguageController() {
    try {
      Get.find<LanguageController>();
    } catch (e) {
      // Controller not found, initialize it
      Get.put(LanguageController());
    }
  }

  // Load notification status from shared preferences
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

  // Navigate to email recovery screen
  void _navigateToEmailRecovery() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmailRecoveryScreen(email: 'email_hint'.tr),
      ),
    );
  }

  // Navigate to phone recovery screen
  void _navigateToPhoneRecovery() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const PhoneRecoveryScreen(phone: '+1 234 567 8900'),
      ),
    );
  }

  // Handle notification toggle
  Future<void> _handleNotificationToggle(bool newValue) async {
    if (newValue) {
      // User is trying to enable notifications - request permission
      try {
        await NotificationService.initialize(context);
        bool permissionGranted = await NotificationService.requestPermissions();

        if (permissionGranted) {
          // Save the enabled state
          await NotificationService.setNotificationEnabled(true);
          setState(() {
            _notificationsEnabled = true;
          });
          AppSnackBar.show(context,
              message: 'notification_enabled'.tr);
        } else {
          // Permission denied, keep notifications disabled
          await NotificationService.setNotificationEnabled(false);
          setState(() {
            _notificationsEnabled = false;
          });
          AppSnackBar.show(context, message: 'notification_permission'.tr);
        }
      } catch (e) {
        // Error occurred, keep notifications disabled
        await NotificationService.setNotificationEnabled(false);
        setState(() {
          _notificationsEnabled = false;
        });
        AppSnackBar.show(context, message: 'Error enabling notifications: $e');
      }
    } else {
      // User is disabling notifications - save the disabled state
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
            SizedBox(height: MediaQuery.of(context).padding.top + 30),
            _buildSettingsAppBar(context),
            const SizedBox(height: 6),
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
                  padding: const EdgeInsets.only(top: 20, left: 26, right: 26),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // General section with expandable content
                      _buildGeneralSection(),
                      const SizedBox(
                        height: 4,
                      ),
                      // Confidential Documents section with expandable content
                      _buildConfidentialDocumentsSection(),
                      const SizedBox(
                        height: 4,
                      ),
                      SettingToggleTile(
                        title: 'notifications_and_alerts'.tr,
                        value: _notificationsEnabled,
                        onChanged: _handleNotificationToggle,
                      ),
                      SettingTile(title: 'support_and_feedback'.tr, onTap: () {}),
                      const SizedBox(
                        height: 4,
                      ),
                      SettingTile(title: 'privacy_policy'.tr, onTap: () {}),
                      const SizedBox(
                        height: 4,
                      ),
                      SettingTile(title: 'rate_us'.tr, onTap: () {}),
                      const SizedBox(
                        height: 4,
                      ),
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
                child: Obx(() => DropdownButton<String>(
                  value: languageController.currentLanguage.value,
                  icon: SvgPicture.asset(
                    'assets/icons/arrow_up_down_icon.svg',
                    height: 16,
                    width: 16,
                  ),
                  elevation: 16,
                  isExpanded: true,
                  underline: Container(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
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
                      child: Text(lang['name']!),
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
          // Header row for Confidential Documents
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
                    angle: _isConfidentialExpanded ? 1.5708 : 0, // 90 degrees in radians
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

          // Expandable content for Code Recovery Options
          if (_isConfidentialExpanded)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Container(
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

                    // Dropdown for recovery options
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.bgBoxColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedRecoveryOption,
                        icon: SvgPicture.asset(
                          'assets/icons/arrow_up_down_icon.svg',
                          height: 16,
                          width: 16,
                        ),
                        elevation: 16,
                        isExpanded: true,
                        underline: Container(),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.gradientEnd,
                        ),
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              _selectedRecoveryOption = value;
                            });

                            // Add navigation logic here
                            if (value == 'Email') {
                              _navigateToEmailRecovery();
                            } else if (value == 'Phone Number') {
                              _navigateToPhoneRecovery();
                            }
                          }
                        },
                        items: _recoveryOptions
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Static email field (always shows regardless of selection)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'email'.tr,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.bgBoxColor,
                            borderRadius: BorderRadius.circular(10),
                            border:
                            Border.all(color: Colors.grey.withOpacity(0.1)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'abc@gmail.com',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.gradientEnd,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add,
                                    color: AppColors.primary,
                                    size: 16,
                                  ),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Text(
            'settings'.tr,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}