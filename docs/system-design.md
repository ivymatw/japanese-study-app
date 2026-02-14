# 日語學習 App - 系統設計

## 技術架構

### 技術棧選擇
- **前端框架**: React Native (跨平台開發)
- **狀態管理**: Redux Toolkit
- **資料庫**: SQLite (本地存儲)
- **OCR服務**: Google Vision API + Tesseract.js (備用)
- **翻譯服務**: Google Translate API
- **影像處理**: react-native-image-picker + OpenCV

### 系統架構圖
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   相機模組      │───▶│   OCR 處理      │───▶│   翻譯服務      │
│   (拍照/裁切)   │    │   (文字識別)    │    │   (中日翻譯)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
          │                       │                       │
          ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   影像存儲      │    │   內容分析      │    │   本地資料庫    │
│   (原圖/處理圖) │    │   (單字/句子)   │    │   (SQLite)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                    ┌─────────────────┐
                    │   測驗系統      │
                    │   (卡片/手勢)   │
                    └─────────────────┘
```

## 資料庫設計

### 資料表結構

**1. tables (學習表)**
```sql
CREATE TABLE tables (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    type TEXT CHECK(type IN ('vocabulary', 'grammar')) NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

**2. items (學習項目)**
```sql
CREATE TABLE items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    table_id INTEGER REFERENCES tables(id),
    japanese TEXT NOT NULL,
    chinese TEXT NOT NULL,
    original_image TEXT, -- 原始圖片路徑
    position_x INTEGER,  -- 在圖片中的位置
    position_y INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

**3. test_records (測驗記錄)**
```sql
CREATE TABLE test_records (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    table_ids TEXT NOT NULL, -- JSON array of table IDs
    total_items INTEGER NOT NULL,
    correct_items INTEGER NOT NULL,
    incorrect_items TEXT, -- JSON array of item IDs
    started_at DATETIME NOT NULL,
    completed_at DATETIME
);
```

**4. images (圖片管理)**
```sql
CREATE TABLE images (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    file_path TEXT NOT NULL,
    table_id INTEGER REFERENCES tables(id),
    processed BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

## 核心模組設計

### 1. CameraModule (相機模組)
```javascript
class CameraModule {
    // 拍攝多張照片
    async captureMultiplePhotos()
    // 影像預處理 (裁切、銳化、去噪)
    async preprocessImage(imageUri)
    // 儲存圖片到本地
    async saveImage(imageData, tableId)
}
```

### 2. OCRModule (文字識別)
```javascript
class OCRModule {
    // Google Vision API 識別
    async recognizeTextWithVision(imageUri)
    // Tesseract 備用識別
    async recognizeTextWithTesseract(imageUri)
    // 智能內容分類 (單字/語法)
    async classifyContent(recognizedText)
}
```

### 3. TranslationModule (翻譯模組)
```javascript
class TranslationModule {
    // 批量翻譯
    async translateBatch(japaneseTexts)
    // 單一翻譯
    async translateSingle(japaneseText)
    // 翻譯快取機制
    async getCachedTranslation(text)
}
```

### 4. TestModule (測驗模組)
```javascript
class TestModule {
    // 建立測驗
    async createTest(tableIds, settings)
    // 隨機排序題目
    shuffleItems(items)
    // 記錄答題結果
    async recordAnswer(itemId, isCorrect)
    // 產生錯題集
    async generateRetestItems(testId)
}
```

## UI/UX 設計

### 主要頁面
1. **首頁** - 顯示學習表列表
2. **拍照頁** - 相機介面 + 圖片預覽
3. **編輯頁** - 識別結果編輯
4. **測驗設定** - 選擇表格和測驗模式
5. **測驗頁** - 卡片翻轉 + 滑動手勢
6. **結果頁** - 測驗統計 + 錯題檢討

### 手勢設計
- **卡片翻面**: 點擊卡片
- **答對**: 右滑 (swipe right) ✅
- **答錯**: 左滑 (swipe left) ❌
- **返回**: 向下滑 (swipe down)

## 性能優化

### 1. 圖片處理
- 壓縮圖片減少儲存空間
- 非同步處理避免 UI 卡頓
- 快取處理結果

### 2. OCR 優化
- 批次處理多個識別請求
- 本地 OCR 作為備用方案
- 識別結果快取

### 3. 資料庫優化
- 建立適當索引
- 分頁載入大量資料
- 定期清理過期資料

## 安全性考量

1. **API 金鑰保護** - 使用環境變數存儲
2. **本地資料加密** - SQLite 加密
3. **網路請求** - HTTPS 連線
4. **隱私保護** - 圖片本地處理優先