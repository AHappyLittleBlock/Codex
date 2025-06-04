import Foundation
import CreateML
import NaturalLanguage
import SwiftUI

struct TextLabel: Identifiable, Codable {
    var id = UUID()
    var name: String
    var examples: [String] = []
}

struct TestCase: Identifiable, Codable {
    var id = UUID()
    var text: String
}

class Trainer: ObservableObject {
    @Published var labels: [TextLabel] = []
    @Published var testCases: [TestCase] = []
    @Published var status: String = "Idle"
    @Published var trainingProgress: Double = 0
    @Published var trainingFinished: Bool = false

    private var classifier: NLModel?
    private let settings: AppSettings

    init(settings: AppSettings) {
        self.settings = settings
        load()
    }

    // MARK: - Label Management

    func addLabel() {
        labels.append(TextLabel(name: ""))
        save()
    }

    func removeLabels(at offsets: IndexSet) {
        labels.remove(atOffsets: offsets)
        save()
    }

    func addExamples(_ textBlock: String, to label: TextLabel) {
        guard let index = labels.firstIndex(where: { $0.id == label.id }) else { return }
        let lines = textBlock
            .split(whereSeparator: { $0.isNewline })
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        labels[index].examples.append(contentsOf: lines)
        save()
    }

    func addExample(_ text: String, to label: TextLabel) {
        addExamples(text, to: label)
    }

    func train() {
        let allExamples = labels.flatMap { label in
            label.examples.map { (text: $0, label: label.name) }
        }
        guard !allExamples.isEmpty else { return }
        guard let data = try? MLDataTable(dictionary: [
            "text": allExamples.map { $0.text },
            "label": allExamples.map { $0.label }
        ]) else {
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
                    self.trainingFinished = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.status = "Training failed: \(error.localizedDescription)"
                }
            }
        }
    }

    func predictProbabilities(_ text: String) -> [(String, Double)]? {
        guard let classifier else { return nil }
        let hyps = classifier.predictedLabelHypotheses(for: text, maximumCount: labels.count)
        return hyps.sorted { $0.value > $1.value }
    }

    func addTestCase(_ text: String) {
        let tc = TestCase(text: text)
        testCases.append(tc)
        save()
    }

    // MARK: - Persistence

    private var storeURL: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("labels.json")
    }

    private var testsURL: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("tests.json")
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(labels)
            try FileManager.default.createDirectory(at: storeURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: storeURL)
            let tdata = try JSONEncoder().encode(testCases)
            try tdata.write(to: testsURL)
        } catch {
            print("Failed to save data: \(error)")
        }
    }

    private func load() {
        if let data = try? Data(contentsOf: storeURL),
           let decoded = try? JSONDecoder().decode([TextLabel].self, from: data) {
            labels = decoded
        }
        if let tdata = try? Data(contentsOf: testsURL),
           let decoded = try? JSONDecoder().decode([TestCase].self, from: tdata) {
            testCases = decoded
        }
    }

    // MARK: - Data Generation

    func generateData(prompt: String, for label: TextLabel, completion: @escaping () -> Void) {
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
                let block = lines.joined(separator: "\n")
                self.addExamples(block, to: label)
                self.status = "Idle"
            }
        }
        task.resume()
    }
}
