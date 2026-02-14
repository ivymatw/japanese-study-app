import SwiftUI

struct AddStudyTableView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var tableName = ""
    @State private var selectedType = TableType.vocabulary
    @State private var items: [StudyItemInput] = []
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    enum TableType: String, CaseIterable {
        case vocabulary = "vocabulary"
        case grammar = "grammar"
        
        var displayName: String {
            switch self {
            case .vocabulary: return "單字"
            case .grammar: return "語法"
            }
        }
        
        var placeholder: (japanese: String, chinese: String) {
            switch self {
            case .vocabulary:
                return ("例：こんにちは", "例：你好")
            case .grammar:
                return ("例：私は学生です", "例：我是學生")
            }
        }
    }
    
    struct StudyItemInput: Identifiable {
        let id = UUID()
        var japanese = ""
        var chinese = ""
        
        var isValid: Bool {
            return !japanese.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                   !chinese.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("基本資訊") {
                    TextField("表格名稱", text: $tableName)
                    
                    Picker("類型", selection: $selectedType) {
                        ForEach(TableType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("學習內容") {
                    ForEach(items.indices, id: \.self) { index in
                        VStack(spacing: 8) {
                            TextField(selectedType.placeholder.japanese, text: $items[index].japanese)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField(selectedType.placeholder.chinese, text: $items[index].chinese)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteItems)
                    
                    Button("新增項目") {
                        items.append(StudyItemInput())
                    }
                    .foregroundColor(.blue)
                }
                
                if !items.isEmpty {
                    Section {
                        HStack {
                            Text("總計項目")
                            Spacer()
                            Text("\(validItemsCount)")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("有效項目")
                            Spacer()
                            Text("\(validItemsCount)")
                                .foregroundColor(validItemsCount > 0 ? .green : .red)
                        }
                    }
                }
            }
            .navigationTitle("新增學習表")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("儲存") {
                        saveStudyTable()
                    }
                    .disabled(!isFormValid)
                }
            }
            .onAppear {
                if items.isEmpty {
                    items = [StudyItemInput(), StudyItemInput(), StudyItemInput()]
                }
            }
            .alert("提示", isPresented: $showingAlert) {
                Button("確定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var validItemsCount: Int {
        return items.filter(\.isValid).count
    }
    
    private var isFormValid: Bool {
        return !tableName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               validItemsCount > 0
    }
    
    private func deleteItems(offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    private func saveStudyTable() {
        let trimmedName = tableName.trimmingCharacters(in: .whitespacesAndNewlines)
        let validItems = items.filter(\.isValid)
        
        guard !trimmedName.isEmpty, !validItems.isEmpty else {
            alertMessage = "請確認表格名稱和學習項目都已填寫完整"
            showingAlert = true
            return
        }
        
        let table = StudyTable.create(
            title: trimmedName,
            type: selectedType.rawValue,
            context: viewContext
        )
        
        for item in validItems {
            table.addItem(
                japanese: item.japanese.trimmingCharacters(in: .whitespacesAndNewlines),
                chinese: item.chinese.trimmingCharacters(in: .whitespacesAndNewlines),
                context: viewContext
            )
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            alertMessage = "儲存失敗：\(error.localizedDescription)"
            showingAlert = true
        }
    }
}

struct AddStudyTableView_Previews: PreviewProvider {
    static var previews: some View {
        AddStudyTableView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}