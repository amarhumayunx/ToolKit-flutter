import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import 'cv_maker_screen.dart';

class CreateCvScreen extends StatelessWidget {
  const CreateCvScreen({super.key});

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
                    MaterialPageRoute(builder: (context) => const CvMakerScreen()),
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
              )
,

              const SizedBox(height: 30),

              // Previously Created Resumes Container - Updated to match Figma design
              Container(
                width: double.infinity,
                height: 270,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 22),
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
                    // Previously Created Resumes Title - Now inside the container
                    Text(
                      'Previously created Resume',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Resume previews row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildResumePreview('23/02/25 | 6:05pm | 3.4 MB'),
                        _buildResumePreview('23/02/25 | 6:05pm | 3.4 MB'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResumePreview(String details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Resume document preview
        Container(
          width: 130,
          height: 162,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/resume_preview.png',
              width: 130,
              height: 162,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Resume document mock content
                      const SizedBox(height: 10),
                      Container(
                          width: 120, height: 1, color: Colors.grey.shade300),
                      const SizedBox(height: 3),
                      Container(
                          width: 120, height: 1, color: Colors.grey.shade300),
                      const SizedBox(height: 3),
                      Container(
                          width: 120, height: 1, color: Colors.grey.shade300),
                      const SizedBox(height: 3),
                      Container(
                          width: 120, height: 1, color: Colors.grey.shade300),
                      const SizedBox(height: 8),

                      Container(
                          width: 120, height: 1, color: Colors.grey.shade300),
                      const SizedBox(height: 3),
                      Container(
                          width: 120, height: 1, color: Colors.grey.shade300),
                      const SizedBox(height: 3),
                      Container(
                          width: 120, height: 1, color: Colors.grey.shade300),
                      const SizedBox(height: 8),

                      Container(
                          width: 120, height: 1, color: Colors.grey.shade300),
                      const SizedBox(height: 3),
                      Container(
                          width: 120, height: 1, color: Colors.grey.shade300),
                      const SizedBox(height: 3),
                      Container(
                          width: 120, height: 1, color: Colors.grey.shade300),
                      const SizedBox(height: 3),
                      Container(
                          width: 120, height: 1, color: Colors.grey.shade300),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Date and size details
        Text(
          details,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
