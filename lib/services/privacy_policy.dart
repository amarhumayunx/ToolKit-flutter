import 'package:flutter/material.dart';
import '../screens/webview_screen.dart';

class PrivacyPolicyService {
  static const String privacyPolicyUrl = 'https://v0-toolkitx.vercel.app/';

  static Future<void> openPrivacyPolicy(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WebViewScreen(
          url: privacyPolicyUrl,
          title: 'Privacy Policy',
        ),
      ),
    );
  }
}