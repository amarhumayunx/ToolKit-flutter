import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toolkit/widgets/settings_widgets/locked_files_tab.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/ads/banner_ad_widget.dart';
import '../../config/ad_config.dart';

class LockedFilesScreen extends StatelessWidget {
  const LockedFilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        title: 'locked_files'.tr,
        onBackPressed: () {
          Navigator.of(context).pop(false);
        },
      ),
      body: Stack(
        children: [
          const LockedFilesView(searchQuery: ''),
          // Banner ad at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BannerAdWidget(
              adUnitId: AdConfig.bannerAdLockedFilesScreen,
            ),
          ),
        ],
      ),
    );
  }
}
