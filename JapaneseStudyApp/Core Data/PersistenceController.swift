import CoreData
import Foundation

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // 建立預覽數據
        let sampleTable = StudyTable(context: viewContext)
        sampleTable.id = UUID()
        sampleTable.title = "基礎日語單字"
        sampleTable.type = "vocabulary"
        sampleTable.createdAt = Date()
        sampleTable.updatedAt = Date()
        
        let item1 = StudyItem(context: viewContext)
        item1.id = UUID()
        item1.japanese = "こんにちは"
        item1.chinese = "你好"
        item1.createdAt = Date()
        item1.table = sampleTable
        
        let item2 = StudyItem(context: viewContext)
        item2.id = UUID()
        item2.japanese = "ありがとう"
        item2.chinese = "謝謝"
        item2.createdAt = Date()
        item2.table = sampleTable
        
        let item3 = StudyItem(context: viewContext)
        item3.id = UUID()
        item3.japanese = "さようなら"
        item3.chinese = "再見"
        item3.createdAt = Date()
        item3.table = sampleTable
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DataModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, 
                                                              forKey: NSPersistentHistoryTrackingKey)
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, 
                                                              forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("儲存失敗：\(nsError.localizedDescription)")
            }
        }
    }
}