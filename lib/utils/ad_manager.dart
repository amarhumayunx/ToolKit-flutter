import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../config/ad_config.dart';

/// AdManager - Manages interstitial and rewarded ads lifecycle
class AdManager {
  static InterstitialAd? _homeNavigationInterstitial;
  static InterstitialAd? _filesDeleteInterstitial;
  static InterstitialAd? _compressSuccessInterstitial;
  static InterstitialAd? _compressSaveInterstitial;
  static InterstitialAd? _convertPdfFileSelectedInterstitial;
  static InterstitialAd? _pdfSaveSuccessInterstitial;
  static InterstitialAd? _convertWordFileSelectedInterstitial;
  static InterstitialAd? _wordSaveSuccessInterstitial;
  static InterstitialAd? _convertImgSelectedInterstitial;
  static InterstitialAd? _imgSaveSuccessInterstitial;
  static InterstitialAd? _mergeFileSuccessInterstitial;
  static InterstitialAd? _mergeSaveActionInterstitial;
  static InterstitialAd? _splitFileSuccessInterstitial;
  static InterstitialAd? _rearrangeFileSuccessInterstitial;
  static InterstitialAd? _editFileSaveActionInterstitial;
  static InterstitialAd? _ocrTextExtractedInterstitial;
  
  static RewardedAd? _compressLargeFileRewarded;
  static RewardedAd? _pdfBatchConvertRewarded;
  static RewardedAd? _mergeMultipleFilesRewarded;
  static RewardedAd? _splitMultiplePartsRewarded;
  static RewardedAd? _ocrBatchScanRewarded;
  static RewardedAd? _scannerBatchScanRewarded;
  static RewardedAd? _cvPremiumTemplatesRewarded;
  
  static InterstitialAd? _scannerDocumentScannedInterstitial;
  static InterstitialAd? _scannerSaveActionInterstitial;
  static InterstitialAd? _batchSaveAllActionInterstitial;
  static InterstitialAd? _cvMakerCreateNewInterstitial;
  static InterstitialAd? _cvTemplateSelectedInterstitial;
  static InterstitialAd? _fileTransferSuccessInterstitial;
  static InterstitialAd? _unlockFileActionInterstitial;

  static int _homeNavigationCount = 0;
  static DateTime? _lastInterstitialShown;

  /// Preload interstitial ads
  static Future<void> preloadInterstitials() async {
    _loadHomeNavigationInterstitial();
    _loadFilesDeleteInterstitial();
    _loadCompressSuccessInterstitial();
    _loadCompressSaveInterstitial();
    _loadConvertPdfFileSelectedInterstitial();
    _loadPdfSaveSuccessInterstitial();
    _loadConvertWordFileSelectedInterstitial();
    _loadWordSaveSuccessInterstitial();
    _loadConvertImgSelectedInterstitial();
    _loadImgSaveSuccessInterstitial();
    _loadMergeFileSuccessInterstitial();
    _loadMergeSaveActionInterstitial();
    _loadSplitFileSuccessInterstitial();
    _loadRearrangeFileSuccessInterstitial();
    _loadEditFileSaveActionInterstitial();
    _loadOcrTextExtractedInterstitial();
  }

  /// Preload rewarded ads
  static Future<void> preloadRewardedAds() async {
    _loadCompressLargeFileRewarded();
    _loadPdfBatchConvertRewarded();
    _loadMergeMultipleFilesRewarded();
    _loadSplitMultiplePartsRewarded();
    _loadOcrBatchScanRewarded();
    _loadScannerBatchScanRewarded();
    _loadCvPremiumTemplatesRewarded();
  }
  
  /// Preload new interstitial ads
  static Future<void> preloadNewInterstitials() async {
    _loadScannerDocumentScannedInterstitial();
    _loadScannerSaveActionInterstitial();
    _loadBatchSaveAllActionInterstitial();
    _loadCvMakerCreateNewInterstitial();
    _loadCvTemplateSelectedInterstitial();
    _loadFileTransferSuccessInterstitial();
    _loadUnlockFileActionInterstitial();
  }

  /// Load home navigation interstitial
  static void _loadHomeNavigationInterstitial() {
    AdService.loadInterstitialAd(
      AdConfig.interstitialAdHomeNavigation,
      callback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _homeNavigationInterstitial = ad;
          _setupInterstitialCallbacks(ad, () => _homeNavigationInterstitial = null);
        },
        onAdFailedToLoad: (error) {
          // Failed to load ad
        },
      ),
    );
  }

  /// Load files delete interstitial
  static void _loadFilesDeleteInterstitial() {
    AdService.loadInterstitialAd(
      AdConfig.interstitialAdFilesDeleteAction,
      callback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _filesDeleteInterstitial = ad;
          _setupInterstitialCallbacks(ad, () => _filesDeleteInterstitial = null);
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdManager: Failed to load files delete interstitial: $error');
        },
      ),
    );
  }

  /// Load compress success interstitial
  static void _loadCompressSuccessInterstitial() {
    AdService.loadInterstitialAd(
      AdConfig.interstitialAdCompressFileSuccess,
      callback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _compressSuccessInterstitial = ad;
          _setupInterstitialCallbacks(ad, () => _compressSuccessInterstitial = null);
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdManager: Failed to load compress success interstitial: $error');
        },
      ),
    );
  }

  /// Load compress save interstitial
  static void _loadCompressSaveInterstitial() {
    AdService.loadInterstitialAd(
      AdConfig.interstitialAdCompressSaveAction,
      callback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _compressSaveInterstitial = ad;
          _setupInterstitialCallbacks(ad, () => _compressSaveInterstitial = null);
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdManager: Failed to load compress save interstitial: $error');
        },
      ),
    );
  }

  /// Load convert PDF file selected interstitial
  static void _loadConvertPdfFileSelectedInterstitial() {
    AdService.loadInterstitialAd(
      AdConfig.interstitialAdConvertPdfFileSelected,
      callback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _convertPdfFileSelectedInterstitial = ad;
          _setupInterstitialCallbacks(ad, () => _convertPdfFileSelectedInterstitial = null);
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdManager: Failed to load convert PDF file selected interstitial: $error');
        },
      ),
    );
  }

  /// Load compress large file rewarded ad
  static void _loadCompressLargeFileRewarded() {
    AdService.loadRewardedAd(
      AdConfig.rewardedAdCompressLargeFile,
      callback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _compressLargeFileRewarded = ad;
          _setupRewardedCallbacks(ad, () => _compressLargeFileRewarded = null);
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdManager: Failed to load compress large file rewarded ad: $error');
        },
      ),
    );
  }

  /// Setup interstitial callbacks
  static void _setupInterstitialCallbacks(InterstitialAd ad, void Function() onDispose) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _lastInterstitialShown = DateTime.now();
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        onDispose();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        onDispose();
      },
    );
  }

  /// Setup rewarded callbacks
  static void _setupRewardedCallbacks(RewardedAd ad, void Function() onDispose) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {},
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        onDispose();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        onDispose();
      },
    );
  }

  /// Show home navigation interstitial (with cooldown)
  static void showHomeNavigationInterstitial() {
    _homeNavigationCount++;
    
    // Show ad after 3-4 navigations and if cooldown period has passed
    if (_homeNavigationCount >= 3) {
      final now = DateTime.now();
      if (_lastInterstitialShown == null || 
          now.difference(_lastInterstitialShown!).inSeconds >= 60) {
        _homeNavigationInterstitial?.show();
        _homeNavigationCount = 0;
        _loadHomeNavigationInterstitial(); // Preload next ad
      }
    }
  }

  /// Show files delete interstitial
  static void showFilesDeleteInterstitial() {
    _filesDeleteInterstitial?.show();
    _loadFilesDeleteInterstitial(); // Preload next ad
  }

  /// Show compress success interstitial
  static void showCompressSuccessInterstitial() {
    _compressSuccessInterstitial?.show();
    _loadCompressSuccessInterstitial(); // Preload next ad
  }

  /// Show compress save interstitial
  static void showCompressSaveInterstitial() {
    _compressSaveInterstitial?.show();
    _loadCompressSaveInterstitial(); // Preload next ad
  }

  /// Show convert PDF file selected interstitial
  static void showConvertPdfFileSelectedInterstitial() {
    _convertPdfFileSelectedInterstitial?.show();
    _loadConvertPdfFileSelectedInterstitial(); // Preload next ad
  }

  /// Load PDF save success interstitial
  static void _loadPdfSaveSuccessInterstitial() {
    AdService.loadInterstitialAd(
      AdConfig.interstitialAdPdfSaveSuccess,
      callback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _pdfSaveSuccessInterstitial = ad;
          _setupInterstitialCallbacks(ad, () => _pdfSaveSuccessInterstitial = null);
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdManager: Failed to load PDF save success interstitial: $error');
        },
      ),
    );
  }

  /// Load convert Word file selected interstitial
  static void _loadConvertWordFileSelectedInterstitial() {
    AdService.loadInterstitialAd(
      AdConfig.interstitialAdConvertWordFileSelected,
      callback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _convertWordFileSelectedInterstitial = ad;
          _setupInterstitialCallbacks(ad, () => _convertWordFileSelectedInterstitial = null);
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdManager: Failed to load convert Word file selected interstitial: $error');
        },
      ),
    );
  }

  /// Load Word save success interstitial
  static void _loadWordSaveSuccessInterstitial() {
    AdService.loadInterstitialAd(
      AdConfig.interstitialAdWordSaveSuccess,
      callback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _wordSaveSuccessInterstitial = ad;
          _setupInterstitialCallbacks(ad, () => _wordSaveSuccessInterstitial = null);
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdManager: Failed to load Word save success interstitial: $error');
        },
      ),
    );
  }

  /// Load convert Image selected interstitial
  static void _loadConvertImgSelectedInterstitial() {
    AdService.loadInterstitialAd(
      AdConfig.interstitialAdConvertImgSelected,
      callback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _convertImgSelectedInterstitial = ad;
          _setupInterstitialCallbacks(ad, () => _convertImgSelectedInterstitial = null);
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdManager: Failed to load convert Image selected interstitial: $error');
        },
      ),
    );
  }

  /// Load Image save success interstitial
  static void _loadImgSaveSuccessInterstitial() {
    AdService.loadInterstitialAd(
      AdConfig.interstitialAdImgSaveSuccess,
      callback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _imgSaveSuccessInterstitial = ad;
          _setupInterstitialCallbacks(ad, () => _imgSaveSuccessInterstitial = null);
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdManager: Failed to load Image save success interstitial: $error');
        },
      ),
    );
  }

  /// Load merge file success interstitial
  static void _loadMergeFileSuccessInterstitial() {
    AdService.loadInterstitialAd(
      AdConfig.interstitialAdMergeFileSuccess,
      callback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _mergeFileSuccessInterstitial = ad;
          _setupInterstitialCallbacks(ad, () => _mergeFileSuccessInterstitial = null);
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdManager: Failed to load merge file success interstitial: $error');
        },
      ),
    );
  }

  /// Load merge save action interstitial
  static void _loadMergeSaveActionInterstitial() {
    AdService.loadInterstitialAd(
      AdConfig.interstitialAdMergeSaveAction,
      callback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _mergeSaveActionInterstitial = ad;
          _setupInterstitialCallbacks(ad, () => _mergeSaveActionInterstitial = null);
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdManager: Failed to load merge save action interstitial: $error');
        },
      ),
    );
  }

  /// Load split file success interstitial
  static void _loadSplitFileSuccessInterstitial() {
    AdService.loadInterstitialAd(
      AdConfig.interstitialAdSplitFileSuccess,
      callback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _splitFileSuccessInterstitial = ad;
          _setupInterstitialCallbacks(ad, () => _splitFileSuccessInterstitial = null);
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdManager: Failed to load split file success interstitial: $error');
        },
      ),
    );
  }

  /// Load rearrange file success interstitial
  static void _loadRearrangeFileSuccessInterstitial() {
    AdService.loadInterstitialAd(
      AdConfig.interstitialAdRearrangeFileSuccess,
      callback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rearrangeFileSuccessInterstitial = ad;
          _setupInterstitialCallbacks(ad, () => _rearrangeFileSuccessInterstitial = null);
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdManager: Failed to load rearrange file success interstitial: $error');
        },
      ),
    );
  }

  /// Load edit file save action interstitial
  static void _loadEditFileSaveActionInterstitial() {
    AdService.loadInterstitialAd(
      AdConfig.interstitialAdEditFileSaveAction,
      callback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _editFileSaveActionInterstitial = ad;
          _setupInterstitialCallbacks(ad, () => _editFileSaveActionInterstitial = null);
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdManager: Failed to load edit file save action interstitial: $error');
        },
      ),
    );
  }

  /// Load OCR text extracted interstitial
  static void _loadOcrTextExtractedInterstitial() {
    AdService.loadInterstitialAd(
      AdConfig.interstitialAdOcrTextExtracted,
      callback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ocrTextExtractedInterstitial = ad;
          _setupInterstitialCallbacks(ad, () => _ocrTextExtractedInterstitial = null);
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdManager: Failed to load OCR text extracted interstitial: $error');
        },
      ),
    );
  }

  /// Load PDF batch convert rewarded ad
  static void _loadPdfBatchConvertRewarded() {
    AdService.loadRewardedAd(
      AdConfig.rewardedAdPdfBatchConvert,
      callback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _pdfBatchConvertRewarded = ad;
          _setupRewardedCallbacks(ad, () => _pdfBatchConvertRewarded = null);
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdManager: Failed to load PDF batch convert rewarded ad: $error');
        },
      ),
    );
  }

  /// Load merge multiple files rewarded ad
  static void _loadMergeMultipleFilesRewarded() {
    AdService.loadRewardedAd(
      AdConfig.rewardedAdMergeMultipleFiles,
      callback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _mergeMultipleFilesRewarded = ad;
          _setupRewardedCallbacks(ad, () => _mergeMultipleFilesRewarded = null);
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdManager: Failed to load merge multiple files rewarded ad: $error');
        },
      ),
    );
  }

  /// Load split multiple parts rewarded ad
  static void _loadSplitMultiplePartsRewarded() {
    AdService.loadRewardedAd(
      AdConfig.rewardedAdSplitMultipleParts,
      callback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _splitMultiplePartsRewarded = ad;
          _setupRewardedCallbacks(ad, () => _splitMultiplePartsRewarded = null);
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdManager: Failed to load split multiple parts rewarded ad: $error');
        },
      ),
    );
  }

  /// Load OCR batch scan rewarded ad
  static void _loadOcrBatchScanRewarded() {
    AdService.loadRewardedAd(
      AdConfig.rewardedAdOcrBatchScan,
      callback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _ocrBatchScanRewarded = ad;
          _setupRewardedCallbacks(ad, () => _ocrBatchScanRewarded = null);
        },
        onAdFailedToLoad: (error) {
          debugPrint('AdManager: Failed to load OCR batch scan rewarded ad: $error');
        },
      ),
    );
  }

  /// Show PDF save success interstitial
  static void showPdfSaveSuccessInterstitial() {
    _pdfSaveSuccessInterstitial?.show();
    _loadPdfSaveSuccessInterstitial();
  }

  /// Show convert Word file selected interstitial
  static void showConvertWordFileSelectedInterstitial() {
    _convertWordFileSelectedInterstitial?.show();
    _loadConvertWordFileSelectedInterstitial();
  }

  /// Show Word save success interstitial
  static void showWordSaveSuccessInterstitial() {
    _wordSaveSuccessInterstitial?.show();
    _loadWordSaveSuccessInterstitial();
  }

  /// Show convert Image selected interstitial
  static void showConvertImgSelectedInterstitial() {
    _convertImgSelectedInterstitial?.show();
    _loadConvertImgSelectedInterstitial();
  }

  /// Show Image save success interstitial
  static void showImgSaveSuccessInterstitial() {
    _imgSaveSuccessInterstitial?.show();
    _loadImgSaveSuccessInterstitial();
  }

  /// Show merge file success interstitial
  static void showMergeFileSuccessInterstitial() {
    _mergeFileSuccessInterstitial?.show();
    _loadMergeFileSuccessInterstitial();
  }

  /// Show merge save action interstitial
  static void showMergeSaveActionInterstitial() {
    _mergeSaveActionInterstitial?.show();
    _loadMergeSaveActionInterstitial();
  }

  /// Show split file success interstitial
  static void showSplitFileSuccessInterstitial() {
    _splitFileSuccessInterstitial?.show();
    _loadSplitFileSuccessInterstitial();
  }

  /// Show rearrange file success interstitial
  static void showRearrangeFileSuccessInterstitial() {
    _rearrangeFileSuccessInterstitial?.show();
    _loadRearrangeFileSuccessInterstitial();
  }

  /// Show edit file save action interstitial
  static void showEditFileSaveActionInterstitial() {
    _editFileSaveActionInterstitial?.show();
    _loadEditFileSaveActionInterstitial();
  }

  /// Show OCR text extracted interstitial
  static void showOcrTextExtractedInterstitial() {
    _ocrTextExtractedInterstitial?.show();
    _loadOcrTextExtractedInterstitial();
  }

  /// Show PDF batch convert rewarded ad
  static Future<bool> showPdfBatchConvertRewarded({
    required Function() onRewardEarned,
  }) async {
    if (_pdfBatchConvertRewarded != null) {
      _pdfBatchConvertRewarded!.show(
        onUserEarnedReward: (ad, reward) {
          onRewardEarned();
        },
      );
      _loadPdfBatchConvertRewarded();
      return true;
    }
    return false;
  }

  /// Show merge multiple files rewarded ad
  static Future<bool> showMergeMultipleFilesRewarded({
    required Function() onRewardEarned,
  }) async {
    if (_mergeMultipleFilesRewarded != null) {
      _mergeMultipleFilesRewarded!.show(
        onUserEarnedReward: (ad, reward) {
          onRewardEarned();
        },
      );
      _loadMergeMultipleFilesRewarded();
      return true;
    }
    return false;
  }

  /// Show split multiple parts rewarded ad
  static Future<bool> showSplitMultiplePartsRewarded({
    required Function() onRewardEarned,
  }) async {
    if (_splitMultiplePartsRewarded != null) {
      _splitMultiplePartsRewarded!.show(
        onUserEarnedReward: (ad, reward) {
          onRewardEarned();
        },
      );
      _loadSplitMultiplePartsRewarded();
      return true;
    }
    return false;
  }

  /// Show OCR batch scan rewarded ad
  static Future<bool> showOcrBatchScanRewarded({
    required Function() onRewardEarned,
  }) async {
    if (_ocrBatchScanRewarded != null) {
      _ocrBatchScanRewarded!.show(
        onUserEarnedReward: (ad, reward) {
          onRewardEarned();
        },
      );
      _loadOcrBatchScanRewarded();
      return true;
    }
    return false;
  }

  /// Show compress large file rewarded ad
  static Future<bool> showCompressLargeFileRewarded({
    required Function() onRewardEarned,
  }) async {
    if (_compressLargeFileRewarded != null) {
      _compressLargeFileRewarded!.show(
        onUserEarnedReward: (ad, reward) {
          onRewardEarned();
        },
      );
      _loadCompressLargeFileRewarded(); // Preload next ad
      return true;
    }
    return false;
  }

  /// Load scanner document scanned interstitial
  static void _loadScannerDocumentScannedInterstitial() {
    AdService.loadInterstitialAd(
      AdConfig.interstitialAdScannerDocumentScanned,
      callback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _scannerDocumentScannedInterstitial = ad;
          _setupInterstitialCallbacks(ad, () => _scannerDocumentScannedInterstitial = null);
        },
        onAdFailedToLoad: (error) {},
      ),
    );
  }
  
  /// Load scanner save action interstitial
  static void _loadScannerSaveActionInterstitial() {
    AdService.loadInterstitialAd(
      AdConfig.interstitialAdScannerSaveAction,
      callback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _scannerSaveActionInterstitial = ad;
          _setupInterstitialCallbacks(ad, () => _scannerSaveActionInterstitial = null);
        },
        onAdFailedToLoad: (error) {},
      ),
    );
  }
  
  /// Load batch save all action interstitial
  static void _loadBatchSaveAllActionInterstitial() {
    AdService.loadInterstitialAd(
      AdConfig.interstitialAdBatchSaveAllAction,
      callback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _batchSaveAllActionInterstitial = ad;
          _setupInterstitialCallbacks(ad, () => _batchSaveAllActionInterstitial = null);
        },
        onAdFailedToLoad: (error) {},
      ),
    );
  }
  
  /// Load CV maker create new interstitial
  static void _loadCvMakerCreateNewInterstitial() {
    AdService.loadInterstitialAd(
      AdConfig.interstitialAdCvMakerCreateNew,
      callback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _cvMakerCreateNewInterstitial = ad;
          _setupInterstitialCallbacks(ad, () => _cvMakerCreateNewInterstitial = null);
        },
        onAdFailedToLoad: (error) {},
      ),
    );
  }
  
  /// Load CV template selected interstitial
  static void _loadCvTemplateSelectedInterstitial() {
    AdService.loadInterstitialAd(
      AdConfig.interstitialAdCvTemplateSelected,
      callback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _cvTemplateSelectedInterstitial = ad;
          _setupInterstitialCallbacks(ad, () => _cvTemplateSelectedInterstitial = null);
        },
        onAdFailedToLoad: (error) {},
      ),
    );
  }
  
  /// Load file transfer success interstitial
  static void _loadFileTransferSuccessInterstitial() {
    AdService.loadInterstitialAd(
      AdConfig.interstitialAdFileTransferSuccess,
      callback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _fileTransferSuccessInterstitial = ad;
          _setupInterstitialCallbacks(ad, () => _fileTransferSuccessInterstitial = null);
        },
        onAdFailedToLoad: (error) {},
      ),
    );
  }
  
  /// Load unlock file action interstitial
  static void _loadUnlockFileActionInterstitial() {
    AdService.loadInterstitialAd(
      AdConfig.interstitialAdUnlockFileAction,
      callback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _unlockFileActionInterstitial = ad;
          _setupInterstitialCallbacks(ad, () => _unlockFileActionInterstitial = null);
        },
        onAdFailedToLoad: (error) {},
      ),
    );
  }
  
  /// Load scanner batch scan rewarded ad
  static void _loadScannerBatchScanRewarded() {
    AdService.loadRewardedAd(
      AdConfig.rewardedAdScannerBatchScan,
      callback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _scannerBatchScanRewarded = ad;
          _setupRewardedCallbacks(ad, () => _scannerBatchScanRewarded = null);
        },
        onAdFailedToLoad: (error) {},
      ),
    );
  }
  
  /// Load CV premium templates rewarded ad
  static void _loadCvPremiumTemplatesRewarded() {
    AdService.loadRewardedAd(
      AdConfig.rewardedAdCvPremiumTemplates,
      callback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _cvPremiumTemplatesRewarded = ad;
          _setupRewardedCallbacks(ad, () => _cvPremiumTemplatesRewarded = null);
        },
        onAdFailedToLoad: (error) {},
      ),
    );
  }
  
  /// Show scanner document scanned interstitial
  static void showScannerDocumentScannedInterstitial() {
    _scannerDocumentScannedInterstitial?.show();
    _loadScannerDocumentScannedInterstitial();
  }
  
  /// Show scanner save action interstitial
  static void showScannerSaveActionInterstitial() {
    _scannerSaveActionInterstitial?.show();
    _loadScannerSaveActionInterstitial();
  }
  
  /// Show batch save all action interstitial
  static void showBatchSaveAllActionInterstitial() {
    _batchSaveAllActionInterstitial?.show();
    _loadBatchSaveAllActionInterstitial();
  }
  
  /// Show CV maker create new interstitial
  static void showCvMakerCreateNewInterstitial() {
    _cvMakerCreateNewInterstitial?.show();
    _loadCvMakerCreateNewInterstitial();
  }
  
  /// Show CV template selected interstitial
  static void showCvTemplateSelectedInterstitial() {
    _cvTemplateSelectedInterstitial?.show();
    _loadCvTemplateSelectedInterstitial();
  }
  
  /// Show file transfer success interstitial
  static void showFileTransferSuccessInterstitial() {
    _fileTransferSuccessInterstitial?.show();
    _loadFileTransferSuccessInterstitial();
  }
  
  /// Show unlock file action interstitial
  static void showUnlockFileActionInterstitial() {
    _unlockFileActionInterstitial?.show();
    _loadUnlockFileActionInterstitial();
  }
  
  /// Show scanner batch scan rewarded ad
  static Future<bool> showScannerBatchScanRewarded({
    required Function() onRewardEarned,
  }) async {
    if (_scannerBatchScanRewarded != null) {
      _scannerBatchScanRewarded!.show(
        onUserEarnedReward: (ad, reward) {
          onRewardEarned();
        },
      );
      _loadScannerBatchScanRewarded();
      return true;
    }
    return false;
  }
  
  /// Show CV premium templates rewarded ad
  static Future<bool> showCvPremiumTemplatesRewarded({
    required Function() onRewardEarned,
  }) async {
    if (_cvPremiumTemplatesRewarded != null) {
      _cvPremiumTemplatesRewarded!.show(
        onUserEarnedReward: (ad, reward) {
          onRewardEarned();
        },
      );
      _loadCvPremiumTemplatesRewarded();
      return true;
    }
    return false;
  }

  /// Dispose all ads
  static void disposeAll() {
    _homeNavigationInterstitial?.dispose();
    _filesDeleteInterstitial?.dispose();
    _compressSuccessInterstitial?.dispose();
    _compressSaveInterstitial?.dispose();
    _convertPdfFileSelectedInterstitial?.dispose();
    _pdfSaveSuccessInterstitial?.dispose();
    _convertWordFileSelectedInterstitial?.dispose();
    _wordSaveSuccessInterstitial?.dispose();
    _convertImgSelectedInterstitial?.dispose();
    _imgSaveSuccessInterstitial?.dispose();
    _mergeFileSuccessInterstitial?.dispose();
    _mergeSaveActionInterstitial?.dispose();
    _splitFileSuccessInterstitial?.dispose();
    _rearrangeFileSuccessInterstitial?.dispose();
    _editFileSaveActionInterstitial?.dispose();
    _ocrTextExtractedInterstitial?.dispose();
    _scannerDocumentScannedInterstitial?.dispose();
    _scannerSaveActionInterstitial?.dispose();
    _batchSaveAllActionInterstitial?.dispose();
    _cvMakerCreateNewInterstitial?.dispose();
    _cvTemplateSelectedInterstitial?.dispose();
    _fileTransferSuccessInterstitial?.dispose();
    _unlockFileActionInterstitial?.dispose();
    _compressLargeFileRewarded?.dispose();
    _pdfBatchConvertRewarded?.dispose();
    _mergeMultipleFilesRewarded?.dispose();
    _splitMultiplePartsRewarded?.dispose();
    _ocrBatchScanRewarded?.dispose();
    _scannerBatchScanRewarded?.dispose();
    _cvPremiumTemplatesRewarded?.dispose();
  }
}
