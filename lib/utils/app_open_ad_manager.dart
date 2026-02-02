import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/ad_config.dart';

/// Utility class that manages loading and showing app open ads.
/// Singleton pattern to ensure single instance throughout app lifecycle.
class AppOpenAdManager {
  // Singleton instance
  static AppOpenAdManager? _instance;
  
  /// Maximum duration allowed between loading and showing the ad.
  final Duration maxCacheDuration = const Duration(hours: 4);

  /// Keep track of load time so we don't show an expired ad.
  DateTime? _appOpenLoadTime;

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;

  // Private constructor
  AppOpenAdManager._internal();

  /// Get singleton instance
  factory AppOpenAdManager() {
    _instance ??= AppOpenAdManager._internal();
    return _instance!;
  }

  /// Get the ad unit ID based on platform
  String get adUnitId {
    return AdConfig.getPlatformAdUnitId(
      AdConfig.appOpenAdSplashScreen,
      AdConfig.appOpenAdSplashScreenIOS,
    );
  }

  /// Whether an ad is available to be shown.
  bool get isAdAvailable {
    return _appOpenAd != null;
  }

  /// Load an AppOpenAd.
  void loadAd() {
    AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          print('AppOpenAd loaded');
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('AppOpenAd failed to load: $error');
          // Handle the error - ad will be retried on next foreground event
        },
      ),
    );
  }

  /// Shows the ad, if one exists and is not already being shown.
  ///
  /// If the previously cached ad has expired, this just loads and caches a
  /// new ad.
  void showAdIfAvailable() {
    if (_isShowingAd) {
      print('Tried to show ad while already showing an ad.');
      return;
    }
    
    if (!isAdAvailable) {
      print('Tried to show ad before available. Loading ad...');
      loadAd();
      // Wait a bit and try again if ad loads
      Future.delayed(const Duration(milliseconds: 500), () {
        if (isAdAvailable && !_isShowingAd) {
          _showAd();
        }
      });
      return;
    }
    
    // Check if ad has expired (more than 4 hours old)
    if (_appOpenLoadTime != null &&
        DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      print('Maximum cache duration exceeded. Loading another ad.');
      _appOpenAd!.dispose();
      _appOpenAd = null;
      loadAd();
      // Wait a bit and try again if ad loads
      Future.delayed(const Duration(milliseconds: 500), () {
        if (isAdAvailable && !_isShowingAd) {
          _showAd();
        }
      });
      return;
    }

    _showAd();
  }

  /// Internal method to show the ad
  void _showAd() {
    if (_appOpenAd == null || _isShowingAd) {
      return;
    }

    // Set the fullScreenContentCallback and show the ad.
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        print('AppOpenAd onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('AppOpenAd onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd(); // Try to load another ad
      },
      onAdDismissedFullScreenContent: (ad) {
        print('AppOpenAd onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd(); // Load the next ad
      },
      onAdImpression: (ad) {
        print('AppOpenAd onAdImpression');
      },
      onAdClicked: (ad) {
        print('AppOpenAd onAdClicked');
      },
    );

    _appOpenAd!.show();
  }

  /// Dispose the ad when no longer needed
  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
  }
}
