import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Import provider

import '../../utils/app_colors.dart';
import '../../widgets/buttons/save_edit_delete_btns.dart';
import '../../provider/user_provider.dart'; // Import UserProvider

class CareerObjectivesPage extends StatefulWidget {
  const CareerObjectivesPage({
    super.key,
  });

  @override
  State<CareerObjectivesPage> createState() => _CareerObjectivesPageState();
}

class _CareerObjectivesPageState extends State<CareerObjectivesPage> {
  final TextEditingController _objectiveController = TextEditingController();

  bool hasObjective = false;
  String savedObjective = '';

  @override
  void initState() {
    super.initState();
    // Check if objective already exists in provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.userData.careerObjective != null &&
          userProvider.userData.careerObjective!.isNotEmpty) {
        setState(() {
          savedObjective = userProvider.userData.careerObjective!;
          hasObjective = true;
        });
      }
    });
  }

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

    // Get user provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    setState(() {
      savedObjective = _objectiveController.text;
      hasObjective = true;

      // Update provider with new objective
      userProvider.updateCareerObjective(savedObjective);

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
    // Get user provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    setState(() {
      // Clear saved career objective
      savedObjective = '';
      hasObjective = false;

      // Update provider with empty objective
      userProvider.updateCareerObjective('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),

                    // Show objective form or saved objective detail
                    hasObjective
                        ? _buildSavedObjective()
                        : _buildObjectiveForm(),
                  ],
                ),
              ),
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
      height: 432,
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
        padding: const EdgeInsets.only(left: 18,right: 18,top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Objective field with expanded height
            _buildObjectiveField(),
            const SizedBox(height: 32),
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.dividerColor,
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
          'Career Objective / Profile Summary',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 284,
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
            maxLines: 12,
            decoration: InputDecoration(
              hintText: 'Type your career objectives / Profile Summary',
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
    );
  }
}
