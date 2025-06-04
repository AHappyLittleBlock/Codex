import Foundation
import CreateML
import NaturalLanguage
import SwiftUI

struct TrainingExample: Identifiable, Codable {
    let id = UUID()
    var text: String
    var label: String
}

class Trainer: ObservableObject {
    @Published var examples: [TrainingExample] = []
    @Published var status: String = "Idle"
    @Published var trainingProgress: Double = 0
    private var classifier: NLModel?
    private let settings: AppSettings

    init(settings: AppSettings) {
        self.settings = settings
        loadExamples()
    }

    func addExample(text: String, label: String) {
        let example = TrainingExample(text: text, label: label)
        examples.append(example)
        saveExamples()
    }

    func addExamples(textBlock: String, label: String) {
        let lines = textBlock
            .split(whereSeparator: { $0.isNewline })
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        for line in lines {
            addExample(text: line, label: label)
        }
    }

    func removeExamples(at offsets: IndexSet) {
        examples.remove(atOffsets: offsets)
        saveExamples()
    }

    func train() {
        let rows = examples.map { ["text": $0.text, "label": $0.label] }
        guard let data = try? MLDataTable(dictionary: ["text": rows.map { $0["text"]! },
                                             "label": rows.map { $0["label"]! }]) else {
            status = "Failed to build table"
            return
        }
        status = "Training..."
        trainingProgress = 0
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let classifier = try MLTextClassifier(trainingData: data, textColumn: "text", labelColumn: "label")
                DispatchQueue.main.async { self.trainingProgress = 0.5 }
                let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("TextClassifier.mlmodel")
                try classifier.write(to: fileURL)
                let nl = try NLModel(mlModel: classifier.model)
                DispatchQueue.main.async {
                    self.classifier = nl
                    self.status = "Training complete. Model saved to \(fileURL.path)"
                    self.trainingProgress = 1
                }
            } catch {
                DispatchQueue.main.async {
                    self.status = "Training failed: \(error.localizedDescription)"
                }
            }
        }
    }

    func predict(_ text: String) -> String? {
        classifier?.predictedLabel(for: text)
    }

    // MARK: - Persistence

    private var storeURL: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("examples.json")
    }

    private func saveExamples() {
        do {
            let data = try JSONEncoder().encode(examples)
            try FileManager.default.createDirectory(at: storeURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: storeURL)
        } catch {
            print("Failed to save examples: \(error)")
        }
    }

    private func loadExamples() {
        guard let data = try? Data(contentsOf: storeURL) else { return }
        if let decoded = try? JSONDecoder().decode([TrainingExample].self, from: data) {
            examples = decoded
        }
    }

    // MARK: - Data Generation

    func generateData(prompt: String, label: String, completion: @escaping () -> Void) {
        guard !settings.apiKey.isEmpty else { return }
        status = "Generating..."
        let provider = settings.apiProvider
        let session = URLSession.shared
        var request: URLRequest
        if provider == "openai" {
            request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
            request.httpMethod = "POST"
            request.addValue("Bearer \(settings.apiKey)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let body: [String: Any] = [
                "model": "gpt-3.5-turbo",
                "messages": [["role": "user", "content": prompt]]
            ]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        } else {
            request = URLRequest(url: URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=\(settings.apiKey)")!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let body: [String: Any] = ["contents": [["parts": [["text": prompt]]]]]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        let task = session.dataTask(with: request) { data, _, _ in
            defer { DispatchQueue.main.async { completion() } }
            guard
                let data = data,
                let raw = String(data: data, encoding: .utf8)
            else { return }
            let lines = raw.split(whereSeparator: Character.isNewline).map { String($0) }.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            DispatchQueue.main.async {
                for line in lines {
                    self.addExample(text: line, label: label)
                }
                self.status = "Idle"
            }
        }
        task.resume()
    }
}
