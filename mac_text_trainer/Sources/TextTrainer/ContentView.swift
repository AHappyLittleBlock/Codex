import SwiftUI

struct ContentView: View {
    @EnvironmentObject var trainer: Trainer
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        TabView {
            TrainView()
                .tabItem { Label("Train", systemImage: "hammer") }
            PredictView()
                .tabItem { Label("Run", systemImage: "bolt") }
            SettingsView(settings: settings)
                .tabItem { Label("Settings", systemImage: "gear") }
        }
        .frame(minWidth: 500, minHeight: 600)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppSettings())
            .environmentObject(Trainer(settings: AppSettings()))
    }
}
