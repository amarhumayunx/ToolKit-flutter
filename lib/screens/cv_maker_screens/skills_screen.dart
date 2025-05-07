import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/skills_model.dart';
import '../../provider/skills_provider.dart';

import '../../widgets/tags_input_widget.dart';

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

  @override
  void dispose() {
    _skillController.dispose();
    _skillFocusNode.dispose();
    super.dispose();
  }

  void _addSkill(String name) {
    final skillsProvider = Provider.of<SkillsProvider>(context, listen: false);
    if (skillsProvider.skillItems.length < 6) {
      skillsProvider.addSkill(Skill(name: name));
    } else {
      // Show a message that maximum skills have been reached
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only add up to 6 skills'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _removeSkill(int index) {
    final skillsProvider = Provider.of<SkillsProvider>(context, listen: false);
    skillsProvider.removeSkill(index);
  }

  @override
  Widget build(BuildContext context) {
    final skillsProvider = Provider.of<SkillsProvider>(context);
    final skills = skillsProvider.skillItems;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26.0),
              child: TagInputWidget<Skill>(
                title: 'Add Your Skills',
                inputLabel: 'Skill',
                hintText: 'Enter a skill',
                items: skills,
                getItemName: (skill) => skill.name,
                onAdd: _addSkill,
                onRemove: _removeSkill,
                emptyMessage: 'No skills added yet',
                controller: _skillController,
                focusNode: _skillFocusNode,
              ),
            ),
          ),
        ),
      ],
    );
  }
}