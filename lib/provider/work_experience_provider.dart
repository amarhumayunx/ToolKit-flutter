import 'package:flutter/material.dart';
import '../models/work_experience_model.dart';

class WorkExperienceProvider extends ChangeNotifier {
  List<WorkExperienceItem> _workExperienceItems = [];

  List<WorkExperienceItem> get workExperienceItems => _workExperienceItems;

  void addWorkExperience(WorkExperienceItem item) {
    _workExperienceItems.add(item);
    notifyListeners();
  }

  void updateWorkExperience(int index, WorkExperienceItem item) {
    if (index >= 0 && index < _workExperienceItems.length) {
      _workExperienceItems[index] = item;
      notifyListeners();
    }
  }

  void deleteWorkExperience(int index) {
    if (index >= 0 && index < _workExperienceItems.length) {
      _workExperienceItems.removeAt(index);
      notifyListeners();
    }
  }

  void setWorkExperienceItems(List<WorkExperienceItem> items) {
    _workExperienceItems = items;
    notifyListeners();
  }

  // Add this new method to clear work experience items
  void clearWorkExperienceItems() {
    _workExperienceItems.clear();
    notifyListeners();
  }
}