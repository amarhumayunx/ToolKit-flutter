import 'dart:io' show Platform;

/// Ad Configuration
/// Contains all ad unit IDs for the Toolkit app
/// Supports platform-specific ad unit IDs for Android and iOS
class AdConfig {
  // App ID (same for both platforms)
  static const String appId = 'ca-app-pub-3425673808153409~4673401193';

  // Test Ad Unit IDs (for development - same for both platforms)
  static const String testBannerAdUnitId = 'ca-app-pub-3940256099942544/9214589741';
  static const String testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String testNativeAdUnitId = 'ca-app-pub-3940256099942544/2247696110';
  
  // iOS Test Ad Unit IDs (same as Android test IDs)
  static const String testBannerAdUnitIdIOS = 'ca-app-pub-3940256099942544/2934735716';
  static const String testInterstitialAdUnitIdIOS = 'ca-app-pub-3940256099942544/4411468910';
  static const String testRewardedAdUnitIdIOS = 'ca-app-pub-3940256099942544/1712485313';
  static const String testNativeAdUnitIdIOS = 'ca-app-pub-3940256099942544/3986624511';

  // Production Ad Unit IDs
  // Home Screen
  static const String bannerAdHomeScreen = 'ca-app-pub-3425673808153409/1897874675';
  static const String nativeAdHomeToolsSection = 'ca-app-pub-3425673808153409/4224461596';
  static const String interstitialAdHomeNavigation = 'ca-app-pub-3425673808153409/1159314556';

  // Files Main Screen
  static const String bannerAdFilesMainScreen = 'ca-app-pub-3425673808153409/5533673832';
  static const String nativeAdFilesListItem = 'ca-app-pub-3425673808153409/4332272804';
  static const String interstitialAdFilesDeleteAction = 'ca-app-pub-3425673808153409/4290257810';

  // Compress File Screen
  static const String bannerAdCompressFileScreen = 'ca-app-pub-3425673808153409/3841318212';
  static const String interstitialAdCompressFileSuccess = 'ca-app-pub-3425673808153409/2785604452';
  static const String rewardedAdCompressLargeFile = 'ca-app-pub-3425673808153409/4140701111';

  // Compress Result Screen
  static const String bannerAdCompressResultScreen = 'ca-app-pub-3425673808153409/4962828198';
  static const String interstitialAdCompressSaveAction = 'ca-app-pub-3425673808153409/9201456103';

  // Convert PDF Main Screen
  static const String bannerAdConvertPdfMainScreen = 'ca-app-pub-3425673808153409/5342295668';
  static const String interstitialAdConvertPdfFileSelected = 'ca-app-pub-3425673808153409/2636047755';

  // PDF Format Selection Screen
  static const String bannerAdPdfFormatSelectionScreen = 'ca-app-pub-3425673808153409/9145809302';

  // PDF Save Screen
  static const String interstitialAdPdfSaveSuccess = 'ca-app-pub-3425673808153409/9908226630';
  static const String rewardedAdPdfBatchConvert = 'ca-app-pub-3425673808153409/9748251014';

  // Convert Word Main Screen
  static const String bannerAdConvertWordMainScreen = 'ca-app-pub-3425673808153409/4384437212';
  static const String interstitialAdConvertWordFileSelected = 'ca-app-pub-3425673808153409/1155638646';

  // Word Format Selection Screen
  static const String bannerAdWordFormatSelectionScreen = 'ca-app-pub-3425673808153409/6122214230';

  // Word Save Screen
  static const String interstitialAdWordSaveSuccess = 'ca-app-pub-3425673808153409/3071162024';

  // Convert Image Main Screen
  static const String bannerAdConvertImgMainScreen = 'ca-app-pub-3425673808153409/1566702187';
  static const String interstitialAdConvertImgSelected = 'ca-app-pub-3425673808153409/8243791178';

  // Image Format Selection Screen
  static const String bannerAdImgFormatSelectionScreen = 'ca-app-pub-3425673808153409/9256396034';

  // Image Save Screen
  static const String interstitialAdImgSaveSuccess = 'ca-app-pub-3425673808153409/6084820674';

  // Merge File Main Screen
  static const String bannerAdMergeFileMainScreen = 'ca-app-pub-3425673808153409/8466058549';
  static const String interstitialAdMergeFileSuccess = 'ca-app-pub-3425673808153409/3620925970';
  static const String rewardedAdMergeMultipleFiles = 'ca-app-pub-3425673808153409/3458657339';

  // Merge Result Screen
  static const String bannerAdMergeResultScreen = 'ca-app-pub-3425673808153409/9775270781';
  static const String interstitialAdMergeSaveAction = 'ca-app-pub-3425673808153409/4136958960';

  // Split Screen
  static const String bannerAdSplitScreen = 'ca-app-pub-3425673808153409/6192631883';
  static const String interstitialAdSplitFileSuccess = 'ca-app-pub-3425673808153409/3022160174';
  static const String rewardedAdSplitMultipleParts = 'ca-app-pub-3425673808153409/4444435946';

  // Split Result Screen
  static const String bannerAdSplitResultScreen = 'ca-app-pub-3425673808153409/4687978523';

  // Page Selection Screen
  static const String bannerAdPageSelectionScreen = 'ca-app-pub-3425673808153409/8327840634';

  // Rearrange File Screen
  static const String bannerAdRearrangeFileScreen = 'ca-app-pub-3425673808153409/4496406836';
  static const String interstitialAdRearrangeFileSuccess = 'ca-app-pub-3425673808153409/8244080157';

  // Rearrange Result Screen
  static const String bannerAdRearrangeResultScreen = 'ca-app-pub-3425673808153409/4304835140';

  // Rearrange Page Selection Screen
  static const String bannerAdRearrangePageSelectionScreen = 'ca-app-pub-3425673808153409/7082686501';

  // Edit File Screen
  static const String bannerAdEditFileScreen = 'ca-app-pub-3425673808153409/4167720886';
  static const String interstitialAdEditFileSaveAction = 'ca-app-pub-3425673808153409/6894984242';

  // OCR Screen
  static const String bannerAdOcrScreen = 'ca-app-pub-3425673808153409/9228475871';
  static const String interstitialAdOcrTextExtracted = 'ca-app-pub-3425673808153409/3976149191';
  static const String rewardedAdOcrBatchScan = 'ca-app-pub-3425673808153409/2784348842';

  // OCR Camera Screen
  static const String bannerAdOcrCameraScreen = 'ca-app-pub-3425673808153409/6356283410';

  // Extracted Text Screen
  static const String bannerAdExtractedTextScreen = 'ca-app-pub-3425673808153409/6114025665';

  // Scanner Screens
  static const String bannerAdScannerScreen = 'ca-app-pub-3425673808153409/6577060099';
  static const String interstitialAdScannerDocumentScanned = 'ca-app-pub-3425673808153409/1452919447';
  static const String rewardedAdScannerBatchScan = 'ca-app-pub-3425673808153409/7099804271';
  static const String bannerAdDocumentPreviewScreen = 'ca-app-pub-3425673808153409/1328602844';
  static const String bannerAdDocumentEditScreen = 'ca-app-pub-3425673808153409/2574429425';
  static const String bannerAdScannerResultScreen = 'ca-app-pub-3425673808153409/2446243396';
  static const String interstitialAdScannerSaveAction = 'ca-app-pub-3425673808153409/2450112823';
  static const String bannerAdBatchResultScreen = 'ca-app-pub-3425673808153409/8221314250';
  static const String interstitialAdBatchSaveAllAction = 'ca-app-pub-3425673808153409/3567753371';

  // CV Maker Screens
  static const String bannerAdCvMakerScreen = 'ca-app-pub-3425673808153409/9941590033';
  static const String interstitialAdCvMakerCreateNew = 'ca-app-pub-3425673808153409/8628508362';
  static const String bannerAdMainCvScreen = 'ca-app-pub-3425673808153409/9982146151';
  static const String nativeAdCvListItem = 'ca-app-pub-3425673808153409/2382857730';
  static const String bannerAdCreateCvScreen = 'ca-app-pub-3425673808153409/9374613823';
  static const String bannerAdPersonalInfoScreen = 'ca-app-pub-3425673808153409/8756694395';
  static const String bannerAdWorkExperienceScreen = 'ca-app-pub-3425673808153409/6273807767';
  static const String bannerAdEducationDetailsScreen = 'ca-app-pub-3425673808153409/6785793712';
  static const String bannerAdSkillsScreen = 'ca-app-pub-3425673808153409/2191286043';
  static const String bannerAdCertificationsScreen = 'ca-app-pub-3425673808153409/9366874961';
  static const String bannerAdLanguageScreen = 'ca-app-pub-3425673808153409/2801466618';
  static const String bannerAdCareerObjectivesScreen = 'ca-app-pub-3425673808153409/8562376405';
  static const String bannerAdWebsiteScreen = 'ca-app-pub-3425673808153409/4139259121';
  static const String bannerAdBaseCvTemplateScreen = 'ca-app-pub-3425673808153409/2191257792';
  static const String interstitialAdCvTemplateSelected = 'ca-app-pub-3425673808153409/3089901331';
  static const String rewardedAdCvPremiumTemplates = 'ca-app-pub-3425673808153409/1446303716';

  // File Transfer Screens
  static const String bannerAdFileTransferScreen = 'ca-app-pub-3425673808153409/7252012783';
  static const String interstitialAdFileTransferSuccess = 'ca-app-pub-3425673808153409/4184147694';
  static const String bannerAdQrScannerScreen = 'ca-app-pub-3425673808153409/7959084639';
  static const String bannerAdQrDisplayScreen = 'ca-app-pub-3425673808153409/7931821018';
  static const String bannerAdQrResultScreen = 'ca-app-pub-3425673808153409/5532231844';

  // Settings Screens
  static const String bannerAdSettingsScreen = 'ca-app-pub-3425673808153409/4219150172';
  static const String nativeAdSettingsListItem = 'ca-app-pub-3425673808153409/2706757958';
  static const String bannerAdProfileScreen = 'ca-app-pub-3425673808153409/1592986839';
  static const String bannerAdPhoneRecoveryScreen = 'ca-app-pub-3425673808153409/2650917632';
  static const String bannerAdSetPasswordScreen = 'ca-app-pub-3425673808153409/6427167655';
  static const String bannerAdSetPasswordProperScreen = 'ca-app-pub-3425673808153409/3262782410';
  static const String bannerAdPasswordVerificationScreen = 'ca-app-pub-3425673808153409/1949700747';
  static const String bannerAdPhoneNumberScreen = 'ca-app-pub-3425673808153409/9887583285';
  static const String bannerAdLockedFilesScreen = 'ca-app-pub-3425673808153409/8574501612';
  static const String interstitialAdUnlockFileAction = 'ca-app-pub-3425673808153409/7406041550';
  static const String bannerAdContinueWithGoogleScreen = 'ca-app-pub-3425673808153409/7010455731';

  // Other Screens
  static const String appOpenAdSplashScreen = 'ca-app-pub-3425673808153409/3466796542';
  static const String bannerAdOnboardingScreen = 'ca-app-pub-3425673808153409/3466796542'; // Note: ID not provided in ads.txt, using placeholder
  static const String bannerAdWebviewScreen = 'ca-app-pub-3425673808153409/4095984959';

  // iOS Production Ad Unit IDs
  // TODO: Replace these placeholder IDs with your actual iOS ad unit IDs from AdMob
  // For now, using Android IDs as fallback. Update these when you have iOS-specific IDs.
  
  // iOS Home Screen
  static const String bannerAdHomeScreenIOS = bannerAdHomeScreen; // TODO: Add iOS ID
  static const String nativeAdHomeToolsSectionIOS = nativeAdHomeToolsSection; // TODO: Add iOS ID
  static const String interstitialAdHomeNavigationIOS = interstitialAdHomeNavigation; // TODO: Add iOS ID
  
  // iOS Files Main Screen
  static const String bannerAdFilesMainScreenIOS = bannerAdFilesMainScreen; // TODO: Add iOS ID
  static const String nativeAdFilesListItemIOS = nativeAdFilesListItem; // TODO: Add iOS ID
  static const String interstitialAdFilesDeleteActionIOS = interstitialAdFilesDeleteAction; // TODO: Add iOS ID
  
  // iOS Compress File Screen
  static const String bannerAdCompressFileScreenIOS = bannerAdCompressFileScreen; // TODO: Add iOS ID
  static const String interstitialAdCompressFileSuccessIOS = interstitialAdCompressFileSuccess; // TODO: Add iOS ID
  static const String rewardedAdCompressLargeFileIOS = rewardedAdCompressLargeFile; // TODO: Add iOS ID
  
  // iOS Compress Result Screen
  static const String bannerAdCompressResultScreenIOS = bannerAdCompressResultScreen; // TODO: Add iOS ID
  static const String interstitialAdCompressSaveActionIOS = interstitialAdCompressSaveAction; // TODO: Add iOS ID
  
  // iOS Convert PDF Main Screen
  static const String bannerAdConvertPdfMainScreenIOS = bannerAdConvertPdfMainScreen; // TODO: Add iOS ID
  static const String interstitialAdConvertPdfFileSelectedIOS = interstitialAdConvertPdfFileSelected; // TODO: Add iOS ID
  
  // iOS PDF Format Selection Screen
  static const String bannerAdPdfFormatSelectionScreenIOS = bannerAdPdfFormatSelectionScreen; // TODO: Add iOS ID
  
  // iOS PDF Save Screen
  static const String interstitialAdPdfSaveSuccessIOS = interstitialAdPdfSaveSuccess; // TODO: Add iOS ID
  static const String rewardedAdPdfBatchConvertIOS = rewardedAdPdfBatchConvert; // TODO: Add iOS ID
  
  // iOS Convert Word Main Screen
  static const String bannerAdConvertWordMainScreenIOS = bannerAdConvertWordMainScreen; // TODO: Add iOS ID
  static const String interstitialAdConvertWordFileSelectedIOS = interstitialAdConvertWordFileSelected; // TODO: Add iOS ID
  
  // iOS Word Format Selection Screen
  static const String bannerAdWordFormatSelectionScreenIOS = bannerAdWordFormatSelectionScreen; // TODO: Add iOS ID
  
  // iOS Word Save Screen
  static const String interstitialAdWordSaveSuccessIOS = interstitialAdWordSaveSuccess; // TODO: Add iOS ID
  
  // iOS Convert Image Main Screen
  static const String bannerAdConvertImgMainScreenIOS = bannerAdConvertImgMainScreen; // TODO: Add iOS ID
  static const String interstitialAdConvertImgSelectedIOS = interstitialAdConvertImgSelected; // TODO: Add iOS ID
  
  // iOS Image Format Selection Screen
  static const String bannerAdImgFormatSelectionScreenIOS = bannerAdImgFormatSelectionScreen; // TODO: Add iOS ID
  
  // iOS Image Save Screen
  static const String interstitialAdImgSaveSuccessIOS = interstitialAdImgSaveSuccess; // TODO: Add iOS ID
  
  // iOS Merge File Main Screen
  static const String bannerAdMergeFileMainScreenIOS = bannerAdMergeFileMainScreen; // TODO: Add iOS ID
  static const String interstitialAdMergeFileSuccessIOS = interstitialAdMergeFileSuccess; // TODO: Add iOS ID
  static const String rewardedAdMergeMultipleFilesIOS = rewardedAdMergeMultipleFiles; // TODO: Add iOS ID
  
  // iOS Merge Result Screen
  static const String bannerAdMergeResultScreenIOS = bannerAdMergeResultScreen; // TODO: Add iOS ID
  static const String interstitialAdMergeSaveActionIOS = interstitialAdMergeSaveAction; // TODO: Add iOS ID
  
  // iOS Split Screen
  static const String bannerAdSplitScreenIOS = bannerAdSplitScreen; // TODO: Add iOS ID
  static const String interstitialAdSplitFileSuccessIOS = interstitialAdSplitFileSuccess; // TODO: Add iOS ID
  static const String rewardedAdSplitMultiplePartsIOS = rewardedAdSplitMultipleParts; // TODO: Add iOS ID
  
  // iOS Split Result Screen
  static const String bannerAdSplitResultScreenIOS = bannerAdSplitResultScreen; // TODO: Add iOS ID
  
  // iOS Page Selection Screen
  static const String bannerAdPageSelectionScreenIOS = bannerAdPageSelectionScreen; // TODO: Add iOS ID
  
  // iOS Rearrange File Screen
  static const String bannerAdRearrangeFileScreenIOS = bannerAdRearrangeFileScreen; // TODO: Add iOS ID
  static const String interstitialAdRearrangeFileSuccessIOS = interstitialAdRearrangeFileSuccess; // TODO: Add iOS ID
  
  // iOS Rearrange Result Screen
  static const String bannerAdRearrangeResultScreenIOS = bannerAdRearrangeResultScreen; // TODO: Add iOS ID
  
  // iOS Rearrange Page Selection Screen
  static const String bannerAdRearrangePageSelectionScreenIOS = bannerAdRearrangePageSelectionScreen; // TODO: Add iOS ID
  
  // iOS Edit File Screen
  static const String bannerAdEditFileScreenIOS = bannerAdEditFileScreen; // TODO: Add iOS ID
  static const String interstitialAdEditFileSaveActionIOS = interstitialAdEditFileSaveAction; // TODO: Add iOS ID
  
  // iOS OCR Screen
  static const String bannerAdOcrScreenIOS = bannerAdOcrScreen; // TODO: Add iOS ID
  static const String interstitialAdOcrTextExtractedIOS = interstitialAdOcrTextExtracted; // TODO: Add iOS ID
  static const String rewardedAdOcrBatchScanIOS = rewardedAdOcrBatchScan; // TODO: Add iOS ID
  
  // iOS OCR Camera Screen
  static const String bannerAdOcrCameraScreenIOS = bannerAdOcrCameraScreen; // TODO: Add iOS ID
  
  // iOS Extracted Text Screen
  static const String bannerAdExtractedTextScreenIOS = bannerAdExtractedTextScreen; // TODO: Add iOS ID
  
  // iOS Scanner Screens
  static const String bannerAdScannerScreenIOS = bannerAdScannerScreen; // TODO: Add iOS ID
  static const String interstitialAdScannerDocumentScannedIOS = interstitialAdScannerDocumentScanned; // TODO: Add iOS ID
  static const String rewardedAdScannerBatchScanIOS = rewardedAdScannerBatchScan; // TODO: Add iOS ID
  static const String bannerAdDocumentPreviewScreenIOS = bannerAdDocumentPreviewScreen; // TODO: Add iOS ID
  static const String bannerAdDocumentEditScreenIOS = bannerAdDocumentEditScreen; // TODO: Add iOS ID
  static const String bannerAdScannerResultScreenIOS = bannerAdScannerResultScreen; // TODO: Add iOS ID
  static const String interstitialAdScannerSaveActionIOS = interstitialAdScannerSaveAction; // TODO: Add iOS ID
  static const String bannerAdBatchResultScreenIOS = bannerAdBatchResultScreen; // TODO: Add iOS ID
  static const String interstitialAdBatchSaveAllActionIOS = interstitialAdBatchSaveAllAction; // TODO: Add iOS ID
  
  // iOS CV Maker Screens
  static const String bannerAdCvMakerScreenIOS = bannerAdCvMakerScreen; // TODO: Add iOS ID
  static const String interstitialAdCvMakerCreateNewIOS = interstitialAdCvMakerCreateNew; // TODO: Add iOS ID
  static const String bannerAdMainCvScreenIOS = bannerAdMainCvScreen; // TODO: Add iOS ID
  static const String nativeAdCvListItemIOS = nativeAdCvListItem; // TODO: Add iOS ID
  static const String bannerAdCreateCvScreenIOS = bannerAdCreateCvScreen; // TODO: Add iOS ID
  static const String bannerAdPersonalInfoScreenIOS = bannerAdPersonalInfoScreen; // TODO: Add iOS ID
  static const String bannerAdWorkExperienceScreenIOS = bannerAdWorkExperienceScreen; // TODO: Add iOS ID
  static const String bannerAdEducationDetailsScreenIOS = bannerAdEducationDetailsScreen; // TODO: Add iOS ID
  static const String bannerAdSkillsScreenIOS = bannerAdSkillsScreen; // TODO: Add iOS ID
  static const String bannerAdCertificationsScreenIOS = bannerAdCertificationsScreen; // TODO: Add iOS ID
  static const String bannerAdLanguageScreenIOS = bannerAdLanguageScreen; // TODO: Add iOS ID
  static const String bannerAdCareerObjectivesScreenIOS = bannerAdCareerObjectivesScreen; // TODO: Add iOS ID
  static const String bannerAdWebsiteScreenIOS = bannerAdWebsiteScreen; // TODO: Add iOS ID
  static const String bannerAdBaseCvTemplateScreenIOS = bannerAdBaseCvTemplateScreen; // TODO: Add iOS ID
  static const String interstitialAdCvTemplateSelectedIOS = interstitialAdCvTemplateSelected; // TODO: Add iOS ID
  static const String rewardedAdCvPremiumTemplatesIOS = rewardedAdCvPremiumTemplates; // TODO: Add iOS ID
  
  // iOS File Transfer Screens
  static const String bannerAdFileTransferScreenIOS = bannerAdFileTransferScreen; // TODO: Add iOS ID
  static const String interstitialAdFileTransferSuccessIOS = interstitialAdFileTransferSuccess; // TODO: Add iOS ID
  static const String bannerAdQrScannerScreenIOS = bannerAdQrScannerScreen; // TODO: Add iOS ID
  static const String bannerAdQrDisplayScreenIOS = bannerAdQrDisplayScreen; // TODO: Add iOS ID
  static const String bannerAdQrResultScreenIOS = bannerAdQrResultScreen; // TODO: Add iOS ID
  
  // iOS Settings Screens
  static const String bannerAdSettingsScreenIOS = bannerAdSettingsScreen; // TODO: Add iOS ID
  static const String nativeAdSettingsListItemIOS = nativeAdSettingsListItem; // TODO: Add iOS ID
  static const String bannerAdProfileScreenIOS = bannerAdProfileScreen; // TODO: Add iOS ID
  static const String bannerAdPhoneRecoveryScreenIOS = bannerAdPhoneRecoveryScreen; // TODO: Add iOS ID
  static const String bannerAdSetPasswordScreenIOS = bannerAdSetPasswordScreen; // TODO: Add iOS ID
  static const String bannerAdSetPasswordProperScreenIOS = bannerAdSetPasswordProperScreen; // TODO: Add iOS ID
  static const String bannerAdPasswordVerificationScreenIOS = bannerAdPasswordVerificationScreen; // TODO: Add iOS ID
  static const String bannerAdPhoneNumberScreenIOS = bannerAdPhoneNumberScreen; // TODO: Add iOS ID
  static const String bannerAdLockedFilesScreenIOS = bannerAdLockedFilesScreen; // TODO: Add iOS ID
  static const String interstitialAdUnlockFileActionIOS = interstitialAdUnlockFileAction; // TODO: Add iOS ID
  static const String bannerAdContinueWithGoogleScreenIOS = bannerAdContinueWithGoogleScreen; // TODO: Add iOS ID
  
  // iOS Other Screens
  static const String appOpenAdSplashScreenIOS = appOpenAdSplashScreen; // TODO: Add iOS ID
  static const String bannerAdOnboardingScreenIOS = bannerAdOnboardingScreen; // TODO: Add iOS ID
  static const String bannerAdWebviewScreenIOS = bannerAdWebviewScreen; // TODO: Add iOS ID

  /// Get platform-specific ad unit ID
  /// Returns iOS ID if platform is iOS and iOS ID is provided, otherwise returns Android ID
  static String getPlatformAdUnitId(String androidId, String iosId) {
    if (Platform.isIOS) {
      return iosId;
    }
    return androidId;
  }

  /// Get platform-specific test ad unit ID
  static String getPlatformTestAdUnitId(String adType) {
    final type = adType.toLowerCase();
    if (Platform.isIOS) {
      switch (type) {
        case 'banner':
          return testBannerAdUnitIdIOS;
        case 'interstitial':
          return testInterstitialAdUnitIdIOS;
        case 'rewarded':
          return testRewardedAdUnitIdIOS;
        case 'native':
          return testNativeAdUnitIdIOS;
        default:
          return testBannerAdUnitIdIOS;
      }
    } else {
      switch (type) {
        case 'banner':
          return testBannerAdUnitId;
        case 'interstitial':
          return testInterstitialAdUnitId;
        case 'rewarded':
          return testRewardedAdUnitId;
        case 'native':
          return testNativeAdUnitId;
        default:
          return testBannerAdUnitId;
      }
    }
  }

  // Helper method to get test or production ad unit ID with platform support
  static String getAdUnitId(String productionId, {bool useTestAds = false, String? adType, String? iosId}) {
    if (useTestAds) {
      return getPlatformTestAdUnitId(adType ?? 'banner');
    }
    
    // Use platform-specific ID if iOS ID is provided and platform is iOS
    if (Platform.isIOS && iosId != null) {
      return iosId;
    }
    
    return productionId;
  }

  /// Get platform-specific ad unit ID from Android and iOS constants
  /// Usage: AdConfig.getPlatformAdUnitId(AdConfig.bannerAdHomeScreen, AdConfig.bannerAdHomeScreenIOS)
  /// This automatically returns iOS ID on iOS platform, Android ID on Android platform
  static String getPlatformSpecificAdUnitId(String androidId, String iosId) {
    return getPlatformAdUnitId(androidId, iosId);
  }
}
