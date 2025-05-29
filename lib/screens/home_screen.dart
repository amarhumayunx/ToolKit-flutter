import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toolkit/utils/app_colors.dart';
import '../widgets/bottom_nav_bar/home_bottom_nav.dart';
import '../widgets/buttons/create_cv_btn.dart';
import '../widgets/convert_options_view.dart';
import '../widgets/gradient_background.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_section_heading.dart';
import '../widgets/recent_view.dart';
import '../widgets/tools_list_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Important for transparent bottom nav overlay
      body: GradientBackgroundWidget(
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
                        const SectionHeading(title: 'Explore Tools'),
                        const SizedBox(height: 14),
                        const ToolsListView(),

                        const SectionHeading(title: 'Convert Options'),
                        const SizedBox(height: 14),
                        const ConvertOptionsView(),
                        // In the HomeScreen class, in the Column children list,
// after the Row with the "Recents" heading and "see all" text:

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SectionHeading(title: 'Recents'),
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Row(
                                children: [
                                  Text(
                                    'see all',
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
                          ],
                        ),
// Add the RecentsView here
                        const SizedBox(height: 4),
                        const RecentsView(),

// Extra space at bottom for nav bar
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
      ),
      bottomNavigationBar: HomeBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Handle navigation logic here
        },
      ),
    );
  }
}
