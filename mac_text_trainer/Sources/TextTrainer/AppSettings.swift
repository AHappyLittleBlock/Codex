import SwiftUI

class AppSettings: ObservableObject {
    @AppStorage("apiProvider") var apiProvider: String = "openai"
    @AppStorage("apiKey") var apiKey: String = ""
}
