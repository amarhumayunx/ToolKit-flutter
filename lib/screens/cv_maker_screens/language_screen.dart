import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/language_model.dart';
import '../../provider/language_provider.dart';
import '../../widgets/tags_input_widget.dart';

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

  // Set maximum number of languages
  final int _maxLanguages = 3;

  @override
  void dispose() {
    _languageController.dispose();
    _languageFocusNode.dispose();
    super.dispose();
  }

  void _addLanguage(String name) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    // Check if we've reached the maximum limit
    if (languageProvider.languages.length < _maxLanguages) {
      languageProvider.addLanguage(Language(name: name));
    }
  }

  void _removeLanguage(int index) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    languageProvider.removeLanguage(index);
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final languages = languageProvider.languages;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26.0),
              child: TagInputWidget<Language>(
                title: 'Add Your Languages',
                inputLabel: 'Language',
                hintText: 'Enter a language',
                items: languages,
                getItemName: (language) => language.name,
                onAdd: _addLanguage,
                onRemove: _removeLanguage,
                emptyMessage: 'No languages added yet',
                controller: _languageController,
                focusNode: _languageFocusNode,
                maxItems: _maxLanguages, // Pass the maximum limit to TagInputWidget
              ),
            ),
          ),
        ),
      ],
    );
  }
}