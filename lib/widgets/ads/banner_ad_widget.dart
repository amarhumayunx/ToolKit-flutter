import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/ad_service.dart';
import '../../config/ad_config.dart';

/// Reusable Banner Ad Widget
class BannerAdWidget extends StatefulWidget {
  final String adUnitId;
  final AdSize? adSize;
  final Alignment alignment;
  final EdgeInsets? padding;
  final bool isTop; // If true, ad is at top; if false, ad is at bottom

  const BannerAdWidget({
    super.key,
    required this.adUnitId,
    this.adSize,
    this.alignment = Alignment.bottomCenter,
    this.padding,
    this.isTop = false,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    try {
      // Ensure AdService is initialized before loading ads
      await AdService.initialize();

      // Get anchored adaptive banner ad size (following official documentation)
      AdSize adSize;
      try {
        if (widget.adSize != null) {
          adSize = widget.adSize!;
        } else {
          // Get an AnchoredAdaptiveBannerAdSize before loading the ad (as per docs)
          final size =
              await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.sizeOf(context).width.truncate(),
          );
          if (size == null) {
            adSize = AdSize.banner;
          } else {
            adSize = size;
          }
        }
      } catch (e) {
        adSize = AdSize.banner;
      }

      // Load banner ad following official documentation pattern
      final bannerAd = BannerAd(
        adUnitId: AdConfig.getAdUnitId(
          widget.adUnitId,
          useTestAds: AdService.useTestAds,
          adType: 'banner',
        ),
        request: const AdRequest(),
        size: adSize,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (mounted) {
              setState(() {
                _isAdLoaded = true;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            if (mounted) {
              setState(() {
                _isAdLoaded = false;
                _bannerAd = null;
              });
            }
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
        ),
      );

      bannerAd.load();

      if (mounted) {
        setState(() {
          _bannerAd = bannerAd;
        });
      } else {
        bannerAd.dispose();
      }
    } catch (e) {
      // Error loading ad
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only show ad if it's loaded and ready
    if (_bannerAd != null && _isAdLoaded) {
      final adHeight = _bannerAd!.size.height.toDouble();
      final adWidth = _bannerAd!.size.width.toDouble();

      return Align(
        alignment: widget.isTop ? Alignment.topCenter : Alignment.bottomCenter,
        child: SafeArea(
          top: widget.isTop,
          bottom: !widget.isTop,
          child: Container(
            color: Colors.white,
            width: double.infinity,
            child: SizedBox(
              width: adWidth,
              height: adHeight,
              child: AdWidget(ad: _bannerAd!),
            ),
          ),
        ),
      );
    }

    // Don't show anything while loading or if failed
    return const SizedBox.shrink();
  }
}
