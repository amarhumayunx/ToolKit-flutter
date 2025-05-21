import 'package:flutter/foundation.dart';
import '../models/education_item_model.dart';

class EducationProvider with ChangeNotifier {
  final List<EducationItem> _educationItems = [];

  List<EducationItem> get educationItems => _educationItems;

  void addEducationItem(EducationItem item) {
    _educationItems.add(item);
    notifyListeners();
  }

  void updateEducationItem(int index, EducationItem item) {
    if (index >= 0 && index < _educationItems.length) {
      _educationItems[index] = item;
      notifyListeners();
    }
  }

  void deleteEducationItem(int index) {
    if (index >= 0 && index < _educationItems.length) { // Changed from *educationItems to _educationItems
      _educationItems.removeAt(index); // Changed from *educationItems to _educationItems
      notifyListeners();
    }
  }

  void clearEducationItems() {
    _educationItems.clear(); // Changed from *educationItems to _educationItems
    notifyListeners();
  }
}