import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            StudyTableListView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("學習表")
                }
            
            CameraView()
                .tabItem {
                    Image(systemName: "camera.fill")
                    Text("拍照")
                }
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("統計")
                }
        }
        .accentColor(.blue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}