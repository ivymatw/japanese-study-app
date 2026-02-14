# iOS Tests Directory

iOS 測試檔案目錄，包含單元測試、整合測試和 UI 測試。

## iOS 測試結構

```
JapaneseStudyAppTests/
├── Unit Tests/              # 單元測試 (XCTest)
│   ├── Managers/           # 管理器測試
│   │   ├── CameraManagerTests.swift
│   │   ├── VisionManagerTests.swift
│   │   └── TranslationServiceTests.swift
│   ├── Models/             # 模型測試
│   │   ├── StudyTableTests.swift
│   │   └── StudyItemTests.swift
│   └── Utils/              # 工具類測試
│       └── NetworkManagerTests.swift
├── Integration Tests/       # 整合測試
│   ├── CoreData/          # Core Data 測試
│   │   └── PersistenceTests.swift
│   └── API/               # API 整合測試
│       └── TranslationAPITests.swift
├── UI Tests/               # UI 測試 (XCUITest)
│   ├── CameraFlowUITests.swift      # 拍照流程測試
│   ├── StudySessionUITests.swift    # 學習流程測試
│   └── EditingFlowUITests.swift     # 編輯流程測試
├── Test Resources/         # 測試資源
│   ├── Sample Images/     # 測試圖片
│   │   ├── vocabulary_page.jpg
│   │   └── grammar_page.jpg
│   └── Mock Data/         # 模擬資料
│       └── sample_study_data.json
└── Test Utilities/         # 測試工具
    ├── XCTestCase+Extensions.swift
    └── MockDataGenerator.swift
```

## iOS 測試工具

- **XCTest**: Apple 官方測試框架 (單元測試)
- **XCUITest**: Apple 官方 UI 測試框架
- **Instruments**: 性能測試和記憶體分析
- **SwiftUI Preview**: 視覺化 UI 測試

## 測試執行

```bash
# 在 Xcode 中執行所有測試
⌘ + U

# 單獨執行單元測試
xcodebuild test -scheme JapaneseStudyApp -destination 'platform=iOS Simulator,name=iPhone 14'

# 執行 UI 測試
xcodebuild test -scheme JapaneseStudyAppUITests -destination 'platform=iOS Simulator,name=iPhone 14'

# 生成測試覆蓋率報告
xcodebuild test -enableCodeCoverage YES
```