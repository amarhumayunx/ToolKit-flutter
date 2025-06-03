import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import '../../widgets/settings_widgets/all_files_tab.dart';
import '../../widgets/settings_widgets/favorites_view_tab.dart';
import '../../widgets/settings_widgets/recent_view_tab.dart';

class FilesMainScreen extends StatefulWidget {
  const FilesMainScreen({super.key});

  @override
  State<FilesMainScreen> createState() => _FilesMainScreenState();
}

class _FilesMainScreenState extends State<FilesMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Changed from 4 to 3
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header with integrated search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  if (_isSearching) const SizedBox(width: 8),
                  Expanded(
                    child: _isSearching
                        ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                        hintText: 'Search files...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        border: InputBorder.none,
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    )
                        : Row(
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          'Files',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isSearching ? Icons.close : Icons.search,
                      color: Colors.black,
                      size: 24,
                    ),
                    onPressed: _toggleSearch,
                  ),
                ],
              ),
            ),

            // Tab Bar
            // Tab Bar
            TabBar(
              controller: _tabController,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 2.0,
                  color: AppColors.primary,
                ),
                insets: EdgeInsets.only(left: 20, right: 20, bottom: 8),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              // Custom touch effect properties
              splashFactory: InkRipple.splashFactory,
              overlayColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) {
                    return AppColors.primary.withOpacity(0.12);
                  }
                  if (states.contains(MaterialState.hovered)) {
                    return AppColors.primary.withOpacity(0.08);
                  }
                  if (states.contains(MaterialState.focused)) {
                    return AppColors.primary.withOpacity(0.08);
                  }
                  return null;
                },
              ),
              tabs: const [
                Tab(text: 'RECENTS'),
                Tab(text: 'FAVOURITES'),
                Tab(text: 'ALL'), // Removed 'LOCKED' tab
              ],
            ),

            const SizedBox(height: 20),

            // Tab Bar View
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Recents Tab
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child:
                      RecentsViewTab(searchQuery: _searchController.text),
                    ),
                    // Favorites Tab
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: FavoritesView(searchQuery: _searchController.text),
                    ),
                    // All Files Tab
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: AllFilesView(searchQuery: _searchController.text),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}