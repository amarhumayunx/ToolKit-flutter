import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/buttons/gradient_btn.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/settings_widgets/auth_subtitle_widget.dart';
import '../../widgets/settings_widgets/auth_title_widget.dart';
import 'set_password_screen.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String email; // This can be email or phone number
  final bool isPhoneVerification; // Flag to differentiate between email and phone
  final bool isPasswordReset; // New flag for password reset flow

  const OtpVerifyScreen({
    super.key,
    required this.email,
    this.isPhoneVerification = false,
    this.isPasswordReset = false,
  });

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final List<TextEditingController> _controllers =
  List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  bool _isResendLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Move to next field when digit is entered
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else {
      // Handle backspace - move to previous field
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }

    // Auto-verify when all fields are filled
    if (_isOtpComplete()) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _verifyOtp();
      });
    }
  }

  String _getOtpCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  bool _isOtpComplete() {
    return _controllers.every((controller) => controller.text.isNotEmpty);
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isResendLoading = true;
    });

    try {
      // Clear all fields
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();

      // Simulate resending OTP (replace with actual implementation)
      await _simulateOTPResending();

      AppSnackBar.show(context, message: 'OTP resent to ${widget.email}');
    } catch (e) {
      AppSnackBar.show(context, message: 'Failed to resend OTP');
    } finally {
      if (mounted) {
        setState(() {
          _isResendLoading = false;
        });
      }
    }
  }

  Future<void> _simulateOTPResending() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    print('OTP resent to: ${widget.email}');
  }

  Future<void> _verifyOtp() async {
    if (!_isOtpComplete() || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String otpCode = _getOtpCode();

      // Here you would verify the OTP with your backend/service
      bool isOtpValid = await _verifyOtpWithService(otpCode);

      if (isOtpValid) {
        AppSnackBar.show(context, message: 'otp_verified_successfully'.tr);

        if (widget.isPasswordReset) {
          // Navigate to set password screen for password reset
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SetPasswordScreen(
                isRecovery: true, // Flag to indicate this is password recovery
              ),
            ),
          );

          if (result == true && mounted) {
            // Password reset successful, return to previous screens
            Navigator.of(context).pop(true);
          }
        } else {
          // Regular phone verification success
          Navigator.of(context).pop(true);
        }
      } else {
        AppSnackBar.show(context, message: 'Invalid OTP. Please try again.');
        _clearOtpFields();
      }
    } catch (e) {
      AppSnackBar.show(context, message: 'Error verifying OTP: ${e.toString()}');
      _clearOtpFields();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _verifyOtpWithService(String otp) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Here you would call your OTP verification service
    // For demo purposes, we'll accept '123456' as valid OTP
    // Replace this with actual OTP verification logic

    // Example with Firebase Auth:
    // try {
    //   PhoneAuthCredential credential = PhoneAuthProvider.credential(
    //     verificationId: _verificationId,
    //     smsCode: otp,
    //   );
    //   await FirebaseAuth.instance.signInWithCredential(credential);
    //   return true;
    // } catch (e) {
    //   return false;
    // }

    print('Verifying OTP: $otp for ${widget.email}');
    return otp == '123456' || otp.length == 6; // Demo validation
  }

  void _clearOtpFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  // Determine if the input is a phone number (starts with + and contains digits)
  bool get _isPhoneNumber {
    return widget.isPhoneVerification ||
        (widget.email.startsWith('+') && widget.email.contains(RegExp(r'\d')));
  }

  String get _screenTitle {
    if (widget.isPasswordReset) {
      return 'Reset Password';
    }
    return _isPhoneNumber ? 'verify_your_phone'.tr : 'verify_your_email'.tr;
  }

  String get _subtitleText {
    if (widget.isPasswordReset) {
      return 'Enter the verification code sent to your phone';
    }
    return _isPhoneNumber ? 'enter_code_sms'.tr : 'enter_code_email'.tr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: _screenTitle,
        onBackPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                AuthTitleWidget(title: _screenTitle),
                const SizedBox(height: 44),

                AuthSubtitleWidget(
                  normalText: _subtitleText,
                  highlightedText: widget.email,
                ),
                const SizedBox(height: 32),

                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFFFEF1E8),
                            blurRadius: 2,
                            spreadRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        cursorColor: AppColors.primary,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: AppColors.primary,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.only(bottom: 10),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          _onDigitChanged(value, index);
                          setState(() {});
                        },
                        onTap: () {
                          _controllers[index].selection = TextSelection.fromPosition(
                            TextPosition(offset: _controllers[index].text.length),
                          );
                        },
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),

                // Resend option
                Row(
                  children: [
                    Text(
                      "did_not_receive_code".tr,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                    GestureDetector(
                      onTap: _isResendLoading ? null : _resendOtp,
                      child: Text(
                        _isResendLoading ? 'Sending...' : 'resend'.tr,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _isResendLoading
                              ? Colors.grey
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Verify button
                CustomGradientButton(
                  text: 'verify'.tr,
                  onPressed: (_isOtpComplete() && !_isLoading) ? _verifyOtp : null,
                ),

                const SizedBox(height: 24),
              ],
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