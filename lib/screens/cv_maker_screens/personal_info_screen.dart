import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/user_provider.dart';
import '../../widgets/cv_widgets/personal_info_form.dart';
import '../../widgets/cv_widgets/personal_info_img_picker.dart';

class PersonalInfoPage extends StatefulWidget {
  final int templateId;
  final String templateName;

  const PersonalInfoPage({
    Key? key,
    required this.templateId,
    required this.templateName,
  }) : super(key: key);

  @override
  PersonalInfoPageState createState() => PersonalInfoPageState();
}

class PersonalInfoPageState extends State<PersonalInfoPage> {
  File? _imageFile;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _nameError;
  String? _designationError; // Added designation error state
  String? _emailError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserData());
  }

  void _loadUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userData = userProvider.userData;

    if (userData.fullName?.isNotEmpty ?? false) {
      _nameController.text = userData.fullName!;
    }
    if (userData.designation?.isNotEmpty ?? false) {
      _designationController.text = userData.designation!;
    }
    if (userData.email?.isNotEmpty ?? false) {
      _emailController.text = userData.email!;
    }
    if (userData.phoneNumber?.isNotEmpty ?? false) {
      _phoneController.text = userData.phoneNumber!;
    }

    if (userData.profileImagePath != null) {
      final file = File(userData.profileImagePath!);
      if (file.existsSync()) {
        setState(() => _imageFile = file);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool validate() {
    bool isValid = true;

    if (_nameController.text.isEmpty) {
      setState(() => _nameError = 'Please enter your name');
      isValid = false;
    }

    // Added designation validation
    if (_designationController.text.isEmpty) {
      setState(() => _designationError = 'Please enter your designation');
      isValid = false;
    } else if (!_isValidDesignation(_designationController.text)) {
      setState(() => _designationError = 'Please enter a valid designation');
      isValid = false;
    }

    if (_emailController.text.isEmpty) {
      setState(() => _emailError = 'Please enter your email');
      isValid = false;
    } else if (!_isValidEmail(_emailController.text)) {
      setState(() => _emailError = 'Please enter a valid email');
      isValid = false;
    }

    if (_phoneController.text.isEmpty) {
      setState(() => _phoneError = 'Please enter your phone number');
      isValid = false;
    } else if (!_isValidPhone(_phoneController.text)) {
      setState(() => _phoneError = 'Please enter a valid phone number');
      isValid = false;
    }

    return isValid;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    return phoneRegex.hasMatch(phone);
  }

  // Added designation validation method
  bool _isValidDesignation(String designation) {
    final designationRegex = RegExp(r'^[a-zA-Z0-9\s\-]{2,}$');
    return designationRegex.hasMatch(designation);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            PersonalInfoImagePicker(
              imageFile: _imageFile,
              onImagePicked: (file) {
                setState(() => _imageFile = file);
                Provider.of<UserProvider>(context, listen: false)
                    .updateUserData(profileImagePath: file.path);
              },
            ),
            if (_imageFile == null) const SizedBox(height: 20),
            if (_imageFile == null || _imageFile != null)const SizedBox(height: 20),
            PersonalInfoForm(
              nameController: _nameController,
              designationController: _designationController,
              emailController: _emailController,
              phoneController: _phoneController,
              nameError: _nameError,
              designationError: _designationError, // Added designation error
              emailError: _emailError,
              phoneError: _phoneError,
              onNameErrorChanged: (error) => setState(() => _nameError = error),
              onDesignationErrorChanged: (error) => setState(() => _designationError = error), // Added handler
              onEmailErrorChanged: (error) => setState(() => _emailError = error),
              onPhoneErrorChanged: (error) => setState(() => _phoneError = error),
            ),
          ],
        ),
      ),
    );
  }
}