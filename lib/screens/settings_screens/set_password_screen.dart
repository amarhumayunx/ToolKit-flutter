import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/buttons/gradient_btn.dart';
import '../../widgets/custom_appbar.dart';

class SetPasswordScreen extends StatefulWidget {
  final bool isChangingPassword; // New parameter to determine if changing password

  const SetPasswordScreen({
    super.key,
    this.isChangingPassword = false,
  });

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  String _previousPassword = '';
  String _password = '';
  String _confirmPassword = '';
  bool _isPreviousPasswordStep = false;
  bool _isConfirming = false;
  bool _isPasswordSet = false;
  String? _savedPassword;

  @override
  void initState() {
    super.initState();
    // If changing password, start with previous password verification
    _isPreviousPasswordStep = widget.isChangingPassword;
    if (widget.isChangingPassword) {
      _loadSavedPassword();
    }
  }

  // Load saved password from SharedPreferences
  void _loadSavedPassword() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _savedPassword = prefs.getString('user_password');
    } catch (e) {
      print('Error loading saved password: $e');
    }
  }

  // Save password to SharedPreferences
  Future<void> _savePassword(String password) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_password', password);
      await prefs.setBool('is_password_set', true);
    } catch (e) {
      print('Error saving password: $e');
    }
  }

  void _onNumberPressed(String number) {
    setState(() {
      if (_isPreviousPasswordStep) {
        // Handle previous password input
        if (_previousPassword.length < 4) {
          _previousPassword += number;
        }
      } else if (!_isConfirming) {
        // Handle new password input
        if (_password.length < 4) {
          _password += number;
          // Automatically move to confirmation when 4 digits are entered
          if (_password.length == 4) {
            _isConfirming = true;
          }
        }
      } else {
        // Handle password confirmation
        if (_confirmPassword.length < 4) {
          _confirmPassword += number;
        }
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      if (_isPreviousPasswordStep) {
        if (_previousPassword.isNotEmpty) {
          _previousPassword = _previousPassword.substring(0, _previousPassword.length - 1);
        }
      } else if (!_isConfirming) {
        if (_password.isNotEmpty) {
          _password = _password.substring(0, _password.length - 1);
        }
      } else {
        if (_confirmPassword.isNotEmpty) {
          _confirmPassword = _confirmPassword.substring(0, _confirmPassword.length - 1);
        }
      }
    });
  }

  void _onVerifyPreviousPassword() {
    if (_previousPassword.length == 4) {
      // Verify against saved password from SharedPreferences
      if (_savedPassword != null && _previousPassword == _savedPassword) {
        setState(() {
          _isPreviousPasswordStep = false;
        });
        AppSnackBar.show(context, message: 'Previous password verified!');
      } else {
        AppSnackBar.show(context, message: 'Incorrect previous password!');
        setState(() {
          _previousPassword = '';
        });
      }
    }
  }

  void _onConfirmPressed() {
    if (_password.length == 4) {
      setState(() {
        _isConfirming = true;
      });
    }
  }

  void _onSetPasswordPressed() async {
    if (_password == _confirmPassword && _confirmPassword.length == 4) {
      // Save the new password to SharedPreferences
      await _savePassword(_password);

      setState(() {
        _isPasswordSet = true;
      });

      String successMessage = widget.isChangingPassword
          ? 'Password changed successfully!'
          : 'Password set successfully!';

      AppSnackBar.show(context, message: successMessage);

      // Return true to indicate password was set successfully
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(context).pop(true);
      });
    } else {
      // Handle password mismatch
      AppSnackBar.show(context, message: 'Passwords do not match!');
      setState(() {
        _confirmPassword = '';
      });
    }
  }

  void _resetFlow() {
    setState(() {
      _previousPassword = '';
      _password = '';
      _confirmPassword = '';
      _isPreviousPasswordStep = widget.isChangingPassword;
      _isConfirming = false;
      _isPasswordSet = false;
    });
  }

  String _getCurrentTitle() {
    if (_isPreviousPasswordStep) {
      return 'Enter Previous Password';
    } else if (_isConfirming) {
      return 'Confirm your 4-Digit Code';
    } else {
      return widget.isChangingPassword
          ? 'Enter New 4-Digit Code'
          : 'Set your 4-Digit Code';
    }
  }

  String _getCurrentPassword() {
    if (_isPreviousPasswordStep) {
      return _previousPassword;
    } else if (_isConfirming) {
      return _confirmPassword;
    } else {
      return _password;
    }
  }

  Widget _buildPasswordDots(String password) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < password.length
                ? AppColors.primary
                : AppColors.t3SubHeading.withOpacity(0.3),
          ),
        );
      }),
    );
  }

  Widget _buildNumberButton(String number) {
    return GestureDetector(
      onTap: () => _onNumberPressed(number),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            number,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: _onDeletePressed,
      child: SizedBox(
        width: 70,
        height: 70,
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/password_delete_icon.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              AppColors.primary,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  Widget _getCurrentActionButton() {
    if (_isPreviousPasswordStep && _previousPassword.length == 4) {
      return CustomGradientButton(
        text: 'Verify Password',
        onPressed: _onVerifyPreviousPassword,
      );
    } else if (_isConfirming && _confirmPassword.length == 4) {
      return CustomGradientButton(
        text: widget.isChangingPassword ? 'Change Password' : 'Set Password',
        onPressed: _onSetPasswordPressed,
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title: widget.isChangingPassword ? 'Change Password' : 'Set Password',
        onBackPressed: () {
          Navigator.of(context).pop(false);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 60),

            // Title
            Text(
              _getCurrentTitle(),
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),

            const SizedBox(height: 120),

            // Password dots
            _buildPasswordDots(_getCurrentPassword()),

            const SizedBox(height: 30),

            // Number pad with updated layout
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNumberButton('1'),
                    _buildNumberButton('2'),
                    _buildNumberButton('3'),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNumberButton('4'),
                    _buildNumberButton('5'),
                    _buildNumberButton('6'),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNumberButton('7'),
                    _buildNumberButton('8'),
                    _buildNumberButton('9'),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Empty space to maintain alignment
                    const SizedBox(width: 70, height: 70),
                    _buildNumberButton('0'), // 0 now appears under 8
                    _buildDeleteButton(), // Delete button now appears under 9
                  ],
                ),
              ],
            ),

            const Spacer(),

            // Action button - dynamically shows based on current step
            _getCurrentActionButton(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}