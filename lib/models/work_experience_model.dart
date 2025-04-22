class WorkExperienceItem {
  final String position;
  final String company;
  final String startDate;
  final String endDate;
  final List<String> projects;
  final String description;
  final bool isCurrent;

  WorkExperienceItem({
    required this.position,
    required this.company,
    required this.startDate,
    required this.endDate,
    required this.projects,
    required this.description,
    this.isCurrent = false,
  });
}