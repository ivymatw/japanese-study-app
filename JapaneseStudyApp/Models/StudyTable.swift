import Foundation
import CoreData

extension StudyTable {
    
    var itemsArray: [StudyItem] {
        let set = items as? Set<StudyItem> ?? []
        return set.sorted { ($0.createdAt ?? Date()) < ($1.createdAt ?? Date()) }
    }
    
    var typeDisplayName: String {
        switch type {
        case "vocabulary":
            return "單字"
        case "grammar":
            return "語法"
        default:
            return "未知"
        }
    }
    
    var itemCount: Int {
        return itemsArray.count
    }
    
    static func create(title: String, type: String, context: NSManagedObjectContext) -> StudyTable {
        let table = StudyTable(context: context)
        table.id = UUID()
        table.title = title
        table.type = type
        table.createdAt = Date()
        table.updatedAt = Date()
        return table
    }
    
    func addItem(japanese: String, chinese: String, context: NSManagedObjectContext) {
        let item = StudyItem(context: context)
        item.id = UUID()
        item.japanese = japanese
        item.chinese = chinese
        item.createdAt = Date()
        item.table = self
        
        self.updatedAt = Date()
    }
    
    func removeItem(_ item: StudyItem, context: NSManagedObjectContext) {
        context.delete(item)
        self.updatedAt = Date()
    }
    
    static var fetchRequest: NSFetchRequest<StudyTable> {
        let request = NSFetchRequest<StudyTable>(entityName: "StudyTable")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \StudyTable.updatedAt, ascending: false)]
        return request
    }
}