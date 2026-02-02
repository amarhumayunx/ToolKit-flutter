import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:open_file/open_file.dart'; // Add this package to pubspec.yaml

import 'package:toolkit/utils/app_colors.dart';

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
import '../widgets/settings_widgets/result_document_container.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/ads/banner_ad_widget.dart';
import '../widgets/ads/native_ad_widget.dart';
import '../config/ad_config.dart';
import '../utils/ad_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'files_screens/files_main_screen.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;

  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _screens = [
      const HomeContentView(),
      const Placeholder(),
      FilesMainScreen(onBackToHome: () => _handleNavigation(0)),
    ];
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleNavigation(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    // Show interstitial ad when navigating away from home
    if (_currentIndex != 0) {
      AdManager.showHomeNavigationInterstitial();
    }

    // Animate screen transition
    _animationController.reset();
    _animationController.forward();
  }

  // Public method to allow child widgets to change tabs
  void handleNavigation(int index) {
    _handleNavigation(index);
  }

  Future<bool> _onWillPop() async {
    // If not on home tab, navigate to home tab
    if (_currentIndex != 0) {
      _handleNavigation(0);
      return false;
    }

    // Show exit dialog when on home tab
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Exit App',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to exit the app?',
            style: GoogleFonts.inter(
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'cancel'.tr,
                style: GoogleFonts.inter(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Exit',
                style: GoogleFonts.inter(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldExit == true) {
      SystemNavigator.pop();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBody: true,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: _screens[_currentIndex],
        ),
        bottomNavigationBar: HomeBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _handleNavigation,
        ),
      ),
    );
  }
}

class HomeContentView extends StatefulWidget {
  const HomeContentView({super.key});

  @override
  State<HomeContentView> createState() => _HomeContentViewState();
}

class _HomeContentViewState extends State<HomeContentView>
    with AutomaticKeepAliveClientMixin {
  Box<FileModel>? filesBox;
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when the widget becomes visible again
    _refreshData();
  }

  Future<void> _refreshData() async {
    if (filesBox != null && mounted) {
      setState(() {
        // This will trigger a rebuild with the latest data
      });
    }
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

  List<MapEntry<int, FileModel>> _getRecentFiles() {
    if (_isLoading || filesBox == null || filesBox!.isEmpty) return [];

    List<MapEntry<int, FileModel>> allFilesWithIndex = [];
    for (int i = 0; i < filesBox!.length; i++) {
      final file = filesBox!.getAt(i);
      if (file != null && !file.isLocked) {
        allFilesWithIndex.add(MapEntry(i, file));
      }
    }

    allFilesWithIndex.sort((a, b) => b.value.date.compareTo(a.value.date));

    return allFilesWithIndex.take(2).toList(); // Only show 2 recent files
  }

  void _toggleFavorite(int index) {
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

  Future<void> _toggleLock(int index) async {
    final file = filesBox!.getAt(index);
    if (file != null) {
      final updatedFile = FileModel(
        name: file.name,
        path: file.path,
        date: file.date,
        size: file.size,
        isFavorite: file.isFavorite,
        isLocked: !file.isLocked,
        originalPath: file.originalPath,
        isEncrypted: file.isEncrypted,
      );

      await filesBox!.putAt(index, updatedFile);

      final success =
          await SaveDocumentService.toggleFileLock(updatedFile, index);

      if (success) {
        setState(() {});
        AppSnackBar.show(context,
            message: updatedFile.isLocked
                ? 'file_locked_encrypted'.tr
                : 'file_unlocked_decrypted'.tr);
      } else {
        await filesBox!.putAt(index, file);
        AppSnackBar.show(context, message: 'failed_toggle_file_lock'.tr);
      }
    }
  }

  // Add this method to handle file opening
  Future<void> _openFile(String filePath) async {
    try {
      final file = File(filePath);

      // Check if file exists
      if (!await file.exists()) {
        AppSnackBar.show(context, message: 'file_not_found'.tr);
        return;
      }

      // Try to open the file
      final result = await OpenFile.open(filePath);

      // Handle the result
      switch (result.type) {
        case ResultType.done:
          // File opened successfully
          break;
        case ResultType.noAppToOpen:
          AppSnackBar.show(context, message: 'no_app_to_open_file'.tr);
          break;
        case ResultType.fileNotFound:
          AppSnackBar.show(context, message: 'file_not_found'.tr);
          break;
        case ResultType.permissionDenied:
          AppSnackBar.show(context, message: 'permission_denied_open_file'.tr);
          break;
        case ResultType.error:
          AppSnackBar.show(context,
              message: '${'error_opening_file'.tr}: ${result.message}');
          break;
      }
    } catch (e) {
      AppSnackBar.show(context, message: '${'error_opening_file'.tr}: $e');
    }
  }

  Future<void> _renameFile(int index, String newPath) async {
    try {
      final file = filesBox!.getAt(index);
      if (file == null) return;

      final oldFile = File(file.path);

      if (await oldFile.exists()) {
        await oldFile.rename(newPath);
      }

      final newFileName = path.basename(newPath);
      setState(() {
        filesBox!.putAt(
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

      AppSnackBar.show(context, message: 'file_renamed_successfully'.tr);
    } catch (e) {
      AppSnackBar.show(context, message: '${'error_renaming_file'.tr}: $e');
    }
  }

  void _deleteFile(int index) {
    setState(() {
      filesBox!.deleteAt(index);
    });
    AppSnackBar.show(context, message: 'file_deleted'.tr);
  }

  void _navigateToRecentTab() {
    // Get the parent HomeScreen state and change the tab
    final homeScreenState = context.findAncestorStateOfType<_HomeScreenState>();
    if (homeScreenState != null) {
      homeScreenState.handleNavigation(2); // Files tab
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

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
              child: RefreshIndicator(
                onRefresh: () async {
                  await _refreshData();
                },
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                        const SizedBox(height: 2),
                        // Native ad between tools and convert options (using medium template)
                        Center(
                          child: NativeAdWidget(
                            adUnitId: AdConfig.nativeAdHomeToolsSection,
                            height: 250,
                            templateType: TemplateType.medium,
                          ),
                        ),
                        const SizedBox(height: 5),
                        SectionHeading(title: 'convert_options'.tr),
                        const SizedBox(height: 14),
                        const ConvertOptionsView(),

                        // Recent documents section with See All
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SectionHeading(title: 'recents'.tr),
                            ValueListenableBuilder(
                              valueListenable:
                                  filesBox?.listenable() ?? ValueNotifier(null),
                              builder: (context, box, widget) {
                                final recentFilesWithIndex = _getRecentFiles();
                                return recentFilesWithIndex.isNotEmpty
                                    ? GestureDetector(
                                        onTap: _navigateToRecentTab,
                                        child: Text(
                                          'see_all'.tr,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Recent documents list with ValueListenableBuilder
                        ValueListenableBuilder(
                          valueListenable:
                              filesBox?.listenable() ?? ValueNotifier(null),
                          builder: (context, box, widget) {
                            final recentFilesWithIndex = _getRecentFiles();

                            if (_isLoading) {
                              return Column(
                                children: List.generate(
                                  2,
                                  (index) => const DocumentSkeletonLoader(),
                                ),
                              );
                            }

                            if (recentFilesWithIndex.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  child: Text(
                                    'no_recent_documents_found'.tr,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              );
                            }

                            return Column(
                              children: recentFilesWithIndex.map((entry) {
                                final index = entry.key;
                                final file = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: ResultDocumentContainer(
                                    documentName: file.name,
                                    date: DateFormat('yy/MM/dd')
                                        .format(file.date),
                                    time: DateFormat('h:mma').format(file.date),

                                    isFavorite: file.isFavorite,
                                    isLocked: file.isLocked,
                                    filePath: file.path,
                                    onFavoriteToggle: () =>
                                        _toggleFavorite(index),
                                    onDelete: () => _deleteFile(index),
                                    onFileRenamed: (newPath) =>
                                        _renameFile(index, newPath),
                                    onLockToggle: () => _toggleLock(index),
                                    // Add the onTap callback to open files
                                    onTap: () => _openFile(file.path),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),

                        const SizedBox(height: 2),
                        // Banner ad at bottom of scroll view content
                        Center(
                          child: BannerAdWidget(
                            adUnitId: AdConfig.bannerAdHomeScreen,
                            alignment: Alignment.bottomCenter,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
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
