import SwiftUI

struct TestView: View {
    @EnvironmentObject var trainer: Trainer
    @State private var text: String = ""
    @State private var results: [(String, Double)] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextEditor(text: $text)
                .frame(height: 80)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
            HStack {
                Button("Guess") {
                    if let r = trainer.predictProbabilities(text) {
                        results = r
                    }
                }
                .buttonStyle(.borderedProminent)
                Button("Save") { trainer.addTestCase(text) }
            }
            ForEach(results, id: \.0) { item in
                let maxVal = results.first?.1 ?? 0
                HStack {
                    Text(item.0)
                        .fontWeight(item.1 == maxVal ? .bold : .regular)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Rectangle().fill(Color.gray.opacity(0.2))
                            Rectangle().fill(Color.accentColor).frame(width: geo.size.width * item.1)
                        }
                        .cornerRadius(4)
                    }
                    .frame(height: 8)
                    Text(String(format: "%.0f%%", item.1 * 100))
                }
            }
            Spacer()
            Divider()
            if !trainer.testCases.isEmpty {
                Text("Saved Spaces:").bold()
                ForEach(trainer.testCases) { tc in
                    Button(tc.text) { text = tc.text }
                        .buttonStyle(.plain)
                }
            }
        }
        .padding()
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView().environmentObject(Trainer(settings: AppSettings()))
    }
}
