import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app_open_ad_manager.dart';

/// Listens for app foreground events and shows app open ads.
class AppLifecycleReactor {
  final AppOpenAdManager appOpenAdManager;

  AppLifecycleReactor({required this.appOpenAdManager});

  void listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream
        .forEach((state) => _onAppStateChanged(state));
  }

  void _onAppStateChanged(AppState appState) {
    // Show app open ad every time app comes to foreground
    // This includes when app is resumed from background
    if (appState == AppState.foreground) {
      // Small delay to ensure smooth transition
      Future.delayed(const Duration(milliseconds: 300), () {
        appOpenAdManager.showAdIfAvailable();
      });
    }
  }

  void stopListening() {
    AppStateEventNotifier.stopListening();
  }
}
