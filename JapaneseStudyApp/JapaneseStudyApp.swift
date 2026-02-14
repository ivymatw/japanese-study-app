import SwiftUI
import CoreData

@main
struct JapaneseStudyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(StudySessionManager())
                .environmentObject(VisionManager())
                .environmentObject(TranslationService())
        }
    }
}