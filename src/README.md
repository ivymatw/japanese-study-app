# iOS Source Code Directory

這裡將存放 iOS 原生應用的 Swift 原始碼。

## iOS 專案目錄結構

```
JapaneseStudyApp/
├── App/                    # 應用程式入口點
│   ├── JapaneseStudyApp.swift     # App 主檔案
│   └── ContentView.swift          # 主要內容視圖
├── Views/                  # SwiftUI Views
│   ├── StudyTableListView.swift   # 學習表列表
│   ├── CameraView.swift           # 相機介面
│   ├── EditingView.swift          # 編輯頁面
│   ├── StudyCardView.swift        # 測驗卡片
│   └── ResultView.swift           # 結果頁面
├── Managers/               # 業務邏輯管理器
│   ├── CameraManager.swift        # 相機管理
│   ├── VisionManager.swift        # OCR 識別
│   ├── TranslationService.swift   # 翻譯服務
│   └── StudySessionManager.swift  # 學習會話
├── Models/                 # 資料模型
│   ├── StudyTable.swift           # 學習表
│   ├── StudyItem.swift            # 學習項目
│   └── TestSession.swift          # 測驗會話
├── Core Data/              # Core Data 模型
│   ├── DataModel.xcdatamodeld     # 資料庫模型
│   └── PersistenceController.swift # 持久化控制器
├── Extensions/             # Swift 擴展
│   ├── UIImage+Extensions.swift   # 圖片處理擴展
│   └── String+Extensions.swift    # 字串擴展
├── Utils/                  # 工具類
│   ├── NetworkManager.swift       # 網路管理
│   └── Constants.swift            # 常數定義
└── Resources/              # 資源檔案
    ├── Assets.xcassets            # 圖片資源
    ├── Localizable.strings        # 本地化字串
    └── Info.plist                 # 應用設定
```

建立 Xcode 專案後將實作完整的 iOS 原生應用程式碼。