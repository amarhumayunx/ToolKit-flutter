import 'package:hive_ce/hive.dart';

// Remove the part directive since we're using manual adapter now
// part 'file_model.g.dart';

@HiveType(typeId: 1) // Match this with the adapter's typeId
class FileModel {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String path;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final String size;

  @HiveField(4)
  bool isFavorite;

  FileModel({
    required this.name,
    required this.path,
    required this.date,
    required this.size,
    this.isFavorite = false,
  });
}