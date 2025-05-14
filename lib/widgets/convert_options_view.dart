import 'package:flutter/material.dart';
import '../screens/convert_image_screens/convert_img_main_screen.dart';
import '../screens/convert_pdf_screens/convert_pdf_main_screen.dart'; // Add this import
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
          final option = convertOptions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ToolItem(
              icon: option['icon']!,
              name: option['name']!,
              onTap: () {
                if (option['name'] == 'Convert Image') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ConvertImgMainScreen(),
                    ),
                  );
                } else if (option['name'] == 'Convert pdf') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ConvertPdfMainScreen(),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
