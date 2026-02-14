# Source Code Directory

這裡將存放 React Native 應用的原始碼。

## 預計目錄結構

```
src/
├── components/          # 可重用組件
│   ├── Camera/         # 相機相關組件
│   ├── Card/           # 測驗卡片組件
│   └── Common/         # 共用 UI 組件
├── screens/            # 頁面組件
│   ├── HomeScreen/     # 首頁
│   ├── CameraScreen/   # 拍照頁面
│   ├── EditScreen/     # 編輯頁面
│   ├── TestScreen/     # 測驗頁面
│   └── ResultScreen/   # 結果頁面
├── services/           # 服務層
│   ├── OCRService.js   # OCR 服務
│   ├── TranslationService.js  # 翻譯服務
│   └── DatabaseService.js     # 資料庫服務
├── store/              # Redux store
│   ├── slices/         # Redux slices
│   └── index.js        # Store 配置
├── utils/              # 工具函數
├── constants/          # 常數定義
└── types/              # TypeScript 型別定義
```

React Native 專案初始化後將在此建立完整的程式碼結構。