import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_colors.dart';
import '../../widgets/buttons/gradient_btn.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/cv_progress_indicator.dart';

class JobScreen extends StatefulWidget {
  final int currentStep;
  final bool isCompleted;

  const JobScreen({
    super.key,
    this.currentStep = 2,
    this.isCompleted = false,
  });

  @override
  State<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends State<JobScreen> {
  final List<String> stepTitles = [
    'Personal Information',
    'Job',
    'Career Objectives',
    'Education Detail',
    'Work Experience',
    'Projects',
    'Certification and Training',
    'Hobbies and Interests',
    'Languages',
    'Website and Social Links',
  ];

  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _jobSummaryController = TextEditingController();

  bool hasJobDetail = false;
  String savedJobTitle = '';
  String savedJobSummary = '';

  @override
  void dispose() {
    _jobTitleController.dispose();
    _jobSummaryController.dispose();
    super.dispose();
  }

  void _saveJob() {
    if (_jobTitleController.text.isEmpty || _jobSummaryController.text.isEmpty) {
      // Show some validation message if needed
      return;
    }

    setState(() {
      savedJobTitle = _jobTitleController.text;
      savedJobSummary = _jobSummaryController.text;
      hasJobDetail = true;

      // Clear form fields
      _jobTitleController.clear();
      _jobSummaryController.clear();
    });
  }

  void _editJob() {
    setState(() {
      _jobTitleController.text = savedJobTitle;
      _jobSummaryController.text = savedJobSummary;
      hasJobDetail = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Job Details',
        onBackPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),

                    // Use the reusable CVProgressIndicator widget
                    CVProgressIndicator(currentStep: widget.currentStep),

                    const SizedBox(height: 30),

                    // Show job form or saved job detail
                    hasJobDetail
                        ? _buildSavedJobDetail()
                        : _buildJobForm(),
                  ],
                ),
              ),
            ),
          ),

          // Fixed position footer with Add button
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.gradientStart,
                      AppColors.gradientEnd,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CustomGradientButton(
                  text: 'Add',
                  onPressed: () {
                    if (!hasJobDetail) {
                      // If no job saved, save current one
                      _saveJob();
                    }

                    // Navigate to the Career Objectives screen (next step)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobScreen(
                          currentStep: 3, // Move to step 3 (Career Objectives)
                          isCompleted: false,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedJobDetail() {
    return Container(
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Job Detail 1',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

            ],
          ),
          const SizedBox(height: 8),
          Text(
            savedJobSummary,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildJobForm() {
    return Container(
      height: 422,
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
            CustomTextField(
              label: 'Job Title',
              hint: 'Your Job Title',
              controller: _jobTitleController,
            ),
            const SizedBox(height: 16),

            // Job summary field with expanded height
            _buildJobSummaryField(),
            const SizedBox(height: 20),
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFE0E0E0),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 88,
                height: 36,
                child: ElevatedButton(
                  onPressed: _saveJob,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE5F4F9),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom job summary field with larger height
  Widget _buildJobSummaryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Job Summary',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 192,
          decoration: BoxDecoration(
            color: AppColors.bgBoxColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: _jobSummaryController,
            maxLines: 5, // Increase the number of lines
            decoration: InputDecoration(
              hintText: 'Type your job summary',
              hintStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: Colors.grey,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}