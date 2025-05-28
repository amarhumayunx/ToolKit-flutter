import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toolkit/utils/app_colors.dart';
import '../utils/app_snackbar.dart';
import '../widgets/gradient_background.dart';
import '../widgets/settings_widgets/settings_tile.dart';
import '../widgets/settings_widgets/settings_toggle_tile.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  bool _isGeneralExpanded = false;
  bool _isConfidentialExpanded = false;
  String _selectedLanguage = 'English';
  String _selectedRecoveryOption = 'Email';
  String _emailController = '';
  String _phoneController = '';

  // List of available languages
  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese'
  ];

  // List of recovery options
  final List<String> _recoveryOptions = [
    'Email',
    'Phone Number'
  ];

  @override
  void initState() {
    super.initState();
    _loadNotificationStatus();
  }

  // Load notification status from shared preferences
  void _loadNotificationStatus() async {
    try {
      bool enabled = await NotificationService.areNotificationsEnabled();
      setState(() {
        _notificationsEnabled = enabled;
      });
    } catch (e) {
      debugPrint('Error loading notification status: $e');
      setState(() {
        _notificationsEnabled = false;
      });
    }
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
              message: 'Notifications enabled successfully');
        } else {
          // Permission denied, keep notifications disabled
          await NotificationService.setNotificationEnabled(false);
          setState(() {
            _notificationsEnabled = false;
          });
          AppSnackBar.show(context, message: 'Notification permission denied');
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
        AppSnackBar.show(context, message: 'Notifications disabled');
      } catch (e) {
        debugPrint('Error disabling notifications: $e');
        AppSnackBar.show(context, message: 'Error disabling notifications');
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

                      // Confidential Documents section with expandable content
                      _buildConfidentialDocumentsSection(),

                      SettingToggleTile(
                        title: 'Notifications & Alerts',
                        value: _notificationsEnabled,
                        onChanged: _handleNotificationToggle,
                      ),
                      SettingTile(title: 'Support & Feedback', onTap: () {}),
                      SettingTile(title: 'Privacy Policy', onTap: () {}),
                      SettingTile(title: 'Rate US', onTap: () {}),
                      SettingTile(title: 'Share', onTap: () {}),
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
          // Header row for General
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
                    'General',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Icon(
                    _isGeneralExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Expandable content for language selection
          if (_isGeneralExpanded)
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
                      'Language',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.bgBoxColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedLanguage,
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
                          setState(() {
                            _selectedLanguage = value!;
                          });
                        },
                        items: _languages
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
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
                    'Confidential Documents',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Icon(
                    _isConfidentialExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                    size: 20,
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
                      'Code Recovery Options',
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
                          setState(() {
                            _selectedRecoveryOption = value!;
                          });
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

                    // Conditional text field based on selection
                    if (_selectedRecoveryOption == 'Email')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email',
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
                              border: Border.all(color: Colors.grey.withOpacity(0.1)),
                            ),
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _emailController = value;
                                });
                              },
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.gradientEnd,
                              ),
                              decoration: InputDecoration(
                                hintText: 'abc@gmail.com',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(12),
                              ),
                            ),
                          ),
                          if (_emailController.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: AppColors.primary,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                    if (_selectedRecoveryOption == 'Phone Number')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phone Number',
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
                              border: Border.all(color: Colors.grey.withOpacity(0.1)),
                            ),
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _phoneController = value;
                                });
                              },
                              keyboardType: TextInputType.phone,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.gradientEnd,
                              ),
                              decoration: InputDecoration(
                                hintText: '+1 234 567 8900',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(12),
                              ),
                            ),
                          ),
                          if (_phoneController.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: AppColors.primary,
                                      size: 16,
                                    ),
                                  ),
                                ],
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
            'Settings',
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