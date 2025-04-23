import 'package:flutter/material.dart';
import '../models/user_model_1.dart';
import '../models/website_model.dart';

class UserProvider extends ChangeNotifier {
  final UserModel _userData = UserModel();
  List<Website> _websites = [];

  UserModel get userData => _userData;
  List<Website> get websites => _websites;

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

  void updateCareerObjective(String objective) {
    _userData.careerObjective = objective;
    notifyListeners();
  }

  // Update method to store multiple websites
  void updateWebsite(String? url) {
    _userData.websiteUrl = url; // Keep for backward compatibility
    notifyListeners();
  }

  // Add a new method to handle multiple websites
  void updateWebsites(List<Website> websites) {
    _websites = websites;
    // Also update the single websiteUrl for backward compatibility
    _userData.websiteUrl = websites.isNotEmpty ? websites[0].url : null;
    notifyListeners();
  }

  void clearUserData() {
    _userData.fullName = null;
    _userData.designation = null;
    _userData.email = null;
    _userData.phoneNumber = null;
    _userData.careerObjective = null;
    _userData.websiteUrl = null;
    _websites = [];
    notifyListeners();
  }
}