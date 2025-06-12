import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:toolkit/screens/settings_screens/profile_screen.dart';
import 'package:toolkit/screens/settings_screens/phone_number_screen.dart'; // Add this import
import '../../provider/profile_provider.dart';
import '../../screens/settings_screens/continue_with_google_screen.dart';
import '../../services/auth_service.dart';

class SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final VoidCallback? onProfilePressed;

  const SettingsAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.onProfilePressed,
  });

  // Avatar list matching your profile screen
  final List<Map<String, String>> avatars = const [
    {"id": "1", "path": "assets/images/avatar/avatar_1.svg"},
    {"id": "2", "path": "assets/images/avatar/avatar_2.svg"},
    {"id": "3", "path": "assets/images/avatar/avatar_3.svg"},
    {"id": "4", "path": "assets/images/avatar/avatar_4.svg"},
    {"id": "5", "path": "assets/images/avatar/avatar_5.svg"},
    {"id": "6", "path": "assets/images/avatar/avatar_6.svg"},
  ];

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Consumer<ProfileProvider>(
          builder: (context, profileProvider, child) {
            // Get the current avatar or default to avatar 6
            final currentAvatarId = profileProvider.selectedAvatar ?? '6';
            final currentAvatar = avatars.firstWhere(
                  (avatar) => avatar["id"] == currentAvatarId,
              orElse: () => avatars.last, // This will be avatar 6
            );

            return GestureDetector(
              onTap: onProfilePressed ?? () => _handleProfileTap(context),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Container(
                    color: Colors.white,
                    child: SvgPicture.asset(
                      currentAvatar["path"]!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF5E56E7),
              Color(0xFF5E56E7),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }

  void _handleProfileTap(BuildContext context) async {
    try {
      final AuthService authService = AuthService();

      // Use authStateChanges stream to get real-time auth state
      final user = await authService.authStateChanges.first;
      final profileProvider =
      Provider.of<ProfileProvider>(context, listen: false);

      if (user != null) {
        // User is logged in, load fresh data and check phone number
        try {
          final userData = await authService.getUserData(user.uid);
          final hasPhoneNumber = await authService.hasPhoneNumber();

          if (userData != null) {
            // Update provider with fresh data from Firestore
            profileProvider.loadProfileData(
              avatar: userData.avatarId ?? '6',
              username: userData.displayName,
              email: userData.email,
              gender: userData.gender,
              dateOfBirth: userData.dateOfBirth,
              phoneNumber: userData.phoneNumber,
            );
          } else {
            // Fallback to user auth data if Firestore data is missing
            profileProvider.loadProfileData(
              avatar: profileProvider.selectedAvatar ?? '6',
              username: user.displayName ?? 'Not set',
              email: user.email ?? 'Not set',
              gender: 'Not set',
              dateOfBirth: 'Not set',
            );
          }

          // Check if user has phone number before navigating
          if (hasPhoneNumber) {
            // User has phone number, navigate to profile screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileScreen(),
              ),
            );
          } else {
            // User doesn't have phone number, navigate to phone number screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PhoneNumberScreen(),
              ),
            );
          }
        } catch (e) {
          print('Error loading user data: $e');
          // If there's an error loading data, navigate to sign-in screen
          _navigateToSignIn(context, profileProvider);
        }
      } else {
        // User is not logged in, clear profile data and navigate to Google sign-in
        _navigateToSignIn(context, profileProvider);
      }
    } catch (e) {
      print('Error in profile tap: $e');
      // Navigate to sign-in screen on any error
      final profileProvider =
      Provider.of<ProfileProvider>(context, listen: false);
      _navigateToSignIn(context, profileProvider);
    }
  }

  void _navigateToSignIn(
      BuildContext context, ProfileProvider profileProvider) {
    // Clear any existing profile data
    profileProvider.loadProfileData(
      avatar: '6',
      username: 'Not set',
      email: 'Not set',
      gender: 'Not set',
      dateOfBirth: 'Not set',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ContinueWithGoogleScreen(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}