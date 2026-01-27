# Flutter 開發常用指令教學

## 虛擬機 (Emulator/Simulator) 操作

使用 Terminal 開啟虛擬機的方法：

1. **列出所有可用的虛擬機**
   ```bash
   flutter emulators
   ```

2. **啟動特定虛擬機**
   使用 `flutter emulators --launch <device_id>`。

   **iOS Simulator:**
   ```bash
   flutter emulators --launch apple_ios_simulator
   ```

   **Android Emulator (範例):**
   ```bash
   flutter emulators --launch Pixel_3a_API_34_extension_level_7_arm64-v8a
   ```
   *(註：Android 的 ID 會根據你電腦上建立的模擬器名稱不同而變，請先用第一步查詢)*
