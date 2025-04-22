import 'dart:typed_data';

class SavedCV {
  final String id;
  final String fileName;
  final String dateTime;
  final String fileSize;
  final Uint8List? thumbnailBytes; // Thumbnail image of the first page
  final String filePath; // Path to the saved PDF file

  SavedCV({
    required this.id,
    required this.fileName,
    required this.dateTime,
    required this.fileSize,
    this.thumbnailBytes,
    required this.filePath,
  });

  // Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'dateTime': dateTime,
      'fileSize': fileSize,
      'filePath': filePath,
      // Thumbnail bytes will be stored separately
    };
  }

  // Create from Map for retrieval
  factory SavedCV.fromMap(Map<String, dynamic> map, {Uint8List? thumbBytes}) {
    return SavedCV(
      id: map['id'],
      fileName: map['fileName'],
      dateTime: map['dateTime'],
      fileSize: map['fileSize'],
      filePath: map['filePath'],
      thumbnailBytes: thumbBytes,
    );
  }
}