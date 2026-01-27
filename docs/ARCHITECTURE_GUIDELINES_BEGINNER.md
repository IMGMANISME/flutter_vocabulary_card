# 🏗 Flutter 架構指南 (新手友善版)

> **歡迎來到本專案！** 👋
> 本文件是我們開發的「交通規則」。即使你是第一次接觸 Clean Architecture，只要跟著這份指南，就能寫出高品質、好維護的程式碼。
>
> **核心觀念：** 程式碼要像整理房間一樣，把不同的東西分類收好，不要全部堆在床上（UI）。

---

## 📚 目錄
1. [一句話懂架構](#1-一句話懂架構-clean-architecture)
2. [專案地圖 (目錄結構)](#2-專案地圖-目錄結構)
3. [核心觀念白話文](#3-核心觀念白話文-關鍵字解釋)
4. [🧑‍🍳 開發食譜：如何新增一個功能？](#4--開發食譜-如何新增一個功能)
5. [🚫 新手常見錯誤 (必讀)](#5--新手常見錯誤-千萬別這樣做)
6. [🛠 常用工具與寫法](#6--常用工具與寫法)

---

## 1. 🧅 一句話懂架構 (Clean Architecture)

我們採用 **Clean Architecture**，你可以把它想像成一顆**洋蔥**，或是**夾心餅乾**。

### 三大分層
我們把程式碼分成三層，每一層都有自己的任務，絕對不能「越級」！

| 層級 | 名稱 | 比喻 | 職責 (做什麼事?) | 規則 (你可以呼叫誰?) |
|:---:|:---:|:---:|:---|:---|
| **最外層** | **Presentation (UI)** | **臉/皮膚** 🎨 | **"顯示畫面"** <br> 負責畫出按鈕、文字，接收使用者的點擊。 | ✅ 只能呼叫 **Domain** (UseCase)<br>❌ 不能直接碰 Data (API) |
| **中間層** | **Domain** | **大腦** 🧠 | **"決定邏輯"** <br> 決定「登入要檢查什麼？」、「密碼要幾位數？」。這裡是純邏輯，不依賴任何外部套件。 | ✅ 它是老大，誰都不依賴。<br>❌ 完全不知道 UI 或 API 的存在。 |
| **底層** | **Data** | **手腳/工具** 🔧 | **"執行動作"** <br> 負責真的去打 API、存資料庫、讀檔案。 | ✅ 只能呼叫 **Domain** (為了滿足大腦的需求)。 |

### ➡️ 資料怎麼流動？
1. **使用者**點擊 UI (Presentation)
2. **UI** 通知 **大腦** (Domain) 說：「嘿，使用者想登入」
3. **大腦** 命令 **手腳** (Data) 說：「去 伺服器 (Server) 查一下這個帳號」
4. **手腳** 拿到資料，回報給 **大腦**
5. **大腦** 整理一下，丟給 **UI**
6. **UI** 更新畫面

---

## 2. 🗺 專案地圖 (目錄結構)

我們採用 **Feature-First (依功能分類)**。也就是說，「會員功能」的所有相關檔案都在 `features/auth` 資料夾裡，而不是散落在各地。

```text
lib/
├── core/                       # 🧰 工具箱 (整個 App 共用的東西)
│   ├── constants/              # 放常數 (API 網址、顏色代碼)
│   ├── errors/                 # 定義錯誤類型 (網路斷線、密碼錯誤)
│   ├── network/                # 設定 Dio (或是你的 HTTP Client)
│
├── features/                   # 🧩 功能模組 (我們主要工作的地方！)
│   ├── auth/                   # 範例：登入註冊功能
│   │   ├── domain/             # 🧠 大腦層 (先寫這裡！)
│   │   │   ├── entities/       # 資料的"本質" (User 物件，乾淨的 Dart class)
│   │   │   ├── repositories/   # 定義"合約" (抽象介面，規定要有哪些功能)
│   │   │   └── usecases/       # 具體任務 (LoginUseCase, LogoutUseCase)
│   │   │
│   │   ├── data/               # 🔧 手腳層 (實作合約)
│   │   │   ├── models/         # DTO (負責把 JSON 轉成 Dart，髒活都在這)
│   │   │   ├── datasources/    # 真正的 API 呼叫 (Dio request 寫在這)
│   │   │   └── repositories/   # 實作 domain 的合約 (協調 DTO 和 DataSource)
│   │   │
│   │   └── presentation/       # 🎨 UI 層 (最後寫)
│   │       ├── providers/      # 狀態管理 (Riverpod)
│   │       ├── pages/          # 頁面 (LoginPage)
│   │       └── widgets/        # 小元件 (LoginButton)
│   │
│   └── home/                   # 其他功能...
│
├── shared/                     # 🤝 共用元件 (各個 Feature 都會用到的按鈕、Loading)
├── main.dart                   # 🚪 程式入口
└── config/                     # ⚙️ 設定 (路由、主題)
```

---

## 3. 📖 核心觀念白話文 (關鍵字解釋)

### `Entity` vs `DTO` (Model)
新手最容易搞混這兩個。
- **Entity (實體)**：Domain 層用。**乾淨、簡單**。是我們 App 內部溝通用的標準格式。
- **DTO (Data Transfer Object)**：Data 層用。**髒髒的**。它長得跟後端 API 給的 JSON 一模一樣。負責 `fromJson` / `toJson`。
> **為什麼要分開？**
> 如果後端改了欄位名 (例如 `user_name` 改成 `u_name`)，我們只要改 DTO 就好，UI 和 Domain 層完全不用動！(保護機制)

### `Repository` (倉庫)
它是 Presentation (UI) 和 Data (API) 之間的中間人。
- UI 只知道：「我要找 Repository 拿資料。」
- UI **不知道** 資料是從 API 來的，還是從手機資料庫來的，還是假資料。(這就是**抽象化**)

### `UseCase` (用例)
代表「使用者的一個動作」。例如：`LoginUseCase`, `GetProductListUseCase`。
好處是：看檔名就知道這個 App 有什麼功能。

---

## 4. 🧑‍🍳 開發食譜：如何新增一個功能？

假設你要做一個 **「瀏覽文章列表 (Post)」** 的功能，請依照這 5 個步驟：

### 第 1 步：定義 Domain (大腦)
先想好資料長怎樣，以及我們需要什麼功能。
1. 在 `domain/entities` 建立 `Post` (包含 title, content)。
2. 在 `domain/repositories` 建立 `PostRepository` 介面 (定義 `getPosts()` 方法)。
3. 在 `domain/usecases` 建立 `GetPostsUseCase`。

```dart
// domain/usecases/get_posts_use_case.dart
class GetPostsUseCase {
  final PostRepository repository;
  GetPostsUseCase(this.repository);

  Future<List<Post>> call() {
    return repository.getPosts();
  }
}
```

### 第 2 步：實作 Data (手腳)
處理髒活，把資料抓回來。
1. 在 `data/models` 建立 `PostDto` (寫 `fromJson`)。
2. 在 `data/datasources` 寫 API 請求 (`dio.get('/posts')`)。
3. 在 `data/repositories` 實作介面：呼叫 API -> 拿到 DTO -> 轉成 Entity -> 回傳。

### 第 3 步：設定 Dependency Injection (連結)
告訴 Riverpod 怎麼找到這些類別。
```dart
// data/repositories/post_repository_impl.dart
@riverpod
PostRepository postRepository(PostRepositoryRef ref) {
  return PostRepositoryImpl(api: ref.watch(apiProvider));
}
```

### 第 4 步：實作 Presentation (UI)
1. **Providers**: 建立 `postListProvider` 呼叫 UseCase。
2. **Page**: 建立 `PostPage`，用 `ref.watch(postListProvider)` 監聽資料。

```dart
// presentation/pages/post_page.dart
class PostPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postListProvider);
    
    return postsAsync.when(
      data: (posts) => ListView(children: ...),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('出錯了: $err'),
    );
  }
}
```

---

## 5. 🚫 新手常見錯誤 (千萬別這樣做)

### ❌ 錯誤 1：在 UI 直接 Call API
```dart
// 絕對禁止！
ElevatedButton(
  onPressed: () async {
    var response = await dio.get('https://api.com/login'); // 錯！UI 不能碰 Dio
    // ...
  }
)
```
✅ **正確**：UI 呼叫 Controller/Provider -> Provider 呼叫 UseCase -> UseCase 呼叫 Repository。

### ❌ 錯誤 2：Model 到處亂用
DTO (`data/models`) **不能** 出現在 Presentation (UI) 層。
UI 層應該只看得到 Entity (`domain/entities`)。

### ❌ 錯誤 3：邏輯寫在 Widget 裡
```dart
// 盡量不要
Widget build(context) {
  if (user.age > 18) { ... } // 這是業務邏輯，應該移到 Domain 或 ViewModel 判斷
}
```

---

## 6. 🛠 常用工具與寫法

### 狀態管理 (Riverpod 2.0)
我們主要用 `AsyncValue` 來處理非同步資料，它自動幫你分好三種狀態：
1. `data`: 資料回來了
2. `loading`: 轉圈圈中
3. `error`: 爆掉了

### 程式碼產生 (Code Generation)
我們大量使用 `freezed` 和 `riverpod_annotation`。
如果你修改了帶有 `@riverpod` 或 `@freezed` 的檔案，記得跑指令：

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
或者 (如果專案有設定 Watch)：
```bash
flutter pub run build_runner watch
```

---

> **最後提醒** 💡
> 架構是為了幫助我們走得更遠，而不是為了限制你。
> 一開始可能會覺得步驟很多 (寫一個功能要開 5 個檔案?)，但當你的專案變大、或是要修改功能時，你會感謝分層架構救了你一命！
