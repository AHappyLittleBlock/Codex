# Text Recognition Example

This folder contains an example of training a simple character recognition model
using TensorFlow. It uses the EMNIST dataset and converts the trained model to
Core ML so that it can be used in a Swift macOS or iOS app.

## Requirements

- Python 3
- `tensorflow` and `tensorflow_datasets`
- `coremltools`

## Training

Run the training script to download the dataset, train the CNN, and export the
Core ML model:

```bash
python train_text_recognition.py
```

After training finishes, you will get `TextRecognition.mlmodel` that you can add
to your Xcode project.

The EMNIST dataset labels start at 1, so the preprocessing step subtracts 1 so
that the model predicts classes 0–25.

## Using in Swift

Add the generated `TextRecognition.mlmodel` to your Xcode project and use it
with `CoreML` and `Vision`:

```swift
import CoreML
import Vision

let model = try VNCoreMLModel(for: TextRecognition().model)

let request = VNCoreMLRequest(model: model) { request, error in
    if let results = request.results as? [VNClassificationObservation] {
        for result in results {
            print("\(result.identifier): \(result.confidence)")
        }
    }
}
```

You can feed images of letters to the request to obtain the predicted character.
