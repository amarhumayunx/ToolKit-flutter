import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'file_compression_service.dart';

class CompressedFileResultScreen extends StatelessWidget {
  final List<File> originalFiles;
  final List<File> compressedFiles;

  const CompressedFileResultScreen({
    Key? key,
    required this.originalFiles,
    required this.compressedFiles,
  }) : super(key: key);

  // Calculate total size reduction
  double get totalSizeReduction {
    double originalSize = 0;
    double compressedSize = 0;

    for (var file in originalFiles) {
      originalSize += file.lengthSync().toDouble();
    }

    for (var file in compressedFiles) {
      compressedSize += file.lengthSync().toDouble();
    }

    // Calculate percentage reduction
    if (originalSize > 0) {
      return ((originalSize - compressedSize) / originalSize) * 100;
    }

    return 0;
  }

  // Calculate total saved space
  String get totalSpaceSaved {
    double originalSize = 0;
    double compressedSize = 0;

    for (var file in originalFiles) {
      originalSize += file.lengthSync().toDouble();
    }

    for (var file in compressedFiles) {
      compressedSize += file.lengthSync().toDouble();
    }

    double savedBytes = originalSize - compressedSize;
    return FileCompressor.getReadableFileSize(savedBytes.toInt());
  }

  String _getFileSize(File file) {
    return FileCompressor.getReadableFileSize(file.lengthSync());
  }

  void _saveFile(BuildContext context, File file) {
    // In a real app, this would save the file to a user-selected location
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('File would be saved: ${path.basename(file.path)}')),
    );
  }

  void _shareFiles(BuildContext context) {
    // This is a placeholder for sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing compressed files (placeholder)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Implementation remains similar to your original code
    // Display the results and provide file handling options
    return Scaffold(
      appBar: AppBar(title: const Text('Compression Results')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: originalFiles.length,
              itemBuilder: (context, index) {
                final originalFile = originalFiles[index];
                final compressedFile = compressedFiles[index];

                final originalSize = originalFile.lengthSync();
                final compressedSize = compressedFile.lengthSync();

                final savedPercent = ((originalSize - compressedSize) / originalSize * 100);

                return ListTile(
                  title: Text(path.basename(originalFile.path)),
                  subtitle: Text(
                      "${_getFileSize(originalFile)} → ${_getFileSize(compressedFile)}\n"
                          "Saved: ${savedPercent.toStringAsFixed(1)}%"
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () => _saveFile(context, compressedFile),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Reduction:"),
                    Text("${totalSizeReduction.toStringAsFixed(1)}%"),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Space Saved:"),
                    Text(totalSpaceSaved),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _shareFiles(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Share Compressed Files'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}