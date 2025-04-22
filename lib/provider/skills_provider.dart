import 'package:flutter/foundation.dart';
import '../models/skills_model.dart';

class SkillsProvider with ChangeNotifier {
  List<Skill> _skillItems = [];

  List<Skill> get skillItems => _skillItems;

  void addSkill(Skill skill) {
    _skillItems.add(skill);
    notifyListeners();
  }

  void removeSkill(int index) {
    _skillItems.removeAt(index);
    notifyListeners();
  }

  void setSkills(List<Skill> skills) {
    _skillItems = skills;
    notifyListeners();
  }
  void clearSkillItems() {
    _skillItems = [];
    notifyListeners();
  }
}