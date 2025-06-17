import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../provider/profile_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_snackbar.dart';
import 'profile_screen.dart';
import 'phone_number_screen.dart';

class ContinueWithGoogleScreen extends StatefulWidget {
  const ContinueWithGoogleScreen({super.key});

  @override
  State<ContinueWithGoogleScreen> createState() =>
      _ContinueWithGoogleScreenState();
}

class _ContinueWithGoogleScreenState extends State<ContinueWithGoogleScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Check if user is already logged in when screen opens
    _checkExistingLogin();
  }

  Future<void> _checkExistingLogin() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        // User is already logged in, load data and check if phone number exists
        final profileProvider =
            Provider.of<ProfileProvider>(context, listen: false);
        final userData = await _authService.getUserData(user.uid);
        final hasPhoneNumber = await _authService.hasPhoneNumber();

        if (userData != null) {
          profileProvider.loadProfileData(
            email: userData.email,
            username: userData.displayName,
            gender: userData.gender,
            dateOfBirth: userData.dateOfBirth,
            avatar: userData.avatarId,
            phoneNumber: userData.phoneNumber,
          );
        } else {
          profileProvider.loadProfileData(
            email: user.email,
            username: user.displayName,
            gender: 'Not set',
            dateOfBirth: 'Not set',
            avatar: '1',
          );
        }

        if (mounted) {
          if (hasPhoneNumber) {
            // User has phone number, go directly to profile
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          } else {
            // User doesn't have phone number, go to phone number screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PhoneNumberScreen(),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error checking existing login: $e');
      // Continue with normal flow if error occurs
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.3),
              AppColors.primary,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Text(
                  ' Smart Tools.\nOne Tap Away',
                  style: GoogleFonts.inter(
                    fontSize: 48,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const Spacer(flex: 3),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: _isLoading ? null : _handleGoogleSignIn,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isLoading)
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                              ),
                            )
                          else
                            SvgPicture.asset(
                              'assets/icons/google_icon.svg',
                              width: 24,
                              height: 24,
                            ),
                          const SizedBox(width: 12),
                          Text(
                            _isLoading
                                ? 'Signing in...'
                                : 'Continue with Google',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  child: Text(
                    'Skip for now',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(_isLoading ? 0.4 : 0.8),
                      decoration: TextDecoration.underline,
                      decorationColor:
                          Colors.white.withOpacity(_isLoading ? 0.4 : 0.8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential != null && userCredential.user != null) {
        final profileProvider =
            Provider.of<ProfileProvider>(context, listen: false);

        // Load user data from Firestore
        final userModel =
            await _authService.getUserData(userCredential.user!.uid);
        final hasPhoneNumber = await _authService.hasPhoneNumber();

        if (userModel != null) {
          // Load all profile data including phone number
          profileProvider.loadProfileData(
            email: userModel.email,
            username: userModel.displayName,
            gender: userModel.gender,
            dateOfBirth: userModel.dateOfBirth,
            avatar: userModel.avatarId,
            phoneNumber: userModel.phoneNumber,
          );
        } else {
          // If user data doesn't exist, load with default values
          profileProvider.loadProfileData(
            email: userCredential.user!.email,
            username: userCredential.user!.displayName,
            gender: 'Not set',
            dateOfBirth: 'Not set',
            avatar: '1',
          );
        }

        if (mounted) {
          if (hasPhoneNumber) {
            // User already has phone number, go directly to profile
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          } else {
            // User doesn't have phone number, go to phone number screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PhoneNumberScreen(),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context,
            message: 'Failed to sign in with Google. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
