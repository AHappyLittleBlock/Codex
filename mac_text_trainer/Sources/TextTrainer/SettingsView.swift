import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: AppSettings

    var body: some View {
        Form {
            Picker("Provider", selection: $settings.apiProvider) {
                Text("OpenAI").tag("openai")
                Text("Gemini").tag("gemini")
            }
            TextField("API Key", text: $settings.apiKey)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(settings: AppSettings())
    }
}
