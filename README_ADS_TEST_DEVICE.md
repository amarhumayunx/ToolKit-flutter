# Test Device ID aur Release Mode mein Real Ads

Sirf is README mein: apni device ko **test device** banana aur **release mode** mein **real/production ads** dekhna (testing ads hata kar).

---

## 1. Test device kyun chahiye?

- **Test device** = AdMob us device par ads “test mode” mein serve karta hai.
- Apni hi device par real ads dekh sakte ho, lekin clicks/impressions invalid traffic mein count nahi hote → **policy safe**.
- **useTestAds = false** karke Google ke test ad IDs hata dete ho, apne **production ad unit IDs** use hote hain → **real ads** dikhengi.

---

## 2. Apni device ka Test Device ID kaise nikale?

### Android

1. Phone USB se connect karo, **USB debugging** on karo.
2. App **debug** ya **release** mode mein chalao (ads load honi chahiye).
3. Android Studio → **Logcat** kholo (ya terminal: `adb logcat`).
4. Filter mein ye search karo: **`Use RequestConfiguration.Builder().setTestDeviceIds`**  
   Ya: **`addTestDevice`** / **`Ads`**.
5. Log mein aisa line aayega:
   ```text
   I/Ads: Use RequestConfiguration.Builder().setTestDeviceIds(Arrays.asList("33BE2250B43518CCDA7DE426D04EE231"))
   ```
6. In quotes wala **hash** (e.g. `33BE2250B43518CCDA7DE426D04EE231`) tumhara **Test Device ID** hai.

**Alternative:** Play Store se **“AdMob Device ID Finder”** jaise app use karke bhi nikal sakte ho.

### iOS

1. iPhone Mac se connect karo, Xcode se app chalao.
2. **Xcode → Debug console** (botton) kholo.
3. Wahi search karo: **`setTestDeviceIds`** / **`addTestDevice`** / **`GADMobileAds`**.
4. Console mein device ID wali line dikhegi — usme quotes ke andar wala ID copy karo.

---

## 3. Code mein kahan add karna hai?

**File:** `lib/services/ad_service.dart`

### Step A: Test Device ID add karo

`testDeviceIds` list mein apna device ID daalo:

```dart
static const List<String> testDeviceIds = [
  '33BE2250B43518CCDA7DE426D04EE231',  // Android
  // 'XXXXXXXX',  // iOS agar alag device hai
];
```

- Ek se zyada device ho to comma se alag IDs add kar sakte ho.

### Step B: Testing ads hata kar real ads use karo

`useTestAds` ko **`false`** karo:

```dart
static bool useTestAds = false;
```

- `true` = hamesha Google test ad IDs (real ads nahi).  
- `false` = tumhare production ad unit IDs → **real ads**.

---

## 4. Release mode mein kaise chalana hai?

- **Android:**  
  ```bash
  flutter run --release
  ```  
  ya  
  ```bash
  flutter build apk
  ```  
  Phir generated APK device par install karke chalao.

- **iOS:**  
  ```bash
  flutter run --release
  ```  
  ya Xcode se **Release** scheme select karke run/build karo.

Release build + `useTestAds = false` + `testDeviceIds` mein apni device → **real ads** tumhari device par dikhengi, aur wo **test device** ki wajah se policy-wise safe rahegi.

---

## 5. Short checklist

| Step | Kya karna hai |
|------|----------------|
| 1 | Logcat / Xcode console se apna **Test Device ID** nikalo |
| 2 | `lib/services/ad_service.dart` → `testDeviceIds` mein ye ID add karo |
| 3 | `useTestAds = false` karo |
| 4 | App **release** mode mein chalao |
| 5 | Real ads apni device par dikhni chahiye |

---

## 6. Summary

- **Test device** = `AdService.testDeviceIds` mein apni device ID.  
- **Real ads** = `AdService.useTestAds = false`.  
- Dono saath use karo + release run karo → **sirf isi setup** ke liye ye README kaafi hai.
