import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/ad_service.dart';

/// Reusable Native Ad Widget using Native Templates (following official documentation)
class NativeAdWidget extends StatefulWidget {
  final String adUnitId;
  final double? height;
  final double? width;
  final TemplateType templateType;

  const NativeAdWidget({
    super.key,
    required this.adUnitId,
    this.height,
    this.width,
    this.templateType = TemplateType.medium,
  });

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
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
      
      // Load native ad using native templates (following official documentation)
      final nativeAd = await AdService.loadNativeAd(
        widget.adUnitId,
        templateType: widget.templateType,
        listener: NativeAdListener(
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
                _nativeAd = null;
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
        ),
      );

      if (mounted && nativeAd != null) {
        setState(() {
          _nativeAd = nativeAd;
        });
      }
    } catch (e) {
      // Error loading ad
    }
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only show ad if it's loaded and ready (following official documentation)
    if (_nativeAd != null && _isAdLoaded) {
      final screenWidth = MediaQuery.of(context).size.width;
      final adWidth = widget.width ?? (screenWidth - 40);
      
      // Native templates handle their own styling, so we just wrap in a container
      return Container(
        height: widget.height,
        width: adWidth,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: SizedBox(
          width: adWidth,
          height: widget.height,
          child: AdWidget(ad: _nativeAd!),
        ),
      );
    }

    // Don't show anything while loading or if failed
    return const SizedBox.shrink();
  }
}
