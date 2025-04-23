import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class ConvertImgMainScreen extends StatelessWidget {
  const ConvertImgMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Convert Image',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          // Status bar elements (time, signal, battery)
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Convert Image illustration
              Center(
                child: SvgPicture.asset(
                  'assets/images/convert_image.svg',
                  height: 176,
                  width: 186,
                ),
              ),
              const SizedBox(height: 30),
              // Format info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Convert Image Format',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Easily convert images to various formats while maintaining quality, resolution and clarity.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Select File button
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select File',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // File selection area with dotted border
                  DottedBorderContainer(
                    color: Color(0xFF00BCD4),
                    strokeWidth: 1.5,
                    dashPattern: [5, 4],
                    borderRadius: 8,
                    child: Container(
                      width: double.infinity,
                      height: 128,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Color(0xFF00BCD4).withOpacity(0.05),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/upload_file_icon.svg',
                            height: 28,
                            width: 36,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Drag & Drop or click to \nchoose file',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: Colors.grey,
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// Dotted border container widget
class DottedBorderContainer extends StatelessWidget {
  final Widget child;
  final Color color;
  final double strokeWidth;
  final List<double> dashPattern;
  final double borderRadius;

  const DottedBorderContainer({
    Key? key,
    required this.child,
    required this.color,
    required this.strokeWidth,
    required this.dashPattern,
    required this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: CustomPaint(
            painter: _DottedBorderPainter(
              color: color,
              strokeWidth: strokeWidth,
              dashPattern: dashPattern,
              borderRadius: borderRadius,
            ),
          ),
        ),
      ],
    );
  }
}

// Custom painter for dotted border
class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final List<double> dashPattern;
  final double borderRadius;

  _DottedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashPattern,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Create a dash effect
    final Path path = Path()..addRRect(rrect);

    // Draw using dash pattern
    canvas.drawPath(
      dashPath(
        path,
        dashArray: CircularIntervalList<double>(dashPattern),
      ),
      paint,
    );
  }

  Path dashPath(
    Path path, {
    required CircularIntervalList<double> dashArray,
  }) {
    final dashPath = Path();
    final dashOffset = dashArray.next;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      var draw = true;

      while (distance < metric.length) {
        final len = dashArray.next;
        if (draw) {
          dashPath.addPath(
            metric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }

    return dashPath;
  }

  @override
  bool shouldRepaint(_DottedBorderPainter oldDelegate) => true;
}

// Helps cycle through a list repeatedly
class CircularIntervalList<T> {
  final List<T> _values;
  int _index = 0;

  CircularIntervalList(this._values);

  T get next {
    if (_index >= _values.length) {
      _index = 0;
    }
    return _values[_index++];
  }
}
