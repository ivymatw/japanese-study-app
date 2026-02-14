# 日語學習 App 📱📚

一款智能日語學習應用，透過拍照識別教科書內容，自動建立學習卡片進行記憶測驗。

## 🌟 主要功能

### 📸 智能拍照識別
- 拍攝教科書頁面
- 自動 OCR 文字識別（日文）
- 智能分類單字與語法例句
- 自動翻譯為繁體中文

### 📝 內容管理
- 建立自訂學習表格
- 編輯修正識別結果
- 本地資料庫儲存
- 支援批量管理

### 🎴 互動測驗
- 雙面卡片設計（日文/中文）
- 隨機順序出題
- 滑動手勢操作（右滑答對/左滑答錯）
- 錯題重複練習

## 🔧 技術棧 (iOS 原生)

- **開發語言**: Swift
- **UI 框架**: SwiftUI
- **資料庫**: Core Data + SQLite
- **OCR**: Vision Framework + Google Vision API
- **翻譯**: Google Translate API
- **測試**: XCTest + XCUITest

## 📋 專案狀態

🚧 **開發中** - 需求分析和系統設計已完成

### 完成項目
- [x] 需求規格書
- [x] 系統架構設計
- [x] 資料庫設計
- [x] 測試計畫
- [x] 專案文檔結構

### 進行中
- [ ] React Native 專案初始化
- [ ] 相機模組實作
- [ ] OCR 整合測試

### 待辦事項
- [ ] UI/UX 原型設計
- [ ] 核心功能開發
- [ ] 整合測試
- [ ] 性能優化
- [ ] 發布準備

## 📁 專案結構

```
japanese-study-app/
├── docs/                   # 📖 專案文檔
│   ├── requirements.md     # 需求規格
│   ├── system-design.md    # 系統設計
│   ├── test-plan.md        # 測試規劃
│   └── development-log.md  # 開發日誌
├── src/                    # 💻 原始碼
├── tests/                  # 🧪 測試檔案
├── assets/                 # 🎨 靜態資源
└── README.md              # 📄 專案說明
```

## 🚀 快速開始

### 系統需求
- macOS 13+ (Ventura 或更新版本)
- Xcode 15+ 
- iOS 16+ (目標設備)
- 真實 iPhone 設備（相機功能測試）

### 安裝與執行
```bash
# 克隆專案
git clone https://github.com/ivymatw/japanese-study-app.git
cd japanese-study-app

# 在 Xcode 中開啟專案
open JapaneseStudyApp.xcodeproj

# 在 Xcode 中建置並執行
⌘ + R
```

### 環境配置
在 Xcode 專案中建立 `Config.swift` 檔案並設定 API 金鑰：
```swift
enum Config {
    static let googleVisionAPIKey = "your_api_key_here"
    static let googleTranslateAPIKey = "your_api_key_here"
}
```

### 開發者帳戶設定
- 需要 Apple Developer 帳戶進行真機測試
- 設定 Provisioning Profile 和 Code Signing

## 🧪 測試

```bash
# 在 Xcode 中執行所有測試
⌘ + U

# 命令行執行單元測試
xcodebuild test -scheme JapaneseStudyApp -destination 'platform=iOS Simulator,name=iPhone 15'

# 執行 UI 測試
xcodebuild test -scheme JapaneseStudyAppUITests -destination 'platform=iOS Simulator,name=iPhone 15'

# 生成測試覆蓋率報告
xcodebuild test -enableCodeCoverage YES -resultBundlePath ./TestResults
```

## 📖 文檔

詳細的技術文檔和設計決策請參考 `docs/` 目錄：

- [需求規格書](docs/requirements.md) - 功能需求和使用者需求
- [系統設計](docs/system-design.md) - 架構設計和技術選型
- [測試規劃](docs/test-plan.md) - 測試策略和測試用例
- [開發日誌](docs/development-log.md) - 開發過程記錄

## 🤝 開發指南

### Git 工作流程
1. 從 `main` 建立功能分支
2. 開發並測試功能
3. 提交 Pull Request
4. 代碼審查後合併

### 編碼規範
- 使用 TypeScript 進行開發
- 遵循 ESLint 規範
- 撰寫單元測試
- 更新相關文檔

### 提交格式
```
type(scope): description

feat: 新功能
fix: 錯誤修復  
docs: 文檔更新
test: 測試相關
refactor: 重構
style: 格式調整
```

## 📄 授權

本專案採用 MIT 授權條款。詳見 [LICENSE](LICENSE) 檔案。

## 👥 貢獻者

- **Steve Ma** - 專案發起人與主要開發者

## 🎯 路線圖

### v1.0 (MVP)
- ✅ 基本拍照和 OCR 功能
- ✅ 簡單的卡片測驗系統
- ✅ 本地資料儲存

### v1.1
- 🔄 UI/UX 改善
- 🔄 批量處理優化
- 🔄 測驗統計功能

### v1.2
- 🔄 雲端同步功能
- 🔄 多裝置支援
- 🔄 進階測驗模式

---

💡 **想法或建議？** 歡迎開 issue 討論！