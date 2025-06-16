import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toolkit/screens/settings_screens/set_password_screen.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/buttons/gradient_btn.dart';
import '../../widgets/custom_appbar.dart';

class PhoneRecoveryScreen extends StatefulWidget {
  const PhoneRecoveryScreen({Key? key}) : super(key: key);

  @override
  State<PhoneRecoveryScreen> createState() => _PhoneRecoveryScreenState();
}

class _PhoneRecoveryScreenState extends State<PhoneRecoveryScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
  List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
  List.generate(6, (index) => FocusNode());

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isOtpSent = false;
  String? _foundUserId;
  String _countryCode = '+92';

  @override
  void dispose() {
    _phoneController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_phoneController.text.trim().isEmpty) {
      AppSnackBar.show(context, message: 'Please enter your phone number');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final fullPhoneNumber = '$_countryCode${_phoneController.text.trim()}';
      final userId = await _authService.findUserByPhoneNumber(fullPhoneNumber);

      if (userId == null) {
        AppSnackBar.show(context,
            message: 'No account found with this phone number');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      _foundUserId = userId;
      final success = await _authService.sendOTP(fullPhoneNumber);

      if (success) {
        setState(() {
          _isOtpSent = true;
          _isLoading = false;
        });
        AppSnackBar.show(context, message: 'OTP sent to your phone number');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      String errorMessage = 'Failed to send OTP';
      switch (e.code) {
        case 'invalid-phone-number':
          errorMessage = 'Invalid phone number format';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many requests. Please try again later';
          break;
        case 'app-not-authorized':
          errorMessage = 'App not authorized for phone verification';
          break;
        default:
          errorMessage = e.message ?? 'Failed to send OTP';
      }

      AppSnackBar.show(context, message: errorMessage);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      AppSnackBar.show(context,
          message: 'An error occurred. Please try again.');
    }
  }

// In your PhoneRecoveryScreen, replace the _verifyOtp method:

  Future<void> _verifyOtp() async {
    String otpCode = _otpControllers.map((controller) => controller.text).join();

    if (otpCode.length != 6) {
      AppSnackBar.show(context, message: 'Please enter all 6 digits');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // This now returns the user ID instead of just true/false
      final userId = await _authService.verifyOTPForPasswordReset(otpCode);

      if (userId != null) {
        // Clear OTP fields
        for (var controller in _otpControllers) {
          controller.clear();
        }

        // Navigate to SetPasswordScreen for password reset, passing the userId
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SetPasswordScreen(
              isRecovery: true,
              email: null,
              userId: userId, // Pass the user ID
            ),
          ),
        );

        // If password was successfully reset, pop back
        if (result == true) {
          Navigator.of(context).pop(true);
        }
      } else {
        AppSnackBar.show(context, message: 'Failed to verify OTP');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Invalid OTP';
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'The verification code entered is invalid';
          break;
        case 'session-expired':
          errorMessage = 'The verification session has expired. Please request a new OTP';
          break;
        default:
          errorMessage = e.message ?? 'Failed to verify OTP';
      }

      AppSnackBar.show(context, message: errorMessage);
    } catch (e) {
      AppSnackBar.show(context, message: 'An error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final fullPhoneNumber = '$_countryCode${_phoneController.text.trim()}';
      final success =
      await _authService.sendOTP(fullPhoneNumber, isResend: true);

      if (success) {
        AppSnackBar.show(context, message: 'OTP resent successfully');
      }
    } catch (e) {
      AppSnackBar.show(context, message: 'Failed to resend OTP');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: !_isOtpSent ? 'Phone verify' : 'Otp Verify',
        onBackPressed: () {
          Navigator.of(context).pop(false);
        },
      ),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isOtpSent) _buildPhoneVerifySection(),
                    if (_isOtpSent) _buildOtpVerifySection(),
                  ],
                ),
              ),
            ),

            // Bottom Button Container
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: _buildBottomButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    if (_isLoading) {
      return Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    String buttonText = 'Continue';
    VoidCallback? onPressed = _sendOtp;

    if (_isOtpSent) {
      buttonText = 'Verify';
      onPressed = _verifyOtp;
    }

    return CustomGradientButton(
      text: buttonText,
      onPressed: onPressed,
    );
  }

  Widget _buildPhoneVerifySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter your\nPhone number',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 40),
        Text(
          'Please enter your phone number to\ncontinue',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B6B6B),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 40),
        Text(
          'Enter mobile no.*',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF1A1A1A),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        // Phone Number Input
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 8,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Row(
            children: [
              // Country Code Dropdown
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _countryCode,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF6B6B6B),
                      size: 20,
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: const Color(0xFFE0E0E0),
              ),
              // Phone Number Input
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  cursorColor: AppColors.primary,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  decoration: InputDecoration(
                    hintText: '01774',
                    hintStyle: GoogleFonts.inter(
                      color: const Color(0xFFA0A0A0),
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 60),
      ],
    );
  }

  Widget _buildOtpVerifySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verify your\nPhone number',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A1A),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 40),
        RichText(
          text: TextSpan(
            text: 'Enter the code from the sms we sent\nto ',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF6B6B6B),
              height: 1.4,
            ),
            children: [
              TextSpan(
                text:
                '$_countryCode${_phoneController.text.length > 5 ? '${_phoneController.text.substring(0, 5)}***' : _phoneController.text.trim()}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // OTP Input Fields
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _otpControllers[index].text.isNotEmpty
                      ? AppColors.gradientStart
                      : const Color(0xFFE0E0E0),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                keyboardType: TextInputType.number,
                cursorColor: AppColors.primary,
                textAlign: TextAlign.center,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                ),
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
                onChanged: (value) => _onOtpChanged(value, index),
              ),
            );
          }),
        ),

        const SizedBox(height: 30),

        // Resend Section
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Didn't receive any code? ",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF6B6B6B),
                ),
              ),
              GestureDetector(
                onTap: _isLoading ? null : _resendOtp,
                child: Text(
                  'RESEND',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _isLoading ? Colors.grey : AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 60),
      ],
    );
  }
}