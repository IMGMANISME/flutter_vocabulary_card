# 🏗 Flutter Architecture Guidelines

> 本文件為本專案開發架構設計規範，**所有開發者需嚴格遵守**，以確保程式碼品質、可維護性與擴充性。

---

## 🧱 架構原則：Clean Architecture

本專案採用 **Clean Architecture**，強調責任分離與依賴反轉原則。每一層都應該有明確的職責，並且相依性方向必須由外向內（或由下向上）。

### 依賴流向
`Presentation` → `Domain` ← `Data`

1. **Presentation Layer (UI & State)**
   - **職責**：顯示 UI、處理使用者輸入、管理畫面狀態。
   - **依賴**：依賴 `Domain` 層的 UseCase 與 Entity。
   - **禁止**：**絕對不可**直接依賴 `Data` 層（如 Repository 實作或 API Client）。

2. **Domain Layer (Business Logic)**
   - **職責**：定義核心業務邏輯（UseCase）、業務實體（Entity）與介面契約（Repository Interface）。
   - **依賴**：**不依賴任何其他層**。這是純 Dart 程式碼，不應包含 Flutter UI 相依性或外部資料庫實作。
   - **特性**：穩定的核心，變動頻率最低。

3. **Data Layer (Implementation)**
   - **職責**：實作 `Domain` 層定義的介面。負責資料的取得（Network, Local DB）、DTO 轉換、錯誤捕捉。
   - **依賴**：依賴 `Domain` 層（為了實作其 Interface）。

---

## 📁 專案目錄結構

採用 **Feature-First** (依功能分層) 結構，將相關程式碼聚合。

```
lib/
├── core/                     # 核心共用層
│   ├── constants/            # 全域常數 (ApiEndpoints, AppColors)
│   ├── errors/               # 自定義錯誤 (Failure, Exceptions)
│   ├── network/              # 網路設定 (DioClient, Interceptors)
│   └── utils/                # 通用工具 (DateFormatter, Validators)
├── config/                   # App 配置
│   ├── router/               # 路由定義 (GoRouter)
│   └── theme/                # 全域樣式
├── features/                 # 功能模組 (Feature-First)
│   ├── auth/                 # 範例：認證模組
│   │   ├── domain/
│   │   │   ├── entities/     # 業務實體 (純 Dart class)
│   │   │   ├── repositories/ # Repository 介面定義 (abstract class)
│   │   │   └── usecases/     # 具體業務邏輯 (如 LoginUseCase)
│   │   ├── data/
│   │   │   ├── models/       # DTO (Data Transfer Object), 負責 JSON 序列化
│   │   │   ├── datasources/  # 資料來源 (RemoteDataSource, LocalDataSource)
│   │   │   └── repositories/ # Repository 介面實作
│   │   └── presentation/
│   │       ├── providers/    # Riverpod Notifier / Providers
│   │       ├── pages/        # 頁面 (Page/Screen)
│   │       └── widgets/      # 該頁面專用的 Widget
│   └── [feature_name]/
├── shared/                   # 跨模組共用層
│   ├── widgets/              # 通用元件 (Buttons, Loaders)
│   └── extensions/           # Dart Extensions
├── main.dart
└── bootstrap.dart            # App 啟動初始化邏輯
```

---

## 🛠 技術規範與最佳實踐

### 1. 狀態管理 (State Management)
- 使用 **Riverpod** (v2+) 配合 `riverpod_annotation` 與代碼生成 (`build_runner`)。
- **Provider 命名**：使用 camelCase，例如 `userListProvider`。
- **狀態類別**：
  - 簡單資料或 Service 使用 `@riverpod` 標註函式。
  - 複雜狀態使用 `@riverpod` 標註 `class` (繼承 `_$ClassName`)。
- **AsyncValue**：善用 `AsyncValue` 處理 Loading / Error / Data 三種狀態。

```dart
// 範例：使用 Code Gen 定義 Provider
@riverpod
Future<List<User>> userList(UserListRef ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUsers();
}
```

### 2. 資料流與物件轉換

- **DTO vs Entity**:
  - **DTO (Data Transfer Object)**: 位於 `data/models/`，負責 `fromJson` / `toJson`，與後端 API 結構一一對應。
  - **Entity**: 位於 `domain/entities/`，是 App 內部使用的純淨物件，不應包含 JSON 邏輯。
  - **轉換**：在 Repository 實作層將 DTO 轉換為 Entity 回傳給 Domain 層。

### 3. UseCase 設計
- 每個 UseCase 應專注於單一職責（Single Responsibility）。
- 命名格式：`Verb` + `Subject` + `UseCase` (如 `LoginWithEmailUseCase`)。
- 透過 `call` 方法執行，使其可像函式一樣被調用。

### 4. 錯誤處理 (Error Handling)
- 使用 `Either<Failure, T>` 或自定義 `Result` 類別來封裝返回值（推薦 `fpdart` 或自行實作）。
- **不要在 Domain 層拋出 Exception**，應捕捉 Exception 並轉換為 `Failure` 物件回傳。
- UI 層根據 `Failure` 類型顯示對應錯誤訊息。

---

## 🔍 開發 Checklist

### 新增功能 (Feature) 流程
1. **定義 Domain**:
   - 在 `domain/entities` 建立資料模型。
   - 在 `domain/repositories` 定義介面。
   - 在 `domain/usecases` 定義業務邏輯。
2. **實作 Data**:
   - 在 `data/models` 建立 DTO (繼承或映射 Entity)。
   - 在 `data/repositories` 實作介面，串接 API。
3. **實作 Presentation**:
   - 建立 Riverpod Provider 呼叫 UseCase。
   - 建立 UI Page 監聽 Provider 狀態。

### 程式碼品質要求
- [ ] 所有 Public Method 需有註解說明。
- [ ] 複雜邏輯必須包含單元測試 (`test/`)。
- [ ] UI 盡量拆分為小 Widget，避免單一檔案超過 300 行。
- [ ] 執行 `flutter analyze` 確保無警告。

---

## 📦 推薦套件 (Dependencies)

| 類別 | 套件 | 用途 |
|------|------|------|
| **Core** | `flutter_riverpod`, `riverpod_annotation` | 狀態管理與 DI |
| **Network** | `dio` | HTTP Client |
| **Model** | `freezed`, `json_annotation` | 不可變物件與 JSON 生成 |
| **Navigation** | `go_router` | 路由管理 |
| **Utils** | `flutter_hooks` (Optional) | 簡化 UI 邏輯 |
| **Testing** | `mocktail` | Mock 測試物件 |

---

## 🚫 禁止事項 (Don'ts)

1. **嚴禁**在 `Presentation` 層直接使用 `http` 或 `dio` 請求 API。
2. **嚴禁**在 `Domain` 層引用 `package:flutter` (Entity 不應繼承 StatelessWidget)。
3. **嚴禁**在 Widget 的 `build` 方法中執行複雜運算或 API 呼叫 (應移至 UseCase/Provider)。