import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../screens/cv_maker_screens/create_cv_screen.dart';
import '../../utils/app_colors.dart';

class CreateCVButton extends StatelessWidget {
  final VoidCallback onTap;

  const CreateCVButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:  () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  CreateCvScreen()),
      );
    },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/pencil_cv.svg',
            ),
            const SizedBox(width: 12),
            Text(
              'Create Your CV',
              style: GoogleFonts.inter(
                color:AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
