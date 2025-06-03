import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../utils/app_colors.dart';
import '../../widgets/buttons/save_edit_delete_btns.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/cv_widgets/custom_divider.dart';

import '../date_picker_field.dart';

class EducationFormWidget extends StatefulWidget {
  final TextEditingController degreeController;
  final TextEditingController instituteController;
  final TextEditingController startDateController;
  final TextEditingController endDateController;
  final TextEditingController descriptionController;
  final bool isCompleted;
  final String? dateError;
  final FocusNode degreeFocus;
  final FocusNode instituteFocus;
  final FocusNode startDateFocus;
  final FocusNode endDateFocus;
  final FocusNode descriptionFocus;
  final Function(bool) onCompletedChanged;
  final Function(BuildContext, TextEditingController, bool) onDateSelected;
  final VoidCallback onSavePressed;

  const EducationFormWidget({
    super.key,
    required this.degreeController,
    required this.instituteController,
    required this.startDateController,
    required this.endDateController,
    required this.descriptionController,
    required this.isCompleted,
    required this.dateError,
    required this.degreeFocus,
    required this.instituteFocus,
    required this.startDateFocus,
    required this.endDateFocus,
    required this.descriptionFocus,
    required this.onCompletedChanged,
    required this.onDateSelected,
    required this.onSavePressed,
  });

  @override
  State<EducationFormWidget> createState() => _EducationFormWidgetState();
}

class _EducationFormWidgetState extends State<EducationFormWidget> {
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary, // Purple header
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate = DateFormat('dd/MM/yy').format(picked);
      controller.text = formattedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              controller: widget.degreeController,
              focusNode: widget.degreeFocus,
              nextFocus: widget.instituteFocus,
            ),
            const SizedBox(height: 16),

            // Institute
            CustomTextField(
              label: 'Institute',
              hint: 'Enter your institute',
              controller: widget.instituteController,
              focusNode: widget.instituteFocus,
              nextFocus: widget.startDateFocus,
            ),
            const SizedBox(height: 16),

            // Dates row
            Row(
              children: [
                // Start date
                Expanded(
                  child: DateField(
                    label: 'Start date',
                    controller: widget.startDateController,
                    focusNode: widget.startDateFocus,
                    onTap: () => _selectDate(context, widget.startDateController),
                  ),
                ),
                const SizedBox(width: 20),
                // End date - only show if not completed
                if (!widget.isCompleted)
                  Expanded(
                    child: DateField(
                      label: 'End Date',
                      controller: widget.endDateController,
                      focusNode: widget.endDateFocus,
                      onTap: () => _selectDate(context, widget.endDateController),
                      errorText: widget.dateError,
                    ),
                  ),
                if (widget.isCompleted) const Expanded(child: SizedBox()),
              ],
            ),

            // Completed checkbox
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: widget.isCompleted,
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: const BorderSide(
                      color: AppColors.fieldHintColor,
                    ),
                    onChanged: (value) {
                      widget.onCompletedChanged(value ?? false);
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Continued',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.fieldHintColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            _buildDescriptionField(),
            const SizedBox(height: 20),
            const CustomDivider(),
            const SizedBox(height: 20),
            SaveButton(
              onPressed: widget.onSavePressed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Column(
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
            controller: widget.descriptionController,
            focusNode: widget.descriptionFocus,
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }
}