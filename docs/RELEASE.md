# 📦 上架與更新指令手冊

> Gocab 發佈流程。iOS 已可直接使用；Android 需先完成[一次性設定](#android-一次性設定必做一次)。
> 指令皆以專案根目錄為工作目錄執行。

---

## ⚡ 例行更新（最常用）

每次發新版都是這三步：

**1. 改版本號** — [`pubspec.yaml`](../pubspec.yaml) 的 `version`，兩平台共用

```bash
sed -i '' 's/^version: .*/version: 1.0.0+2/' pubspec.yaml && grep ^version: pubspec.yaml
```

`1.0.0` = 使用者看到的版本；`+2` = build number，**每次上傳必須遞增**，重複會被商店退件。

**2. 建置**

```bash
flutter build ipa --release
```

```bash
flutter build appbundle --release
```

**3. 上傳**

```bash
open build/ios/archive/Runner.xcarchive
```

Android 到 [Play Console](https://play.google.com/console) 上傳 `build/app/outputs/bundle/release/app-release.aab`。

---

## 🍎 iOS

### 環境速查

| 項目 | 值 |
|---|---|
| Bundle ID | `com.gman.gocabapp` |
| 團隊 | `ZXT349Q3QD` (Nianci Huang) |
| 最低版本 | iOS 15.0 |
| 產出 | `build/ios/ipa/flutter_vocabulary_card.ipa` |

### 首次上架

到 [App Store Connect](https://appstoreconnect.apple.com/apps) → 「+」→ 新 App，Bundle ID 選 `com.gman.gocabapp`。此步驟無 CLI 替代，紀錄不存在時上傳會被退。

### 建置與上傳

```bash
flutter build ipa --release
```

```bash
open build/ios/archive/Runner.xcarchive
```

Xcode Organizer → **Distribute App** → **App Store Connect** → **Upload**。沿用已登入的帳號，免密碼，且會先跑一次驗證。

### 上傳前自我驗證（選用）

```bash
cd $(mktemp -d) && unzip -q "$OLDPWD/build/ios/ipa/flutter_vocabulary_card.ipa" && codesign -dvvv Payload/Runner.app 2>&1 | grep -E "Identifier=|Authority=Apple Dist"
```

預期：

```
Identifier=com.gman.gocabapp
Authority=Apple Distribution: Nianci Huang (ZXT349Q3QD)
```

### CLI 上傳（CI 用）

需先於 App Store Connect → Users and Access → Integrations 產生 API Key，`.p8` 放到 `~/.appstoreconnect/private_keys/`（檔名須為 `AuthKey_<KeyID>.p8`）。

```bash
xcrun altool --upload-app --type ios -f build/ios/ipa/flutter_vocabulary_card.ipa --apiKey <KEY_ID> --apiIssuer <ISSUER_ID>
```

### TestFlight

App Store Connect → App → **TestFlight**。`Processing` 約 5～15 分鐘後轉為可用。

- 內部測試員：最多 100 人，免審核，立即可加
- 外部測試員：首次需 Apple 審核

---

## 🤖 Android

> 🟡 **設定進度**：套件名、簽章接線、`.gitignore` 已完成（2026-08-12）。
> 尚缺 **① 金鑰庫**、**② key.properties**、**⑤ Firebase 註冊**——這三項需要你的密碼或 Console 權限。
> 完成前 `flutter build appbundle --release` 會失敗於 `No matching client found for package name`。

### Android 一次性設定（必做一次）

#### ① 建立上傳金鑰庫 ⬜ 待辦

**這條由你自己執行**，過程會要求你設定密碼：

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

> ⚠️ 這個 `.jks` 檔與密碼**遺失就無法再更新 App**。請備份到安全的地方，不要放進 git。

#### ② 建立 `android/key.properties` ⬜ 待辦

`storeFile` 填 ① 產生的 `.jks` 絕對路徑：

```
storePassword=你設定的密碼
keyPassword=你設定的密碼
keyAlias=upload
storeFile=/Users/gman/upload-keystore.jks
```

此檔已列入 `.gitignore`，不會進版控。

#### ③ .gitignore ✅ 已完成

`android/key.properties`、`*.jks`、`*.keystore` 已加入。

#### ④ build.gradle.kts 與套件名 ✅ 已完成

[`android/app/build.gradle.kts`](../android/app/build.gradle.kts) 的 `namespace` 與 `applicationId` 已改為 `com.gman.gocabapp`，簽章設定已接上 `key.properties`，`MainActivity.kt` 也已搬到 `android/app/src/main/kotlin/com/gman/gocabapp/`。

設定為**條件式**：`key.properties` 不存在時 release 版會退回 debug 金鑰（讓 `flutter run --release` 仍可用）並在建置時印出警告。要上架 Play 就必須完成 ①②。

#### ⑤ Firebase 重新註冊 ⬜ 待辦

現有的 `google-services.json` 綁定的是舊套件名 `com.example.flutter_vocabulary_card`，改完套件名後 Google 登入會失效。

取得新金鑰的 SHA-1 與 SHA-256：

```bash
keytool -list -v -keystore ~/upload-keystore.jks -alias upload | grep -E "SHA1|SHA256"
```

到 Firebase Console → 專案設定 → 新增 Android App：
- 套件名稱填 `com.gman.gocabapp`
- 貼上上面兩組指紋
- 下載新的 `google-services.json` 覆蓋 `android/app/google-services.json`

再把新檔案裡的 `mobilesdk_app_id` 同步到 [`lib/firebase_options.dart`](../lib/firebase_options.dart) 的 `android` 區塊 `appId`（目前仍是舊 App 的 `1:1082504661197:android:efed9cf1e89beaa20ec184`）。執行期讀的是這個檔案，不是 json。

> ⚠️ **Play App Signing 的陷阱**：上架後 Google Play 會用**它自己的金鑰**重新簽章，所以正式環境的 Google 登入認的是 Play 的憑證指紋，不是你本機的。
> 首次上傳後，到 Play Console → 測試與發布 → 應用程式完整性 → 應用程式簽署金鑰憑證，把那組 SHA-1 **也**加進 Firebase，否則正式版登入會失敗（但本機測試正常，很難察覺）。

#### ⑥ 驗證

```bash
flutter build appbundle --release
```

```bash
unzip -p build/app/outputs/bundle/release/app-release.aab BUNDLE-METADATA/com.android.tools.build.gradle/app-metadata.properties 2>/dev/null; unzip -p build/app/outputs/bundle/release/app-release.aab base/manifest/AndroidManifest.xml | strings | grep -i gocab | head
```

### 例行發佈

```bash
flutter build appbundle --release
```

產出：`build/app/outputs/bundle/release/app-release.aab`

到 [Play Console](https://play.google.com/console) → 你的 App → 測試 → **內部測試**（等同 TestFlight，免審核、立即生效）→ 建立新版本 → 上傳 `.aab`。

正式上架則走「正式版」軌道，首次需完整審核（數小時到數天）。

---

## 🔗 Firebase 設定一致性

改 Bundle ID / applicationId 後，設定散落在多個檔案，**漏改任一處都會讓 Google 登入靜默失效**。

執行期真正生效的是 [`lib/firebase_options.dart`](../lib/firebase_options.dart)（由 [`lib/bootstrap.dart`](../lib/bootstrap.dart) 讀取），**不是** plist / json。只換設定檔不夠。

| 平台 | 需同步的位置 |
|---|---|
| iOS | `ios/Runner/GoogleService-Info.plist`、`ios/Runner/Info.plist`（`GIDClientID` + `CFBundleURLSchemes`）、`lib/firebase_options.dart` 的 `ios` 區塊 |
| Android | `android/app/google-services.json`、`lib/firebase_options.dart` 的 `android` 區塊、Firebase Console 的 SHA 指紋 |

### iOS 一致性檢查

```bash
echo "--- GoogleService-Info.plist ---" && /usr/libexec/PlistBuddy -c "Print :CLIENT_ID" -c "Print :BUNDLE_ID" ios/Runner/GoogleService-Info.plist && echo "--- Info.plist ---" && /usr/libexec/PlistBuddy -c "Print :GIDClientID" ios/Runner/Info.plist && echo "--- firebase_options.dart (ios) ---" && sed -n '/FirebaseOptions ios =/,/);/p' lib/firebase_options.dart | grep -E "iosClientId|iosBundleId|googleusercontent"
```

三處 client ID 須完全相同，`BUNDLE_ID` 須等於 `PRODUCT_BUNDLE_IDENTIFIER`。

> 註：`firebase_options.dart` 的 `macos` 區塊仍指向舊的 `com.example.flutterVocabularyCard`，因不發佈 macOS 版而刻意未動。上面指令已限定只查 `ios`。

### 重新產生全部設定（替代方案）

```bash
dart pub global activate flutterfire_cli && flutterfire configure
```

會互動式重新產生 `firebase_options.dart` 與各平台設定檔。方便但會覆蓋手動調整，用前先確認 git 工作區乾淨。

---

## 🔧 疑難排解

### iOS

| 訊息 | 解法 |
|---|---|
| `does not have permission to create "iOS App Store" provisioning profiles` | 用到免費團隊。`project.pbxproj` 三處 `DEVELOPMENT_TEAM` 須皆為 `ZXT349Q3QD` |
| `No signing certificate "iOS Distribution" found` | 同上；團隊正確時 Xcode 會自動產生，需 Admin 或 Account Holder 角色 |
| `The app identifier ... is not available` | Bundle ID 被別的團隊佔用。`com.gman.Gocab` 已被免費團隊 `Q56BA6VT7Y` 永久佔用且無法釋出，這就是改用 `com.gman.gocabapp` 的原因，**請勿改回** |
| `did not include a dSYM for objective_c.framework` | **可忽略**。該 framework 由 Flutter native assets 管線編譯，繞過 Xcode 且已 strip，無法產生 dSYM。不影響上傳 |
| build number 重複 | 回到[改版本號](#-例行更新最常用) |

```bash
security find-identity -v -p codesigning
```

正常應含 `Apple Distribution: Nianci Huang (ZXT349Q3QD)`。

### Android

| 訊息 | 解法 |
|---|---|
| `Package name com.example... is restricted` | 未改 `applicationId`，見[一次性設定 ④](#-修改-androidappbuildgradlekts) |
| `You uploaded an APK signed with a debug certificate` | 未設定 release 簽章，見[一次性設定 ①～④](#android-一次性設定必做一次) |
| `Version code N has already been used` | 遞增 `pubspec.yaml` 的 build number |
| 正式版 Google 登入失敗但本機正常 | 未把 Play App Signing 憑證的 SHA-1 加進 Firebase，見[一次性設定 ⑤](#-firebase-重新註冊) |

```bash
flutter clean && flutter pub get
```

建置行為異常時先跑這個。

---

## 📎 相關

- [架構規範](ARCHITECTURE_GUIDELINES.md)
- [Flutter iOS 部署](https://docs.flutter.dev/deployment/ios) ・ [Android 部署](https://docs.flutter.dev/deployment/android)
