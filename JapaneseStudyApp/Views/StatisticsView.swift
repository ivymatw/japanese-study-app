import SwiftUI

struct StatisticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StudyTable.updatedAt, ascending: false)],
        animation: .default)
    private var studyTables: FetchedResults<StudyTable>
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // 總覽統計
                    OverviewStatsView(tables: Array(studyTables))
                    
                    // 學習進度
                    ProgressStatsView(tables: Array(studyTables))
                    
                    // 表格統計
                    TablesStatsView(tables: Array(studyTables))
                }
                .padding()
            }
            .navigationTitle("統計")
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct OverviewStatsView: View {
    let tables: [StudyTable]
    
    var totalTables: Int { tables.count }
    var totalItems: Int { tables.reduce(0) { $0 + $1.itemCount } }
    var vocabularyTables: Int { tables.filter { $0.type == "vocabulary" }.count }
    var grammarTables: Int { tables.filter { $0.type == "grammar" }.count }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("學習概覽")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                StatCardView(
                    title: "學習表",
                    value: "\(totalTables)",
                    subtitle: "個表格",
                    color: .blue,
                    icon: "book.fill"
                )
                
                StatCardView(
                    title: "學習項目",
                    value: "\(totalItems)",
                    subtitle: "個項目",
                    color: .green,
                    icon: "text.book.closed.fill"
                )
                
                StatCardView(
                    title: "單字表",
                    value: "\(vocabularyTables)",
                    subtitle: "個表格",
                    color: .orange,
                    icon: "character.book.closed.fill"
                )
                
                StatCardView(
                    title: "語法表",
                    value: "\(grammarTables)",
                    subtitle: "個表格",
                    color: .purple,
                    icon: "text.alignleft"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct ProgressStatsView: View {
    let tables: [StudyTable]
    
    private var recentlyUpdatedTables: [StudyTable] {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return tables.filter { table in
            guard let updatedAt = table.updatedAt else { return false }
            return updatedAt >= oneWeekAgo
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("本週進度")
                .font(.headline)
                .padding(.horizontal)
            
            if recentlyUpdatedTables.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("本週尚未進行學習")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("開始學習來追蹤你的進度吧！")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 100)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 12) {
                    StatCardView(
                        title: "活躍表格",
                        value: "\(recentlyUpdatedTables.count)",
                        subtitle: "本週使用",
                        color: .mint,
                        icon: "flame.fill"
                    )
                    
                    StatCardView(
                        title: "新增項目",
                        value: "\(recentlyAddedItemsCount)",
                        subtitle: "本週新增",
                        color: .cyan,
                        icon: "plus.circle.fill"
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var recentlyAddedItemsCount: Int {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        var count = 0
        
        for table in tables {
            for item in table.itemsArray {
                if let createdAt = item.createdAt, createdAt >= oneWeekAgo {
                    count += 1
                }
            }
        }
        
        return count
    }
}

struct TablesStatsView: View {
    let tables: [StudyTable]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("表格詳細")
                .font(.headline)
                .padding(.horizontal)
            
            if tables.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("尚未建立學習表")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 100)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(tables, id: \.id) { table in
                        TableStatRowView(table: table)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct TableStatRowView: View {
    let table: StudyTable
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(table.title ?? "未命名表格")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(table.typeDisplayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(table.itemCount)")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Text("項目")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct StatCardView: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                
                HStack {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                HStack {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}