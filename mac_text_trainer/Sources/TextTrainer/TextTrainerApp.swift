import SwiftUI

@main
struct TextTrainerApp: App {
    @StateObject private var settings = AppSettings()
    @StateObject private var trainer: Trainer

    init() {
        let set = AppSettings()
        _settings = StateObject(wrappedValue: set)
        _trainer = StateObject(wrappedValue: Trainer(settings: set))
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(trainer)
                .environmentObject(settings)
        }
    }
}
