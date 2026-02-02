# iOS Ads Setup Guide - Step by Step

Yeh guide aapko iOS par ads show karne ke liye zaroori steps batata hai.

## 📋 Prerequisites (Pehle se zaroori cheezein)

1. ✅ Flutter project setup ho chuka hai
2. ✅ `google_mobile_ads` package install ho chuka hai
3. ✅ AdMob account ban chuka hai
4. ✅ Android ads already implement ho chuki hain

---

## 🚀 Step-by-Step Setup

### Step 1: AdMob Account Mein iOS Ad Units Create Karein

1. **AdMob Console mein jao**: https://apps.admob.com/
2. **Apna app select karo** (Toolkit App)
3. **"Ad units" tab par click karo**
4. **Har screen ke liye iOS ad units create karo**:
   - Banner ads ke liye: "Banner" type select karo
   - Interstitial ads ke liye: "Interstitial" type select karo
   - Rewarded ads ke liye: "Rewarded" type select karo
   - Native ads ke liye: "Native" type select karo
   - App Open ads ke liye: "App Open" type select karo

5. **Har ad unit create karte waqt**:
   - Platform: **iOS** select karo
   - Ad unit name: Android wala hi naam rakho (e.g., `banner_ad_home_screen`)
   - Ad unit ID copy karke save karo

### Step 2: iOS Ad Unit IDs Ko Code Mein Add Karein

1. **`lib/config/ad_config.dart` file kholo**
2. **Har iOS constant ko update karo**:

```dart
// Example - Home Screen Banner Ad
// Before:
static const String bannerAdHomeScreenIOS = bannerAdHomeScreen; // TODO: Add iOS ID

// After (apna iOS ID add karo):
static const String bannerAdHomeScreenIOS = 'ca-app-pub-3425673808153409/YOUR_IOS_ID_HERE';
```

3. **Sabhi screens ke liye iOS IDs add karo** (50+ ad units hain)

### Step 3: Info.plist Mein AdMob App ID Add Karein

1. **`ios/Runner/Info.plist` file kholo**
2. **Ye code add karo** (closing `</dict>` tag se pehle):

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3425673808153409~4673401193</string>
```

**Complete example:**
```xml
<dict>
    <!-- ... existing keys ... -->
    
    <key>GADApplicationIdentifier</key>
    <string>ca-app-pub-3425673808153409~4673401193</string>
</dict>
```

### Step 4: SKAdNetworkItems Add Karein (iOS 14+ ke liye zaroori)

1. **`ios/Runner/Info.plist` mein ye bhi add karo**:

```xml
<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>4fzdc2evr5.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>4pfyvq9l8r.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>2fnua5tdw4.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>ydx93a7ass.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>5a6flpkh64.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>p78axxw29g.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>v72qych5uu.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>ludvb6z3bs.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cp8zw746q7.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>3sh42y64q3.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>c6k4g5qg8m.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>s39g8k73mm.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>3qy4746246.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>f38h382jlk.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>hs6bdukanm.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>prcb7njmu6.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>v9wttpbfk9.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>n38lu8286q.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>47vhws6wlr.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>kbd757ywx3.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>9t245vhmpl.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>eh6m2bh4zr.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>a2p9lx4jpn.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>22mmun2rn5.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>4468km3ulz.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>2u9pt9hc89.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>8s468mfl3y.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>klf5c3l5u5.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>ppxm28t8ap.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>ecpz2srf59.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>uw77j35x4d.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>pwa83g5rt2.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>mlmmfzh3r3.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>578prtvx9j.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>4dzt52r2t5.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>e5fvkxwrpn.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>8c4e2ghe7u.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>zq492l623r.skadnetwork</string>
    </dict>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>3qcr597p9d.skadnetwork</string>
    </dict>
</array>
```

### Step 5: Podfile Update Karein (Agar zaroorat ho)

1. **`ios/Podfile` check karo** - usually Flutter automatically handle karta hai
2. **Terminal mein ye commands run karo**:

```bash
cd ios
pod deintegrate
pod install
cd ..
```

### Step 6: Test Karein

1. **Test ads enable karo** (development ke liye):
   ```dart
   // lib/services/ad_service.dart mein
   static bool useTestAds = true; // iOS test ads automatically use honge
   ```

2. **iOS simulator ya real device par test karo**:
   ```bash
   flutter run -d ios
   ```

3. **Production ads ke liye**:
   ```dart
   static bool useTestAds = false; // Production ads show hongi
   ```

---

## ✅ Checklist

- [ ] AdMob account mein iOS ad units create kiye
- [ ] Sabhi iOS ad unit IDs copy kiye
- [ ] `lib/config/ad_config.dart` mein iOS IDs add kiye
- [ ] `ios/Runner/Info.plist` mein `GADApplicationIdentifier` add kiya
- [ ] `ios/Runner/Info.plist` mein `SKAdNetworkItems` add kiye
- [ ] `pod install` run kiya
- [ ] iOS device/simulator par test kiya

---

## 🔍 Troubleshooting

### Problem: Ads show nahi ho rahi
**Solution**: 
- Check karo ke `GADApplicationIdentifier` sahi hai
- Check karo ke iOS ad unit IDs sahi add kiye hain
- Console mein errors check karo

### Problem: Build error
**Solution**:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
```

### Problem: Test ads show nahi ho rahi
**Solution**: 
- `AdService.useTestAds = true` check karo
- iOS test ad unit IDs verify karo

---

## 📝 Important Notes

1. **iOS ad unit IDs Android se alag hote hain** - har platform ke liye separate IDs chahiye
2. **Test ads** development ke liye zaroori hain - production ads use karne se pehle test karo
3. **SKAdNetworkItems** iOS 14+ ke liye zaroori hai for proper ad attribution
4. **App Store submission** se pehle production ads test karo

---

**Last Updated**: January 23, 2025
