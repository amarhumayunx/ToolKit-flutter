import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/buttons/gradient_btn.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/settings_widgets/auth_subtitle_widget.dart';
import '../../widgets/settings_widgets/auth_title_widget.dart';
import '../../widgets/settings_widgets/input_field_widget.dart';
import '../../services/auth_service.dart';
import '../../utils/app_snackbar.dart';
import 'otp_verify_screen.dart';

class PhoneRecoveryScreen extends StatefulWidget {
  final String? phone;
  final bool isPasswordReset; // New parameter to indicate password reset flow

  const PhoneRecoveryScreen({
    super.key,
    this.phone,
    this.isPasswordReset = false,
  });

  @override
  State<PhoneRecoveryScreen> createState() => _PhoneRecoveryScreenState();
}

class _PhoneRecoveryScreenState extends State<PhoneRecoveryScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  String _selectedCountryCode = '+92';
  bool _isLoading = false;

  final List<Map<String, String>> _countryCodes = [
    {'code': '+880', 'country': 'BD'},
    {'code': '+1', 'country': 'US'},
    {'code': '+44', 'country': 'UK'},
    {'code': '+92', 'country': 'PK'},
    {'code': '+86', 'country': 'CN'},
  ];

  @override
  void initState() {
    super.initState();
    _initializePhoneNumber();
  }

  void _initializePhoneNumber() {
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
    } else if (widget.isPasswordReset) {
      // If it's password reset, try to load user's existing phone number
      _loadUserPhoneNumber();
    }
  }

  Future<void> _loadUserPhoneNumber() async {
    try {
      final phoneNumber = await _authService.getUserPhoneNumber();
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        for (var countryData in _countryCodes) {
          if (phoneNumber.startsWith(countryData['code']!)) {
            setState(() {
              _selectedCountryCode = countryData['code']!;
              _phoneController.text = phoneNumber.substring(countryData['code']!.length);
            });
            break;
          }
        }
      }
    } catch (e) {
      print('Error loading user phone number: $e');
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String get _fullPhoneNumber => '$_selectedCountryCode${_phoneController.text}';

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // For password reset, verify that this phone number belongs to the current user
      if (widget.isPasswordReset) {
        final userPhoneNumber = await _authService.getUserPhoneNumber();
        if (userPhoneNumber == null || userPhoneNumber != _fullPhoneNumber) {
          AppSnackBar.show(
              context,
              message: 'This phone number is not associated with your account'
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Here you would integrate with your SMS service (Firebase Auth, Twilio, etc.)
      // For now, we'll simulate sending OTP
      await _simulateOTPSending();

      // Navigate to OTP verification screen
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OtpVerifyScreen(
            email: _fullPhoneNumber,
            isPhoneVerification: true,
            isPasswordReset: widget.isPasswordReset,
          ),
        ),
      );

      // Handle the result from OTP verification
      if (result == true && mounted) {
        if (widget.isPasswordReset) {
          // If password reset was successful, pop this screen too
          Navigator.of(context).pop(true);
        } else {
          // Handle regular phone verification success
          AppSnackBar.show(context, message: 'Phone number verified successfully');
          Navigator.of(context).pop(true);
        }
      }

    } catch (e) {
      AppSnackBar.show(
          context,
          message: 'Failed to send OTP: ${e.toString()}'
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _simulateOTPSending() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Here you would call your SMS service
    // Example with Firebase Auth:
    // await FirebaseAuth.instance.verifyPhoneNumber(
    //   phoneNumber: _fullPhoneNumber,
    //   verificationCompleted: (PhoneAuthCredential credential) {},
    //   verificationFailed: (FirebaseAuthException e) {},
    //   codeSent: (String verificationId, int? resendToken) {},
    //   codeAutoRetrievalTimeout: (String verificationId) {},
    // );

    print('OTP sent to: $_fullPhoneNumber');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: widget.isPasswordReset ? 'Reset Password' : 'phone_verify'.tr,
        onBackPressed: () {
          Navigator.of(context).pop(false);
        },
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuthTitleWidget(
                      title: widget.isPasswordReset
                          ? 'Verify your phone number'
                          : 'enter_your_phone'.tr
                  ),
                  const SizedBox(height: 44),
                  AuthSubtitleWidget(
                    normalText: widget.isPasswordReset
                        ? 'Enter your registered phone number to reset password'
                        : 'please_enter_your'.tr,
                    highlightedText: widget.isPasswordReset ? '' : 'phone_number'.tr,
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
                    text: widget.isPasswordReset ? 'Send OTP' : 'enter'.tr,
                    onPressed: _isLoading ? null : _sendOTP,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}