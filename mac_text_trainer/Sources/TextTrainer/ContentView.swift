import SwiftUI

struct ContentView: View {
    @EnvironmentObject var trainer: Trainer
    @EnvironmentObject var settings: AppSettings

    var body: some View {
        TabView(selection: $selectedTab) {
            TrainView(selectedTab: $selectedTab)
                .tabItem { Label("Train", systemImage: "hammer") }
                .tag(0)
            TestView()
                .tabItem { Label("Test", systemImage: "bolt") }
                .tag(1)
        }
        .frame(minWidth: 500, minHeight: 600)
        .toolbar {
            Button(action: { showSettings.toggle() }) {
                Image(systemName: "gearshape")
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(settings: settings)
                .padding()
                .frame(width: 300)
        }
    }

    @State private var selectedTab: Int = 0
    @State private var showSettings = false
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppSettings())
            .environmentObject(Trainer(settings: AppSettings()))
    }
}
