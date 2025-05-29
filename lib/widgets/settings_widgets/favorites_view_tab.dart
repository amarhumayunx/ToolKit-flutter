import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toolkit/widgets/settings_widgets/sort_btn.dart';
class FavoritesView extends StatefulWidget {
  final String searchQuery;

  const FavoritesView({super.key, required this.searchQuery});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}
class _FavoritesViewState extends State<FavoritesView> {
  String _sortBy = 'Recent';
  Set<String> _favorites = {'Important Document'}; // Track favorite documents

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
    // Filter and sort favorites based on search query and sort option
    var favorites = [
      {
        'name': 'Important Document',
        'date': '20/02/25',
        'time': '3:45pm',
        'size': '4.7 MB',
      },
    ]
        .where((fav) => fav['name']!
        .toLowerCase()
        .contains(widget.searchQuery.toLowerCase()))
        .toList();

    // Sort favorites
    if (_sortBy == 'Name') {
      favorites.sort((a, b) => a['name']!.compareTo(b['name']!));
    } else if (_sortBy == 'Date') {
      favorites.sort((a, b) => b['date']!.compareTo(a['date']!));
    }

    return Column(
      children: [
        // Sort button with container and custom icon
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: SortButton(
                currentSort: _sortBy,
                onSortSelected: (sortOption) {
                  setState(() {
                    _sortBy = sortOption;
                  });
                },
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView(
            children: [
              if (favorites.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Text(
                      'No favorites found',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                )
              else
                ...favorites.map((fav) => Column(
                  children: [
                    _buildFavoriteItem(
                      context,
                      documentName: fav['name']!,
                      date: fav['date']!,
                      time: fav['time']!,
                      size: fav['size']!,
                      isFavorite: _favorites.contains(fav['name']!),
                      onFavoriteToggle: () => _toggleFavorite(fav['name']!),
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

  Widget _buildFavoriteItem(
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