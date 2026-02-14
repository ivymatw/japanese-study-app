import SwiftUI

struct TestConfigView: View {
    let table: StudyTable
    
    @EnvironmentObject private var sessionManager: StudySessionManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var showJapaneseFirst = true
    @State private var shuffleOrder = true
    @State private var selectedTables: Set<StudyTable> = []
    @State private var showingTestView = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("學習表選擇") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Button(action: {
                                if selectedTables.contains(table) {
                                    selectedTables.remove(table)
                                } else {
                                    selectedTables.insert(table)
                                }
                            }) {
                                HStack {
                                    Image(systemName: selectedTables.contains(table) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedTables.contains(table) ? .blue : .gray)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(table.title ?? "未命名表格")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        HStack {
                                            Text(table.typeDisplayName)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            
                                            Spacer()
                                            
                                            Text("\(table.itemCount) 個項目")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    Text("將測驗 \(totalSelectedItems) 個項目")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("測驗設定") {
                    Toggle("優先顯示日文", isOn: $showJapaneseFirst)
                    
                    Toggle("隨機順序", isOn: $shuffleOrder)
                }
                
                Section("說明") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "hand.tap")
                                .foregroundColor(.blue)
                            Text("點擊卡片翻面查看答案")
                                .font(.subheadline)
                        }
                        
                        HStack {
                            Image(systemName: "arrow.right")
                                .foregroundColor(.green)
                            Text("向右滑動標記答對")
                                .font(.subheadline)
                        }
                        
                        HStack {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.red)
                            Text("向左滑動標記答錯")
                                .font(.subheadline)
                        }
                    }
                    .foregroundColor(.secondary)
                }
                
                if sessionManager.incorrectItems.count > 0 {
                    Section("複習模式") {
                        Button("複習錯誤項目 (\(sessionManager.incorrectItems.count) 個)") {
                            startReviewSession()
                        }
                        .foregroundColor(.orange)
                    }
                }
            }
            .navigationTitle("測驗設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("開始") {
                        startTest()
                    }
                    .disabled(selectedTables.isEmpty)
                }
            }
            .onAppear {
                selectedTables.insert(table)
            }
            .fullScreenCover(isPresented: $showingTestView) {
                TestView()
                    .environmentObject(sessionManager)
            }
        }
    }
    
    private var totalSelectedItems: Int {
        return selectedTables.reduce(0) { $0 + $1.itemCount }
    }
    
    private func startTest() {
        let settings = StudySessionManager.TestSettings(
            showJapaneseFirst: showJapaneseFirst,
            shuffleOrder: shuffleOrder
        )
        
        sessionManager.startSession(
            with: Array(selectedTables),
            settings: settings
        )
        
        showingTestView = true
        dismiss()
    }
    
    private func startReviewSession() {
        sessionManager.startReviewSession()
        showingTestView = true
        dismiss()
    }
}

struct TestView: View {
    @EnvironmentObject private var sessionManager: StudySessionManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var isCardFlipped = false
    @State private var showingResultView = false
    @State private var showingExitAlert = false
    
    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // 頂部資訊欄
                HStack {
                    Button("退出") {
                        showingExitAlert = true
                    }
                    .foregroundColor(.red)
                    
                    Spacer()
                    
                    Text("\(sessionManager.currentItemIndex + 1) / \(sessionManager.totalItems)")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(Int(sessionManager.accuracyPercentage * 100))%")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                .padding()
                
                // 進度條
                ProgressView(value: sessionManager.progressPercentage)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .padding(.horizontal)
                
                // 卡片區域
                if let currentItem = sessionManager.currentItem {
                    StudyCardView(
                        item: currentItem,
                        isFlipped: $isCardFlipped,
                        onSwipeRight: {
                            sessionManager.answerCorrect()
                            isCardFlipped = false
                        },
                        onSwipeLeft: {
                            sessionManager.answerIncorrect()
                            isCardFlipped = false
                        }
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 400)
                    .padding()
                }
                
                // 統計資訊
                HStack(spacing: 40) {
                    VStack {
                        Text("\(sessionManager.correctCount)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("答對")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text("\(sessionManager.incorrectCount)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        
                        Text("答錯")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text("\(sessionManager.remainingItems)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("剩餘")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
        }
        .onChange(of: sessionManager.isSessionCompleted) { completed in
            if completed {
                showingResultView = true
            }
        }
        .fullScreenCover(isPresented: $showingResultView) {
            TestResultView()
                .environmentObject(sessionManager)
        }
        .alert("確定要退出測驗嗎？", isPresented: $showingExitAlert) {
            Button("取消", role: .cancel) { }
            Button("退出", role: .destructive) {
                sessionManager.endSession()
                dismiss()
            }
        } message: {
            Text("目前進度將會遺失")
        }
    }
}

struct TestResultView: View {
    @EnvironmentObject private var sessionManager: StudySessionManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // 完成圖示
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            // 結果標題
            Text("測驗完成！")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // 統計結果
            VStack(spacing: 16) {
                HStack {
                    Text("總題數：")
                    Spacer()
                    Text("\(sessionManager.totalItems)")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("答對：")
                    Spacer()
                    Text("\(sessionManager.correctCount)")
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("答錯：")
                    Spacer()
                    Text("\(sessionManager.incorrectCount)")
                        .foregroundColor(.red)
                        .fontWeight(.semibold)
                }
                
                Divider()
                
                HStack {
                    Text("正確率：")
                    Spacer()
                    Text("\(Int(sessionManager.accuracyPercentage * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // 動作按鈕
            VStack(spacing: 12) {
                if sessionManager.incorrectItems.count > 0 {
                    Button("複習錯誤項目 (\(sessionManager.incorrectItems.count))") {
                        sessionManager.startReviewSession()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
                
                Button("完成") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct TestConfigView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let table = StudyTable(context: context)
        table.title = "測試表格"
        table.type = "vocabulary"
        
        return TestConfigView(table: table)
            .environmentObject(StudySessionManager())
    }
}