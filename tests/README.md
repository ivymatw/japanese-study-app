# Tests Directory

測試檔案目錄，包含單元測試、整合測試和端到端測試。

## 測試結構

```
tests/
├── unit/               # 單元測試
│   ├── components/     # 組件測試
│   ├── services/       # 服務層測試
│   └── utils/          # 工具函數測試
├── integration/        # 整合測試
│   ├── api/           # API 整合測試
│   └── database/      # 資料庫整合測試
├── e2e/               # 端到端測試
│   ├── camera.e2e.js  # 拍照流程測試
│   ├── test.e2e.js    # 測驗流程測試
│   └── edit.e2e.js    # 編輯流程測試
├── fixtures/          # 測試資料
│   ├── images/        # 測試圖片
│   └── mock-data/     # 模擬資料
└── setup/             # 測試設定
    ├── jest.config.js # Jest 配置
    └── detox.config.js # Detox 配置
```

## 測試工具

- **Jest**: JavaScript 測試框架
- **React Native Testing Library**: React Native 組件測試
- **Detox**: React Native 端到端測試框架
- **MSW**: API mocking