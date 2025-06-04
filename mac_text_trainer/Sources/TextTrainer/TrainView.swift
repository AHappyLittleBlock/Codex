import SwiftUI

struct TrainView: View {
    @EnvironmentObject var trainer: Trainer
    @Binding var selectedTab: Int
    @State private var showPromptFor: TextLabel?
    @State private var showTextSheetFor: TextLabel?
    @State private var textBlock: String = ""
    @State private var prompt: String = ""
    @State private var isTraining = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ForEach($trainer.labels) { $label in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            TextField("Label", text: $label.name)
                            Spacer()
                            Menu {
                                Button("Add Text") { showTextSheetFor = label; textBlock = "" }
                                Button("Paste Spaced Text") { showTextSheetFor = label; textBlock = "" }
                                Button(action: { showPromptFor = label; prompt = "" }) {
                                    Text("Generate Data")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                            }
                        }
                        if let ex = label.examples.first {
                            Text(isTraining ? scramble(ex) : ex)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        if isTraining {
                            ProgressView(value: trainer.trainingProgress)
                        }
                        Divider()
                    }
                }
                Button("+ Section") { trainer.addLabel() }
                    .buttonStyle(.bordered)
                Button("Train") {
                    isTraining = true
                    trainer.trainingFinished = false
                    trainer.train()
                }
                .buttonStyle(.borderedProminent)
                Text(trainer.status).foregroundColor(.secondary)
            }
            .padding()
        }
        .onReceive(trainer.$trainingFinished) { done in
            if done {
                isTraining = false
                selectedTab = 1
            }
        }
        .sheet(item: $showTextSheetFor) { label in
            VStack {
                TextEditor(text: $textBlock).frame(height: 120)
                Button("Save") {
                    trainer.addExamples(textBlock, to: label)
                    showTextSheetFor = nil
                }.buttonStyle(.borderedProminent)
            }
            .padding()
            .frame(width: 300)
        }
        .sheet(item: $showPromptFor) { label in
            VStack {
                TextField("Prompt", text: $prompt)
                Button("Generate") {
                    trainer.generateData(prompt: prompt, for: label) {
                        showPromptFor = nil
                    }
                }.buttonStyle(.borderedProminent)
            }
            .padding()
            .frame(width: 300)
        }
    }

    private func scramble(_ text: String) -> String {
        String(text.map { _ in "abcdefghijklmnopqrstuvwxyz".randomElement()! })
    }
}

struct TrainView_Previews: PreviewProvider {
    static var previews: some View {
        TrainView(selectedTab: .constant(0))
            .environmentObject(Trainer(settings: AppSettings()))
    }
}
