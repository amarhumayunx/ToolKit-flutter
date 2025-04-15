import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_colors.dart';
import '../../widgets/buttons/save_edit_delete_btns.dart';
import '../../widgets/custom_text_field.dart';


class JobPage extends StatefulWidget {


  const JobPage({
    super.key,

  });

  @override
  State<JobPage> createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> {


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
    if (_jobTitleController.text.isEmpty ||
        _jobSummaryController.text.isEmpty) {
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

  void _deleteJob() {
    setState(() {
      // Clear saved job details
      savedJobTitle = '';
      savedJobSummary = '';
      hasJobDetail = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26.0),
      child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10,),
                    // Show job form or saved job detail
                    hasJobDetail ? _buildSavedJobDetail() : _buildJobForm(),
                  ],
                ),
              ),
            ),
          ],
      ),
    );
  }

  Widget _buildSavedJobDetail() {
    // Using the new SavedDetailContainer widget
    return SavedDetailContainer(
      title: savedJobTitle,
      content: savedJobSummary,
      onEdit: _editJob,
      onDelete: _deleteJob,
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

            // Using the new SaveButton widget
            SaveButton(onPressed: _saveJob),
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
