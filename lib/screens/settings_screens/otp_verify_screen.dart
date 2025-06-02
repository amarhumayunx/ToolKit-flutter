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

class OtpVerifyScreen extends StatefulWidget {
  final String email; // This can be email or phone number
  final bool isPhoneVerification; // Flag to differentiate between email and phone

  const OtpVerifyScreen({
    super.key,
    required this.email,
    this.isPhoneVerification = false,
  });

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final List<TextEditingController> _controllers =
  List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

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
  }

  String _getOtpCode() {
    return _controllers.map((controller) => controller.text).join();
  }

  bool _isOtpComplete() {
    return _controllers.every((controller) => controller.text.isNotEmpty);
  }

  void _resendOtp() {
    // Clear all fields
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();

    AppSnackBar.show(context, message: 'OTP resent to ${widget.email}');
  }

  // Determine if the input is a phone number (starts with + and contains digits)
  bool get _isPhoneNumber {
    return widget.isPhoneVerification ||
        (widget.email.startsWith('+') && widget.email.contains(RegExp(r'\d')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'otp_verify'.tr,
        onBackPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            AuthTitleWidget(
              title: _isPhoneNumber ? 'verify_your_phone'.tr : 'verify_your_email'.tr,
            ),
            const SizedBox(height: 44),

            AuthSubtitleWidget(
              normalText: _isPhoneNumber
                  ? 'enter_code_sms'.tr
                  : 'enter_code_email'.tr,
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
                      _controllers[index].selection =
                          TextSelection.fromPosition(
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
                  onTap: _resendOtp,
                  child: Text(
                    'resend'.tr,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            // Verify button
            CustomGradientButton(
              text: 'verify'.tr,
              onPressed: _isOtpComplete()
                  ? () {
                String otpCode = _getOtpCode();
                print('OTP entered: $otpCode');
                print('${_isPhoneNumber ? 'Phone' : 'Email'}: ${widget.email}');


                AppSnackBar.show(context, message: 'otp_verified_successfully'.tr);

              }
                  : null,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}