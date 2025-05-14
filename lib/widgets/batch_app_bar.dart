import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_colors.dart';

class BatchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onNextPressed;
  final VoidCallback onBackPressed;
  final String actionText; // New parameter for customizable action text

  const BatchAppBar({
    Key? key,
    required this.onNextPressed,
    required this.onBackPressed,
    this.actionText = 'Next', // Default value is 'Next'
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: onBackPressed,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton(
              onPressed: onNextPressed,
              child: Text(
                actionText, // Use the actionText parameter here
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
