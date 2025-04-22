import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/language_model.dart';
import '../../provider/language_provider.dart';
import '../../utils/app_colors.dart';

class LanguagesPage extends StatefulWidget {
  const LanguagesPage({
    super.key,
  });

  @override
  State<LanguagesPage> createState() => _LanguagesPageState();
}

class _LanguagesPageState extends State<LanguagesPage> {
  final TextEditingController _languageController = TextEditingController();
  final FocusNode _languageFocusNode = FocusNode();

  @override
  void dispose() {
    _languageController.dispose();
    _languageFocusNode.dispose();
    super.dispose();
  }

  void _addLanguage() {
    if (_languageController.text.trim().isNotEmpty) {
      final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      languageProvider.addLanguage(Language(name: _languageController.text.trim()));
      _languageController.clear();
      _languageFocusNode.requestFocus();
    }
  }

  void _removeLanguage(int index) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    languageProvider.removeLanguage(index);
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final selectedLanguages = languageProvider.languages;

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

                  // Language input form
                  _buildLanguageForm(),

                  const SizedBox(height: 30),

                  // Selected languages display
                  _buildSelectedLanguages(selectedLanguages),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageForm() {
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
              'Add Your Languages',
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
                  _addLanguage();
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Language',
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
                            controller: _languageController,
                            focusNode: _languageFocusNode,
                            decoration: InputDecoration(
                              hintText: 'Enter a language',
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
                      GestureDetector(
                        onTap: _addLanguage,
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

  Widget _buildSelectedLanguages(List<Language> selectedLanguages) {
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
              'Your Languages',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            selectedLanguages.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'No languages added yet',
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
                selectedLanguages.length,
                    (index) => _buildLanguageTag(selectedLanguages[index], index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTag(Language language, int index) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Language Tag Container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            language.name,
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
            onTap: () => _removeLanguage(index),
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