import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/education_item_model.dart';
import '../../provider/education_provider.dart';
import '../../widgets/buttons/add_another_button.dart';
import '../../widgets/cv_widgets/education_form_widget.dart';
import '../../widgets/cv_widgets/saved_education_item.dart';

class EducationDetailPage extends StatefulWidget {
  const EducationDetailPage({super.key});

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

  void _selectDate(BuildContext context, TextEditingController controller, bool isStartDate) async {
    FocusScope.of(context).unfocus();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? DateTime.now() : (startDate ?? DateTime.now()),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      if (isStartDate) {
        startDate = picked;
        if (endDate != null && endDate!.isBefore(picked)) {
          endDate = null;
          _endDateController.clear();
          setState(() {
            dateError = null;
          });
        }
      } else {
        endDate = picked;
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

      setState(() {
        controller.text =
        "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year.toString().substring(2)}";
      });
    }
  }

  void _saveEducation() {
    if (!isCompleted &&
        startDate != null &&
        endDate != null &&
        endDate!.isBefore(startDate!)) {
      setState(() {
        dateError = 'End date must be after start date';
      });
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

    _clearForm();
  }

  void _editEducation(int index) {
    final educationProvider = Provider.of<EducationProvider>(context, listen: false);
    final item = educationProvider.educationItems[index];

    final startDateParts = item.startDate.split('/');
    if (startDateParts.length == 3) {
      startDate = DateTime(
        int.parse('20${startDateParts[2]}'),
        int.parse(startDateParts[1]),
        int.parse(startDateParts[0]),
      );
    }

    if (item.endDate.isNotEmpty) {
      final endDateParts = item.endDate.split('/');
      if (endDateParts.length == 3) {
        endDate = DateTime(
          int.parse('20${endDateParts[2]}'),
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
    final educationProvider = Provider.of<EducationProvider>(context, listen: false);
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
    final canAddMoreEducation = educationItems.length < 2;

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
                  if (showForm || !hasEducation)
                    EducationFormWidget(
                      degreeController: _degreeController,
                      instituteController: _instituteController,
                      startDateController: _startDateController,
                      endDateController: _endDateController,
                      descriptionController: _descriptionController,
                      isCompleted: isCompleted,
                      dateError: dateError,
                      onCompletedChanged: (value) {
                        setState(() {
                          isCompleted = value;
                          if (isCompleted) {
                            _endDateController.clear();
                            endDate = null;
                            dateError = null;
                          }
                        });
                      },
                      onDateSelected: _selectDate,
                      onSavePressed: _saveEducation,
                    ),
                  if (!showForm && hasEducation) ...[
                    for (int i = 0; i < educationItems.length; i++)
                      SavedEducationItemWidget(
                        item: educationItems[i],
                        index: i,
                        onEdit: _editEducation,
                        onDelete: _deleteEducation,
                      ),
                    const SizedBox(height: 16),
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
}