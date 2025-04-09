import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Template1 extends StatefulWidget {
  const Template1({super.key});

  @override
  State<Template1> createState() => _Template1State();
}

class _Template1State extends State<Template1> {
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
          padding: const EdgeInsets.all(5), // Added consistent padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section with name and title
              _buildHeader(),
              const SizedBox(height: 4), // Consistent spacing

              // Profile section
              _buildSectionWithDivider('PROFILE'),
              const SizedBox(height: 3),
              _buildProfileContent(),
              const SizedBox(height: 4),

              // Experiences section
              _buildSectionWithDivider('EXPERIENCES'),
              const SizedBox(height: 3),
              _buildExperienceItem(
                'JOB TITLE / POSITION',
                'Company Name',
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                'MM / YY - MM / YY',
                bulletPoints: ['Point 1', 'Point 2', 'Another'],
              ),
              const SizedBox(height: 3),

              _buildExperienceItem(
                'JOB TITLE / POSITION',
                'Company Name',
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                'MM / YY - MM / YY',
              ),
              const SizedBox(height: 3),

              _buildExperienceItem(
                'JOB TITLE / POSITION',
                'Company Name',
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                'MM / YY - MM / YY',
              ),
              const SizedBox(height: 4),

              // Education section
              _buildSectionWithDivider('EDUCATION'),
              const SizedBox(height: 3),
              _buildEducationItem(
                  'DEGREE / DIPLOMA NAME', 'University Name', '20XX - 20XX'),
              const SizedBox(height: 3),
              _buildEducationItem(
                  'DEGREE / DIPLOMA NAME', 'University Name', '20XX - 20XX'),
              const SizedBox(height: 4),

              // Certifications section
              _buildSectionWithDivider('CERTIFICATIONS'),
              const SizedBox(height: 3),
              _buildCertificationItem(
                'CERTIFICATION NAME',
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                'MM / YY - MM / YY',
              ),
              const SizedBox(height: 4),

              // Hobbies section - newly added
              _buildSectionWithDivider('HOBBIES'),
              const SizedBox(height: 3),
              _buildHobbiesList(['Photography', 'Hiking', 'Reading', 'Playing Piano']),
              const SizedBox(height: 4),

              // Languages section
              _buildSectionWithDivider('LANGUAGES'),
              const SizedBox(height: 3),
              _buildLanguagesList(['English', 'Other']),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sophia Williams',
          style: GoogleFonts.inriaSerif(
            fontSize: 6, // Increased for better visibility
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          'Product Designer',
          style: GoogleFonts.inriaSerif(
            fontSize: 4, // Standardized size
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 3),
        // Modified Row layout with better spacing
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Phone - reduce width to make space
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  const Icon(Icons.phone, size: 4),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      '+XX XXXXXXXXX',
                      style: GoogleFonts.inriaSerif(
                        fontSize: 3, // Standardized size
                        color: Colors.grey.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Add explicit spacing between elements
            const SizedBox(width: 5),

            // Email
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  const Icon(Icons.email, size: 4),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      'Email',
                      style: GoogleFonts.inriaSerif(
                        fontSize: 3, // Standardized size
                        color: Colors.grey.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Add explicit spacing between elements
            const SizedBox(width: 5),

            // LinkedIn
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  const Icon(Icons.link, size: 4),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      'LinkedIn',
                      style: GoogleFonts.inriaSerif(
                        fontSize: 3, // Standardized size
                        color: Colors.grey.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionWithDivider(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 4, // Standardized section headers
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          height: 1,
          color: Colors.grey.shade300,
        ),
      ],
    );
  }

  Widget _buildProfileContent() {
    return Text(
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam pharetra in viverra at laoreet.',
      style: GoogleFonts.inter(
        fontSize: 3, // Standardized normal text
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildExperienceItem(
      String title, String company, String description, String dateRange,
      {List<String>? bulletPoints}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 4, // Standardized size
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              dateRange,
              style: GoogleFonts.poppins(
                fontSize: 3, // Standardized size
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 1),
        Text(
          company,
          style: GoogleFonts.poppins(
            fontSize: 3, // Standardized size
            color: Colors.grey.shade700,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          description,
          style: GoogleFonts.inter(
            fontSize: 3, // Standardized normal text
            color: Colors.grey.shade800,
          ),
        ),
        if (bulletPoints != null) ...[
          const SizedBox(height: 1),
          ...bulletPoints
              .map(
                (point) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold, fontSize: 3)),
                Expanded(
                  child: Text(
                    point,
                    style: GoogleFonts.inter(
                      fontSize: 3, // Standardized size
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
          )
              .toList(),
        ],
      ],
    );
  }

  Widget _buildEducationItem(String degree, String university, String years) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                degree,
                style: GoogleFonts.poppins(
                  fontSize: 4, // Standardized size
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                university,
                style: GoogleFonts.poppins(
                  fontSize: 3, // Standardized size
                  color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        Text(
          years,
          style: GoogleFonts.poppins(
            fontSize: 3, // Standardized size
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildCertificationItem(
      String title, String description, String dateRange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 4, // Standardized size
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              dateRange,
              style: GoogleFonts.poppins(
                fontSize: 3, // Standardized size
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 1),
        Text(
          description,
          style: GoogleFonts.inter(
            fontSize: 3, // Standardized normal text
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  // New method for hobbies section
  Widget _buildHobbiesList(List<String> hobbies) {
    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: hobbies.map((hobby) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: Colors.grey.shade300, width: 0.5),
          ),
          child: Text(
            hobby,
            style: GoogleFonts.poppins(
              fontSize: 3,
              color: Colors.grey.shade800,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLanguagesList(List<String> languages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: languages
          .map((language) => Padding(
        padding: const EdgeInsets.only(bottom: 1),
        child: Row(
          children: [
            Text(
              '• ',
              style: GoogleFonts.inter(
                fontSize: 3,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              language,
              style: GoogleFonts.poppins(
                fontSize: 3, // Standardized normal text
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ))
          .toList(),
    );
  }
}