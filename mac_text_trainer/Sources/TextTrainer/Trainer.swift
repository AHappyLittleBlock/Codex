import Foundation
import CreateML
import NaturalLanguage

struct TrainingExample: Identifiable {
    let id = UUID()
    var text: String
    var label: String
}

class Trainer: ObservableObject {
    @Published var examples: [TrainingExample] = []
    @Published var status: String = "Idle"
    private var classifier: NLModel?

    func addExample(text: String, label: String) {
        let example = TrainingExample(text: text, label: label)
        examples.append(example)
    }

    func train() {
        let rows = examples.map { ["text": $0.text, "label": $0.label] }
        guard let data = try? MLDataTable(dictionary: ["text": rows.map { $0["text"]! },
                                             "label": rows.map { $0["label"]! }]) else {
            status = "Failed to build table"
            return
        }
        status = "Training..."
        do {
            let classifier = try MLTextClassifier(trainingData: data, textColumn: "text", labelColumn: "label")
            let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("TextClassifier.mlmodel")
            try classifier.write(to: fileURL)
            self.classifier = try NLModel(mlModel: classifier.model)
            status = "Training complete. Model saved to \(fileURL.path)"
        } catch {
            status = "Training failed: \(error.localizedDescription)"
        }
    }

    func predict(_ text: String) -> String? {
        classifier?.predictedLabel(for: text)
    }
}
