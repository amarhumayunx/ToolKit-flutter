// Create a new file: lib/provider/language_provider.dart

import 'package:flutter/foundation.dart';
import '../models/language_model.dart';

class LanguageProvider with ChangeNotifier {
  final List<Language> _languages = [];

  List<Language> get languages => _languages;

  void addLanguage(Language language) {
    _languages.add(language);
    notifyListeners();
  }

  void removeLanguage(int index) {
    if (index >= 0 && index < _languages.length) {
      _languages.removeAt(index);
      notifyListeners();
    }
  }

  void clearLanguages() {
    _languages.clear();
    notifyListeners();
  }
}