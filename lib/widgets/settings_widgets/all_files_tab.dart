import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:toolkit/widgets/settings_widgets/sort_btn.dart';
import '../../models/file_model.dart';
import '../../services/save_document_service.dart';

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
            ));
      }
    });
  }

  void _deleteFile(int index) {
    setState(() {
      filesBox.deleteAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File deleted')),
    );
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
                        return Column(
                          children: [
                            _buildFileItem(
                              context,
                              index: index,
                              documentName: file.name,
                              date: DateFormat('yy/MM/dd').format(file.date),
                              time: DateFormat('h:mma').format(file.date),
                              size: file.size,
                              isFavorite: file.isFavorite,
                              onFavoriteToggle: () => _toggleFavorite(index),
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

  Widget _buildFileItem(
    BuildContext context, {
    required int index,
    required String documentName,
    required String date,
    required String time,
    required String size,
    required bool isFavorite,
    required VoidCallback onFavoriteToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 50,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/doc.png',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            Container(
              width: 1,
              color: Colors.grey.shade300,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    documentName,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$date | $time | $size',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onFavoriteToggle,
              child: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? Colors.amber : Colors.grey,
                size: 24,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PopupMenuButton<String>(
                icon: SvgPicture.asset(
                  'assets/icons/more_icon.svg',
                  height: 20,
                  width: 20,
                ),
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteFile(index);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
