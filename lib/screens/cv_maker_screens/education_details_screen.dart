import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/education_item_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/buttons/gradient_btn.dart';
import '../../widgets/buttons/save_edit_delete_btns.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/cv_progress_indicator.dart';

class EducationDetailScreen extends StatefulWidget {
  final int currentStep;
  final bool isCompleted;

  const EducationDetailScreen({
    super.key,
    this.currentStep = 4,
    this.isCompleted = false,
  });

  @override
  State<EducationDetailScreen> createState() => _EducationDetailScreenState();
}

class _EducationDetailScreenState extends State<EducationDetailScreen> {
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _instituteController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool isCompleted = false;
  bool hasEducation = false;
  bool showForm = false;
  List<EducationItem> educationItems = [];

  @override
  void dispose() {
    _degreeController.dispose();
    _instituteController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      // Format date as MM/YYYY
      setState(() {
        controller.text =
            "${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _saveEducation() {
    if (_degreeController.text.isEmpty || _instituteController.text.isEmpty) {
      // Show validation message if needed
      return;
    }

    setState(() {
      educationItems.add(
        EducationItem(
          degree: _degreeController.text,
          institute: _instituteController.text,
          startDate: _startDateController.text,
          endDate: isCompleted ? '' : _endDateController.text,
          description: _descriptionController.text,
          isCompleted: isCompleted,
        ),
      );

      hasEducation = true;
      showForm = false;

      // Clear form fields
      _degreeController.clear();
      _instituteController.clear();
      _startDateController.clear();
      _endDateController.clear();
      _descriptionController.clear();
      isCompleted = false;
    });
  }

  void _editEducation(int index) {
    final item = educationItems[index];

    setState(() {
      _degreeController.text = item.degree;
      _instituteController.text = item.institute;
      _startDateController.text = item.startDate;
      _endDateController.text = item.endDate;
      _descriptionController.text = item.description;
      isCompleted = item.isCompleted;
      showForm = true;

      // Remove the item from the list
      educationItems.removeAt(index);
    });
  }

  void _deleteEducation(int index) {
    setState(() {
      educationItems.removeAt(index);
      if (educationItems.isEmpty) {
        hasEducation = false;
      }
    });
  }

  void _toggleForm() {
    setState(() {
      showForm = !showForm;

      // Clear form fields when showing the form
      if (showForm) {
        _degreeController.clear();
        _instituteController.clear();
        _startDateController.clear();
        _endDateController.clear();
        _descriptionController.clear();
        isCompleted = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Education Detail',
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
                    const SizedBox(height: 10),

                    // Progress indicator
                    CVProgressIndicator(currentStep: widget.currentStep),

                    const SizedBox(height: 30),

                    // Form is shown only when showForm is true
                    if (showForm) _buildEducationForm(),

                    // Display saved education items only when form is not shown
                    if (hasEducation && !showForm) ...[
                      for (int i = 0; i < educationItems.length; i++)
                        _buildSavedEducation(educationItems[i], i),
                      const SizedBox(height: 16),
                    ],

                    // Add another education button (only shown when form is not visible)
                    if (hasEducation && !showForm)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Container(
                            height: 48,
                            width: 278,
                            decoration: BoxDecoration(
                              color: AppColors.bgBoxColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextButton.icon(
                              onPressed: _toggleForm,
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: Colors.black,
                                size: 16,
                              ),
                              label: Text(
                                'Add another Education',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Show form by default if no education items yet and form is not already shown
                    if (!hasEducation && !showForm) _buildEducationForm(),
                  ],
                ),
              ),
            ),
          ),

          // Fixed position footer with Next button
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
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,

                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CustomGradientButton(
                  text: 'Add',
                  onPressed: () {
                    if (showForm) {
                      if (_degreeController.text.isNotEmpty ||
                          _instituteController.text.isNotEmpty) {
                        _saveEducation();
                      }
                    } else if (hasEducation) {
                      // Navigate to the Work Experience screen (next step)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WorkExperienceScreen(),
                        ),
                      );
                    } else {
                      // Show the form if there are no education items yet
                      setState(() {
                        showForm = true;
                      });
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedEducation(EducationItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Educational Detail ${index + 1}',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.degree,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  item.isCompleted
                      ? item.startDate
                      : "${item.startDate} - ${item.endDate}",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Text(
              item.institute,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (item.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                item.description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 10),
            const Divider(
              height: 9,
              thickness: 1,
              color: Color(0xFFE0E0E0),
            ),
            const SizedBox(height: 8),
            // Replace with EditDeleteActionRow
            EditDeleteActionRow(
              onEdit: () => _editEducation(index),
              onDelete: () => _deleteEducation(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationForm() {
    return Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Degree and Courses
            CustomTextField(
              label: 'Degree and Courses',
              hint: 'Enter your education',
              controller: _degreeController,
            ),
            const SizedBox(height: 16),

            // Institute
            CustomTextField(
              label: 'Institute',
              hint: 'Enter your institute',
              controller: _instituteController,
            ),
            const SizedBox(height: 16),

            // Dates row
            Row(
              children: [
                // Start date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start date',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectDate(context, _startDateController),
                        child: Container(
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
                            controller: _startDateController,
                            enabled: false,
                            decoration: InputDecoration(
                              hintText: 'MM/YYYY',
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
                              suffixIcon:
                                  const Icon(Icons.calendar_today, size: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // End date - only show if not completed
                if (!isCompleted)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End Date',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _selectDate(context, _endDateController),
                          child: Container(
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
                              controller: _endDateController,
                              enabled: false,
                              decoration: InputDecoration(
                                hintText: 'MM/YYYY',
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
                                suffixIcon:
                                    const Icon(Icons.calendar_today, size: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Add a placeholder widget when completed is checked
                if (isCompleted) const Expanded(child: SizedBox()),
              ],
            ),
            const SizedBox(height: 16),

            // Completed checkbox
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: isCompleted,
                    activeColor: AppColors.gradientStart,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (value) {
                      setState(() {
                        isCompleted = value ?? false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Completed',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Description',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '( Optional )',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 120,
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
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Anything',
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
            ),
            const SizedBox(height: 20),
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFE0E0E0),
            ),
            const SizedBox(height: 20),

            // Replace with SaveButton
            SaveButton(
              onPressed: _saveEducation,
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for the next screen in the sequence
class WorkExperienceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Work Experience')),
      body: Center(child: Text('Work Experience Screen')),
    );
  }
}
