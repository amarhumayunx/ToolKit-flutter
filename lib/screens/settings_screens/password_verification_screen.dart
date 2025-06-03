import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_snackbar.dart';
import '../../widgets/buttons/gradient_btn.dart';
import '../../widgets/custom_appbar.dart';

class PasswordVerificationScreen extends StatefulWidget {
  final Widget destinationScreen;
  final String title;

  const PasswordVerificationScreen({
    super.key,
    required this.destinationScreen,
    this.title = 'Enter Password',
  });

  @override
  State<PasswordVerificationScreen> createState() => _PasswordVerificationScreenState();
}

class _PasswordVerificationScreenState extends State<PasswordVerificationScreen> {
  String _enteredPassword = '';
  String? _savedPassword;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPassword();
  }

  // Load saved password from SharedPreferences
  void _loadSavedPassword() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _savedPassword = prefs.getString('user_password');
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading saved password: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onNumberPressed(String number) {
    setState(() {
      if (_enteredPassword.length < 4) {
        _enteredPassword += number;
      }
    });
  }

  void _onDeletePressed() {
    setState(() {
      if (_enteredPassword.isNotEmpty) {
        _enteredPassword = _enteredPassword.substring(0, _enteredPassword.length - 1);
      }
    });
  }

  void _onVerifyPassword() {
    if (_enteredPassword.length == 4) {
      // Verify against saved password from SharedPreferences
      if (_savedPassword != null && _enteredPassword == _savedPassword) {
        // Password is correct, navigate to destination screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => widget.destinationScreen),
        );
      } else {
        // Incorrect password
        AppSnackBar.show(context, message: 'Incorrect password!');
        setState(() {
          _enteredPassword = '';
        });
      }
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: CustomAppBar(
          title: widget.title,
          onBackPressed: () {
            Navigator.of(context).pop();
          },
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title: widget.title,
        onBackPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 60),

            // Title
            Text(
              'Enter your 4-Digit Code',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),

            const SizedBox(height: 120),

            // Password dots
            _buildPasswordDots(_enteredPassword),

            const SizedBox(height: 30),

            // Number pad
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
                    const SizedBox(width: 70, height: 70),
                    _buildNumberButton('0'),
                    _buildDeleteButton(),
                  ],
                ),
              ],
            ),

            const Spacer(),

            // Verify button - shows when 4 digits are entered
            if (_enteredPassword.length == 4)
              CustomGradientButton(
                text: 'Verify Password',
                onPressed: _onVerifyPassword,
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}