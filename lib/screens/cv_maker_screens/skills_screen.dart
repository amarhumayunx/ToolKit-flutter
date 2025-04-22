import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/skills_model.dart';
import '../../provider/skills_provider.dart';
import '../../utils/app_colors.dart';

class SkillsPage extends StatefulWidget {
  const SkillsPage({
    super.key,
  });

  @override
  State<SkillsPage> createState() => _SkillsPageState();
}

class _SkillsPageState extends State<SkillsPage> {
  final TextEditingController _skillController = TextEditingController();
  final FocusNode _skillFocusNode = FocusNode();
  List<Skill> skills = [];

  @override
  void dispose() {
    _skillController.dispose();
    _skillFocusNode.dispose();
    super.dispose();
  }
  void _addSkill() {
    if (_skillController.text.trim().isNotEmpty) {
      final skillsProvider = Provider.of<SkillsProvider>(context, listen: false);
      skillsProvider.addSkill(Skill(name: _skillController.text.trim()));
      _skillController.clear();
      _skillFocusNode.requestFocus();
    }
  }

// Update the _removeSkill method:
  void _removeSkill(int index) {
    final skillsProvider = Provider.of<SkillsProvider>(context, listen: false);
    skillsProvider.removeSkill(index);
  }

  @override
  Widget build(BuildContext context) {
    // In the build method, add this before return:
    final skillsProvider = Provider.of<SkillsProvider>(context);
    final skills = skillsProvider.skillItems;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Skills input form
                  _buildSkillsForm(),

                  const SizedBox(height: 30),

                  // Display skills as tags
                  _buildSkillsTags(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsForm() {
    return Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Your Skills',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Focus(
              onKey: (FocusNode node, RawKeyEvent event) {
                if (event is RawKeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.enter) {
                  _addSkill();
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Skill',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
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
                          child: TextFormField(
                            controller: _skillController,
                            focusNode: _skillFocusNode,
                            decoration: InputDecoration(
                              hintText: 'Enter a skill',
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
                      ),
                      const SizedBox(width: 12),
                      // Added space between text field and button
                      GestureDetector(
                        onTap: _addSkill,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.gradientStart,
                                AppColors.gradientEnd,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsTags() {
    // Get skills from provider
    final skillsProvider = Provider.of<SkillsProvider>(context);
    final skills = skillsProvider.skillItems;

    return Container(
      width: double.infinity,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Skills',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            skills.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'No skills added yet',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
                : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(
                skills.length,
                    (index) => _buildSkillTag(skills[index], index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillTag(Skill skill, int index) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Skill Tag Container
        Container(

          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
           color: AppColors.primary,
            borderRadius: BorderRadius.circular(12), // More rounded corners to match design
          ),
          child: Text(
            skill.name,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),

        // Close Button (X) in circular overlay at top-right
        Positioned(
          top: -6,
          right: -4,
          child: GestureDetector(
            onTap: () => _removeSkill(index),
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.close,
                  color: AppColors.primary,
                  size: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
