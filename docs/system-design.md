# 日語學習 App - 系統設計

## 技術架構

### 技術棧選擇 (iOS 原生)
- **開發語言**: Swift
- **UI 框架**: SwiftUI
- **資料庫**: Core Data + SQLite
- **OCR服務**: Vision Framework (iOS 原生) + Google Vision API (備用)
- **翻譯服務**: Google Translate API
- **影像處理**: AVFoundation + Vision Framework

### iOS 原生架構圖
```
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────┐
│   AVFoundation      │───▶│   Vision Framework  │───▶│ Google Translate│
│   (相機拍照/錄影)   │    │   (OCR文字識別)     │    │   (翻譯API)     │
└─────────────────────┘    └─────────────────────┘    └─────────────────┘
          │                           │                         │
          ▼                           ▼                         ▼
┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────┐
│     PhotoKit        │    │    NLP Processing   │    │   Core Data     │
│   (圖片庫管理)      │    │   (內容智能分析)    │    │  (本地資料庫)   │
└─────────────────────┘    └─────────────────────┘    └─────────────────┘
                                     │
                                     ▼
                         ┌─────────────────────┐
                         │      SwiftUI        │
                         │   (測驗UI/手勢)     │
                         └─────────────────────┘
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

## 核心模組設計 (iOS Swift)

### 1. CameraManager (相機管理器)
```swift
class CameraManager: NSObject, ObservableObject {
    // 設定相機會話
    func setupCameraSession()
    
    // 拍攝多張照片
    func captureMultiplePhotos() -> [UIImage]
    
    // 影像預處理 (裁切、增強)
    func preprocessImage(_ image: UIImage) -> UIImage
    
    // 儲存到 PhotoKit
    func saveToPhotoLibrary(_ images: [UIImage])
}
```

### 2. VisionManager (視覺識別管理器)
```swift
class VisionManager: ObservableObject {
    // Vision Framework OCR
    func recognizeTextWithVision(_ image: UIImage) async -> [VNRecognizedTextObservation]
    
    // Google Vision API 備用
    func recognizeWithGoogleAPI(_ image: UIImage) async -> String
    
    // 智能內容分類
    func classifyContent(_ recognizedText: String) -> ContentType
    
    // 日文文字偵測
    func detectJapaneseText(_ observations: [VNRecognizedTextObservation]) -> [String]
}
```

### 3. TranslationService (翻譯服務)
```swift
class TranslationService: ObservableObject {
    // 批量翻譯
    func translateBatch(_ japaneseTexts: [String]) async -> [String]
    
    // 單一翻譯
    func translateSingle(_ text: String) async -> String
    
    // 快取管理
    private func getCachedTranslation(_ text: String) -> String?
    private func setCachedTranslation(_ text: String, translation: String)
}
```

### 4. StudySessionManager (學習會話管理器)
```swift
class StudySessionManager: ObservableObject {
    // 建立測驗會話
    func createStudySession(tableIds: [UUID], settings: TestSettings) -> StudySession
    
    // 隨機排序
    func shuffleItems(_ items: [StudyItem]) -> [StudyItem]
    
    // 記錄答題
    func recordAnswer(itemId: UUID, isCorrect: Bool)
    
    // 產生複習清單
    func generateReviewItems(from sessionId: UUID) -> [StudyItem]
}
```

## SwiftUI 介面設計

### 主要 View
1. **ContentView** - 應用主入口點
2. **StudyTableListView** - 學習表列表 (NavigationView)
3. **CameraView** - 相機介面 (UIViewControllerRepresentable)
4. **EditingView** - OCR 結果編輯 (Form + TextField)
5. **TestConfigView** - 測驗設定 (Sheet presentation)
6. **StudyCardView** - 測驗卡片 (Card flip animation)
7. **ResultView** - 測驗結果 (Chart + List)

### SwiftUI 手勢實作
```swift
// 卡片翻面
.onTapGesture {
    withAnimation(.easeInOut) {
        isFlipped.toggle()
    }
}

// 滑動手勢
.gesture(
    DragGesture()
        .onEnded { value in
            if value.translation.x > 100 {
                markAsCorrect() // 右滑答對
            } else if value.translation.x < -100 {
                markAsIncorrect() // 左滑答錯
            }
        }
)
```

## iOS 性能優化

### 1. 圖片處理優化
```swift
// 使用 ImageIO 框架壓縮
let options: [CFString: Any] = [
    kCGImageDestinationLossyCompressionQuality: 0.8,
    kCGImagePropertyPixelWidth: 1024,
    kCGImagePropertyPixelHeight: 768
]

// 非同步處理
DispatchQueue.global(qos: .userInitiated).async {
    let processedImage = self.processImage(image)
    DispatchQueue.main.async {
        self.displayImage(processedImage)
    }
}
```

### 2. Vision Framework 優化
```swift
// 批次處理 OCR 請求
let request = VNRecognizeTextRequest { request, error in
    // 處理結果
}
request.recognitionLanguages = ["ja", "en"]
request.usesLanguageCorrection = true

// 設定處理優先級
request.preferBackgroundProcessing = true
```

### 3. Core Data 優化
```swift
// 批次操作
context.performAndWait {
    // 批次插入/更新
}

// 分頁查詢
let fetchRequest: NSFetchRequest<StudyItem> = StudyItem.fetchRequest()
fetchRequest.fetchLimit = 50
fetchRequest.fetchOffset = currentPage * 50
```

## 安全性考量

1. **API 金鑰保護** - 使用環境變數存儲
2. **本地資料加密** - SQLite 加密
3. **網路請求** - HTTPS 連線
4. **隱私保護** - 圖片本地處理優先