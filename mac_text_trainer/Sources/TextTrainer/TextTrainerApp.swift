import SwiftUI
import CreateML

@main
struct TextTrainerApp: App {
    @StateObject private var trainer = Trainer()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(trainer)
        }
    }
}
