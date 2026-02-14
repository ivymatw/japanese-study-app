# 日語學習 App - 開發日誌

## 專案初始化 (2026-02-15)

### 📋 需求分析完成
- ✅ 使用者需求整理
- ✅ 功能規格書編寫
- ✅ 技術選型決策

### 🏗️ 系統設計
- ✅ 技術架構設計
- ✅ 資料庫結構設計
- ✅ 模組化架構規劃
- ✅ UI/UX 流程設計

### 🧪 測試策略
- ✅ 測試計畫制定
- ✅ 測試用例設計
- ✅ 性能基準設定

### 📦 專案結構建立
```
japanese-study-app/
├── docs/           # 專案文檔
├── src/            # 原始碼 (待建立)
├── tests/          # 測試檔案 (待建立)
├── assets/         # 靜態資源 (待建立)
└── README.md       # 專案說明
```

### ✅ 專案初始化完成 (2026-02-15)
- 建立 GitHub Repository: https://github.com/ivymatw/japanese-study-app
- 推送完整專案文檔和結構
- 設定 MIT 授權和 .gitignore
- Git 版本控制初始化

### 🔄 技術架構調整 (2026-02-15)
**決策變更：** 從 React Native 跨平台開發改為 iOS 原生開發

**調整原因：**
- 簡化開發流程，專注 iOS 平台
- 更好的相機和手勢支援
- 使用原生 Vision Framework 提升 OCR 性能
- 避免跨平台相容性問題

**技術棧更新：**
- React Native → **Swift + SwiftUI**
- Redux → **@StateObject + @ObservableObject**
- SQLite → **Core Data + SQLite**
- Third-party OCR → **Vision Framework** (主要)

### ✅ iOS 原生實作完成 (2026-02-15 - MiniMax M2.5)
**重要里程碑：** 完成完整 iOS 應用程式碼實作

**完成的核心模組：**
- ✅ **SwiftUI App 架構** - JapaneseStudyApp.swift + ContentView
- ✅ **相機管理器** - CameraManager (AVFoundation 整合)
- ✅ **Vision OCR** - VisionManager (Vision Framework + 文字識別)
- ✅ **翻譯服務** - TranslationService (Google Translate API + 快取)
- ✅ **學習會話** - StudySessionManager (測驗邏輯)
- ✅ **Core Data** - PersistenceController + 資料模型

**完成的 SwiftUI Views：**
- ✅ **StudyTableListView** - 學習表列表管理
- ✅ **CameraView** - 相機拍照介面 
- ✅ **StudyCardView** - 測驗卡片 (翻面動畫 + 滑動手勢)
- ✅ **ProcessingView** - OCR 處理和編輯介面
- ✅ **TestConfigView** - 測驗設定和結果顯示
- ✅ **StatisticsView** - 學習統計和進度追蹤
- ✅ **AddStudyTableView** - 手動建立學習表

**技術整合：**
- ✅ Core Data 資料模型 (StudyTable, StudyItem, TestRecord)
- ✅ 相機權限和 Info.plist 設定
- ✅ Vision Framework 日文 OCR 整合
- ✅ Google Translate API 整合 (含快取機制)
- ✅ SwiftUI 動畫和手勢識別
- ✅ 配置檔案和常數管理

**檔案結構：**
```
JapaneseStudyApp/
├── JapaneseStudyApp.swift       # App 入口點
├── Views/                       # SwiftUI 視圖 (9個)
├── Managers/                    # 業務邏輯管理 (4個)
├── Models/                      # 資料模型擴展 (2個)
├── Core Data/                   # 資料持久化 (2個)
├── Utils/                       # 工具和配置 (1個)
└── Resources/                   # 資源和配置 (1個)
```

### 🎯 下一步計畫
1. 建立實際 Xcode 專案並匯入程式碼
2. 設定 API 金鑰和開發者憑證
3. 真機測試相機和 OCR 功能
4. UI/UX 調優和 bug 修復

---

### 📝 開發筆記
- 選擇 React Native 作為跨平台解決方案，可同時支援 iOS/Android
- OCR 採用 Google Vision API 主要方案 + Tesseract.js 作為離線備用
- 資料庫使用 SQLite 確保離線功能
- 翻譯服務初期使用 Google Translate API，未來可考慮整合多個翻譯源

### 🤔 技術決策記錄
**為什麼選擇 React Native？**
- 跨平台開發效率高
- 豐富的第三方套件生態
- 熟悉的 JavaScript/TypeScript 開發環境
- 良好的相機和手勢支援

**為什麼選擇 Google Vision API？**
- 日文 OCR 準確率最高
- 支援多種日文字型（平假名/片假名/漢字）
- API 穩定性佳
- 合理的價格方案

---

_開發過程中的想法、決策、遇到的問題都會記錄在這裡_