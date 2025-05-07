import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/education_item_model.dart';
import '../../provider/education_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/buttons/add_another_button.dart';
import '../../widgets/buttons/save_edit_delete_btns.dart';
import '../../widgets/custom_text_field.dart';

import '../../widgets/date_picker_field.dart';

class EducationDetailPage extends StatefulWidget {
  const EducationDetailPage({
    super.key,
  });

  @override
  State<EducationDetailPage> createState() => _EducationDetailPageState();
}

class _EducationDetailPageState extends State<EducationDetailPage> {
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _instituteController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool isCompleted = false;
  bool showForm = false;
  int? editingIndex;
  DateTime? startDate;
  DateTime? endDate;
  String? dateError;

  @override
  void dispose() {
    _degreeController.dispose();
    _instituteController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context, TextEditingController controller,
      bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? DateTime.now() : (startDate ?? DateTime.now()),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      if (isStartDate) {
        startDate = picked;
        // If end date exists and is before new start date, clear it
        if (endDate != null && endDate!.isBefore(picked)) {
          endDate = null;
          _endDateController.clear();
          setState(() {
            dateError = null;
          });
        }
      } else {
        endDate = picked;
        // Validate that end date is after start date
        if (startDate != null && picked.isBefore(startDate!)) {
          setState(() {
            dateError = 'End date must be after start date';
          });
          return;
        } else {
          setState(() {
            dateError = null;
          });
        }
      }

      // Format date as DD/MM/YY to match the UI design
      setState(() {
        controller.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year.toString().substring(2)}";
      });
    }
  }

  void _saveEducation() {
    // Validate end date is after start date if both exist
    if (!isCompleted &&
        startDate != null &&
        endDate != null &&
        endDate!.isBefore(startDate!)) {
      setState(() {
        dateError = 'End date must be after start date';
      });
      return;
    }

    final educationProvider =
        Provider.of<EducationProvider>(context, listen: false);
    final newEducation = EducationItem(
      degree: _degreeController.text,
      institute: _instituteController.text,
      startDate: _startDateController.text,
      endDate: isCompleted ? '' : _endDateController.text,
      description: _descriptionController.text,
      isCompleted: isCompleted,
    );

    if (editingIndex != null) {
      educationProvider.updateEducationItem(editingIndex!, newEducation);
    } else {
      educationProvider.addEducationItem(newEducation);
    }

    _clearForm();
  }

  void _editEducation(int index) {
    final educationProvider =
        Provider.of<EducationProvider>(context, listen: false);
    final item = educationProvider.educationItems[index];

    // Parse the dates when editing
    final startDateParts = item.startDate.split('/');
    if (startDateParts.length == 3) {
      startDate = DateTime(
        int.parse('20${startDateParts[2]}'), // Assuming 20XX format for years
        int.parse(startDateParts[1]),
        int.parse(startDateParts[0]),
      );
    }

    if (item.endDate.isNotEmpty) {
      final endDateParts = item.endDate.split('/');
      if (endDateParts.length == 3) {
        endDate = DateTime(
          int.parse('20${endDateParts[2]}'), // Assuming 20XX format for years
          int.parse(endDateParts[1]),
          int.parse(endDateParts[0]),
        );
      }
    }

    setState(() {
      _degreeController.text = item.degree;
      _instituteController.text = item.institute;
      _startDateController.text = item.startDate;
      _endDateController.text = item.endDate;
      _descriptionController.text = item.description;
      isCompleted = item.isCompleted;
      showForm = true;
      editingIndex = index;
      dateError = null;
    });
  }

  void _deleteEducation(int index) {
    final educationProvider =
        Provider.of<EducationProvider>(context, listen: false);
    educationProvider.deleteEducationItem(index);
  }

  void _toggleForm() {
    setState(() {
      showForm = true;
      editingIndex = null;
      _clearFormFields();
    });
  }

  void _clearForm() {
    setState(() {
      _clearFormFields();
      isCompleted = false;
      editingIndex = null;
      showForm = false;
    });
  }

  void _clearFormFields() {
    _degreeController.clear();
    _instituteController.clear();
    _startDateController.clear();
    _endDateController.clear();
    _descriptionController.clear();
    isCompleted = false;
    startDate = null;
    endDate = null;
    dateError = null;
  }

  @override
  Widget build(BuildContext context) {
    final educationProvider = Provider.of<EducationProvider>(context);
    final educationItems = educationProvider.educationItems;
    final hasEducation = educationItems.isNotEmpty;
    final canAddMoreEducation =
        educationItems.length < 2; // Only allow up to 2 education entries

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Show form when showForm is true OR when there are no education items yet
                  if (showForm || !hasEducation) _buildEducationForm(),

                  // If form is shown, we don't display the saved items
                  if (!showForm && hasEducation) ...[
                    // Display saved education items when there are items and form is not showing
                    for (int i = 0; i < educationItems.length; i++)
                      _buildSavedEducation(educationItems[i], i),
                    const SizedBox(height: 16),

                    // Add another education button (only shown when there are existing items AND form is hidden AND we haven't reached the limit)
                    if (canAddMoreEducation)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: AddAnotherButton(
                          text: 'Add another Education',
                          onPressed: _toggleForm,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSavedEducation(EducationItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: AppColors.white,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.degree,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  item.isCompleted
                      ? item.startDate + " - Present"
                      : item.startDate + " - " + item.endDate,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.saveDateColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(
              height: 9,
              thickness: 1,
              color: AppColors.dividerColor,
            ),
            const SizedBox(height: 8),
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
        color: AppColors.white,
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
        padding: const EdgeInsets.all(14.0),
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
                  child: DateField(
                    label: 'Start date',
                    controller: _startDateController,
                    onTap: () =>
                        _selectDate(context, _startDateController, true),
                  ),
                ),
                const SizedBox(width: 20),
                // End date - only show if not completed
                if (!isCompleted)
                  Expanded(
                    child: DateField(
                      label: 'End Date',
                      controller: _endDateController,
                      onTap: () =>
                          _selectDate(context, _endDateController, false),
                      errorText: dateError,
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
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: const BorderSide(
                      color: AppColors.fieldHintColor,
                    ),
                    onChanged: (value) {
                      setState(() {
                        isCompleted = value ?? false;
                        if (isCompleted) {
                          // Clear end date when marking as completed
                          _endDateController.clear();
                          endDate = null;
                          dateError = null;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Continued',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.fieldHintColor),
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
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '( Optional )',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.fieldHintColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 100,
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
                    maxLength: 100,
                    decoration: InputDecoration(
                      hintText: 'e.g cgpa/grade',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: AppColors.fieldHintColor,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      counterText: '',
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
              color: AppColors.dividerColor,
            ),
            const SizedBox(height: 20),

            SaveButton(
              onPressed: _saveEducation,
            ),
          ],
        ),
      ),
    );
  }
}
