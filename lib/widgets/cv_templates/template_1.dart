import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/user_model_1.dart';
import '../../models/website_model.dart';
import '../../provider/user_provider.dart';
import '../../utils/app_colors.dart';
import '../custom_appbar.dart';

class Template1 extends StatefulWidget {
  final List<Website> websites;

  const Template1({Key? key, this.websites = const []}) : super(key: key);

  @override
  State<Template1> createState() => _Template1State();
}

class _Template1State extends State<Template1> {
  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserProvider>(context).userData;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'CV',
        onBackPressed: () {
          Navigator.pop(context);
        },
        actions: [
          TextButton(
            onPressed: () {
              // Save functionality would go here
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Container(
                constraints:
                const BoxConstraints(maxWidth: 340, maxHeight: 482),
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
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section with name and title - using userData
                    _buildHeader(userData),
                    const SizedBox(height: 10),

                    // Profile section with objective from provider
                    _buildSectionWithDivider('Objective'),
                    const SizedBox(height: 4),
                    _buildObjectiveContent(userData),
                    const SizedBox(height: 6),

                    // Experiences section
                    _buildSectionWithDivider('EXPERIENCES'),
                    const SizedBox(height: 4),
                    _buildExperienceItem(
                      'POSITION',
                      'Company Name',
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                      'MM / YY - MM / YY',
                      bulletPoints: ['Project 1', 'Project 2', 'Another'],
                    ),
                    const SizedBox(height: 4),

                    _buildExperienceItem(
                      'POSITION',
                      'Company Name',
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                      'MM / YY - MM / YY',
                    ),
                    const SizedBox(height: 4),

                    _buildExperienceItem(
                      'POSITION',
                      'Company Name',
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                      'MM / YY - MM / YY',
                    ),
                    const SizedBox(height: 6),

                    // Education section
                    _buildSectionWithDivider('EDUCATION'),
                    const SizedBox(height: 4),
                    _buildEducationItem('DEGREE / DIPLOMA NAME',
                        'University Name', '20XX - 20XX'),
                    const SizedBox(height: 4),
                    _buildEducationItem('DEGREE / DIPLOMA NAME',
                        'University Name', '20XX - 20XX'),
                    const SizedBox(height: 4),

                    // Certifications section
                    _buildSectionWithDivider('CERTIFICATIONS'),
                    const SizedBox(height: 4),
                    _buildCertificationItem(
                      'CERTIFICATION NAME',
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                      'MM / YY - MM / YY',
                    ),
                    const SizedBox(height: 6),

                    // Hobbies section
                    _buildSectionWithDivider('HOBBIES'),
                    const SizedBox(height: 4),
                    _buildHobbiesList(
                        ['Photography', 'Hiking', 'Reading', 'Playing Piano']),
                    const SizedBox(height: 6),

                    // Languages section
                    _buildSectionWithDivider('LANGUAGES'),
                    const SizedBox(height: 4),
                    _buildLanguagesList(['English', 'Other']),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Updated to use userData and display website link
  Widget _buildHeader(UserModel userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          userData.fullName ?? 'Your Name', // Display user's name or default
          style: GoogleFonts.inriaSerif(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          userData.designation ?? 'Your Designation',
          // Display user's designation or default
          style: GoogleFonts.inriaSerif(
            fontSize: 10,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        // Modified Row layout with better spacing and user data
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First child: Phone and Email row
            Row(
              children: [
                // Phone
                const Icon(Icons.phone, size: 10),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    userData.phoneNumber ?? '+XX XXXXXXXXX',
                    style: GoogleFonts.inriaSerif(
                      fontSize: 8,
                      color: Colors.grey.shade700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(width: 30),

                // Email
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.email, size: 10),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          userData.email ?? 'Email',
                          style: GoogleFonts.inriaSerif(
                            fontSize: 8,
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

            const SizedBox(height: 4), // Space between first and second row

            Row(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start, // Optional: aligns top if text wraps
                    children: [
                      const Icon(Icons.link, size: 10),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          userData.websiteUrl != null && userData.websiteUrl!.isNotEmpty
                              ? userData.websiteUrl!
                              : 'linkurl',
                          style: GoogleFonts.inriaSerif(
                            fontSize: 8,
                            color: Colors.grey.shade700,
                          ),
                          softWrap: true,
                          maxLines: 3,

                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

          ],
        ),

      ],
    );
  }

  // Rest of the methods remain the same
  Widget _buildSectionWithDivider(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 8,
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

  // Updated to use userData for objective
  Widget _buildObjectiveContent(UserModel userData) {
    return Text(
      userData.careerObjective ??
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam pharetra in viverra at laoreet.',
      style: GoogleFonts.inter(
        fontSize: 6,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildExperienceItem(
      String title, String company, String description, String dateRange,
      {List<String>? bulletPoints}) {
    // Existing implementation
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
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              dateRange,
              style: GoogleFonts.poppins(
                fontSize: 7,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          company,
          style: GoogleFonts.poppins(
            fontSize: 7,
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
        if (bulletPoints != null) ...[
          const SizedBox(height: 2),
          ...bulletPoints
              .map(
                (point) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold, fontSize: 6)),
                Expanded(
                  child: Text(
                    point,
                    style: GoogleFonts.inter(
                      fontSize: 6,
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
    // Existing implementation
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
                  fontSize: 7,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                university,
                style: GoogleFonts.poppins(
                  fontSize: 6,
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
            fontSize: 6,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildCertificationItem(
      String title, String description, String dateRange) {
    // Existing implementation
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
                  fontSize: 7,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              dateRange,
              style: GoogleFonts.poppins(
                fontSize: 7,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          description,
          style: GoogleFonts.inter(
            fontSize: 6,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildHobbiesList(List<String> hobbies) {
    // Existing implementation
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: hobbies.map((hobby) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300, width: 0.5),
          ),
          child: Text(
            hobby,
            style: GoogleFonts.poppins(
              fontSize: 6,
              color: Colors.grey.shade800,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLanguagesList(List<String> languages) {
    // Existing implementation
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: languages
          .map((language) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Row(
          children: [
            Text(
              '• ',
              style: GoogleFonts.inter(
                fontSize: 6,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              language,
              style: GoogleFonts.poppins(
                fontSize: 6,
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
