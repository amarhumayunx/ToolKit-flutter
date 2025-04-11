import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Template3 extends StatefulWidget {
  const Template3({super.key});

  @override
  State<Template3> createState() => _Template3State();
}

class _Template3State extends State<Template3> {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom curved header with photo
              _buildCurvedHeader(),

              // Content container
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column - Contact, Education, Skills, Languages
                    _buildLeftColumn(),

                    // Right column - Profile, Work Experience, Certifications
                    _buildRightColumn(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurvedHeader() {
    return Stack(
      children: [
        // Background with curved shape
        ClipPath(
          clipper: HeaderClipper(),
          child: Container(
            height: 40,
            color: const Color(0xFF5D8AA8), // Steel blue color
            width: double.infinity,
          ),
        ),

        // Content
        SizedBox(
          height: 40,
          child: Row(
            children: [
              // Name and title
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, top: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'SOPHIA',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'WILLIAMS',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'PRODUCT DESIGNER',
                        style: GoogleFonts.poppins(
                          fontSize: 3,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Photo placement
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade300,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeftColumn() {
    return Container(
      width: 74,
      padding: const EdgeInsets.fromLTRB(8, 10, 5, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact section
          _buildSectionTitle('CONTACT'),
          const SizedBox(height: 4),
          _buildContactItem(Icons.phone, '+92 013456789'),
          const SizedBox(height: 2),
          _buildContactItem(Icons.email, 'Email'),
          const SizedBox(height: 2),
          _buildContactItem(Icons.link, 'LinkedIn Address'),
          const SizedBox(height: 8),

          // Education section
          _buildSectionTitle('EDUCATION'),
          const SizedBox(height: 4),
          _buildEducationItem('DEGREE / DIPLOMA NAME', 'Major / Course',
              'Institution Name', '20XX - 20XX'),
          const SizedBox(height: 6),
          _buildEducationItem('DEGREE / DIPLOMA NAME', 'Major / Course',
              'Institution Name', '20XX - 20XX'),
          const SizedBox(height: 8),

          // Skills section
          _buildSectionTitle('SKILLS & INTERESTS'),
          const SizedBox(height: 4),
          _buildSkillsList([
            'Figma',
            'JavaScript (ES6+)',
            'Angular',
            'React',
            'HTML5',
            'NodeJS/TS',
            'Photoshop',
            'Illustrator'
          ]),
          const SizedBox(height: 8),

          // Languages section
          _buildSectionTitle('LANGUAGES'),
          const SizedBox(height: 4),
          _buildLanguageItem('Italy'),
          _buildLanguageItem('English'),
        ],
      ),
    );
  }

  Widget _buildRightColumn() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(5, 10, 8, 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile section
            _buildSectionTitle('PROFILE'),
            const SizedBox(height: 4),
            _buildProfileText(),
            const SizedBox(height: 8),

            // Work Experience section
            _buildSectionTitle('WORK EXPERIENCE'),
            const SizedBox(height: 4),
            _buildExperienceItem(
              'JOB TITLE / POSITION',
              'Company | MM / YY - MM / YY',
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, ipsum dolor sit amet, consectetur adipiscing elit, ipsum',
              ['Project', 'Award', 'Result', 'Another'],
            ),
            const SizedBox(height: 6),
            _buildExperienceItem(
              'JOB TITLE / POSITION',
              'Company | MM / YY - MM / YY',
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, ipsum dolor sit amet, consectetur adipiscing elit, ipsum',
              ['Project', 'Award', 'Result', 'Another'],
            ),
            const SizedBox(height: 8),

            // Certifications section
            _buildSectionTitle('CERTIFICATIONS'),
            const SizedBox(height: 4),
            _buildCertificationItem(
              'CERTIFICATION NAME',
              'Institution | MM / YY - MM / YY',
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, ipsum dolor sit amet consectetur adipiscing sit, ipsum',
            ),
          ],
        ),
      ),
    );
  }

  // Modified to place divider above the title
  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 0.5,
          color: Colors.grey.shade300,
          margin: const EdgeInsets.only(bottom: 2),
        ),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 4,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF5D8AA8), // Steel blue color from header
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
            fontSize: 3.5,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(
          major,
          style: GoogleFonts.poppins(
            fontSize: 3,
            fontStyle: FontStyle.italic,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          institution,
          style: GoogleFonts.poppins(
            fontSize: 3,
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

  Widget _buildSkillsList(List<String> skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: skills.map((skill) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 1),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: GoogleFonts.poppins(
                  fontSize: 3,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5D8AA8),
                ),
              ),
              Expanded(
                child: Text(
                  skill,
                  style: GoogleFonts.poppins(
                    fontSize: 3,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLanguageItem(String language) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Row(
        children: [
          Text(
            '• ',
            style: GoogleFonts.poppins(
              fontSize: 3,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5D8AA8),
            ),
          ),
          Text(
            language,
            style: GoogleFonts.poppins(
              fontSize: 3,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileText() {
    return Text(
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam pharetra in lorem at laoreet. Donec hendrerit libero eget est tempor, quis tempus arcu elementum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, ipsum',
      style: GoogleFonts.poppins(
        fontSize: 3,
        color: Colors.grey.shade800,
        height: 1.3,
      ),
    );
  }

  Widget _buildExperienceItem(String title, String company, String description,
      List<String> bulletPoints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 3.5,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(
          company,
          style: GoogleFonts.poppins(
            fontSize: 3,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          description,
          style: GoogleFonts.poppins(
            fontSize: 3,
            color: Colors.grey.shade800,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 2),
        ...bulletPoints.map((point) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: GoogleFonts.poppins(
                    fontSize: 3,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D8AA8),
                  ),
                ),
                Expanded(
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
          );
        }).toList(),
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
            fontSize: 3.5,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Text(
          institution,
          style: GoogleFonts.poppins(
            fontSize: 3,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          description,
          style: GoogleFonts.poppins(
            fontSize: 3,
            color: Colors.grey.shade800,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

// Custom clipper to create the curved header shape
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Start at top-left
    path.lineTo(0, 0);

    // Draw line to bottom-left
    path.lineTo(0, size.height);

    // Draw line to bottom-right
    path.lineTo(size.width, size.height);

    // Draw line to top-right (starting point of the curve)
    path.lineTo(size.width, 0);

    // Close the path
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
