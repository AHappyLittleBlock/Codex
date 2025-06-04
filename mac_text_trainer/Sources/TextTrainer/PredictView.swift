import SwiftUI

struct PredictView: View {
    @EnvironmentObject var trainer: Trainer
    @State private var text: String = ""
    @State private var results: [(String, Double)] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TextEditor(text: $text)
                .frame(height: 80)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
            Button("Guess") {
                if let label = trainer.predict(text) {
                    results = [(label, 1.0)]
                }
            }
            .buttonStyle(.borderedProminent)
            ForEach(results, id: \.0) { item in
                HStack {
                    Text(item.0)
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
        }
        .padding()
    }
}

struct PredictView_Previews: PreviewProvider {
    static var previews: some View {
        PredictView().environmentObject(Trainer(settings: AppSettings()))
    }
}
