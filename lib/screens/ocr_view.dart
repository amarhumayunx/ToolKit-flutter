import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../controller/ocr_controller.dart';
import '../widgets/bottom_nav_bar/home_bottom_nav.dart';


class OcrScreen extends StatefulWidget {
  @override
  _OcrScreenState createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  int _currentIndex = 0;
  final OcrController controller = OcrController();
  int _selectedIndex = 1; // Start with scan tab selected

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'OCR',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Illustration
                Center(
                  child: SvgPicture.asset(
                    'assets/images/illustration.svg',
                    height: 130,
                  ),
                ),
                SizedBox(height: 14),


                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white, // important for shadow to be visible
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1), // soft shadow
                        blurRadius: 6,
                        offset: Offset(0, 3), // horizontal & vertical offset
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Extract text from file',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'The OCR feature extracts text from scanned documents and images, allowing easy copying, editing, and sharing.',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),


                SizedBox(height: 14),

                // Choose File section
                Text(
                  'Choose File',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF20B2AA)),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Row(
                  children: [
                  Expanded(
                  child: TextButton(
                      onPressed: () {
                // Navigator.push(
                // context,
                // MaterialPageRoute(builder: (context) => ()),
                // );
                },
                  child: Text(
                    'Select File',
                    style: TextStyle(color: Color(0xFF20B2AA)),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                ),
        ),
                      Expanded(
                        child: TextButton(
                          onPressed: () => controller.scanNewFile(context),
                          child: Text(
                            'Scan New',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xFF20B2AA),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Scan New File container
                GestureDetector(
                  onTap: () => controller.scanNewFile(context),
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.teal[200]!,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/scan_icon.svg',
                            color: Colors.teal[300], // Optional if your SVG is monochrome or supports tinting
                            height: 32,
                            width: 32,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Scan New File',
                            style: TextStyle(
                              color: Colors.black38,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
