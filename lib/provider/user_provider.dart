import 'package:flutter/material.dart';

import '../models/user_model_1.dart';

class UserProvider extends ChangeNotifier {
  // Remove the asterisks - this is not valid Dart syntax
  final UserModel _userData = UserModel();

  UserModel get userData => _userData;

  void updateUserData({
    String? fullName,
    String? designation,
    String? email,
    String? phoneNumber,
    String? profileImagePath,
    String? careerObjective,
    String? websiteUrl,
  }) {
    if (fullName != null) _userData.fullName = fullName;
    if (designation != null) _userData.designation = designation;
    if (email != null) _userData.email = email;
    if (phoneNumber != null) _userData.phoneNumber = phoneNumber;
    if (profileImagePath != null) _userData.profileImagePath = profileImagePath;
    if (careerObjective != null) _userData.careerObjective = careerObjective;
    if (websiteUrl != null) _userData.websiteUrl = websiteUrl;
    notifyListeners();
  }

  // Dedicated method for updating career objective
  void updateCareerObjective(String objective) {
    _userData.careerObjective = objective;
    notifyListeners();
  }

  // Update website information - use _userData consistently
  void updateWebsite(String? url) {
    _userData.websiteUrl = url;
    notifyListeners();
  }
  // Clear all user data fields
  void clearUserData() {
    _userData.fullName = null;
    _userData.designation = null;
    _userData.email = null;
    _userData.phoneNumber = null;
    _userData.careerObjective = null;
    _userData.websiteUrl = null;
    // Note: You might want to keep the profile image path or clear it as needed
    // _userData.profileImagePath = null;
    notifyListeners();
  }
}
