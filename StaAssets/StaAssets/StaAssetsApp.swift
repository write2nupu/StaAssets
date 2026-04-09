import SwiftUI
import CoreData

@main
struct StaAssetsApp: App {
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext,
                              persistenceController.container.viewContext)
        }
    }
}
