import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../provider/user_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_text_field.dart';

class PersonalInfoPage extends StatefulWidget {
  final int templateId;
  final String templateName;

  const PersonalInfoPage({
    Key? key,
    required this.templateId,
    required this.templateName,
  }) : super(key: key);

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  File? _imageFile;

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userData = userProvider.userData;

    // Only set text if there's data to prevent nulls
    if (userData.fullName != null && userData.fullName!.isNotEmpty) {
      _nameController.text = userData.fullName!;
    }
    if (userData.designation != null && userData.designation!.isNotEmpty) {
      _designationController.text = userData.designation!;
    }
    if (userData.email != null && userData.email!.isNotEmpty) {
      _emailController.text = userData.email!;
    }
    if (userData.phoneNumber != null && userData.phoneNumber!.isNotEmpty) {
      _phoneController.text = userData.phoneNumber!;
    }

    if (userData.profileImagePath != null) {
      final file = File(userData.profileImagePath!);
      if (file.existsSync()) {
        setState(() {
          _imageFile = file;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen for changes in the user provider that might require UI updates
    final userData = Provider.of<UserProvider>(context).userData;

    // Clear text fields if user data is cleared
    if (userData.fullName == null && _nameController.text.isNotEmpty) {
      _clearFields();
    }
  }

  void _clearFields() {
    setState(() {
      _nameController.clear();
      _designationController.clear();
      _emailController.clear();
      _phoneController.clear();
      _imageFile = null;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // Update provider with new image path
      Provider.of<UserProvider>(context, listen: false)
          .updateUserData(profileImagePath: pickedFile.path);
    }
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

            // Combined container when image is uploaded, separate containers when no image
            _imageFile == null
                ? Column(
              children: [
                // Image container (only shown when no image)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.16),
                        blurRadius: 3,
                        offset: const Offset(0, 0),
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Row(
                          children: [
                            // Empty photo upload container
                            Container(
                              width: 96,
                              height: 78,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.16),
                                    blurRadius: 2,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                                color: AppColors.bgBoxColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.add,
                                  color: AppColors.primary, size: 22),
                            ),
                            const SizedBox(width: 26),
                            Text(
                              'Click here to upload your photo',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Form fields container
                _buildFormFieldsContainer(),
              ],
            )
                : // Single combined container when image exists
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.16),
                    blurRadius: 3,
                    offset: const Offset(0, 0),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Image section
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            // Profile image
                            Container(
                              width: 98,
                              height: 98,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: FileImage(_imageFile!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Edit icon overlay
                            Positioned(
                              bottom: 6,
                              right: 8,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/icons/edit_profile_icon.svg',
                                    width: 10,
                                    height: 10,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Form fields
                    ..._buildFormFields(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFieldsContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 3,
            offset: const Offset(0, 0),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: _buildFormFields(),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      CustomTextField(
        label: 'Full Name',
        hint: 'Your Name',
        controller: _nameController,
        onChanged: (value) {
          Provider.of<UserProvider>(context, listen: false)
              .updateUserData(fullName: value);
        },
      ),
      const SizedBox(height: 16),
      CustomTextField(
        label: 'Designation',
        hint: 'Your Designation',
        controller: _designationController,
        onChanged: (value) {
          Provider.of<UserProvider>(context, listen: false)
              .updateUserData(designation: value);
        },
      ),
      const SizedBox(height: 16),
      CustomTextField(
        label: 'Email',
        hint: 'Your Mail',
        keyboardType: TextInputType.emailAddress,
        controller: _emailController,
        onChanged: (value) {
          Provider.of<UserProvider>(context, listen: false)
              .updateUserData(email: value);
        },
      ),
      const SizedBox(height: 16),
      CustomTextField(
        label: 'Phone Number',
        hint: 'Your Number',
        keyboardType: TextInputType.phone,
        controller: _phoneController,
        onChanged: (value) {
          Provider.of<UserProvider>(context, listen: false)
              .updateUserData(phoneNumber: value);
        },
      ),
    ];
  }
}