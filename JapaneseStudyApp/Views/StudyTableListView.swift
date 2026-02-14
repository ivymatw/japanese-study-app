import SwiftUI
import CoreData

struct StudyTableListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StudyTable.updatedAt, ascending: false)],
        animation: .default)
    private var studyTables: FetchedResults<StudyTable>
    
    @State private var showingAddSheet = false
    @State private var showingTestConfig = false
    @State private var selectedTable: StudyTable?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(studyTables) { table in
                    StudyTableRowView(table: table)
                        .onTapGesture {
                            selectedTable = table
                            showingTestConfig = true
                        }
                }
                .onDelete(perform: deleteTables)
            }
            .navigationTitle("學習表")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Label("新增", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddStudyTableView()
            }
            .sheet(isPresented: $showingTestConfig) {
                if let table = selectedTable {
                    TestConfigView(table: table)
                }
            }
        }
    }
    
    private func deleteTables(offsets: IndexSet) {
        withAnimation {
            offsets.map { studyTables[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                print("刪除失敗：\(error.localizedDescription)")
            }
        }
    }
}

struct StudyTableRowView: View {
    let table: StudyTable
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(table.title ?? "未命名表格")
                    .font(.headline)
                
                Spacer()
                
                Text(table.typeDisplayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(4)
            }
            
            HStack {
                Text("\(table.itemsArray.count) 個項目")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let updatedAt = table.updatedAt {
                    Text(updatedAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 2)
    }
}

struct StudyTableListView_Previews: PreviewProvider {
    static var previews: some View {
        StudyTableListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}