import SwiftUI

struct ContentView: View {
    @EnvironmentObject var trainer: Trainer
    @State private var inputText: String = ""
    @State private var inputLabel: String = ""
    @State private var predictText: String = ""
    @State private var prediction: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("Add Training Example")
                .font(.headline)
            TextField("Text", text: $inputText, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Label", text: $inputLabel)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Add Example") {
                guard !inputText.isEmpty, !inputLabel.isEmpty else { return }
                trainer.addExample(text: inputText, label: inputLabel)
                inputText = ""
                inputLabel = ""
            }
            Divider()
            Button("Train Model") {
                trainer.train()
            }
            Text(trainer.status)
                .foregroundColor(.secondary)
                .padding(.bottom)
            Divider()
            Text("Run Prediction")
                .font(.headline)
            TextField("Text", text: $predictText, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Predict") {
                prediction = trainer.predict(predictText) ?? ""
            }
            Text("Prediction: \(prediction)")
            Spacer()
        }
        .padding()
        .frame(width: 400, height: 500)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Trainer())
    }
}
