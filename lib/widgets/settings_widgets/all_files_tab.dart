import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:toolkit/widgets/settings_widgets/result_document_container.dart';
import 'package:toolkit/widgets/settings_widgets/sort_btn.dart';

import '../../models/file_model.dart';
import '../../services/save_document_service.dart';
import '../../utils/app_snackbar.dart';

class AllFilesView extends StatefulWidget {
  final String searchQuery;

  const AllFilesView({super.key, required this.searchQuery});

  @override
  State<AllFilesView> createState() => _AllFilesViewState();
}

class _AllFilesViewState extends State<AllFilesView> {
  late Box<FileModel> filesBox;
  String _sortBy = 'Recent';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    filesBox = await SaveDocumentService.initFilesBox();
    setState(() => _isLoading = false);
  }

  void _toggleFavorite(int index) {
    setState(() {
      final file = filesBox.getAt(index);
      if (file != null) {
        filesBox.putAt(
            index,
            FileModel(
              name: file.name,
              path: file.path,
              date: file.date,
              size: file.size,
              isFavorite: !file.isFavorite,
              isLocked: file.isLocked,
            ));
      }
    });
  }

  void _toggleLock(int index) {
    setState(() {
      final file = filesBox.getAt(index);
      if (file != null) {
        filesBox.putAt(
            index,
            FileModel(
              name: file.name,
              path: file.path,
              date: file.date,
              size: file.size,
              isFavorite: file.isFavorite,
              isLocked: !file.isLocked,
            ));
      }
    });
    AppSnackBar.show(context,
        message: filesBox.getAt(index)?.isLocked == true ? 'File locked' : 'File unlocked');
  }

  Future<void> _renameFile(int index, String newPath) async {
    try {
      final file = filesBox.getAt(index);
      if (file == null) return;

      final oldFile = File(file.path);
      final newFile = File(newPath);

      // Rename the actual file
      if (await oldFile.exists()) {
        await oldFile.rename(newPath);
      }

      // Update the database entry
      final newFileName = path.basename(newPath);
      setState(() {
        filesBox.putAt(
            index,
            FileModel(
              name: newFileName,
              path: newPath,
              date: file.date,
              size: file.size,
              isFavorite: file.isFavorite,
              isLocked: file.isLocked,
            ));
      });

      AppSnackBar.show(context, message: 'File renamed successfully');
    } catch (e) {
      AppSnackBar.show(context, message: 'Error renaming file: $e');
    }
  }

  void _deleteFile(int index) {
    setState(() {
      filesBox.deleteAt(index);
    });
    AppSnackBar.show(context, message: 'File deleted');
  }

  @override
  Widget build(BuildContext context) {
    // Filter files based on search query
    final filteredFiles = _isLoading
        ? []
        : filesBox.values
        .where((file) => file.name
        .toLowerCase()
        .contains(widget.searchQuery.toLowerCase()))
        .toList();

    // Sort files
    if (_sortBy == 'Name') {
      filteredFiles.sort((a, b) => a.name.compareTo(b.name));
    } else if (_sortBy == 'Date') {
      filteredFiles.sort((a, b) => b.date.compareTo(a.date));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            children: [
              SortButton(
                currentSort: _sortBy,
                onSortSelected: (sortOption) {
                  setState(() => _sortBy = sortOption);
                },
              ),
              const Spacer(),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
            children: [
              if (filteredFiles.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Text(
                      'No files found',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                )
              else
                ...filteredFiles.asMap().entries.map((entry) {
                  final index = entry.key;
                  final file = entry.value;

                  // Find the actual index in the box
                  int actualIndex = -1;
                  for (int i = 0; i < filesBox.length; i++) {
                    final boxFile = filesBox.getAt(i);
                    if (boxFile != null && boxFile.path == file.path) {
                      actualIndex = i;
                      break;
                    }
                  }

                  return Column(
                    children: [
                      ResultDocumentContainer(
                        documentName: file.name,
                        date: DateFormat('yy/MM/dd').format(file.date),
                        time: DateFormat('h:mma').format(file.date),
                        size: file.size,
                        isFavorite: file.isFavorite,
                        isLocked: file.isLocked,
                        filePath: file.path,
                        onFavoriteToggle: () => _toggleFavorite(actualIndex),
                        onDelete: () => _deleteFile(actualIndex),
                        onFileRenamed: (newPath) => _renameFile(actualIndex, newPath),
                        onLockToggle: () => _toggleLock(actualIndex),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                }),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }
}