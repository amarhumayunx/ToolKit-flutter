import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

class DateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onTap;
  final String? errorText;
  final bool isEnabled;

  const DateField({
    super.key,
    required this.label,
    required this.controller,
    required this.onTap,
    this.errorText,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: isEnabled ? onTap : null,
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
            child: AbsorbPointer(
              child: TextFormField(
                controller: controller,
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
        ),
        // Create a fixed-height container for error text that's always present
        Container(
          height: 20, // Fixed height to accommodate the error text
          padding: const EdgeInsets.only(
            top: 4,
          ),
          alignment: Alignment.topLeft,
          child: errorText != null
              ? Text(
                  errorText!,
                  style: GoogleFonts.inter(
                    color: Colors.red,
                    fontSize: 8,
                    fontWeight: FontWeight.w400,
                  ),
                )
              : null, // When no error, container still takes up space but is empty
        ),
      ],
    );
  }
}
