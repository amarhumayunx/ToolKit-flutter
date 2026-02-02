import 'package:flutter/services.dart';

/// Utility class for haptic feedback
class HapticFeedbackUtil {
  /// Light impact feedback - for subtle interactions
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact feedback - for standard button taps
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact feedback - for important actions
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection feedback - for selection changes
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Vibrate feedback - for notifications
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }
}

