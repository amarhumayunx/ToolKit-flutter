import 'package:flutter/material.dart';
import 'tool_item.dart';

class ToolsListView extends StatefulWidget {
  const ToolsListView({Key? key}) : super(key: key);

  @override
  State<ToolsListView> createState() => _ToolsListViewState();
}

class _ToolsListViewState extends State<ToolsListView> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  final int _itemsPerPage = 4;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final double offset = _scrollController.offset;
      final double maxScrollExtent = _scrollController.position.maxScrollExtent;

      // Calculate which page we're on based on scroll position
      // This is a simple calculation that divides the current scroll position
      // by the total scrollable area to get a percentage, and then multiplies
      // by the number of pages (total items / items per page)
      final int page = (offset / maxScrollExtent * ((tools.length / _itemsPerPage).ceil() - 1)).round();

      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
        });
      }
    }
  }

  final List<Map<String, String>> tools = [
    {
      'icon': 'assets/icons/ocr_icon.svg',
      'name': 'OCR',
    },
    {
      'icon': 'assets/icons/compress_file_icon.svg',
      'name': 'Compress Files',
    },
    {
      'icon': 'assets/icons/cv_make_icon.svg',
      'name': 'CV Maker',
    },
    {
      'icon': 'assets/icons/edit_file_icon.svg',
      'name': 'Edit File',
    },
    {
      'icon': 'assets/icons/merge_file_icon.svg',
      'name': 'Merge Files',
    },
    {
      'icon': 'assets/icons/split_file_icon.svg',
      'name': 'Split File',
    },
    {
      'icon': 'assets/icons/rearrange_file_icon.svg',
      'name': 'Rearrange File',
    },
    {
      'icon': 'assets/icons/file_transfer_icon.svg',
      'name': 'File Transfer',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final int pagesCount = (tools.length / _itemsPerPage).ceil();

    return Column(
      children: [
        // Fixed height container for the horizontal list
        SizedBox(
          height: 130,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: tools.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ToolItem(
                  icon: tools[index]['icon'] as String,
                  name: tools[index]['name'] as String,
                  onTap: () {
                    // Handle tool tap
                  },
                ),
              );
            },
          ),
        ),

        // Pagination dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            pagesCount,
                (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index
                      ? Colors.black
                      : Colors.grey.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}