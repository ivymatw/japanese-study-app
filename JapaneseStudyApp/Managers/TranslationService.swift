import Foundation
import Network

class TranslationService: ObservableObject {
    @Published var isTranslating = false
    
    private let apiKey = Config.googleTranslateAPIKey
    private let baseURL = "https://translation.googleapis.com/language/translate/v2"
    
    // 翻譯快取
    private var translationCache: [String: String] = [:]
    private let cacheQueue = DispatchQueue(label: "translation.cache")
    
    private let monitor = NWPathMonitor()
    private let networkQueue = DispatchQueue(label: "network.monitor")
    @Published var isNetworkAvailable = true
    
    init() {
        startNetworkMonitoring()
        loadCacheFromDisk()
    }
    
    // MARK: - 網路監控
    private func startNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isNetworkAvailable = path.status == .satisfied
            }
        }
        monitor.start(queue: networkQueue)
    }
    
    // MARK: - 批量翻譯
    func translateBatch(_ texts: [String]) async -> [String: String] {
        guard !texts.isEmpty else { return [:] }
        
        DispatchQueue.main.async {
            self.isTranslating = true
        }
        
        var translations: [String: String] = [:]
        let textsToTranslate = texts.filter { !$0.isEmpty }
        
        // 首先檢查快取
        var uncachedTexts: [String] = []
        
        cacheQueue.sync {
            for text in textsToTranslate {
                if let cached = translationCache[text] {
                    translations[text] = cached
                } else {
                    uncachedTexts.append(text)
                }
            }
        }
        
        // 翻譯未快取的文字
        if !uncachedTexts.isEmpty && isNetworkAvailable {
            let newTranslations = await performTranslation(uncachedTexts)
            
            // 更新快取
            cacheQueue.async {
                for (text, translation) in newTranslations {
                    self.translationCache[text] = translation
                }
                self.saveCacheToDisk()
            }
            
            // 合併結果
            translations.merge(newTranslations) { _, new in new }
        }
        
        DispatchQueue.main.async {
            self.isTranslating = false
        }
        
        return translations
    }
    
    // MARK: - 單一翻譯
    func translateSingle(_ text: String) async -> String {
        let results = await translateBatch([text])
        return results[text] ?? text
    }
    
    // MARK: - 實際翻譯邏輯
    private func performTranslation(_ texts: [String]) async -> [String: String] {
        guard !apiKey.isEmpty else {
            print("Google Translate API 金鑰未設定")
            return [:]
        }
        
        var translations: [String: String] = [:]
        
        // 將文字分批處理（每批最多 10 個）
        let batchSize = 10
        for i in stride(from: 0, to: texts.count, by: batchSize) {
            let endIndex = min(i + batchSize, texts.count)
            let batch = Array(texts[i..<endIndex])
            
            let batchTranslations = await translateBatchAPI(batch)
            translations.merge(batchTranslations) { _, new in new }
            
            // 避免 API 限制，稍微延遲
            if endIndex < texts.count {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 秒
            }
        }
        
        return translations
    }
    
    private func translateBatchAPI(_ texts: [String]) async -> [String: String] {
        guard let url = URL(string: baseURL) else { return [:] }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "q": texts,
            "source": "ja",
            "target": "zh-TW",
            "key": apiKey,
            "format": "text"
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters)
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                return parseTranslationResponse(data, originalTexts: texts)
            } else {
                print("翻譯 API 請求失敗")
            }
        } catch {
            print("翻譯請求錯誤：\(error.localizedDescription)")
        }
        
        return [:]
    }
    
    private func parseTranslationResponse(_ data: Data, originalTexts: [String]) -> [String: String] {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let responseData = json["data"] as? [String: Any],
               let translations = responseData["translations"] as? [[String: Any]] {
                
                var results: [String: String] = [:]
                
                for (index, translationObj) in translations.enumerated() {
                    if let translatedText = translationObj["translatedText"] as? String,
                       index < originalTexts.count {
                        let originalText = originalTexts[index]
                        results[originalText] = translatedText
                    }
                }
                
                return results
            }
        } catch {
            print("解析翻譯回應失敗：\(error.localizedDescription)")
        }
        
        return [:]
    }
    
    // MARK: - 快取管理
    private func getCacheURL() -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return documentsPath?.appendingPathComponent("translation_cache.json")
    }
    
    private func saveCacheToDisk() {
        guard let url = getCacheURL() else { return }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: translationCache)
            try data.write(to: url)
        } catch {
            print("儲存翻譯快取失敗：\(error.localizedDescription)")
        }
    }
    
    private func loadCacheFromDisk() {
        guard let url = getCacheURL(),
              FileManager.default.fileExists(atPath: url.path) else { return }
        
        do {
            let data = try Data(contentsOf: url)
            if let cache = try JSONSerialization.jsonObject(with: data) as? [String: String] {
                cacheQueue.sync {
                    self.translationCache = cache
                }
            }
        } catch {
            print("載入翻譯快取失敗：\(error.localizedDescription)")
        }
    }
    
    func clearCache() {
        cacheQueue.sync {
            translationCache.removeAll()
        }
        
        if let url = getCacheURL() {
            try? FileManager.default.removeItem(at: url)
        }
    }
}