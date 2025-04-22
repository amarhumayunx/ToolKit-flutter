import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/website_model.dart';
import '../../provider/user_provider.dart';
import '../../provider/template_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/cv_templates/template_1.dart';
import '../../widgets/cv_templates/template_2.dart';
import '../../widgets/cv_templates/template_3.dart';
import '../../widgets/cv_templates/template4.dart';

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
  void dispose() {
    _linkController.dispose();
    _linkFocusNode.dispose();
    super.dispose();
  }

  void _addLink() {
    if (_linkController.text.trim().isNotEmpty) {
      setState(() {
        links.add(Website(
          name: 'Website',  // Using default name since we're not collecting it separately
          url: _linkController.text.trim(),
        ));

        // Update the UserProvider with the latest URL
        // Note: This will only store the most recent URL as per your UserProvider implementation
        Provider.of<UserProvider>(context, listen: false)
            .updateWebsite(_linkController.text.trim());

        _linkController.clear();
        _linkFocusNode.requestFocus();
      });
    }
  }

  void _removeLink(int index) {
    setState(() {
      links.removeAt(index);

      // Update UserProvider - if we removed all links or the main one
      if (links.isEmpty) {
        Provider.of<UserProvider>(context, listen: false).updateWebsite(null);
      } else {
        // If there are still links, update with the first one
        Provider.of<UserProvider>(context, listen: false).updateWebsite(links[0].url);
      }
    });
  }

  // Navigate to appropriate template based on selected template ID
  void _navigateToTemplate(BuildContext context) {
    final templateProvider = Provider.of<TemplateProvider>(context, listen: false);
    final templateId = templateProvider.selectedTemplateId;

    Widget templateScreen;

    switch (templateId) {
      case 1:
        templateScreen = Template1(websites: links);
        break;
      case 2:
        templateScreen = Template2(websites: links);
        break;
      case 3:
        templateScreen = Template3();
        break;
      case 4:
        templateScreen = Template4(websites: links);
        break;
      default:
        templateScreen = Template1(websites: links);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => templateScreen,
      ),
    );
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