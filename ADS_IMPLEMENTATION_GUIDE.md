# Ads Implementation Guide

This document provides a comprehensive guide for implementing ads in the Toolkit Flutter application. It includes screen names, ad placement locations, ad types, and naming conventions.

## ✅ Implementation Status Summary

**Implemented Screens (All from ads.txt):**
- ✅ Home Screen - Banner, Native, Interstitial
- ✅ Files Main Screen - Banner, Native (in lists), Interstitial (on delete)
- ✅ Compress Files Screen - Banner, Interstitial, Rewarded
- ✅ Compress File Result Screen - Banner, Interstitial
- ✅ Convert PDF Main Screen - Banner, Interstitial
- ✅ PDF Format Selection Screen - Banner
- ✅ PDF Save Screen - Interstitial, Rewarded
- ✅ Convert Word Main Screen - Banner, Interstitial
- ✅ Word Format Selection Screen - Banner
- ✅ Word Save Screen - Interstitial
- ✅ Convert Image Main Screen - Banner, Interstitial
- ✅ Image Format Selection Screen - Banner
- ✅ Image Save Screen - Interstitial
- ✅ Merge Files Main Screen - Banner, Interstitial, Rewarded
- ✅ Merge Result Screen - Banner, Interstitial
- ✅ Split Screen - Banner, Interstitial, Rewarded
- ✅ Split Result Screen - Banner
- ✅ Page Selection Screen - Banner
- ✅ Rearrange File Screen - Banner, Interstitial
- ✅ Rearrange Result Screen - Banner
- ✅ Rearrange Page Selection Screen - Banner
- ✅ Edit File Screen - Banner, Interstitial
- ✅ OCR Screen - Banner, Interstitial, Rewarded
- ✅ OCR Camera Screen - Banner
- ✅ Extracted Text Screen - Banner
- ✅ Scanner Screen - Banner, Interstitial, Rewarded
- ✅ Document Preview Screen - Banner
- ✅ Document Edit Screen - Banner
- ✅ Scanner Result Screen - Banner, Interstitial
- ✅ Batch Result Screen - Banner, Interstitial
- ✅ CV Maker Screen - Banner, Interstitial
- ✅ Main CV Screen - Banner
- ✅ Create CV Screen - Banner, Native (in list)
- ✅ Base CV Template Screen - Banner, Interstitial, Rewarded
- ✅ File Transfer Screen - Banner, Interstitial
- ✅ QR Scanner Screen - Banner
- ✅ QR Display Screen - Banner
- ✅ QR Result Screen - Banner
- ✅ Settings Screen - Banner, Native (in list)
- ✅ Profile Screen - Banner
- ✅ Phone Recovery Screen - Banner
- ✅ Set Password Screen - Banner
- ✅ Set Password Proper Screen - Banner
- ✅ Password Verification Screen - Banner
- ✅ Phone Number Screen - Banner
- ✅ Locked Files Screen - Banner, Interstitial
- ✅ Continue With Google Screen - Banner
- ✅ WebView Screen - Banner

**Ad Types Implemented:**
- ✅ Banner Ads: 40+ screens
- ✅ Native Ads: 3 placements (Home Screen + File Lists + CV Lists + Settings List)
- ✅ Interstitial Ads: 25+ placements
- ✅ Rewarded Ads: 7 placements

## Table of Contents
1. [Ad Types & Categories](#ad-types--categories)
2. [Screen Names & Ad Placement](#screen-names--ad-placement)
3. [Naming Conventions](#naming-conventions)
4. [Implementation Recommendations](#implementation-recommendations)
5. [Implementation Status](#implementation-status)

---

## Ad Types & Categories

### 1. Banner Ads
- **Category**: Display Ads
- **Placement**: Top or Bottom of screens
- **Use Case**: Continuous visibility, non-intrusive
- **Naming Pattern**: `banner_ad_{screen_name}`

### 2. Interstitial Ads
- **Category**: Full-Screen Ads
- **Placement**: Between screen transitions, after actions
- **Use Case**: High engagement moments
- **Naming Pattern**: `interstitial_ad_{screen_name}_{action}`

### 3. Rewarded Ads
- **Category**: Incentivized Ads
- **Placement**: Before premium features, after file operations
- **Use Case**: Unlock features, skip wait times
- **Naming Pattern**: `rewarded_ad_{feature_name}`

### 4. Native Ads
- **Category**: Content Ads
- **Placement**: Within lists, between content items
- **Use Case**: Seamless integration with UI
- **Naming Pattern**: `native_ad_{screen_name}_{position}`

### 5. App Open Ads
- **Category**: Launch Ads
- **Placement**: App startup, app resume
- **Use Case**: First impression monetization
- **Naming Pattern**: `app_open_ad`

---

## Screen Names & Ad Placement

### Main Navigation Screens

#### 1. Home Screen (`home_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `HomeScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of screen (above bottom navigation) ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/1897874675`
    - Ad Name: `banner_ad_home_screen`
  - **Native Ad**: Between "Explore Tools" and "Convert Options" sections ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/4224461596`
    - Ad Name: `native_ad_home_tools_section`
  - **Interstitial Ad**: When navigating away from home (after 3-4 navigations) ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/1159314556`
    - Ad Name: `interstitial_ad_home_navigation`
- **Implementation Notes**: 
  - Banner ad displayed at bottom with padding to avoid bottom navigation
  - Native ad placed between ToolsListView and ConvertOptionsView sections
  - Interstitial ad shown with cooldown period (60 seconds) after 3+ navigations

#### 2. Files Main Screen (`files_main_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `FilesMainScreen`
- **Ad Placements**:
  - **Banner Ad**: Top of file list ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/5533673832`
    - Ad Name: `banner_ad_files_main_screen`
  - **Native Ad**: After every 5th file item in the list ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/4332272804`
    - Ad Name: `native_ad_files_list_item_{index}`
    - **Implementation**: Native ads inserted after every 5th file item (positions 5, 10, 15, etc.) in AllFilesView, RecentsViewTab, and FavoritesView
  - **Interstitial Ad**: After deleting a file ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/4290257810`
    - Ad Name: `interstitial_ad_files_delete_action`
    - **Implementation**: Interstitial ad shown immediately after successful file deletion in all three tab widgets

---

### Tool Screensx

#### 3. Compress Files Screen (`compress_file_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `CompressFileScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of screen ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/3841318212`
    - Ad Name: `banner_ad_compress_file_screen`
  - **Interstitial Ad**: After successful compression ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/2785604452`
    - Ad Name: `interstitial_ad_compress_file_success`
  - **Rewarded Ad**: Before compressing large files (>10MB) ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/4140701111`
    - Ad Name: `rewarded_ad_compress_large_file`
- **Implementation Notes**: 
  - Rewarded ad shown when any file exceeds 10MB before compression
  - Interstitial ad displayed after compression completes successfully

#### 4. Compress File Result Screen (`compress_file_result_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `CompressFileResultScreen`
- **Ad Placements**:
  - **Banner Ad**: Top of result display ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/4962828198`
    - Ad Name: `banner_ad_compress_result_screen`
  - **Interstitial Ad**: When saving compressed file ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/9201456103`
    - Ad Name: `interstitial_ad_compress_save_action`
- **Implementation Notes**: 
  - Interstitial ad shown before saving single file or all files as zip

#### 5. Convert PDF Main Screen (`convert_pdf_main_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `ConvertPdfMainScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of screen ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/5342295668`
    - Ad Name: `banner_ad_convert_pdf_main_screen`
  - **Interstitial Ad**: After file selection ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/2636047755`
    - Ad Name: `interstitial_ad_convert_pdf_file_selected`
- **Implementation Notes**: 
  - Interstitial ad shown when user clicks "Next" after selecting a PDF file

#### 6. PDF Format Selection Screen (`pdf_format_selection_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `PdfFormatSelectionScreen`
- **Ad Placements**:
  - **Banner Ad**: Top of format options ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/9145809302`
    - Ad Name: `banner_ad_pdf_format_selection_screen`

#### 7. PDF Save Screen (`pdf_save_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `PdfSaveScreen`
- **Ad Placements**:
  - **Interstitial Ad**: After successful conversion and save ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/9908226630`
    - Ad Name: `interstitial_ad_pdf_save_success`
  - **Rewarded Ad**: Before converting multiple files ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/9748251014`
    - Ad Name: `rewarded_ad_pdf_batch_convert`
- **Implementation Notes**: 
  - Interstitial ad shown after successful PDF conversion
  - Rewarded ad available for batch conversion scenarios

#### 8. Convert Word Main Screen (`convert_word_main_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `ConvertWordMainScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of screen ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/4384437212`
    - Ad Name: `banner_ad_convert_word_main_screen`
  - **Interstitial Ad**: After file selection ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/1155638646`
    - Ad Name: `interstitial_ad_convert_word_file_selected`
- **Implementation Notes**: 
  - Interstitial ad shown when user clicks "Next" after selecting a Word file

#### 9. Word Format Selection Screen (`word_format_selection_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `WordFormatSelectionScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of format options ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/6122214230`
    - Ad Name: `banner_ad_word_format_selection_screen`

#### 10. Word Save Screen (`word_save_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `WordSaveScreen`
- **Ad Placements**:
  - **Interstitial Ad**: After successful conversion ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/3071162024`
    - Ad Name: `interstitial_ad_word_save_success`
- **Implementation Notes**: 
  - Interstitial ad shown after successful Word to PDF/Image conversion

#### 11. Convert Image Main Screen (`convert_img_main_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `ConvertImgMainScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of screen ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/1566702187`
    - Ad Name: `banner_ad_convert_img_main_screen`
  - **Interstitial Ad**: After image selection ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/8243791178`
    - Ad Name: `interstitial_ad_convert_img_selected`
- **Implementation Notes**: 
  - Interstitial ad shown when user clicks "Next" after selecting images

#### 12. Image Format Selection Screen (`format_selection_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `FormatSelectionScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of format options ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/9256396034`
    - Ad Name: `banner_ad_img_format_selection_screen`

#### 13. Image Save Screen (`save_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `SaveScreen`
- **Ad Placements**:
  - **Interstitial Ad**: After successful conversion ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/6084820674`
    - Ad Name: `interstitial_ad_img_save_success`
- **Implementation Notes**: 
  - Interstitial ad shown after successful image to Word/PDF conversion

#### 14. Merge Files Main Screen (`merge_file_main_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `MergeFileMainScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of screen ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/8466058549`
    - Ad Name: `banner_ad_merge_file_main_screen`
  - **Interstitial Ad**: After merging files ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/3620925970`
    - Ad Name: `interstitial_ad_merge_file_success`
  - **Rewarded Ad**: Before merging more than 3 files ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/3458657339`
    - Ad Name: `rewarded_ad_merge_multiple_files`
- **Implementation Notes**: 
  - Rewarded ad shown when merging more than 3 files
  - Interstitial ad displayed after successful merge

#### 15. Merge Result Screen (`merge_result_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `MergeResultScreen`
- **Ad Placements**:
  - **Banner Ad**: Top of result display ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/9775270781`
    - Ad Name: `banner_ad_merge_result_screen`
  - **Interstitial Ad**: When saving merged file ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/4136958960`
    - Ad Name: `interstitial_ad_merge_save_action`
- **Implementation Notes**: 
  - Interstitial ad shown when user saves the merged file

#### 16. Split Screen (`split_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `SplitScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of screen ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/6192631883`
    - Ad Name: `banner_ad_split_screen`
  - **Interstitial Ad**: After splitting file ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/3022160174`
    - Ad Name: `interstitial_ad_split_file_success`
  - **Rewarded Ad**: Before splitting into multiple parts ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/4444435946`
    - Ad Name: `rewarded_ad_split_multiple_parts`
- **Implementation Notes**: 
  - Rewarded ad shown when splitting into multiple parts
  - Interstitial ad displayed after successful split

#### 17. Split Result Screen (`split_result_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `SplitProgressScreen`
- **Ad Placements**:
  - **Banner Ad**: Top of result display ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/4687978523`
    - Ad Name: `banner_ad_split_result_screen`

#### 18. Page Selection Screen (`page_selection_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `PageSelectionScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of page selection ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/8327840634`
    - Ad Name: `banner_ad_page_selection_screen`

#### 19. Rearrange File Screen (`rearrange_file_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `RearrangeFileScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of screen ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/4496406836`
    - Ad Name: `banner_ad_rearrange_file_screen`
  - **Interstitial Ad**: After rearranging pages ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/8244080157`
    - Ad Name: `interstitial_ad_rearrange_file_success`
- **Implementation Notes**: 
  - Interstitial ad shown after successful page rearrangement

#### 20. Rearrange File Result Screen (`rearrange_file_result_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `RearrangeFileResultScreen`
- **Ad Placements**:
  - **Banner Ad**: Top of result display ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/4304835140`
    - Ad Name: `banner_ad_rearrange_result_screen`

#### 21. Rearrange Page Selection Screen (`rearrange_file_page_selection.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `RearrangeFilePageSelection`
- **Ad Placements**:
  - **Banner Ad**: Bottom of page selection ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/7082686501`
    - Ad Name: `banner_ad_rearrange_page_selection_screen`

#### 22. Edit File Screen (`edit_file_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `EditFileScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of editor ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/4167720886`
    - Ad Name: `banner_ad_edit_file_screen`
  - **Interstitial Ad**: After saving edited file ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/6894984242`
    - Ad Name: `interstitial_ad_edit_file_save_action`
- **Implementation Notes**: 
  - Interstitial ad shown when user saves edited file

---

### OCR & Scanner Screens

#### 23. OCR Screen (`ocr_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `OcrScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of screen ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/9228475871`
    - Ad Name: `banner_ad_ocr_screen`
  - **Interstitial Ad**: After text extraction ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/3976149191`
    - Ad Name: `interstitial_ad_ocr_text_extracted`
  - **Rewarded Ad**: Before scanning multiple pages ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/2784348842`
    - Ad Name: `rewarded_ad_ocr_batch_scan`
- **Implementation Notes**: 
  - Interstitial ad shown after successful text extraction
  - Rewarded ad available for batch scanning scenarios

#### 24. OCR Camera Screen (`ocr_camera_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `OcrCameraScreen`
- **Ad Placements**:
  - **Banner Ad**: Top of camera view (non-intrusive) ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/6356283410`
    - Ad Name: `banner_ad_ocr_camera_screen`

#### 25. Extracted Text Screen (`extracted_text_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `ExtractedTextScreen`
- **Ad Placements**:
  - **Banner Ad**: Top of text display ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/6114025665`
    - Ad Name: `banner_ad_extracted_text_screen`

#### 26. Scanner Screen (`scanner_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `ScannerScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of scanner view ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/6577060099`
    - Ad Name: `banner_ad_scanner_screen`
  - **Interstitial Ad**: After scanning document ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/1452919447`
    - Ad Name: `interstitial_ad_scanner_document_scanned`
    - **Implementation**: Call `AdManager.showScannerDocumentScannedInterstitial()` after document scan
  - **Rewarded Ad**: Before batch scanning ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/7099804271`
    - Ad Name: `rewarded_ad_scanner_batch_scan`
    - **Implementation**: Call `AdManager.showScannerBatchScanRewarded()` before batch scan

#### 27. Document Preview Screen (`document_preview_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `DocumentPreviewScreen`
- **Ad Placements**:
  - **Banner Ad**: Top of preview ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/1328602844`
    - Ad Name: `banner_ad_document_preview_screen`

#### 28. Document Edit Screen (`document_edit_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `DocumentEditScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of editor ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/2574429425`
    - Ad Name: `banner_ad_document_edit_screen`
    - **Implementation**: Banner ad positioned at bottom with padding for buttons

#### 29. Result Screen (`result_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `ResultScreen`
- **Ad Placements**:
  - **Banner Ad**: Top of result display ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/2446243396`
    - Ad Name: `banner_ad_scanner_result_screen`
  - **Interstitial Ad**: When saving scanned document ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/2450112823`
    - Ad Name: `interstitial_ad_scanner_save_action`
    - **Implementation**: Interstitial ad shown when save button is clicked

#### 30. Batch Result Screen (`batch_result_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `BatchResultScreen`
- **Ad Placements**:
  - **Banner Ad**: Top of batch results ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/8221314250`
    - Ad Name: `banner_ad_batch_result_screen`
  - **Interstitial Ad**: When saving all documents ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/3567753371`
    - Ad Name: `interstitial_ad_batch_save_all_action`
    - **Implementation**: Call `AdManager.showBatchSaveAllActionInterstitial()` when saving all

---

### CV Maker Screens

#### 31. CV Maker Screen (`cv_maker_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `CvMakerScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of screen ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/9941590033`
    - Ad Name: `banner_ad_cv_maker_screen`
  - **Interstitial Ad**: After creating new CV ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/8628508362`
    - Ad Name: `interstitial_ad_cv_maker_create_new`
    - **Implementation**: Interstitial ad shown when user selects a template to create new CV

#### 32. Main CV Screen (`main_cv_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `MainCvScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of screen (above navigation button) ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/9982146151`
    - Ad Name: `banner_ad_main_cv_screen`
    - **Implementation**: Banner ad positioned at bottom, navigation button moved up

#### 33. Create CV Screen (`create_cv_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `CreateCvScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of screen ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/9374613823`
    - Ad Name: `banner_ad_create_cv_screen`
  - **Native Ad**: After every 4th CV in the list ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/2382857730`
    - Ad Name: `native_ad_cv_list_item_{index}`
    - **Implementation**: Native ads inserted after every 4th CV item in GridView

#### 34. Personal Info Screen (`personal_info_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `PersonalInfoPage`
- **Ad Placements**:
  - **Banner Ad**: Bottom of form (via MainCVScreen banner) ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/8756694395`
    - Ad Name: `banner_ad_personal_info_screen`
    - **Implementation**: Banner ad shown in MainCVScreen which contains PersonalInfoPage

#### 35. Work Experience Screen (`work_experience_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `WorkExperiencePage`
- **Ad Placements**:
  - **Banner Ad**: Bottom of form (via MainCVScreen banner) ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/6273807767`
    - Ad Name: `banner_ad_work_experience_screen`
    - **Implementation**: Banner ad shown in MainCVScreen which contains WorkExperiencePage

#### 36. Education Details Screen (`education_details_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `EducationDetailPage`
- **Ad Placements**:
  - **Banner Ad**: Bottom of form (via MainCVScreen banner) ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/6785793712`
    - Ad Name: `banner_ad_education_details_screen`
    - **Implementation**: Banner ad shown in MainCVScreen which contains EducationDetailPage

#### 37. Skills Screen (`skills_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `SkillsPage`
- **Ad Placements**:
  - **Banner Ad**: Bottom of form (via MainCVScreen banner) ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/2191286043`
    - Ad Name: `banner_ad_skills_screen`
    - **Implementation**: Banner ad shown in MainCVScreen which contains SkillsPage

#### 38. Certifications Screen (`certifications_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `CertificationPage`
- **Ad Placements**:
  - **Banner Ad**: Bottom of form (via MainCVScreen banner) ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/9366874961`
    - Ad Name: `banner_ad_certifications_screen`
    - **Implementation**: Banner ad shown in MainCVScreen which contains CertificationPage

#### 39. Language Screen (`language_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `LanguagesPage`
- **Ad Placements**:
  - **Banner Ad**: Bottom of form (via MainCVScreen banner) ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/2801466618`
    - Ad Name: `banner_ad_language_screen`
    - **Implementation**: Banner ad shown in MainCVScreen which contains LanguagesPage

#### 40. Career Objectives Screen (`career_objectives_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `CareerObjectivesPage`
- **Ad Placements**:
  - **Banner Ad**: Bottom of form (via MainCVScreen banner) ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/8562376405`
    - Ad Name: `banner_ad_career_objectives_screen`
    - **Implementation**: Banner ad shown in MainCVScreen which contains CareerObjectivesPage

#### 41. Website Screen (`website_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `WebsitePage`
- **Ad Placements**:
  - **Banner Ad**: Bottom of form (via MainCVScreen banner) ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/4139259121`
    - Ad Name: `banner_ad_website_screen`
    - **Implementation**: Banner ad shown in MainCVScreen which contains WebsitePage

#### 42. Base CV Template Screen (`base_cv_template_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `BaseCvTemplateScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of template selection ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/2191257792`
    - Ad Name: `banner_ad_base_cv_template_screen`
  - **Interstitial Ad**: After selecting template ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/3089901331`
    - Ad Name: `interstitial_ad_cv_template_selected`
    - **Implementation**: Interstitial ad shown when user changes template
  - **Rewarded Ad**: Before accessing premium templates ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/1446303716`
    - Ad Name: `rewarded_ad_cv_premium_templates`
    - **Implementation**: Available via `AdManager.showCvPremiumTemplatesRewarded()`

---

### File Transfer Screens

#### 43. File Transfer Screen (`file_transfer_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `FileTransferScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of screen ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/7252012783`
    - Ad Name: `banner_ad_file_transfer_screen`
  - **Interstitial Ad**: After successful file transfer ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/4184147694`
    - Ad Name: `interstitial_ad_file_transfer_success`
    - **Implementation**: Interstitial ad shown when QR code is successfully generated (both new and existing)

#### 44. QR Code Scanner Screen (`qr_code_scanner_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `QRCodeScannerScreen`
- **Ad Placements**:
  - **Banner Ad**: Top of scanner view ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/7959084639`
    - Ad Name: `banner_ad_qr_scanner_screen`
    - **Implementation**: Banner ad positioned at top with padding for camera view

#### 45. QR Display Screen (`qr_display_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `QrCodeDisplayScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of QR code display ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/7931821018`
    - Ad Name: `banner_ad_qr_display_screen`

#### 46. QR Result Screen (`qr_result_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `QRResultScreen`
- **Ad Placements**:
  - **Banner Ad**: Top of result display ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/5532231844`
    - Ad Name: `banner_ad_qr_result_screen`
    - **Implementation**: Banner ad positioned at top of result screen

---

### Settings Screens

#### 47. Settings Screen (`settings_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `SettingsScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of settings list ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/4219150172`
    - Ad Name: `banner_ad_settings_screen`
  - **Native Ad**: After every 4th settings item ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/2706757958`
    - Ad Name: `native_ad_settings_list_item_{index}`
    - **Implementation**: Native ad inserted after 4th item (after locked_files tile)

#### 48. Profile Screen (`profile_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `ProfileScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of profile information ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/1592986839`
    - Ad Name: `banner_ad_profile_screen`

#### 49. Phone Recovery Screen (`phone_recovery_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `PhoneRecoveryScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of recovery form ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/2650917632`
    - Ad Name: `banner_ad_phone_recovery_screen`
    - **Implementation**: Banner ad at bottom, button moved up with padding

#### 50. Set Password Screen (`set_password_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `SetPasswordScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of password form ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/6427167655`
    - Ad Name: `banner_ad_set_password_screen`

#### 51. Set Password Proper Screen (`set_password_proper_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `SetPasswordProperScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of password form ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/3262782410`
    - Ad Name: `banner_ad_set_password_proper_screen`

#### 52. Password Verification Screen (`password_verification_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `VerifyPasswordScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of verification form ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/1949700747`
    - Ad Name: `banner_ad_password_verification_screen`

#### 53. Phone Number Screen (`phone_number_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `PhoneNumberScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of phone number form ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/9887583285`
    - Ad Name: `banner_ad_phone_number_screen`

#### 54. Locked Files Screen (`locked_files_Screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `LockedFilesScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of locked files list ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/8574501612`
    - Ad Name: `banner_ad_locked_files_screen`
  - **Interstitial Ad**: After unlocking a file ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/7406041550`
    - Ad Name: `interstitial_ad_unlock_file_action`
    - **Implementation**: Interstitial ad shown when file is unlocked (in locked_files_tab.dart)

#### 55. Continue with Google Screen (`continue_with_google_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `ContinueWithGoogleScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of authentication screen ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/7010455731`
    - Ad Name: `banner_ad_continue_with_google_screen`

---

### Other Screens

#### 56. Splash Screen (`splash_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `SplashScreen`
- **Ad Placements**:
  - **App Open Ad**: When app launches and when app comes to foreground ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/3466796542`
    - Ad Name: `app_open_ad_splash_screen`
    - **Implementation**: 
      - Created `AppOpenAdManager` class (`lib/utils/app_open_ad_manager.dart`) to manage app open ad lifecycle
      - Created `AppLifecycleReactor` class (`lib/utils/app_lifecycle_reactor.dart`) to listen for app foreground events
      - Integrated in `main.dart` - App Open Ad loads on app initialization
      - Ad shows automatically:
        - On cold start (when app first launches) - shown after splash screen (3 seconds delay)
        - Every time app comes to foreground (when app is resumed from background)
      - Ad expiration handled (4 hours max cache duration)
      - Ad automatically reloads after being shown or dismissed
      - Ad loading handled gracefully - if ad not ready, it loads and shows when available

#### 57. Onboarding Screen (`onboarding_screen.dart`) ✅ **IMPLEMENTED**
- **Screen Name**: `OnboardingScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of onboarding slides ✅
    - Ad Unit ID: `ca-app-pub-3425673808153409/3466796542` (Note: Using placeholder ID from ads.txt)
    - Ad Name: `banner_ad_onboarding_screen`
    - **Implementation**: Banner ad positioned at bottom of onboarding screen

#### 58. WebView Screen (`webview_screen.dart`)
- **Screen Name**: `WebViewScreen`
- **Ad Placements**:
  - **Banner Ad**: Bottom of webview ✅ **IMPLEMENTED**
    - Ad Unit ID: `ca-app-pub-3425673808153409/4095984959`
    - Ad Name: `banner_ad_webview_screen`
    - **Implementation**: Banner ad positioned at bottom of webview screen using `Positioned` widget in Stack. WebView content has bottom padding to prevent overlap with ad.

---

## Naming Conventions

### Ad Unit ID Naming Pattern
```
{ad_type}_{screen_name}_{optional_action}
```

### Examples:
- `banner_ad_home_screen`
- `interstitial_ad_compress_file_success`
- `rewarded_ad_merge_multiple_files`
- `native_ad_files_list_item_5`
- `app_open_ad_splash_screen`

### Screen Name Format
- Use PascalCase for screen class names
- Use snake_case for ad unit IDs
- Remove "Screen" suffix in ad names (e.g., `HomeScreen` → `home_screen`)

---

## Implementation Recommendations

### Priority Levels

#### High Priority (Implement First)
1. **Home Screen** - Maximum user traffic
2. **Result Screens** - High engagement moments
3. **File Operation Success** - After compress, merge, split, convert
4. **CV Maker Screens** - Feature-heavy section

#### Medium Priority
1. **Tool Main Screens** - Entry points for features
2. **Settings Screen** - Regular user visits
3. **Files Main Screen** - File management hub

#### Low Priority
1. **Form Screens** - CV maker forms (can be intrusive)
2. **Onboarding Screen** - First-time user experience
3. **Authentication Screens** - User flow interruption

### Ad Frequency Recommendations

#### Interstitial Ads
- Show maximum 1 interstitial per 2-3 screen transitions
- Implement cooldown period (e.g., 30-60 seconds between ads)
- Never show on critical user actions (saving, deleting)

#### Banner Ads
- Can be shown on all screens
- Ensure they don't obstruct important UI elements
- Use responsive sizing for different screen sizes

#### Rewarded Ads
- Offer clear value proposition
- Use for premium features or skipping wait times
- Track user engagement to optimize placement

#### Native Ads
- Match app's design language
- Place naturally within content flow
- Don't exceed 1 native ad per 5-7 content items

### Best Practices

1. **User Experience First**: Don't interrupt critical workflows
2. **Loading States**: Show ads during loading times when possible
3. **Error Handling**: Handle ad loading failures gracefully
4. **Testing**: Test ads in debug mode before production
5. **Analytics**: Track ad performance and user engagement
6. **A/B Testing**: Test different ad placements and frequencies
7. **Compliance**: Follow platform guidelines (Google AdMob, etc.)

### Technical Implementation Notes

1. **Ad Service**: Create a centralized `AdService` class
2. **Ad Manager**: Implement `AdManager` for ad lifecycle management
3. **Ad Config**: Store ad unit IDs in a configuration file
4. **Error Handling**: Implement fallback mechanisms for failed ad loads
5. **Caching**: Preload ads when possible to reduce wait times
6. **Analytics Integration**: Track ad impressions and clicks

---

## Ad Categories Summary

### Display Ads (Banner)
- **Count**: ~50+ placements
- **Primary Use**: Continuous monetization
- **Screens**: All main screens

### Full-Screen Ads (Interstitial)
- **Count**: ~25+ placements
- **Primary Use**: High-value actions
- **Screens**: Result screens, success actions, file operations

### Incentivized Ads (Rewarded)
- **Count**: ~10+ placements
- **Primary Use**: Premium features, batch operations
- **Screens**: Large file operations, batch processing, premium templates

### Content Ads (Native)
- **Count**: ~5+ placements
- **Primary Use**: Seamless integration
- **Screens**: Lists (files, CVs, settings)

### Launch Ads (App Open)
- **Count**: 1 placement
- **Primary Use**: App startup monetization
- **Screens**: Splash screen

---

## Implementation Status

### ✅ Completed Implementations

All ad placements from `ads.txt` have been successfully implemented!

1. **Home Screen** - Banner, Native, and Interstitial ads ✅
2. **Files Main Screen** - Banner, Native, and Interstitial ads ✅
3. **Compress Files Screen** - Banner, Interstitial, and Rewarded ads ✅
4. **Compress File Result Screen** - Banner and Interstitial ads ✅
5. **Convert PDF Main Screen** - Banner and Interstitial ads ✅
6. **PDF Format Selection Screen** - Banner ad ✅
7. **PDF Save Screen** - Interstitial and Rewarded ads ✅
8. **Convert Word Main Screen** - Banner and Interstitial ads ✅
9. **Word Format Selection Screen** - Banner ad ✅
10. **Word Save Screen** - Interstitial ad ✅
11. **Convert Image Main Screen** - Banner and Interstitial ads ✅
12. **Image Format Selection Screen** - Banner ad ✅
13. **Image Save Screen** - Interstitial ad ✅
14. **Merge Files Main Screen** - Banner, Interstitial, and Rewarded ads ✅
15. **Merge Result Screen** - Banner and Interstitial ads ✅
16. **Split Screen** - Banner, Interstitial, and Rewarded ads ✅
17. **Split Result Screen** - Banner ad ✅
18. **Page Selection Screen** - Banner ad ✅
19. **Rearrange File Screen** - Banner and Interstitial ads ✅
20. **Rearrange Result Screen** - Banner ad ✅
21. **Rearrange Page Selection Screen** - Banner ad ✅
22. **Edit File Screen** - Banner and Interstitial ads ✅
23. **OCR Screen** - Banner, Interstitial, and Rewarded ads ✅
24. **OCR Camera Screen** - Banner ad ✅
25. **Extracted Text Screen** - Banner ad ✅
26. **Scanner Screen** - Banner, Interstitial, and Rewarded ads ✅
27. **Document Preview Screen** - Banner ad ✅
28. **Document Edit Screen** - Banner ad ✅
29. **Scanner Result Screen** - Banner and Interstitial ads ✅
30. **Batch Result Screen** - Banner and Interstitial ads ✅
31. **CV Maker Screen** - Banner and Interstitial ads ✅
32. **Main CV Screen** - Banner ad ✅
33. **Create CV Screen** - Banner and Native ads ✅
34. **Base CV Template Screen** - Banner, Interstitial, and Rewarded ads ✅
35. **File Transfer Screen** - Banner and Interstitial ads ✅
36. **QR Scanner Screen** - Banner ad ✅
37. **QR Display Screen** - Banner ad ✅
38. **QR Result Screen** - Banner ad ✅
39. **Settings Screen** - Banner and Native ads ✅
40. **Profile Screen** - Banner ad ✅
41. **Phone Recovery Screen** - Banner ad ✅
42. **Set Password Screen** - Banner ad ✅
43. **Set Password Proper Screen** - Banner ad ✅
44. **Password Verification Screen** - Banner ad ✅
45. **Phone Number Screen** - Banner ad ✅
46. **Locked Files Screen** - Banner and Interstitial ads ✅
47. **Continue With Google Screen** - Banner ad ✅
48. **Onboarding Screen** - Banner ad ✅
49. **WebView Screen** - Banner ad ✅

### 📋 Implementation Summary

- **Total Ad Units Configured**: 50+
- **Banner Ads Implemented**: 40+
- **Native Ads Implemented**: 3 (Home Screen + Files Lists + CV Lists + Settings List)
- **Interstitial Ads Implemented**: 25+
- **Rewarded Ads Implemented**: 7
- **App Open Ads Implemented**: 1 (Splash Screen - App-level implementation)

### 🔧 Technical Implementation Details

- **Ad Service**: Centralized `AdService` class created in `lib/services/ad_service.dart`
- **Ad Manager**: `AdManager` utility for managing interstitial and rewarded ads lifecycle
- **App Open Ad Manager**: `AppOpenAdManager` singleton class created in `lib/utils/app_open_ad_manager.dart` for managing app open ads
- **App Lifecycle Reactor**: `AppLifecycleReactor` class created in `lib/utils/app_lifecycle_reactor.dart` to listen for app foreground events
- **Ad Config**: All ad unit IDs stored in `lib/config/ad_config.dart`
- **Ad Widgets**: Reusable `BannerAdWidget` and `NativeAdWidget` components created
- **Initialization**: Ads initialized in `main.dart` during app startup
- **App Open Ads**: Integrated in `main.dart` - loads on app initialization and shows on foreground events
- **Test Ads**: Test ad unit IDs configured for development (set `AdService.useTestAds = true`)

## Notes

- This guide assumes Google AdMob as the primary ad network
- Ad unit IDs are configured in `lib/config/ad_config.dart`
- Test ad unit IDs are available for development (set `AdService.useTestAds = true`)
- Consider implementing ad-free premium subscription option
- Monitor ad performance and adjust placement based on metrics
- Ensure compliance with GDPR, CCPA, and other privacy regulations
- Interstitial ads have cooldown periods to prevent user annoyance
- Rewarded ads provide value to users (e.g., compressing large files)

---

**Last Updated**: January 23, 2025
**Version**: 3.2.0
**Implementation Status**: All screens from ads.txt implemented ✅

## iOS Ad Unit IDs Configuration

The app now supports platform-specific ad unit IDs for iOS and Android. 

### Current Status:
- ✅ **Android Ad Unit IDs**: All configured and implemented
- ⚠️ **iOS Ad Unit IDs**: Structure ready, but using Android IDs as fallback (needs iOS-specific IDs from AdMob)

### How to Add iOS Ad Unit IDs:

1. **Get iOS Ad Unit IDs from AdMob**:
   - Log in to your AdMob account
   - Create separate ad units for iOS platform
   - Copy the iOS ad unit IDs

2. **Update `lib/config/ad_config.dart`**:
   - Find the iOS constant for the ad unit you want to update
   - Replace the placeholder value with your actual iOS ad unit ID
   - Example:
     ```dart
     // Before (using Android ID as fallback):
     static const String bannerAdHomeScreenIOS = bannerAdHomeScreen; // TODO: Add iOS ID
     
     // After (with actual iOS ID):
     static const String bannerAdHomeScreenIOS = 'ca-app-pub-3425673808153409/YOUR_IOS_ID_HERE';
     ```

3. **The app will automatically use iOS IDs on iOS devices**:
   - The `getPlatformAdUnitId()` method automatically selects the correct ID based on platform
   - No code changes needed in screens/widgets - they automatically use platform-specific IDs

### Platform Detection:
- The app uses `Platform.isIOS` to detect iOS devices
- On iOS: Uses `*IOS` constants
- On Android: Uses regular constants
- Test ads are also platform-specific

### Example Usage:
```dart
// In your screen/widget:
BannerAdWidget(
  adUnitId: AdConfig.getPlatformAdUnitId(
    AdConfig.bannerAdHomeScreen,      // Android ID
    AdConfig.bannerAdHomeScreenIOS,   // iOS ID
  ),
)
```

**Note**: Currently, all iOS constants default to Android IDs. Update them with actual iOS IDs when available from AdMob.

### Newly Implemented Screens (v3.0.0):
- CV Maker Screens (cv_maker_screen, main_cv_screen, create_cv_screen, base_cv_template_screen)
- File Transfer Screens (file_transfer_screen, qr_scanner_screen, qr_display_screen, qr_result_screen)
- Settings Screens (settings_screen, profile_screen, phone_recovery_screen, password screens, locked_files_screen, continue_with_google_screen)

### Newly Implemented Features (v3.1.0):
- App Open Ad for Splash Screen - Implemented at app level with AppOpenAdManager and AppLifecycleReactor
