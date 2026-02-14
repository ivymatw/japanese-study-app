import Foundation

enum Config {
    // Google API 金鑰
    static let googleVisionAPIKey = "YOUR_GOOGLE_VISION_API_KEY"
    static let googleTranslateAPIKey = "YOUR_GOOGLE_TRANSLATE_API_KEY"
    
    // 應用設定
    static let supportedLanguages = ["ja", "en"]
    static let targetLanguage = "zh-TW"
    
    // OCR 設定
    static let minimumTextConfidence: Float = 0.5
    static let maximumTextLength = 100
    
    // 快取設定
    static let maxCacheSize = 1000
    static let cacheExpirationDays = 30
    
    // 測驗設定
    static let defaultCardAnimationDuration: Double = 0.6
    static let swipeThreshold: CGFloat = 100
    
    // UI 設定
    static let cardCornerRadius: CGFloat = 20
    static let cardPadding: CGFloat = 30
    static let cardShadowRadius: CGFloat = 8
}

// MARK: - 開發環境檢查
extension Config {
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    static var isAPIKeyConfigured: Bool {
        return !googleTranslateAPIKey.hasPrefix("YOUR_") && 
               !googleVisionAPIKey.hasPrefix("YOUR_")
    }
}