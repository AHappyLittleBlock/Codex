import SwiftUI

struct ContentView: View {
    @EnvironmentObject var trainer: Trainer
    @State private var inputText: String = ""
    @State private var inputLabel: String = ""
    @State private var predictText: String = ""
    @State private var prediction: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Form {
                Section(header: Text("New Examples")) {
                    TextField("Label", text: $inputLabel)
                    TextEditor(text: $inputText)
                        .frame(height: 80)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.3)))
                    Text("Enter multiple lines of text. Each line will be added as a training example.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button("Add Examples") {
                        guard !inputText.isEmpty, !inputLabel.isEmpty else { return }
                        trainer.addExamples(textBlock: inputText, label: inputLabel)
                        inputText = ""
                        inputLabel = ""
                    }
                }

                Section(header: Text("Training Data")) {
                    List {
                        ForEach(trainer.examples) { example in
                            HStack {
                                Text(example.label).bold()
                                Text(example.text)
                            }
                        }
                        .onDelete(perform: trainer.removeExamples)
                    }
                    .frame(maxHeight: 150)
                }

                Section(header: Text("Model")) {
                    Button("Train Model") {
                        trainer.train()
                    }
                    Text(trainer.status)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("Predict")) {
                    TextEditor(text: $predictText)
                        .frame(height: 60)
                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.3)))
                    Button("Predict") {
                        prediction = trainer.predict(predictText) ?? ""
                    }
                    Text("Prediction: \(prediction)")
                }
            }
        }
        .padding()
        .frame(minWidth: 500, minHeight: 600)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Trainer())
    }
}
