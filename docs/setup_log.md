# 開發環境修復紀錄
> **紀錄時間：** 2026-01-25 11:44


## 1. Flutter 環境設定
- **問題**：Terminal 找不到 `flutter` 指令 (`command not found`)。
- **解決**：已將 Flutter SDK 路徑 (`/Users/gman/Dev_SDK/flutter/bin`) 加入 Shell 設定檔 (`.zshrc`)。

## 2. 版本升級
- **問題**：專案需要 Dart SDK ^3.8.0，但原版本過舊 (3.3.4)。
- **解決**：將 Flutter 升級至 Stable Channel 最新版 (`3.38.7`)，包含 Dart `3.10.7`。
- **其他**：成功執行 `flutter pub get` 與 `run build_runner` 產生必要的程式碼。

## 3. Android 模擬器修復
- **問題**：啟動模擬器時失敗，出現 `The Android emulator exited with code 1`。
- **診斷**：
  - `flutter doctor` 顯示 Android Licenses 未接受。
  - 詳細 Log (`-verbose`) 顯示 `ramdisk (null)`，表示 System Image 檔案損毀。
- **解決**：
  1. 執行 `flutter doctor --android-licenses` 接受所有授權。
  2. 使用 `sdkmanager` 重新安裝 `system-images;android-34;google_apis;arm64-v8a`，補回遺失的 `ramdisk.img`。

## 4. 常用指令備忘
- **啟動模擬器**：
  ```bash
  flutter emulators --launch Pixel_3a_API_34_extension_level_7_arm64-v8a
  ```
  *(或直接開啟 Android Studio / Emulator App)*

- **執行專案**：
  ```bash
  flutter run
  ```
