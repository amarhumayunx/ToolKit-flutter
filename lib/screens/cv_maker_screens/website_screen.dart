import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/website_model.dart';
import '../../provider/user_provider.dart';
import '../../widgets/tags_input_widget.dart';

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

  // Set maximum number of websites
  final int _maxWebsites = 2;

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

  void _addLink(String url) {
    // Check if we've reached the maximum limit
    if (links.length < _maxWebsites) {
      setState(() {
        links.add(Website(
          name: 'Website',
          url: url,
        ));

        // Update the UserProvider with the full list of websites
        Provider.of<UserProvider>(context, listen: false).updateWebsites(links);
      });
    }
  }

  void _removeLink(int index) {
    setState(() {
      links.removeAt(index);

      // Update UserProvider with the updated list
      Provider.of<UserProvider>(context, listen: false).updateWebsites(links);
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
              child: TagInputWidget<Website>(
                title: 'Add Your Links',
                inputLabel: 'Link',
                hintText: 'Enter URL',
                items: links,
                getItemName: (website) => website.url,
                onAdd: _addLink,
                onRemove: _removeLink,
                emptyMessage: 'No links added yet',
                controller: _linkController,
                focusNode: _linkFocusNode,
                maxItems: _maxWebsites, // Pass the maximum limit to TagInputWidget
              ),
            ),
          ),
        ),
      ],
    );
  }
}