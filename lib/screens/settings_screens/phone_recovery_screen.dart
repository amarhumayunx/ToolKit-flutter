import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/buttons/gradient_btn.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/settings_widgets/auth_subtitle_widget.dart';

import '../../widgets/settings_widgets/auth_title_widget.dart';
import '../../widgets/settings_widgets/input_field_widget.dart';
import 'otp_verify_screen.dart';

class PhoneRecoveryScreen extends StatefulWidget {
  final String? phone;

  const PhoneRecoveryScreen({super.key, this.phone});

  @override
  State<PhoneRecoveryScreen> createState() => _PhoneRecoveryScreenState();
}

class _PhoneRecoveryScreenState extends State<PhoneRecoveryScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedCountryCode = '+91';

  final List<Map<String, String>> _countryCodes = [
    {'code': '+880', 'country': 'BD'},
    {'code': '+1', 'country': 'US'},
    {'code': '+44', 'country': 'UK'},
    {'code': '+91', 'country': 'IN'},
    {'code': '+86', 'country': 'CN'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.phone != null) {
      String phone = widget.phone!;
      for (var countryData in _countryCodes) {
        if (phone.startsWith(countryData['code']!)) {
          _selectedCountryCode = countryData['code']!;
          _phoneController.text = phone.substring(countryData['code']!.length);
          break;
        }
      }
      if (_phoneController.text.isEmpty) {
        _phoneController.text = phone;
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String get _fullPhoneNumber => '$_selectedCountryCode${_phoneController.text}';

  void _navigateToOtpScreen() {
    if (_formKey.currentState!.validate()) {
      // Navigate to OTP verification screen with the phone number
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OtpVerifyScreen(
            email: _fullPhoneNumber, // Using email parameter for phone number
            isPhoneVerification: true, // Flag to indicate this is phone verification
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'phone_verify'.tr,
        onBackPressed: () {
          Navigator.of(context).pop(false);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthTitleWidget(title: 'enter_your_phone'.tr),
              const SizedBox(height: 44),
              AuthSubtitleWidget(
                normalText: 'please_enter_your'.tr,
                highlightedText: 'phone_number'.tr,
              ),
              const SizedBox(height: 32),
              AuthInputField(
                controller: _phoneController,
                labelText: 'enter_mobile_label'.tr,
                hintText: 'mobile_hint'.tr,
                keyboardType: TextInputType.phone,
                isPhoneField: true,
                countryCode: _selectedCountryCode,
                countryCodes: _countryCodes,
                onCountryCodeChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCountryCode = newValue;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'enter_phone_error'.tr;
                  }
                  if (value.length < 5) {
                    return 'valid_phone_error'.tr;
                  }
                  return null;
                },
              ),
              const Spacer(),
              CustomGradientButton(
                text: 'enter'.tr,
                onPressed: _navigateToOtpScreen,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}