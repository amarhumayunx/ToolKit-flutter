import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/website_model.dart';
import '../../utils/app_colors.dart';

class Template2 extends StatefulWidget {
  final List<Website> websites;
  const Template2({Key? key, this.websites = const []});

  @override
  State<Template2> createState() => _Template2State();
}

class _Template2State extends State<Template2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 174, maxHeight: 246),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background gray design element
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(100),
                    ),
                  ),
                ),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    // Header with profile image and name side by side
                    _buildHeaderRow(),

                    // Dividing line below header
                    const SizedBox(height: 4),

                    // Two column layout for the rest of the content
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left column (narrower)
                          Expanded(
                            flex: 2,
                            child: _buildLeftColumn(),
                          ),

                          // Small space between columns
                          const SizedBox(width: 10),

                          // Right column (wider)
                          Expanded(
                            flex: 3,
                            child: _buildRightColumn(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Profile image with white outline and purple border - matching the Figma design
        Center(
            child: Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.Cv2PurpleColor,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(1),
            // This gives space for the white outline
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white, // White outline
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(1),
                // Space inside white for the content
                child: ClipOval(
                  child: Container(
                    color: Colors.grey.shade400, // Profile placeholder
                  ),
                ),
              ),
            ),
          ),
        )),
        const SizedBox(width: 15),

        // Name and title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SOPHIA',
                style: GoogleFonts.inriaSerif(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.Cv2PurpleColor, // Purple color
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'WILLIAMS',
                style: GoogleFonts.inriaSerif(
                  fontSize: 10,
                  fontWeight: FontWeight.w200,
                  color: const Color(0xFFD095DA),
                  // Light purple color
                  letterSpacing: 1.2,
                  height: 0.9,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Product Designer',
                style: GoogleFonts.poly(
                  fontSize: 4,
                  color: Color(0xFFA3A3A3),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contact section
        _buildSectionTitle(
          'CONTACT',
          AppColors.Cv2PurpleColor,
        ),
        const SizedBox(height: 3),
        _buildContactItem(Icons.phone, '+XX XXXXXXXX'),
        _buildContactItem(Icons.email, 'Email'),
        _buildContactItem(Icons.link, 'LinkedIn Address'),
        const SizedBox(height: 8),

        // Education section
        _buildSectionTitle(
          'EDUCATION',
          AppColors.Cv2PurpleColor,
        ),
        const SizedBox(height: 3),
        _buildEducationItem(
          'DEGREE / DIPLOMA NAME',
          'Major / Grade',
          'Institution Name',
          '2019 - 2023',
        ),
        const SizedBox(height: 4),
        _buildEducationItem(
          'DEGREE / DIPLOMA NAME',
          'Major / Grade',
          'Institution Name',
          '2015 - 2019',
        ),
        const SizedBox(height: 8),

        // Skills section
        _buildSectionTitle(
          'SKILLS & INTERESTS',
          AppColors.Cv2PurpleColor,
        ),
        const SizedBox(height: 3),
        _buildBulletItem('HTML'),
        _buildBulletItem('CSS'),
        _buildBulletItem('JavaScript (ES6+)'),
        _buildBulletItem('React.js'),
        _buildBulletItem('Python'),
        _buildBulletItem('Sketch'),
        _buildBulletItem('Adobe XD'),
        _buildBulletItem('InVision'),
        _buildBulletItem('Moodboard'),
        const SizedBox(height: 8),

        // Languages section
        _buildSectionTitle(
          'LANGUAGES',
          AppColors.Cv2PurpleColor,
        ),
        const SizedBox(height: 3),
        _buildBulletItem('English'),
        _buildBulletItem('Spanish'),
      ],
    );
  }

  Widget _buildRightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile section
        _buildSectionTitle(
          'PROFILE',
          AppColors.Cv2PurpleColor,
        ),
        const SizedBox(height: 3),
        Text(
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam pharetra in lorem et tristique. Cras interdum lorem sagittis est bibendum, sit amet convallis nisi ultricies. Vivamus commodo neque at eros, consectetur adipiscing elit. Nullam pharetra in lorem et tristique. Cras interdum lorem sagittis est bibendum, quis tempus.',
          style: GoogleFonts.inter(
            fontSize: 3,
            color: Colors.grey.shade800,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),

        // Work Experience section
        _buildSectionTitle(
          'WORK EXPERIENCE',
          AppColors.Cv2PurpleColor,
        ),
        const SizedBox(height: 3),

        // First job
        _buildExperienceItem(
          'JOB TITLE / POSITION',
          'COMPANY NAME | MM / YY - MM / YY',
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam pharetra in lorem et tristique. Cras interdum lorem sagittis est bibendum, quis tempus.',
          bulletPoints: ['Skill 1', 'Skill 2', 'English'],
        ),
        const SizedBox(height: 6),

        // Second job
        _buildExperienceItem(
          'JOB TITLE / POSITION',
          'COMPANY NAME | MM / YY - MM / YY',
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam pharetra in lorem et tristique. Cras interdum lorem sagittis est bibendum, quis tempus.',
          bulletPoints: ['Skill 1', 'Skill 2', 'English'],
        ),
        const SizedBox(height: 8),

        // Certifications section
        _buildSectionTitle(
          'CERTIFICATIONS',
          AppColors.Cv2PurpleColor,
        ),
        const SizedBox(height: 3),
        _buildCertificationItem(
          'CERTIFICATION NAME',
          'Institution | MM / YY - MM / YY',
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam pharetra in lorem et tristique. Cras interdum lorem sagittis est bibendum, quis tempus.',
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 4,
            fontWeight: FontWeight.w600,
            color: color,
            letterSpacing: 1,
          ),
        ),
        Container(
          height: 0.5,
          color: Colors.grey.shade300,
        ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(icon, size: 4, color: Colors.grey.shade700),
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 3,
                color: Colors.grey.shade700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationItem(
      String degree, String major, String institution, String years) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          degree,
          style: GoogleFonts.poppins(
            fontSize: 3,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        Text(
          major,
          style: GoogleFonts.poppins(
            fontSize: 3,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          institution,
          style: GoogleFonts.poppins(
            fontSize: 3,
            fontStyle: FontStyle.italic,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          years,
          style: GoogleFonts.poppins(
            fontSize: 3,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: GoogleFonts.poppins(
              fontSize: 3,
              color: Colors.grey.shade800,
            ),
          ),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 3,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceItem(String title, String company, String description,
      {List<String>? bulletPoints}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 4,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        Text(
          company,
          style: GoogleFonts.poppins(
            fontSize: 3,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          description,
          style: GoogleFonts.inter(
            fontSize: 3,
            color: Colors.grey.shade800,
            height: 1.4,
          ),
        ),
        if (bulletPoints != null) ...[
          const SizedBox(height: 2),
          ...bulletPoints
              .map((point) => Padding(
                    padding: const EdgeInsets.only(bottom: 1),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: GoogleFonts.poppins(
                            fontSize: 3,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            point,
                            style: GoogleFonts.poppins(
                              fontSize: 3,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ],
    );
  }

  Widget _buildCertificationItem(
      String title, String institution, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 4,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        Text(
          institution,
          style: GoogleFonts.poppins(
            fontSize: 3,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          description,
          style: GoogleFonts.inter(
            fontSize: 3,
            color: Colors.grey.shade800,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
