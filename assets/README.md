# Assets Directory

靜態資源檔案目錄，包含圖片、字型、音效等資源。

## 資源結構

```
assets/
├── images/             # 圖片資源
│   ├── icons/         # 應用圖示
│   ├── illustrations/ # 插圖和示意圖
│   └── splash/        # 啟動畫面
├── fonts/             # 字型檔案
│   ├── NotoSansCJK/   # 支援中日文字型
│   └── custom/        # 自定義字型
├── sounds/            # 音效檔案
│   ├── correct.mp3    # 答對音效
│   └── incorrect.mp3  # 答錯音效
└── test-data/         # 測試用資源
    ├── sample-pages/  # 教科書範例頁面
    └── mock-images/   # 測試用圖片
```

## 資源規範

### 圖片
- **格式**: PNG, JPG, SVG
- **解析度**: 提供 @1x, @2x, @3x 版本
- **壓縮**: 適度壓縮保持檔案大小

### 字型
- **中日文支援**: Noto Sans CJK
- **英文**: System fonts (San Francisco, Roboto)
- **大小**: 支援無障礙大字體

### 音效
- **格式**: MP3, AAC
- **品質**: 128kbps
- **長度**: 簡短音效 (<2秒)