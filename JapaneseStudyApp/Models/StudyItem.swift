import Foundation
import CoreData

extension StudyItem {
    
    var displayJapanese: String {
        return japanese ?? ""
    }
    
    var displayChinese: String {
        return chinese ?? ""
    }
    
    var hasContent: Bool {
        return !displayJapanese.isEmpty && !displayChinese.isEmpty
    }
    
    static func create(japanese: String, chinese: String, table: StudyTable, context: NSManagedObjectContext) -> StudyItem {
        let item = StudyItem(context: context)
        item.id = UUID()
        item.japanese = japanese
        item.chinese = chinese
        item.createdAt = Date()
        item.table = table
        return item
    }
    
    func updateContent(japanese: String? = nil, chinese: String? = nil) {
        if let japanese = japanese {
            self.japanese = japanese
        }
        if let chinese = chinese {
            self.chinese = chinese
        }
        self.table?.updatedAt = Date()
    }
    
    static var fetchRequest: NSFetchRequest<StudyItem> {
        let request = NSFetchRequest<StudyItem>(entityName: "StudyItem")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \StudyItem.createdAt, ascending: true)]
        return request
    }
}