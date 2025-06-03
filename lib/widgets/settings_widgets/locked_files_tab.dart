import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toolkit/widgets/settings_widgets/sort_btn.dart';

class LockedFilesView extends StatefulWidget {
  final String searchQuery;

  const LockedFilesView({super.key, required this.searchQuery});

  @override
  State<LockedFilesView> createState() => _LockedFilesViewState();
}

class _LockedFilesViewState extends State<LockedFilesView> {
  String _sortBy = 'Recent';
  final Set<String> _favorites = {'Confidential Report'}; // Track favorite documents

  void _toggleFavorite(String documentName) {
    setState(() {
      if (_favorites.contains(documentName)) {
        _favorites.remove(documentName);
      } else {
        _favorites.add(documentName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter and sort files based on search query and sort option
    var files = [
      {
        'name': 'Confidential Report',
        'date': '20/02/25',
        'time': '11:30am',
        'size': '4.5 MB',
      },
      {
        'name': 'Private Notes',
        'date': '19/02/25',
        'time': '9:45am',
        'size': '1.8 MB',
      },
      {
        'name': 'Secret Project',
        'date': '18/02/25',
        'time': '3:20pm',
        'size': '6.7 MB',
      },
    ]
        .where((file) => file['name']!
        .toLowerCase()
        .contains(widget.searchQuery.toLowerCase()))
        .toList();

    // Sort files
    if (_sortBy == 'Name') {
      files.sort((a, b) => a['name']!.compareTo(b['name']!));
    } else if (_sortBy == 'Date') {
      files.sort((a, b) => b['date']!.compareTo(a['date']!));
    }

    return Column(
      children: [
        // Sort button with container and custom icon
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            children: [
              SortButton(
                currentSort: _sortBy,
                onSortSelected: (sortOption) {
                  setState(() {
                    _sortBy = sortOption;
                  });
                },
              ),
              const Spacer(),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView(
            children: [
              if (files.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Text(
                      'No locked files found',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                )
              else
                ...files.map((file) => Column(
                  children: [
                    _buildFileItem(
                      context,
                      documentName: file['name']!,
                      date: file['date']!,
                      time: file['time']!,
                      size: file['size']!,
                      isFavorite: _favorites.contains(file['name']!),
                      onFavoriteToggle: () =>
                          _toggleFavorite(file['name']!),
                    ),
                    const SizedBox(height: 12),
                  ],
                )),
              const SizedBox(height: 100), // Extra space for nav bar
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFileItem(
      BuildContext context, {
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
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/doc.png',
                        fit: BoxFit.fill,
                      ),
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Icon(
                          Icons.lock,
                          size: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
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
              child: SvgPicture.asset(
                'assets/icons/more_icon.svg',
                height: 20,
                width: 20,
              ),
            )
          ],
        ),
      ),
    );
  }
}