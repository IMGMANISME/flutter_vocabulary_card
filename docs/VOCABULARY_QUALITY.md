# 單字內容品質與 UX

本次保留 C1 學習定位，維持英文詞義、英文例句為主。這個定位是課程目標，
不是對目前每個單字、每個義項都已取得 C1 等級驗證的宣告。

## 目前驗證範圍

2026-10-05 檢查本機 24 個 JSON 檔，共 1,550 筆：

- 檢查必要欄位、型別、空白、重複 ID、重複的「單字 + 詞性」與字母分檔。
- 修正 `prescribe`、`triumph` 缺少中文解釋的問題。
- 校對以下七個義項，重寫英文解釋與例句，加入用法提示與字典參考。
- `non-profit` 的形容詞與名詞是不同卡片，保留各自 ID。
- 其餘 1,543 筆通過結構檢查；尚未逐一確認詞義、例句或 CEFR 等級。

| 單字 | 本次選用義項與改善 | 參考來源 |
|---|---|---|
| accountable | 說明責任；示範 accountable to / for | [Cambridge](https://dictionary.cambridge.org/us/dictionary/english/accountable) |
| critical | 與例句一致的「至關重要」，其他義項放在提示 | [Cambridge](https://dictionary.cambridge.org/us/dictionary/english/critical) |
| efficient | 強調減少資源浪費，與 effective 區分 | [Cambridge](https://dictionary.cambridge.org/us/dictionary/english/efficient) |
| faculty | 對齊例句的能力義，不混入大學學院義 | [Cambridge](https://dictionary.cambridge.org/us/dictionary/english/faculty) |
| prescribe | 指定藥物或療法，例句展示 prescribe a treatment | [Cambridge](https://dictionary.cambridge.org/us/dictionary/english/prescribe) |
| sanction | 對齊制裁義，示範 impose sanctions on | [Cambridge](https://dictionary.cambridge.org/us/dictionary/english/sanction?topic=allowing-and-permitting) |
| triumph | 重大成功或勝利，例句加入克服困難的情境 | [Cambridge](https://dictionary.cambridge.org/us/dictionary/english/triumph?topic=winning-and-defeating) |

字典用來確認義項與搭配；本次新增的解釋、例句與提示為自行撰寫，
不是整段複製字典內容。字典可能對不同義項標示不同 CEFR 等級。

## 後續校對流程

1. 一張卡片選一個清楚的義項，讓詞性、英文詞義、例句與中文一致。
2. 查字典確認詞義、常用搭配、及該義項的程度標記；不能只依詞頭推定 C1。
3. 撰寫能從情境推知詞義的例句，保留必要的介系詞或搭配。
4. 在 `vocabulary_reviews.json` 記錄原詞義、原例句、校對後內容及來源。
5. 同步校對資料，再執行檢查與測試：

```sh
python3 scripts/audit_vocabulary.py --apply-reviews
python3 scripts/audit_vocabulary.py
flutter test --no-pub
```

`--apply-reviews` 只修改與已知原文或校對後原文符合的本機詞條，
並產生 `vocabulary_content_review.entries.dart`。若原文已變更，會要求人工檢查。
此工具與 `build_runner` 的模型生成分開，生成檔已納入版本控制。

## App 使用的內容

App 仍從 Firestore 取得單字；本機 JSON 是內容維護資料，尚未成為離線初次啟動的資料來源。
資料模型會把七筆已知原內容套用校對，並保留 Firestore 文件 ID。
所以現有本機快取與雲端資料符合已知詞性、詞義、例句時，也會顯示校對內容。
不同義項或後來人工修改的內容不會被這些規則覆寫。

本次沒有修改 Firestore 文件。結構檢查只覆蓋版本控制內的 JSON，
不代表已稽核線上資料庫全部內容。缺少必要英文欄位的記錄會回報解析錯誤，
由既有快取備援與錯誤畫面處理，避免顯示空白學習卡。

## UX 行為

- 進度列顯示已標記學會的比例，另外顯示目前卡片位置。
- 洗牌先於篩選；移除已學單字不會重排剩餘卡片。
- 切換已學篩選盡量保留目前單字。
- 標記後提供六秒 Undo；同一單字寫入中暫停重複標記。
- 標記按鈕放在卡片外，卡片兩面可捲動，放大字體時頁面也可捲動。
- 卡片直接顯示詞性；校對卡片背面顯示英文用法提示，詳細資訊保留可選取的來源網址。
- 詞庫載入失敗可重試；學習狀態載入失敗時提供重試並暫停標記。

小螢幕與字體縮放測試使用 Flutter 的一般版面，尚未驗證 iOS / Android 原生玻璃效果。
