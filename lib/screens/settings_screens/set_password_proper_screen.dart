import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/password_validator.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/password_strength_indicator.dart';
import '../../widgets/ads/banner_ad_widget.dart';
import '../../config/ad_config.dart';

class SetPasswordProperScreen extends StatefulWidget {
  final bool isChanging;
  final bool isRecovery;
  final String? email;
  final String? userId;

  const SetPasswordProperScreen({
    super.key,
    this.isChanging = false,
    this.isRecovery = false,
    this.email,
    this.userId,
  });

  @override
  State<SetPasswordProperScreen> createState() => _SetPasswordProperScreenState();
}

class _SetPasswordProperScreenState extends State<SetPasswordProperScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _oldPasswordFocusNode = FocusNode();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isOldPasswordVisible = false;
  bool _isLoading = false;
  bool _isEnteringOldPassword = false;
  
  PasswordStrength _passwordStrength = PasswordStrength.weak;
  PasswordValidationResult? _passwordValidation;
  
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    if (widget.isChanging && !widget.isRecovery) {
      _isEnteringOldPassword = true;
    }
    
    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _oldPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _oldPasswordFocusNode.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    if (_isEnteringOldPassword) return;
    
    final password = _passwordController.text;
    if (password.isNotEmpty) {
      final validation = PasswordValidator.validatePassword(password);
      setState(() {
        _passwordValidation = validation;
        _passwordStrength = validation.strength;
      });
    } else {
      setState(() {
        _passwordValidation = null;
        _passwordStrength = PasswordStrength.weak;
      });
    }
  }

  Future<void> _setPassword() async {
    // Validate password
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    
    if (password.isEmpty) {
      AppSnackBar.show(context, message: 'Please enter a password');
      return;
    }
    
    // Validate password strength
    final validation = PasswordValidator.validatePassword(password);
    if (!validation.isValid) {
      AppSnackBar.show(
        context,
        message: validation.errorMessage,
      );
      return;
    }
    
    // Check if password is too weak
    if (validation.strength == PasswordStrength.weak) {
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Weak Password',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Your password is weak and may be easily guessed. '
            'We recommend using a stronger password for better security.\n\n'
            'Do you want to continue with this password?',
            style: GoogleFonts.inter(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Continue Anyway',
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
      
      if (shouldContinue != true) {
        return;
      }
    }
    
    // Check password match
    if (password != confirmPassword) {
      AppSnackBar.show(
        context,
        message: 'passwords_do_not_match'.tr,
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    try {
      bool success;
      if (widget.isRecovery && widget.userId != null) {
        success = await _authService.resetPasswordForUser(widget.userId!, password);
      } else if (widget.isChanging && !widget.isRecovery) {
        success = await _authService.changePassword(_oldPasswordController.text, password);
      } else {
        success = await _authService.savePassword(password);
      }

      if (success) {
        AppSnackBar.show(
          context,
          message: widget.isChanging ? 'Password changed successfully' : 'Password set successfully',
        );
        Navigator.of(context).pop(true);
      } else {
        AppSnackBar.show(context, message: 'password_set_failed'.tr);
      }
    } catch (e) {
      AppSnackBar.show(context, message: '${'error'.tr}: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyOldPassword() async {
    final oldPassword = _oldPasswordController.text;
    if (oldPassword.isEmpty) {
      AppSnackBar.show(context, message: 'Please enter your current password');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    try {
      final isValid = await _authService.verifyPassword(oldPassword);
      if (isValid) {
        setState(() {
          _isEnteringOldPassword = false;
          _isLoading = false;
        });
      } else {
        AppSnackBar.show(
          context,
          message: 'incorrect_password'.tr,
        );
        setState(() {
          _oldPasswordController.clear();
          _isLoading = false;
        });
      }
    } catch (e) {
      AppSnackBar.show(
        context,
        message: 'password_verification_error'.tr,
      );
      setState(() {
        _oldPasswordController.clear();
        _isLoading = false;
      });
    }
  }

  String _getTitle() {
    if (_isEnteringOldPassword) {
      return 'enter_current_password'.tr;
    } else if (widget.isRecovery) {
      return 'set_new_password'.tr;
    } else if (widget.isChanging) {
      return 'set_new_password'.tr;
    } else {
      return 'set_password'.tr;
    }
  }

  String _getSubtitle() {
    if (_isEnteringOldPassword) {
      return 'Enter your current password to continue';
    } else {
      return 'Create a strong password to secure your files';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title: widget.isRecovery
            ? 'reset_password'.tr
            : widget.isChanging
                ? 'change_password'.tr
                : 'set_password'.tr,
        onBackPressed: () {
          Navigator.of(context).pop();
        },
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  _getTitle(),
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getSubtitle(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Old Password Field (if changing password)
                if (_isEnteringOldPassword) ...[
                  _buildPasswordField(
                    controller: _oldPasswordController,
                    focusNode: _oldPasswordFocusNode,
                    label: 'Current Password',
                    isVisible: _isOldPasswordVisible,
                    onVisibilityToggle: () {
                      setState(() {
                        _isOldPasswordVisible = !_isOldPasswordVisible;
                      });
                    },
                    onSubmitted: (_) => _verifyOldPassword(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyOldPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Continue',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ] else ...[
                  // New Password Field
                  _buildPasswordField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    label: 'New Password',
                    isVisible: _isPasswordVisible,
                    onVisibilityToggle: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    onSubmitted: (_) {
                      _confirmPasswordFocusNode.requestFocus();
                    },
                  ),
                  
                  // Password Strength Indicator
                  if (_passwordController.text.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    PasswordStrengthIndicator(
                      password: _passwordController.text,
                      strength: _passwordStrength,
                    ),
                    const SizedBox(height: 12),
                    PasswordRequirementsChecklist(
                      password: _passwordController.text,
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Confirm Password Field
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocusNode,
                    label: 'Confirm Password',
                    isVisible: _isConfirmPasswordVisible,
                    onVisibilityToggle: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                    onSubmitted: (_) => _setPassword(),
                  ),
                  
                  // Password Match Indicator
                  if (_confirmPasswordController.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _passwordController.text == _confirmPasswordController.text
                              ? Icons.check_circle
                              : Icons.error_outline,
                          color: _passwordController.text == _confirmPasswordController.text
                              ? Colors.green
                              : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _passwordController.text == _confirmPasswordController.text
                              ? 'Passwords match'
                              : 'Passwords do not match',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: _passwordController.text == _confirmPasswordController.text
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Set Password Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _setPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              widget.isChanging ? 'Change Password' : 'Set Password',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 100), // Add bottom padding for ad
              ],
            ),
          ),
          // Banner ad at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BannerAdWidget(
              adUnitId: AdConfig.bannerAdSetPasswordProperScreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    required Function(String) onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: !isVisible,
          onSubmitted: onSubmitted,
          inputFormatters: [
            // Allow alphanumeric and special characters
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9!@#$%^&*(),.?":{}|<>]')),
          ],
          decoration: InputDecoration(
            hintText: 'Enter password',
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[600],
              ),
              onPressed: onVisibilityToggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: GoogleFonts.inter(
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
