import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';
import 'package:toolkit/utils/app_colors.dart';
import 'package:toolkit/widgets/settings_widgets/result_document_container.dart';
import '../models/file_model.dart';
import '../services/save_document_service.dart';
import '../utils/app_snackbar.dart';
import '../widgets/bottom_nav_bar/home_bottom_nav.dart';
import '../widgets/buttons/create_cv_btn.dart';
import '../widgets/convert_options_view.dart';
import '../widgets/gradient_background.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_section_heading.dart';
import '../widgets/tools_list_view.dart';
import 'files_screens/files_main_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Screens for each tab
  final List<Widget> _screens = [
    const HomeContentView(),
    const Placeholder(), // Scanner screen placeholder
    const FilesMainScreen(),
  ];

  void _handleNavigation(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Important for transparent bottom nav overlay
      body: _screens[_currentIndex],
      bottomNavigationBar: HomeBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _handleNavigation,
      ),
    );
  }
}

class HomeContentView extends StatefulWidget {
  const HomeContentView({super.key});

  @override
  State<HomeContentView> createState() => _HomeContentViewState();
}

class _HomeContentViewState extends State<HomeContentView> {
  Box<FileModel>? filesBox;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    try {
      filesBox = await SaveDocumentService.initFilesBox();
      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<MapEntry<int, FileModel>> _getRecentFiles({int limit = 2}) {
    if (_isLoading || filesBox == null || filesBox!.isEmpty) return [];

    List<MapEntry<int, FileModel>> allFilesWithIndex = [];
    for (int i = 0; i < filesBox!.length; i++) {
      final file = filesBox!.getAt(i);
      if (file != null) {
        allFilesWithIndex.add(MapEntry(i, file));
      }
    }

    // Sort by date (most recent first)
    allFilesWithIndex.sort((a, b) => b.value.date.compareTo(a.value.date));

    return allFilesWithIndex.take(limit).toList();
  }

  void _toggleFavorite(int index) {
    if (filesBox == null) return;

    setState(() {
      final file = filesBox!.getAt(index);
      if (file != null) {
        filesBox!.putAt(
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
    if (filesBox == null) return;

    setState(() {
      final file = filesBox!.getAt(index);
      if (file != null) {
        filesBox!.putAt(
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

    AppSnackBar.show(
      context,
      message: filesBox!.getAt(index)?.isLocked == true
          ? 'File locked'
          : 'File unlocked',
    );
  }

  void _deleteFile(int index) {
    if (filesBox == null) return;

    setState(() {
      filesBox!.deleteAt(index);
    });

    AppSnackBar.show(
      context,
      message: 'File deleted',
    );
  }

  Future<void> _renameFile(int index, String newPath) async {
    // Similar implementation as in RecentsViewTab
    // You can copy the implementation from RecentsViewTab
  }

  Widget _buildRecentFilesSection() {
    final recentFiles = _getRecentFiles(limit: 2);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SectionHeading(title: 'recents'.tr),
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: GestureDetector(
                onTap: () {
                  // Switch to Files tab
                  final homeState =
                      context.findAncestorStateOfType<_HomeScreenState>();
                  homeState?._handleNavigation(2);
                },
                child: Row(
                  children: [
                    Text(
                      'see_all'.tr,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 4),
                    SvgPicture.asset(
                      'assets/icons/next_page_icon.svg',
                      width: 6,
                      height: 12,
                      colorFilter: const ColorFilter.mode(
                        Colors.grey,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (recentFiles.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No recent documents found',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          )
        else
          Column(
            children: recentFiles.map((entry) {
              final index = entry.key;
              final file = entry.value;
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
                    onFavoriteToggle: () => _toggleFavorite(index),
                    onDelete: () => _deleteFile(index),
                    onFileRenamed: (newPath) => _renameFile(index, newPath),
                    onLockToggle: () => _toggleLock(index),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }).toList(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackgroundWidget(
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 40),
          const HomeAppBar(),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      CreateCVButton(
                        onTap: () {},
                      ),
                      const SizedBox(height: 28),
                      SectionHeading(title: 'explore_tools'.tr),
                      const SizedBox(height: 14),
                      const ToolsListView(),
                      SectionHeading(title: 'convert_options'.tr),
                      const SizedBox(height: 14),
                      const ConvertOptionsView(),
                      const SizedBox(height: 28),
                      // Recent files section
                      _buildRecentFilesSection(),
                      const SizedBox(height: 100),
                      // Extra space at bottom for nav bar
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
