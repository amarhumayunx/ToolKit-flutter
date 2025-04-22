import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/education_item_model.dart';
import '../../provider/education_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/buttons/add_another_button.dart';
import '../../widgets/buttons/save_edit_delete_btns.dart';
import '../../widgets/custom_text_field.dart';

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

  @override
  void dispose() {
    _degreeController.dispose();
    _instituteController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      // Format date as DD/MM/YY to match the UI design
      setState(() {
        controller.text =
        "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year.toString().substring(2)}";
      });
    }
  }

  void _saveEducation() {
    if (_degreeController.text.isEmpty || _instituteController.text.isEmpty) {
      // Show validation message if needed
      return;
    }

    final educationProvider = Provider.of<EducationProvider>(context, listen: false);
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

    _clearForm();  // This already sets showForm to false
  }

  void _editEducation(int index) {
    final educationProvider = Provider.of<EducationProvider>(context, listen: false);
    final item = educationProvider.educationItems[index];

    setState(() {
      _degreeController.text = item.degree;
      _instituteController.text = item.institute;
      _startDateController.text = item.startDate;
      _endDateController.text = item.endDate;
      _descriptionController.text = item.description;
      isCompleted = item.isCompleted;
      showForm = true;
      editingIndex = index;
    });
  }

  void _deleteEducation(int index) {
    final educationProvider = Provider.of<EducationProvider>(context, listen: false);
    educationProvider.deleteEducationItem(index);
  }

  void _toggleForm() {
    setState(() {
      // Always set showForm to true when adding a new education
      showForm = true;
      // Reset editingIndex to indicate we're adding a new item, not editing
      editingIndex = null;
      // Clear form fields when opening form for new entry
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

  // New method to clear only form fields without changing other state variables
  void _clearFormFields() {
    _degreeController.clear();
    _instituteController.clear();
    _startDateController.clear();
    _endDateController.clear();
    _descriptionController.clear();
    isCompleted = false;
  }

  @override
  Widget build(BuildContext context) {
    final educationProvider = Provider.of<EducationProvider>(context);
    final educationItems = educationProvider.educationItems;
    final hasEducation = educationItems.isNotEmpty;

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
                  if (showForm || !hasEducation)
                    _buildEducationForm(),

                  // If form is shown, we don't display the saved items
                  if (!showForm && hasEducation) ...[
                    // Display saved education items when there are items and form is not showing
                    for (int i = 0; i < educationItems.length; i++)
                      _buildSavedEducation(educationItems[i], i),
                    const SizedBox(height: 16),

                    // Add another education button (only shown when there are existing items AND form is hidden)
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
                      color: AppColors.black
                  ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start date',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.black,
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
                              hintText: '00/00/00',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                color: AppColors.fieldHintColor,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
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
                            color: AppColors.black,
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
                                hintText: '00/00/00',
                                hintStyle: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                  color: AppColors.fieldHintColor,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
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
                      color: AppColors.fieldHintColor
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
                  height: 148,
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
                      hintText: 'e.g cgpa/grade',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: AppColors.fieldHintColor,
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