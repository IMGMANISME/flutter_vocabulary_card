# Gocab (繁體中文)

**Gocab** 是一款英語單字學習應用程式，專為幫助使用者掌握 C1 CEFR 等級的詞彙而設計。它具備響應式單字卡介面、即時 Firestore 同步以及「隱藏已學習單字」等功能。

## 功能特色

-   **單字卡介面**：具備翻轉動畫的互動式單字卡。
-   **響應式版面**：針對各種螢幕尺寸優化，文字大小會自動縮放以適應版面。
-   **學習狀態標記**：可將單字標記為「已學習」，在學習過程中將其過濾隱藏。
-   **即時同步**：
    -   **已登入**：透過 Firebase Firestore 在不同裝置間同步學習狀態。
    -   **未登入**：將學習進度儲存在本機裝置上。
-   **Google 登入**：使用 Google 帳號進行安全驗證。
-   **字母導覽**：快速跳轉至特定字母開頭的單字。

## 技術堆疊

-   **前端**：Flutter (Dart)
-   **後端**：Firebase (Firestore, Authentication)
-   **狀態管理**：Provider
-   **資源**：C1 CEFR 單字列表

## 設定與安裝

1.  **複製專案 (Clone)**：
    ```bash
    git clone https://github.com/yourusername/flutter_vocabulary_card.git
    cd flutter_vocabulary_card
    ```

2.  **安裝依賴套件**：
    ```bash
    flutter pub get
    ```

3.  **Firebase 設定**：
    -   請確保您已為 Firebase 專案設定好 `firebase_options.dart`。
    -   (若尚未設定) 使用 `flutterfire configure` 指令來產生該檔案。

4.  **執行應用程式**：
    -   **iOS**：在 Xcode 中開啟 `ios/Runner.xcworkspace` 以設定簽署 (Signing)，然後執行：
        ```bash
        flutter run
        ```
    -   **Android**：
        ```bash
        flutter run
        ```

## 部署至實體 iOS 裝置

若要在實體 iPhone/iPad 上執行：

1.  在 Xcode 中開啟 `ios/Runner.xcworkspace`。
2.  前往 **Signing & Capabilities** (簽署與功能) 頁籤。
3.  在 **Team** 下拉選單中選擇您的 Apple ID。
4.  連接您的裝置並點選「信任此電腦」。
5.  透過 Xcode 按下執行按鈕，或是使用指令 `flutter run -d <device-id>`。

## 授權

本專案採用 MIT 授權條款。
