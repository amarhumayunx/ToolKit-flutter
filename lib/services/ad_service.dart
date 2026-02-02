import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/ad_config.dart';

/// AdService - Centralized service for managing ads
class AdService {
  static bool _isInitialized = false;

  /// false = production ads (apne ad unit IDs). true = Google test ad IDs only.
  /// Release mode mein real ads dekhne ke liye false karo + apni device testDeviceIds mein add karo.
  static bool useTestAds = false;

  /// Apni device ko test device banana: yahan device ID add karo.
  /// Kaise nikale: README_ADS_TEST_DEVICE.md dekho.
  static const List<String> testDeviceIds = [
    '14C103ADD23A29FFD26DE6E985FD67DF',
  ];

  static bool get isUsingTestAds => useTestAds;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      if (testDeviceIds.isNotEmpty) {
        await MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: testDeviceIds),
        );
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('AdService: Failed to initialize ads: $e');
    }
  }

  /// Create and load a banner ad (following official documentation)
  static BannerAd? createBannerAd(
    String adUnitId, {
    AdSize? adSize,
    BannerAdListener? listener,
  }) {
    final productionAdUnitId = AdConfig.getAdUnitId(adUnitId,
        useTestAds: useTestAds, adType: 'banner');

    final bannerAd = BannerAd(
      adUnitId: productionAdUnitId,
      size: adSize ?? AdSize.banner,
      request: const AdRequest(),
      listener: listener ?? _defaultBannerListener,
    );

    bannerAd.load();
    return bannerAd;
  }

  /// Create and load an interstitial ad
  static Future<InterstitialAd?> loadInterstitialAd(
    String adUnitId, {
    InterstitialAdLoadCallback? callback,
  }) async {
    final productionAdUnitId = AdConfig.getAdUnitId(adUnitId,
        useTestAds: useTestAds, adType: 'interstitial');

    InterstitialAd? interstitialAd;
    await InterstitialAd.load(
      adUnitId: productionAdUnitId,
      request: const AdRequest(),
      adLoadCallback: callback ??
          InterstitialAdLoadCallback(
            onAdLoaded: (ad) {
              interstitialAd = ad;
              _setupInterstitialCallbacks(ad);
            },
            onAdFailedToLoad: (error) {
              // Log only critical errors
            },
          ),
    );

    return interstitialAd;
  }

  /// Create and load a rewarded ad
  static Future<RewardedAd?> loadRewardedAd(
    String adUnitId, {
    RewardedAdLoadCallback? callback,
  }) async {
    final productionAdUnitId = AdConfig.getAdUnitId(adUnitId,
        useTestAds: useTestAds, adType: 'rewarded');

    RewardedAd? rewardedAd;
    await RewardedAd.load(
      adUnitId: productionAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: callback ??
          RewardedAdLoadCallback(
            onAdLoaded: (ad) {
              rewardedAd = ad;
              _setupRewardedCallbacks(ad);
            },
            onAdFailedToLoad: (error) {
              // Log only critical errors
            },
          ),
    );

    return rewardedAd;
  }

  /// Create and load a native ad using native templates (following official documentation)
  static Future<NativeAd?> loadNativeAd(
    String adUnitId, {
    NativeAdListener? listener,
    TemplateType templateType = TemplateType.medium,
  }) async {
    final productionAdUnitId = AdConfig.getAdUnitId(adUnitId,
        useTestAds: useTestAds, adType: 'native');

    final nativeAd = NativeAd(
      adUnitId: productionAdUnitId,
      listener: listener ?? _defaultNativeListener,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: templateType,
        mainBackgroundColor: Colors.white,
        cornerRadius: 12.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          size: 16.0,
          style: NativeTemplateFontStyle.bold,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black,
          size: 16.0,
          style: NativeTemplateFontStyle.bold,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.grey,
          size: 14.0,
          style: NativeTemplateFontStyle.normal,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.grey,
          size: 12.0,
          style: NativeTemplateFontStyle.normal,
        ),
      ),
    );

    nativeAd.load();
    return nativeAd;
  }

  /// Setup default callbacks for interstitial ads
  static void _setupInterstitialCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        // Ad shown
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
      },
      onAdImpression: (ad) {
        // Impression recorded
      },
      onAdClicked: (ad) {
        // Ad clicked
      },
    );
  }

  /// Setup default callbacks for rewarded ads
  static void _setupRewardedCallbacks(RewardedAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        // Ad shown
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
      },
      onAdImpression: (ad) {
        // Impression recorded
      },
      onAdClicked: (ad) {
        // Ad clicked
      },
    );
  }

  /// Default banner ad listener (following official documentation)
  static final BannerAdListener _defaultBannerListener = BannerAdListener(
    onAdLoaded: (ad) {
      // Ad loaded
    },
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
    },
    onAdOpened: (ad) {
      // Ad opened
    },
    onAdClosed: (ad) {
      // Ad closed
    },
    onAdImpression: (ad) {
      // Impression recorded
    },
    onAdClicked: (ad) {
      // Ad clicked
    },
    onAdWillDismissScreen: (ad) {
      // Ad will dismiss
    },
  );

  /// Default native ad listener (following official documentation)
  static final NativeAdListener _defaultNativeListener = NativeAdListener(
    onAdLoaded: (ad) {
      // Ad loaded
    },
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
    },
    onAdOpened: (ad) {
      // Ad opened
    },
    onAdClosed: (ad) {
      // Ad closed
    },
    onAdImpression: (ad) {
      // Impression recorded
    },
    onAdClicked: (ad) {
      // Ad clicked
    },
  );

  /// Get adaptive banner ad size
  static Future<AdSize> getAdaptiveBannerSize(BuildContext context) async {
    final width = MediaQuery.of(context).size.width.truncate();
    final size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    return size ?? AdSize.banner;
  }
}
