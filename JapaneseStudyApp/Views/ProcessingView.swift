import SwiftUI

struct ProcessingView: View {
    let images: [UIImage]
    let onComplete: ([UIImage]) -> Void
    
    @EnvironmentObject private var visionManager: VisionManager
    @EnvironmentObject private var translationService: TranslationService
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var recognizedItems: [VisionManager.RecognizedItem] = []
    @State private var editableItems: [EditableItem] = []
    @State private var isProcessing = false
    @State private var currentStep: ProcessingStep = .recognizing
    @State private var showingNameSheet = false
    @State private var tableName = ""
    @State private var tableType: TableType = .vocabulary
    
    enum ProcessingStep {
        case recognizing
        case translating
        case editing
        case saving
    }
    
    enum TableType: String, CaseIterable {
        case vocabulary = "vocabulary"
        case grammar = "grammar"
        
        var displayName: String {
            switch self {
            case .vocabulary: return "單字"
            case .grammar: return "語法"
            }
        }
    }
    
    struct EditableItem: Identifiable {
        let id = UUID()
        var japanese: String
        var chinese: String
        var isSelected: Bool = true
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 進度指示器
                ProgressIndicatorView(currentStep: currentStep)
                
                switch currentStep {
                case .recognizing, .translating:
                    processingView
                case .editing:
                    editingView
                case .saving:
                    savingView
                }
            }
            .navigationTitle("處理圖片")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                if currentStep == .editing {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("儲存") {
                            showingNameSheet = true
                        }
                        .disabled(editableItems.filter(\.isSelected).isEmpty)
                    }
                }
            }
            .sheet(isPresented: $showingNameSheet) {
                nameTableSheet
            }
            .onAppear {
                startProcessing()
            }
        }
    }
    
    private var processingView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(1.5)
            
            Text(currentStepDescription)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text("處理 \(images.count) 張圖片...")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
    }
    
    private var editingView: some View {
        VStack(spacing: 0) {
            // 選擇指示
            HStack {
                Text("識別結果")
                    .font(.headline)
                
                Spacer()
                
                Text("\(editableItems.filter(\.isSelected).count)/\(editableItems.count) 已選擇")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            
            // 編輯列表
            List {
                ForEach(editableItems.indices, id: \.self) { index in
                    EditableItemRowView(
                        item: $editableItems[index],
                        onToggleSelection: {
                            editableItems[index].isSelected.toggle()
                        }
                    )
                }
            }
        }
    }
    
    private var savingView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("儲存成功！")
                .font(.headline)
            
            Text("已建立新的學習表格")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button("完成") {
                onComplete(images)
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
    
    private var nameTableSheet: some View {
        NavigationView {
            Form {
                Section("學習表設定") {
                    TextField("表格名稱", text: $tableName)
                    
                    Picker("類型", selection: $tableType) {
                        ForEach(TableType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                }
            }
            .navigationTitle("新增學習表")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        showingNameSheet = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("確定") {
                        saveStudyTable()
                    }
                    .disabled(tableName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private var currentStepDescription: String {
        switch currentStep {
        case .recognizing:
            return "正在識別文字..."
        case .translating:
            return "正在翻譯內容..."
        case .editing:
            return "編輯識別結果"
        case .saving:
            return "正在儲存..."
        }
    }
    
    private func startProcessing() {
        Task {
            // 步驟 1: OCR 識別
            currentStep = .recognizing
            recognizedItems = await visionManager.processImages(images)
            
            // 步驟 2: 翻譯
            currentStep = .translating
            let japaneseTexts = recognizedItems.map(\.text)
            let translations = await translationService.translateBatch(japaneseTexts)
            
            // 步驟 3: 準備編輯資料
            editableItems = recognizedItems.map { item in
                EditableItem(
                    japanese: item.text,
                    chinese: translations[item.text] ?? item.text
                )
            }
            
            DispatchQueue.main.async {
                self.currentStep = .editing
            }
        }
    }
    
    private func saveStudyTable() {
        currentStep = .saving
        showingNameSheet = false
        
        let selectedItems = editableItems.filter(\.isSelected)
        
        let table = StudyTable.create(
            title: tableName,
            type: tableType.rawValue,
            context: viewContext
        )
        
        for item in selectedItems {
            table.addItem(
                japanese: item.japanese,
                chinese: item.chinese,
                context: viewContext
            )
        }
        
        do {
            try viewContext.save()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.currentStep = .saving
            }
        } catch {
            print("儲存失敗：\(error.localizedDescription)")
        }
    }
}

struct EditableItemRowView: View {
    @Binding var item: ProcessingView.EditableItem
    let onToggleSelection: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggleSelection) {
                Image(systemName: item.isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isSelected ? .blue : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                TextField("日文", text: $item.japanese)
                    .font(.headline)
                
                TextField("中文", text: $item.chinese)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .opacity(item.isSelected ? 1.0 : 0.6)
    }
}

struct ProgressIndicatorView: View {
    let currentStep: ProcessingView.ProcessingStep
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(ProcessingView.ProcessingStep.allCases, id: \.self) { step in
                Circle()
                    .fill(step.rawValue <= currentStep.rawValue ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 12, height: 12)
            }
        }
        .padding()
    }
}

extension ProcessingView.ProcessingStep: CaseIterable {
    static var allCases: [ProcessingView.ProcessingStep] = [.recognizing, .translating, .editing, .saving]
}

extension ProcessingView.ProcessingStep {
    var rawValue: Int {
        switch self {
        case .recognizing: return 0
        case .translating: return 1
        case .editing: return 2
        case .saving: return 3
        }
    }
}