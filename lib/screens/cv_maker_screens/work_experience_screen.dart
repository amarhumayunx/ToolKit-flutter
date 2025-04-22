import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/work_experience_model.dart';
import '../../provider/work_experience_provider.dart';

import '../../utils/app_colors.dart';
import '../../widgets/buttons/add_another_button.dart';
import '../../widgets/buttons/save_edit_delete_btns.dart';
import '../../widgets/custom_text_field.dart';

class WorkExperiencePage extends StatefulWidget {
  const WorkExperiencePage({
    super.key,
  });

  @override
  State<WorkExperiencePage> createState() => _WorkExperiencePageState();
}

class _WorkExperiencePageState extends State<WorkExperiencePage> {
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _projectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool isCurrent = false;
  bool showForm = false;
  List<String> projectsList = [];

  @override
  void dispose() {
    _positionController.dispose();
    _companyController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _projectController.dispose();
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

  void _addProject() {
    if (_projectController.text.isEmpty) return;

    setState(() {
      projectsList.add(_projectController.text);
      _projectController.clear();
    });
  }

  void _removeProject(int index) {
    setState(() {
      projectsList.removeAt(index);
    });
  }

  void _saveWorkExperience(BuildContext context) {
    if (_positionController.text.isEmpty || _companyController.text.isEmpty) {
      return;
    }

    final provider =
        Provider.of<WorkExperienceProvider>(context, listen: false);

    provider.addWorkExperience(
      WorkExperienceItem(
        position: _positionController.text,
        company: _companyController.text,
        startDate: _startDateController.text,
        endDate: isCurrent ? 'Present' : _endDateController.text,
        projects: projectsList,
        description: _descriptionController.text,
        isCurrent: isCurrent,
      ),
    );

    setState(() {
      showForm = false;
      _positionController.clear();
      _companyController.clear();
      _startDateController.clear();
      _endDateController.clear();
      _projectController.clear();
      _descriptionController.clear();
      projectsList = [];
      isCurrent = false;
    });
  }

  void _editWorkExperience(BuildContext context, int index) {
    final provider =
        Provider.of<WorkExperienceProvider>(context, listen: false);
    final item = provider.workExperienceItems[index];

    setState(() {
      _positionController.text = item.position;
      _companyController.text = item.company;
      _startDateController.text = item.startDate;
      _endDateController.text = item.isCurrent ? '' : item.endDate;
      projectsList = List.from(item.projects);
      _descriptionController.text = item.description;
      isCurrent = item.isCurrent;
      showForm = true;
    });

    provider.deleteWorkExperience(index);
  }

  void _deleteWorkExperience(BuildContext context, int index) {
    final provider =
        Provider.of<WorkExperienceProvider>(context, listen: false);
    provider.deleteWorkExperience(index);
  }

  void _toggleForm() {
    setState(() {
      showForm = !showForm;

      if (showForm) {
        _positionController.clear();
        _companyController.clear();
        _startDateController.clear();
        _endDateController.clear();
        _projectController.clear();
        _descriptionController.clear();
        projectsList = [];
        isCurrent = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkExperienceProvider>(
      builder: (context, provider, child) {
        final workExperienceItems = provider.workExperienceItems;
        final hasExperience = workExperienceItems.isNotEmpty;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 26,right: 26,bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // Form is shown only when showForm is true
                      if (showForm) _buildWorkExperienceForm(context),

                      // Display saved work experience items only when form is not shown
                      if (hasExperience && !showForm) ...[
                        for (int i = 0; i < workExperienceItems.length; i++)
                          _buildSavedWorkExperience(
                              context, workExperienceItems[i], i),
                        const SizedBox(height: 16),
                      ],

                      // Add another work experience button (only shown when form is not visible)
                      if (hasExperience && !showForm)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: AddAnotherButton(
                            text: 'Add another Experience',
                            onPressed: _toggleForm,
                          ),
                        ),

                      // Show form by default if no work experience items yet and form is not already shown
                      if (!hasExperience && !showForm)
                        _buildWorkExperienceForm(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSavedWorkExperience(
      BuildContext context, WorkExperienceItem item, int index) {
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
            // Position
            Text(
              item.position,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.black
              ),
            ),
            const SizedBox(height: 4),

            // Date information
            Text(
              item.isCurrent
                  ? "${item.startDate} - Present"
                  : "${item.startDate} - ${item.endDate}",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.saveDateColor,
              ),
            ),


            const SizedBox(height: 10),
            const Divider(
              height: 9,
              thickness: 1,
              color: AppColors.dividerColor,
            ),
            const SizedBox(height: 8),

            // Edit/Delete buttons
            EditDeleteActionRow(
              onEdit: () => _editWorkExperience(context, index),
              onDelete: () => _deleteWorkExperience(context, index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkExperienceForm(BuildContext context) {
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Position
            CustomTextField(
              label: 'Position',
              hint: 'Enter your position',
              controller: _positionController,
            ),
            const SizedBox(height: 16),

            // Company
            CustomTextField(
              label: 'Company Name',
              hint: 'Enter your company',
              controller: _companyController,
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
                // End date - only show if not current job
                if (!isCurrent)
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
                // Add a placeholder widget when 'Current' is checked
                if (isCurrent) const Expanded(child: SizedBox()),
              ],
            ),
            const SizedBox(height: 16),

            // Current job checkbox
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: isCurrent,
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: const BorderSide(
                      color: AppColors.fieldHintColor, // Outline color
                    ),
                    onChanged: (value) {
                      setState(() {
                        isCurrent = value ?? false;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Current',
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.fieldHintColor),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Projects - Multiple projects support
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Projects',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.black,
                      ),
                    ),

                  ],
                ),
                const SizedBox(height: 8),

                // Input field for adding a new project
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
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
                          controller: _projectController,
                          decoration: InputDecoration(
                            hintText: 'Add a project',
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
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _addProject,
                      child: Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.gradientStart,
                              AppColors.gradientEnd,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                // Display added projects
                if (projectsList.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: projectsList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            children: [
                              Text(
                                "• ",
                                style: GoogleFonts.urbanist(
                                  fontSize: 14,

                                  color: Color(0xFFB5B5B8),
                                ),
                              ),

                              Expanded(
                                child: Text(
                                  projectsList[index],
                                  style: GoogleFonts.urbanist(
                                    fontSize: 12,
                                    color: Color(0xFFB5B5B8),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _removeProject(index),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Color(0xFFC74A4A),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
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
                        fontWeight: FontWeight.w300,
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
                      hintText: 'Your responsibilities and achievements',
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
              onPressed: () => _saveWorkExperience(context),
            ),
          ],
        ),
      ),
    );
  }
}
