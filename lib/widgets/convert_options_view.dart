import 'package:flutter/material.dart';
import 'tool_item.dart';

class ConvertOptionsView extends StatelessWidget {
  const ConvertOptionsView({Key? key}) : super(key: key);

  final List<Map<String, String>> convertOptions = const [
    {
      'icon': 'assets/icons/convert_pdf.svg',
      'name': 'Convert pdf',
    },
    {
      'icon': 'assets/icons/convert_img_icon.svg',
      'name': 'Convert Image',
    },
    // Add more conversion options here as needed
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: convertOptions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ToolItem(
              icon: convertOptions[index]['icon'] as String,
              name: convertOptions[index]['name'] as String,
              onTap: () {
                // Handle convert option tap
              },
            ),
          );
        },
      ),
    );
  }
}
