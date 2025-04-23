import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/website_model.dart';
import '../../provider/user_provider.dart';
import '../../utils/app_colors.dart';

class WebsitePage extends StatefulWidget {
  const WebsitePage({
    super.key,
  });

  @override
  State<WebsitePage> createState() => _WebsitePageState();
}

class _WebsitePageState extends State<WebsitePage> {
  final TextEditingController _linkController = TextEditingController();
  final FocusNode _linkFocusNode = FocusNode();
  List<Website> links = [];
  @override
  void initState() {
    super.initState();
    // Load existing websites when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingWebsites();
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Load the websites from provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (links.isEmpty && userProvider.websites.isNotEmpty) {
      setState(() {
        links = List<Website>.from(userProvider.websites);
      });
    }
  }
  void _loadExistingWebsites() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      links = userProvider.websites;
    });
  }
  @override
  void dispose() {
    _linkController.dispose();
    _linkFocusNode.dispose();
    super.dispose();
  }

  void _addLink() {
    if (_linkController.text.trim().isNotEmpty) {
      setState(() {
        links.add(Website(
          name: 'Website',
          url: _linkController.text.trim(),
        ));

        // Update the UserProvider with the full list of websites
        Provider.of<UserProvider>(context, listen: false).updateWebsites(links);

        _linkController.clear();
        _linkFocusNode.requestFocus();
      });
    }
  }

  void _removeLink(int index) {
    setState(() {
      links.removeAt(index);

      // Update UserProvider with the updated list
      if (links.isEmpty) {
        Provider.of<UserProvider>(context, listen: false).updateWebsites([]);
      } else {
        Provider.of<UserProvider>(context, listen: false).updateWebsites(links);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Links input form
                  _buildLinkForm(),

                  const SizedBox(height: 30),

                  // Display links as tags
                  _buildLinksTags(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLinkForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.30),
            blurRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Your Links',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Focus(
              onKey: (FocusNode node, RawKeyEvent event) {
                if (event is RawKeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.enter) {
                  _addLink();
                  return KeyEventResult.handled;
                }
                return KeyEventResult.ignored;
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Link',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.30),
                                blurRadius: 2,
                                offset: const Offset(0, 0),
                              ),
                            ],
                            color: AppColors.bgBoxColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextFormField(
                            controller: _linkController,
                            focusNode: _linkFocusNode,
                            decoration: InputDecoration(
                              hintText: 'Enter URL',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                color: Colors.grey,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Added space between text field and button
                      GestureDetector(
                        onTap: _addLink,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.gradientStart,
                                AppColors.gradientEnd,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinksTags() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.30),
            blurRadius: 2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Links',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            links.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        'No links added yet',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      links.length,
                      (index) => _buildLinkTag(links[index], index),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkTag(Website link, int index) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Link Tag Container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            link.url,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ),

        // Close Button (X) in circular overlay at top-right
        Positioned(
          top: -6,
          right: -4,
          child: GestureDetector(
            onTap: () => _removeLink(index),
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.close,
                  color: AppColors.primary,
                  size: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
