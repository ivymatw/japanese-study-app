import Foundation
import CoreData

class StudySessionManager: ObservableObject {
    @Published var currentSession: StudySession?
    @Published var isSessionActive = false
    @Published var currentItemIndex = 0
    @Published var correctCount = 0
    @Published var incorrectCount = 0
    @Published var incorrectItems: [StudyItem] = []
    @Published var sessionItems: [StudyItem] = []
    
    struct StudySession {
        let id = UUID()
        let tableIds: [UUID]
        let items: [StudyItem]
        let startTime = Date()
        var endTime: Date?
        var settings: TestSettings
    }
    
    struct TestSettings {
        var showJapaneseFirst: Bool = true
        var shuffleOrder: Bool = true
        var reviewIncorrectOnly: Bool = false
    }
    
    func startSession(with tables: [StudyTable], settings: TestSettings) {
        var allItems: [StudyItem] = []
        let tableIds = tables.map { $0.id ?? UUID() }
        
        for table in tables {
            allItems.append(contentsOf: table.itemsArray)
        }
        
        if settings.shuffleOrder {
            allItems.shuffle()
        }
        
        sessionItems = allItems
        currentSession = StudySession(tableIds: tableIds, items: allItems, settings: settings)
        
        resetSessionStats()
        isSessionActive = true
    }
    
    func startReviewSession() {
        guard !incorrectItems.isEmpty else { return }
        
        let settings = TestSettings(shuffleOrder: true, reviewIncorrectOnly: true)
        sessionItems = incorrectItems
        
        if settings.shuffleOrder {
            sessionItems.shuffle()
        }
        
        currentSession?.settings = settings
        resetSessionStats()
        isSessionActive = true
    }
    
    func answerCorrect() {
        correctCount += 1
        nextItem()
    }
    
    func answerIncorrect() {
        incorrectCount += 1
        
        if currentItemIndex < sessionItems.count {
            let currentItem = sessionItems[currentItemIndex]
            if !incorrectItems.contains(where: { $0.id == currentItem.id }) {
                incorrectItems.append(currentItem)
            }
        }
        
        nextItem()
    }
    
    private func nextItem() {
        currentItemIndex += 1
        
        if currentItemIndex >= sessionItems.count {
            endSession()
        }
    }
    
    func endSession() {
        currentSession?.endTime = Date()
        isSessionActive = false
        
        // 儲存測驗記錄
        saveSessionRecord()
    }
    
    private func resetSessionStats() {
        currentItemIndex = 0
        correctCount = 0
        incorrectCount = 0
        incorrectItems = []
    }
    
    private func saveSessionRecord() {
        // TODO: 實作測驗記錄儲存到 Core Data
        // 這裡可以儲存測驗統計資料供後續分析使用
    }
    
    // MARK: - 會話統計
    var totalItems: Int {
        return sessionItems.count
    }
    
    var completedItems: Int {
        return correctCount + incorrectCount
    }
    
    var progressPercentage: Double {
        guard totalItems > 0 else { return 0 }
        return Double(completedItems) / Double(totalItems)
    }
    
    var accuracyPercentage: Double {
        let total = correctCount + incorrectCount
        guard total > 0 else { return 0 }
        return Double(correctCount) / Double(total)
    }
    
    var remainingItems: Int {
        return totalItems - completedItems
    }
    
    var currentItem: StudyItem? {
        guard currentItemIndex < sessionItems.count else { return nil }
        return sessionItems[currentItemIndex]
    }
    
    var isSessionCompleted: Bool {
        return currentItemIndex >= sessionItems.count && isSessionActive
    }
    
    // MARK: - 會話管理
    func pauseSession() {
        isSessionActive = false
    }
    
    func resumeSession() {
        isSessionActive = true
    }
    
    func skipCurrentItem() {
        nextItem()
    }
}