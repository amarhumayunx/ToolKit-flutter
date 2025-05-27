import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/certification_model.dart';
import '../../provider/certification_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/buttons/add_another_button.dart';
import '../../widgets/buttons/save_edit_delete_btns.dart';
import '../../widgets/custom_text_field.dart';

class CertificationPage extends StatefulWidget {
  final List<Map<String, dynamic>>? initialData;
  const CertificationPage({
    super.key,
    this.initialData,
  });

  @override
  State<CertificationPage> createState() => _CertificationPageState();
}

class _CertificationPageState extends State<CertificationPage> {
  final TextEditingController _certificationNameController =
      TextEditingController();
  final TextEditingController _organizationNameController =
      TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool hasCertification = false;
  bool showForm = false;
  int? editingIndex;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    if (widget.initialData != null && widget.initialData!.isNotEmpty) {
      final certProvider = Provider.of<CertificationProvider>(context, listen: false);

      // Clear any existing data
      certProvider.clearCertificationItems();

      // Load the initial data into the provider
      for (var item in widget.initialData!) {
        certProvider.addCertificationItem(
          CertificationItem(
            certificationName: item['certificationName'] ?? '',
            organizationName: item['organizationName'] ?? '',
            startDate: item['startDate'] ?? '',
            endDate: item['endDate'] ?? '',
            description: item['description'] ?? '',
            isCompleted: item['isCompleted'] ?? false,
          ),
        );
      }

      // Update the local state after loading data
      if (mounted) {
        setState(() {
          hasCertification = certProvider.certificationItems.isNotEmpty;
        });
      }
    }
  }

  @override
  void dispose() {
    _certificationNameController.dispose();
    _organizationNameController.dispose();
    _dateController.dispose();
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
      setState(() {
        // Format date as DD/MM/YYYY to include the day
        controller.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _saveCertification() {
    final certificationProvider =
        Provider.of<CertificationProvider>(context, listen: false);

    final newItem = CertificationItem(
      certificationName: _certificationNameController.text,
      organizationName: _organizationNameController.text,
      startDate: _dateController.text,
      endDate: "",
      // Empty string as we're removing end date
      isCompleted: false,
      description: _descriptionController.text,
    );

    if (editingIndex != null) {
      certificationProvider.updateCertificationItem(editingIndex!, newItem);
      editingIndex = null;
    } else {
      certificationProvider.addCertificationItem(newItem);
    }

    setState(() {
      hasCertification = true;
      showForm = false;

      // Clear form fields
      _certificationNameController.clear();
      _organizationNameController.clear();
      _dateController.clear();
      _descriptionController.clear();
    });
  }

  void _editCertification(int index) {
    final certificationProvider =
        Provider.of<CertificationProvider>(context, listen: false);
    final item = certificationProvider.certificationItems[index];

    setState(() {
      _certificationNameController.text = item.certificationName;
      _organizationNameController.text = item.organizationName;
      _dateController.text = item.startDate;
      _descriptionController.text = item.description;
      showForm = true;
      editingIndex = index;
    });
  }

  void _deleteCertification(int index) {
    final certificationProvider =
        Provider.of<CertificationProvider>(context, listen: false);
    certificationProvider.removeCertificationItem(index);

    setState(() {
      if (certificationProvider.certificationItems.isEmpty) {
        hasCertification = false;
      }
    });
  }

  void _toggleForm() {
    setState(() {
      showForm = !showForm;
      editingIndex = null;

      // Clear form fields when showing the form
      if (showForm) {
        _certificationNameController.clear();
        _organizationNameController.clear();
        _dateController.clear();
        _descriptionController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final certificationProvider = Provider.of<CertificationProvider>(context);
    final certificationItems = certificationProvider.certificationItems;

    // Update hasCertification based on provider
    hasCertification = certificationItems.isNotEmpty;

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

                  // Form is shown only when showForm is true
                  if (showForm) _buildCertificationForm(),

                  // Display saved certification items only when form is not shown
                  if (hasCertification && !showForm) ...[
                    for (int i = 0; i < certificationItems.length; i++)
                      _buildSavedCertification(certificationItems[i], i),
                    const SizedBox(height: 16),
                  ],

                  // Add another certification button (only shown when form is not visible)
                  if (hasCertification && !showForm)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: AddAnotherButton(
                        text: 'Add another certificate',
                        onPressed: _toggleForm,
                      ),
                    ),

                  // Show form by default if no certification items yet and form is not already shown
                  if (!hasCertification && !showForm) _buildCertificationForm(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSavedCertification(CertificationItem item, int index) {
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Add this line
              children: [
                Text(
                  item.certificationName,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  item.startDate,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.saveDateColor),
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
              onEdit: () => _editCertification(index),
              onDelete: () => _deleteCertification(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificationForm() {
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
            // Certification Name
            CustomTextField(
              label: 'Certification Name',
              hint: 'Enter certification name',
              controller: _certificationNameController,
            ),
            const SizedBox(height: 16),

            // Organization Name
            CustomTextField(
              label: 'Organization Name',
              hint: 'Enter organization name',
              controller: _organizationNameController,
            ),
            const SizedBox(height: 16),

            // Date field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _selectDate(context, _dateController),
                  child: Container(
                    width: 148,
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
                      controller: _dateController,
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
                  height: 186,
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
                    maxLines: 7,
                    maxLength: 150,
                    decoration: InputDecoration(
                      hintText: 'Add more details about this certification',
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
              onPressed: _saveCertification,
            ),
          ],
        ),
      ),
    );
  }
}
