import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Template3 extends StatefulWidget {
  const Template3({Key? key}) : super(key: key);

  @override
  State<Template3> createState() => _Template3State();
}

class _Template3State extends State<Template3> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('CV'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Save functionality would go here
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 340, minHeight: 482, maxHeight: 482),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
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
              children: [
                // Header section with name and profile picture
                _buildHeader(),

                // Main content with left and right columns
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left column - Contact, Education, Skills, Languages
                      Container(
                        width: 130,
                        color: const Color(0xFFF2E8E1),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildContactSection(),
                            const SizedBox(height: 16),
                            _buildEducationSection(),
                            const SizedBox(height: 16),
                            _buildSkillsSection(),
                            const SizedBox(height: 16),
                            _buildLanguagesSection(),
                          ],
                        ),
                      ),

                      // Right column - Profile, Experience, Certifications
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileSection(),
                              const SizedBox(height: 16),
                              _buildWorkExperienceSection(),
                              const SizedBox(height: 16),
                              _buildCertificationsSection(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(
        color: Color(0xFFCB7F42),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Row(
        children: [
          // Name and title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SOPHIA',
                  style: GoogleFonts.inriaSerif(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'WILLIAMS',
                  style: GoogleFonts.inriaSerif(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Product Designer',
                  style: GoogleFonts.inriaSerif(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Profile picture
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade300,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONTACT',
          style: GoogleFonts.poppins(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFCB7F42),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.phone, size: 10, color: Color(0xFF666666)),
            const SizedBox(width: 4),
            Text(
              '+65 25436789',
              style: GoogleFonts.poppins(
                fontSize: 6,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.email_outlined, size: 10, color: Color(0xFF666666)),
            const SizedBox(width: 4),
            Text(
              'email',
              style: GoogleFonts.poppins(
                fontSize: 6,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.link, size: 10, color: Color(0xFF666666)),
            const SizedBox(width: 4),
            Text(
              'LinkedIn Address',
              style: GoogleFonts.poppins(
                fontSize: 6,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEducationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EDUCATION',
          style: GoogleFonts.poppins(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFCB7F42),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'DEGREE / DIPLOMA NAME',
          style: GoogleFonts.poppins(
            fontSize: 7,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          'Major | School',
          style: GoogleFonts.poppins(
            fontSize: 6,
            color: Colors.grey.shade700,
            fontStyle: FontStyle.italic,
          ),
        ),
        Text(
          'Institution Name',
          style: GoogleFonts.poppins(
            fontSize: 6,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          '2018 - 2019',
          style: GoogleFonts.poppins(
            fontSize: 6,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'DEGREE / DIPLOMA NAME',
          style: GoogleFonts.poppins(
            fontSize: 7,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          'Major | School',
          style: GoogleFonts.poppins(
            fontSize: 6,
            color: Colors.grey.shade700,
            fontStyle: FontStyle.italic,
          ),
        ),
        Text(
          'Institution Name',
          style: GoogleFonts.poppins(
            fontSize: 6,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SKILLS & INTERESTS',
          style: GoogleFonts.poppins(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFCB7F42),
          ),
        ),
        const SizedBox(height: 6),
        _buildSkillItem('HTML5'),
        _buildSkillItem('CSS3'),
        _buildSkillItem('JavaScript (ES6+)'),
        _buildSkillItem('ReactJS'),
        _buildSkillItem('Vue.js'),
        _buildSkillItem('NodeJS'),
        _buildSkillItem('MongoDB'),
        _buildSkillItem('Bootstrap 5'),
      ],
    );
  }

  Widget _buildSkillItem(String skill) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text(
            '• ',
            style: GoogleFonts.poppins(
              fontSize: 6,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            skill,
            style: GoogleFonts.poppins(
              fontSize: 6,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LANGUAGES',
          style: GoogleFonts.poppins(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFCB7F42),
          ),
        ),
        const SizedBox(height: 6),
        _buildSkillItem('Urdu'),
        _buildSkillItem('English'),
      ],
    );
  }

  Widget _buildProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROFILE',
          style: GoogleFonts.poppins(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFCB7F42),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam pretium in tortor et luctus. Donec hendrerit lorem eget est tempor, eget feugiat ante ultrices porta. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam pretium in tortor et luctus. Donec hendrerit lorem eget est tempor, eget feugiat.',
          style: GoogleFonts.inter(
            fontSize: 6,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkExperienceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WORK EXPERIENCE',
          style: GoogleFonts.poppins(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFCB7F42),
          ),
        ),
        const SizedBox(height: 6),
        _buildWorkExperienceItem(
          'JOB TITLE / POSITION',
          'Company | May \'YY - Mar \'YY',
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, nunc sit amet sem non mauris egestas elementum. In sem nunc.',
          ['React.js', 'Vue.js', 'Angular'],
        ),
        const SizedBox(height: 8),
        _buildWorkExperienceItem(
          'JOB TITLE / POSITION',
          'Company | May \'YY - Mar \'YY',
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, nunc sit amet sem non mauris egestas elementum. In sem nunc.',
          ['React.js', 'Vue.js', 'Angular'],
        ),
      ],
    );
  }

  Widget _buildWorkExperienceItem(String title, String company, String description, List<String> skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 7,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          company,
          style: GoogleFonts.poppins(
            fontSize: 6,
            color: Colors.grey.shade700,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          description,
          style: GoogleFonts.inter(
            fontSize: 6,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 2),
        Wrap(
          spacing: 4,
          children: skills.map((skill) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '• ',
                  style: GoogleFonts.poppins(
                    fontSize: 6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  skill,
                  style: GoogleFonts.poppins(
                    fontSize: 6,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(width: 4),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCertificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CERTIFICATIONS',
          style: GoogleFonts.poppins(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFCB7F42),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'CERTIFICATION NAME',
          style: GoogleFonts.poppins(
            fontSize: 7,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          'Institution | May \'YY - Jun \'YY',
          style: GoogleFonts.poppins(
            fontSize: 6,
            color: Colors.grey.shade700,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, nunc sit amet sem non mauris egestas elementum. In sem nunc.',
          style: GoogleFonts.inter(
            fontSize: 6,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}