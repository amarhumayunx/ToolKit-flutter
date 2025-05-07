import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';

import '../../models/saved_cv.dart';
import '../../provider/saved_cv_provider.dart';
import '../../utils/app_colors.dart';
import 'cv_maker_screen.dart';

class CreateCvScreen extends StatefulWidget {
  const CreateCvScreen({super.key});

  @override
  State<CreateCvScreen> createState() => _CreateCvScreenState();
}

class _CreateCvScreenState extends State<CreateCvScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back button and title
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 24,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'My Resume',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Create New Button with Navigation
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CvMakerScreen()),
                  );
                },
                child: Container(
                  height: 110,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.16),
                        blurRadius: 2,
                        offset: const Offset(0, 0),
                      )
                    ],
                    color: AppColors.bgBoxColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: AppColors.textColor,
                        size: 24,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Create New',
                        style: GoogleFonts.inter(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Previously Created Resumes Container
              Consumer<SavedCVProvider>(
                builder: (context, savedCVProvider, child) {
                  final savedCVs = savedCVProvider.savedCVs;

                  if (savedCVs.isEmpty) {
                    return Container(
                      width: double.infinity,
                      height: 270,

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Previously created Resume',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 80),
                          Center(
                            child: Text(
                              'No saved resumes yet',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Previously Created Resumes Title
                        Text(
                          'Previously created Resume',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Resume previews
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.5,
                          ),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: savedCVs.length > 2 ? const ScrollPhysics() : const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.7,
                            ),
                            itemCount: savedCVs.length,
                            itemBuilder: (context, index) {
                              return _buildResumePreview(
                                savedCVs[index],
                                onTap: () => _openCvFile(savedCVs[index].filePath),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResumePreview(SavedCV cv, {required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Resume document preview
          Container(
            width: 130,
            height: 162,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.dividerColor),

            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: cv.thumbnailBytes != null
                  ? ClipRRect(

                child: Image.memory(
                  cv.thumbnailBytes!,
                  width: 130,
                  height: 162,
                  fit: BoxFit.cover,
                ),
              )
                  : Container(),
            ), // Empty container when no thumbnail
          ),
          const SizedBox(height: 8),
          // Date and size details
          Text(
            '${cv.dateTime} | ${cv.fileSize}',
            style: GoogleFonts.inter(
              fontSize: 8,
              color: Color(0xFFAAAAAE),
            ),
          ),
        ],
      ),
    );
  }

  void _openCvFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await OpenFile.open(filePath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: $e')),
      );
    }
  }
}