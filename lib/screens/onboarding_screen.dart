import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_colors.dart';
import '../utils/constants.dart';
import '../widgets/onboarding_page.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: 'Scan & Convert',
      description:
          'Quickly scan and convert PDFs effortlessly with high-quality results.',
      image: 'assets/images/onboarding_images/1.svg',
      imageHeight: 230,
      imageWidth: 224,
    ),
    OnboardingContent(
      title: 'Edit & Enhance',
      description:
          'Seamless edits, smart annotations for effective document refinement.',
      image: 'assets/images/onboarding_images/2.svg',
      imageHeight: 218,
      imageWidth: 200,
    ),
    OnboardingContent(
      title: 'Protect & Share',
      description:
          'Keep your documents confidential and secure from sharing with ease.',
      image: 'assets/images/onboarding_images/3.svg',
      imageHeight: 240,
      imageWidth: 200,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBar,
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).padding.top + 80,
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // PageView in its own Expanded widget
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _contents.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return OnboardingPage(content: _contents[index]);
                      },
                    ),
                  ),

                  // Dots indicator outside PageView
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _contents.length,
                      (index) => buildDot(index),
                    ),
                  ),
                  const SizedBox(height: 80),

                  // Bottom navigation buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => const HomeScreen()),
                              );
                            },
                            child: Text(
                              'SKIP',
                              style: GoogleFonts.inter(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 36),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_currentPage == _contents.length - 1) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => const HomeScreen()),
                                );
                              } else {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.all(20),
                              fixedSize: const Size(64, 64),
                            ),
                            child: SvgPicture.asset(
                              'assets/icons/next_page_icon.svg',
                              width: 20,
                              height: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index) {
    return Container(
      height: 8,
      width: _currentPage == index ? 28 : 8,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color:
            _currentPage == index ? AppColors.dotActive : AppColors.dotInactive,
      ),
    );
  }
}
