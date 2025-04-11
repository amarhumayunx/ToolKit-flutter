import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_colors.dart';
import '../../widgets/buttons/gradient_btn.dart';
import '../../widgets/buttons/save_edit_delete_btns.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/cv_progress_indicator.dart';

import 'education_details_screen.dart';

class CareerObjectivesScreen extends StatefulWidget {
  final int currentStep;
  final bool isCompleted;

  const CareerObjectivesScreen({
    super.key,
    this.currentStep = 3,
    this.isCompleted = false,
  });

  @override
  State<CareerObjectivesScreen> createState() => _CareerObjectivesScreenState();
}

class _CareerObjectivesScreenState extends State<CareerObjectivesScreen> {
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

  final TextEditingController _objectiveController = TextEditingController();

  bool hasObjective = false;
  String savedObjective = '';

  @override
  void dispose() {
    _objectiveController.dispose();
    super.dispose();
  }

  void _saveObjective() {
    if (_objectiveController.text.isEmpty) {
      // Show some validation message if needed
      return;
    }

    setState(() {
      savedObjective = _objectiveController.text;
      hasObjective = true;

      // Clear form field
      _objectiveController.clear();
    });
  }

  void _editObjective() {
    setState(() {
      _objectiveController.text = savedObjective;
      hasObjective = false;
    });
  }

  void _deleteObjective() {
    setState(() {
      // Clear saved career objective
      savedObjective = '';
      hasObjective = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Career Objectives',
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

                    // Show objective form or saved objective detail
                    hasObjective
                        ? _buildSavedObjective()
                        : _buildObjectiveForm(),
                  ],
                ),
              ),
            ),
          ),

          // Fixed position footer with Add button
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: CustomGradientButton(
              text: 'Add',
              onPressed: () {
                if (!hasObjective) {
                  // If no objective saved, save current one
                  _saveObjective();
                }

                // Navigate to the Education Detail screen (next step)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EducationDetailScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedObjective() {
    // Using the new SavedDetailContainer widget
    return SavedDetailContainer(
      title: 'Objective',
      content: savedObjective,
      onEdit: _editObjective,
      onDelete: _deleteObjective,
    );
  }

  Widget _buildObjectiveForm() {
    return Container(
      height: 431,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.30),
            blurRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Objective field with expanded height
            _buildObjectiveField(),
            const SizedBox(height: 32),
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFE0E0E0),
            ),
            const SizedBox(height: 20),

            // Using the new SaveButton widget
            SaveButton(onPressed: _saveObjective),
          ],
        ),
      ),
    );
  }

  // Custom objective field with larger height
  Widget _buildObjectiveField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Career Objective',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 282,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.30),
                blurRadius: 2,
                offset: const Offset(0, 0),
              ),
            ],
            color: AppColors.bgBoxColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: _objectiveController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Type your career objectives',
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
