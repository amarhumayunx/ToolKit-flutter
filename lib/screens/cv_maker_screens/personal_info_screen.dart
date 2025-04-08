import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/app_colors.dart';
import '../../widgets/buttons/gradient_btn.dart';
import '../../widgets/custom_text_field.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 4),
                blurRadius: 8,
                spreadRadius: 2, // This is the spread radius you're asking for
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              'Personal Information',
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Progress indicator
            Row(
              children: List.generate(7, (index) {
                // Steps (1, 2, 3, 4) are at even indices: 0, 2, 4, 6
                if (index.isEven) {
                  int stepNumber = (index ~/ 2) + 1;
                  return Container(
                    width: 27,
                    height: 27,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: stepNumber == 1
                          ? AppColors.primary
                          : AppColors.lineBarColor,
                    ),
                    child: Center(
                      child: Text(
                        '$stepNumber',
                        style: GoogleFonts.inter(
                          color: stepNumber == 1 ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                } else {
                  // Connectors between steps
                  return Expanded(
                    child: Container(
                      height: 9,
                      color: AppColors.lineBarColor,
                    ),
                  );
                }
              }),
            ),

            const SizedBox(height: 30),

            // Main container for all form fields
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.16),
                    blurRadius: 2,
                    offset: const Offset(0, 0),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Photo upload section
                    GestureDetector(
                      onTap: _pickImage,
                      child: _imageFile == null
                          ? Row(
                        children: [
                          // Empty photo upload container
                          Container(
                            width: 96,
                            height: 78,
                            decoration: BoxDecoration(
                              color: AppColors.bgBoxColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.add,
                                color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            'Click here to upload your photo',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      )
                          : Stack(
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
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    const CustomTextField(
                      label: 'Full Name',
                      hint: 'Your Name',
                    ),

                    const SizedBox(height: 16),

                    const CustomTextField(
                      label: 'Email',
                      hint: 'Your Mail',
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 16),

                    const CustomTextField(
                      label: 'Phone Number',
                      hint: 'Your Number',
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 16),

                    const CustomTextField(
                      label: 'Country',
                      hint: 'Your Country',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 50),

            // Add button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.gradientStart,
                      AppColors.gradientEnd, // End color
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CustomGradientButton(
                  text: 'Add',
                  onPressed: () {
                    // Your custom logic here
                  },
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}