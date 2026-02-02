import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../utils/haptic_feedback.dart';

class NavBarItem extends StatelessWidget {
  final int index;
  final String iconPath;
  final bool isActive;
  final Function(int) onTap;

  const NavBarItem({
    super.key,
    required this.index,
    required this.iconPath,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkResponse(
        onTap: () {
          HapticFeedbackUtil.selectionClick();
          onTap(index);
        },
        radius: 20,        // Very small ripple radius
        containedInkWell: true,
        // Constrains ripple to container bounds
        highlightShape: BoxShape.circle,
        // Circular highlight effect
        splashColor: const Color(0xFF00B4BE).withOpacity(0.1),
        highlightColor: const Color(0xFF00B4BE).withOpacity(0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: AnimatedScale(
            scale: isActive ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: SvgPicture.asset(
              iconPath,
              width: 26,
              height: 26,
              colorFilter: ColorFilter.mode(
                isActive ? const Color(0xFF00B4BE) : Colors.black,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
