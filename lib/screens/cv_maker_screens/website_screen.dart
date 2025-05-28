// The issue is that websites are not being saved to the CV data structure.
// You need to check where the CV data is being collected and saved.

// 1. First, let's update the WebsitePage to handle the missing data gracefully:

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/website_model.dart';
import '../../provider/user_provider.dart';
import '../../widgets/tags_input_widget.dart';

class WebsitePage extends StatefulWidget {
  final List<Map<String, dynamic>>? initialData;

  const WebsitePage({
    this.initialData,
    super.key,
  });

  @override
  State<WebsitePage> createState() => _WebsitePageState();
}

class _WebsitePageState extends State<WebsitePage> {
  final TextEditingController _linkController = TextEditingController();
  final FocusNode _linkFocusNode = FocusNode();
  List<Website> links = [];
  bool _isInitialized = false;

  // Set maximum number of websites
  final int _maxWebsites = 2;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    if (widget.initialData != null && widget.initialData!.isNotEmpty) {
      setState(() {
        links = widget.initialData!.map((item) => Website.fromMap(item)).toList();
      });

      // Update provider
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<UserProvider>(context, listen: false)
            .updateWebsites(links);
      });
    } else {
      // Load from provider if no initial data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        if (userProvider.websites.isNotEmpty) {
          setState(() {
            links = List<Website>.from(userProvider.websites);
          });
        }
      });
    }
  }



  void _loadFromProvider() {
    if (!mounted) return;

    debugPrint('Loading from provider...');
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    debugPrint(
        'Provider websites: ${userProvider.websites.map((w) => '${w.name}: ${w.url}').toList()}');

    if (userProvider.websites.isNotEmpty && !_isInitialized) {
      debugPrint(
          'Loading ${userProvider.websites.length} websites from provider');
      setState(() {
        links = List<Website>.from(userProvider.websites);
        _isInitialized = true;
      });
      debugPrint('State updated with provider data');
    } else {
      debugPrint('Provider has no websites or already initialized');
      setState(() {
        _isInitialized = true; // Mark as initialized even if empty
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('WebsitePage didChangeDependencies called');

    // Only try to load from provider if we haven't initialized yet
    if (!_isInitialized) {
      _loadFromProvider();
    }
  }

  @override
  void dispose() {
    _linkController.dispose();
    _linkFocusNode.dispose();
    super.dispose();
  }

  void _addLink(String url) {
    debugPrint('Adding link: $url');
    debugPrint('Current links count: ${links.length}, Max: $_maxWebsites');

    if (links.length < _maxWebsites) {
      setState(() {
        links.add(Website(
          name: 'Website',
          url: url,
        ));

        Provider.of<UserProvider>(context, listen: false).updateWebsites(links);
      });

      debugPrint('Link added. New count: ${links.length}');
      debugPrint(
          'Updated links: ${links.map((w) => '${w.name}: ${w.url}').toList()}');
    } else {
      debugPrint('Cannot add link: maximum limit reached');
    }
  }

  void _removeLink(int index) {
    debugPrint('Removing link at index: $index');
    debugPrint('Link to remove: ${links[index].url}');

    setState(() {
      links.removeAt(index);
      Provider.of<UserProvider>(context, listen: false).updateWebsites(links);
    });

    debugPrint('Link removed. New count: ${links.length}');
    debugPrint(
        'Remaining links: ${links.map((w) => '${w.name}: ${w.url}').toList()}');
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.initialData != null &&
                      widget.initialData!.isNotEmpty)
                    Text(
                      'Previously saved links:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  TagInputWidget<Website>(
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
                    maxItems: _maxWebsites,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
