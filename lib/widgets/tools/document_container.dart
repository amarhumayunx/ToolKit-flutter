import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tools/file_options_menu.dart';

class DocumentContainer extends StatefulWidget {
  final String filePath;
  final String? date;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const DocumentContainer({
    super.key,
    required this.filePath,
    this.date,
    this.onDelete,
    this.onTap,
  });

  @override
  State<DocumentContainer> createState() => _DocumentContainerState();
}

class _DocumentContainerState extends State<DocumentContainer> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 4,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 50,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/word_icon.svg',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ),
              Container(width: 1, color: Colors.grey.shade300),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.filePath.split('/').last,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.date ?? DateTime.now().toString().substring(0, 16),
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.onDelete != null)
                FileOptionsMenu(
                  filePath: widget.filePath,
                  onDelete: widget.onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}