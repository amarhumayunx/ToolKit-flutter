// Model class for education items
class EducationItem {
  final String degree;
  final String institute;
  final String startDate;
  final String endDate;
  final String description;
  final bool isCompleted;

  EducationItem({
    required this.degree,
    required this.institute,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.isCompleted,
  });
}