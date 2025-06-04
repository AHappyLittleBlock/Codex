import SwiftUI

struct TrainView: View {
    @EnvironmentObject var trainer: Trainer
    @State private var inputText: String = ""
    @State private var inputLabel: String = ""
    @State private var showPromptSheet = false
    @State private var prompt: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    TextField("Label", text: $inputLabel)
                    Spacer()
                    Menu("Add Data") {
                        Button("Add Text") { addExamples() }
                        Button("Paste Spaced Text") { addExamples() }
                        Button("Generate Data") { showPromptSheet = true }
                    }
                }
                TextEditor(text: $inputText)
                    .frame(height: 100)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                if trainer.trainingProgress > 0 && trainer.trainingProgress < 1 {
                    ProgressView(value: trainer.trainingProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                }
                Button(action: { trainer.train() }) {
                    Text("Train Model")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                Text(trainer.status)
                    .foregroundColor(.secondary)
                List {
                    ForEach(trainer.examples) { ex in
                        HStack {
                            Text(ex.label).bold()
                            Text(ex.text)
                        }
                    }
                    .onDelete(perform: trainer.removeExamples)
                }
                .frame(height: 200)
            }
            .padding()
        }
        .sheet(isPresented: $showPromptSheet) {
            VStack(spacing: 12) {
                TextField("Prompt", text: $prompt)
                Button("Generate") {
                    trainer.generateData(prompt: prompt, label: inputLabel) {
                        showPromptSheet = false
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .frame(width: 300)
        }
    }

    private func addExamples() {
        guard !inputText.isEmpty, !inputLabel.isEmpty else { return }
        trainer.addExamples(textBlock: inputText, label: inputLabel)
        inputText = ""
    }
}

struct TrainView_Previews: PreviewProvider {
    static var previews: some View {
        TrainView()
            .environmentObject(Trainer(settings: AppSettings()))
    }
}
