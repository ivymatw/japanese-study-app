import Vision
import UIKit
import NaturalLanguage

class VisionManager: ObservableObject {
    @Published var isProcessing = false
    @Published var recognizedItems: [RecognizedItem] = []
    
    enum ContentType {
        case vocabulary
        case grammar
        case mixed
    }
    
    struct RecognizedItem {
        let id = UUID()
        let text: String
        let confidence: Float
        let boundingBox: CGRect
        var translation: String = ""
        var isSelected: Bool = true
    }
    
    func processImages(_ images: [UIImage]) async -> [RecognizedItem] {
        DispatchQueue.main.async {
            self.isProcessing = true
            self.recognizedItems = []
        }
        
        var allItems: [RecognizedItem] = []
        
        for image in images {
            let items = await recognizeText(in: image)
            allItems.append(contentsOf: items)
        }
        
        // 去除重複項目
        let uniqueItems = removeDuplicates(from: allItems)
        
        DispatchQueue.main.async {
            self.recognizedItems = uniqueItems
            self.isProcessing = false
        }
        
        return uniqueItems
    }
    
    private func recognizeText(in image: UIImage) async -> [RecognizedItem] {
        guard let cgImage = image.cgImage else { return [] }
        
        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    print("OCR 錯誤：\(error.localizedDescription)")
                    continuation.resume(returning: [])
                    return
                }
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                
                let items = self.processObservations(observations)
                continuation.resume(returning: items)
            }
            
            // 設定 OCR 為支援日文
            request.recognitionLanguages = ["ja", "en"]
            request.usesLanguageCorrection = true
            request.recognitionLevel = .accurate
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    print("執行 OCR 失敗：\(error.localizedDescription)")
                    continuation.resume(returning: [])
                }
            }
        }
    }
    
    private func processObservations(_ observations: [VNRecognizedTextObservation]) -> [RecognizedItem] {
        var items: [RecognizedItem] = []
        
        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else { continue }
            
            let text = topCandidate.string
            let confidence = topCandidate.confidence
            let boundingBox = observation.boundingBox
            
            // 過濾掉信心度太低或太短的文字
            if confidence > 0.5 && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let item = RecognizedItem(
                    text: text,
                    confidence: confidence,
                    boundingBox: boundingBox
                )
                items.append(item)
            }
        }
        
        return items.sorted { $0.boundingBox.minY > $1.boundingBox.minY } // 由上到下排序
    }
    
    private func removeDuplicates(from items: [RecognizedItem]) -> [RecognizedItem] {
        var uniqueItems: [RecognizedItem] = []
        var seenTexts: Set<String> = []
        
        for item in items {
            let normalizedText = item.text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !seenTexts.contains(normalizedText) {
                seenTexts.insert(normalizedText)
                uniqueItems.append(item)
            }
        }
        
        return uniqueItems
    }
    
    func classifyContent(_ text: String) -> ContentType {
        // 簡單的內容分類邏輯
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 檢查是否包含句子結構（語法）
        if text.contains("。") || text.contains("？") || text.contains("！") || 
           text.contains("です") || text.contains("ます") || text.contains("だ") {
            return .grammar
        }
        
        // 檢查是否是單一詞彙（單字）
        if text.count <= 10 && !text.contains(" ") {
            return .vocabulary
        }
        
        return .mixed
    }
    
    func filterJapaneseText(_ items: [RecognizedItem]) -> [RecognizedItem] {
        return items.filter { item in
            let text = item.text
            // 檢查是否包含日文字符
            let japaneseRange = NSRange(location: 0, length: text.utf16.count)
            let regex = try? NSRegularExpression(pattern: "[\\p{Hiragana}\\p{Katakana}\\p{Han}]")
            return regex?.firstMatch(in: text, options: [], range: japaneseRange) != nil
        }
    }
}

extension VisionManager {
    // 從 Google Vision API 獲取文字（備用方案）
    func recognizeWithGoogleAPI(_ image: UIImage) async -> [RecognizedItem] {
        // TODO: 實作 Google Vision API 整合
        // 這裡暫時返回空數組，實際實作需要串接 Google Vision API
        return []
    }
}