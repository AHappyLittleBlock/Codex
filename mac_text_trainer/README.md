# Text Trainer Mac App

This directory contains a SwiftUI application that lets you build a simple offline text classifier using Apple's Create ML framework. Enter a label and paste multiple lines of training text, generate examples from OpenAI or Gemini, train the model entirely on your Mac, and run predictions.

## Requirements
- macOS 13+
- Xcode 15 or later

## Building
Open this folder in Xcode as a Swift package:

1. `File` → `Open` and choose the `mac_text_trainer` directory.
2. Select the `TextTrainer` scheme and build/run the app.

The app uses a modern black & white design with three tabs:

1. **Train** – add or generate text examples, view them in a list, and train the model. Progress is shown with a bar while training runs.
2. **Run** – type text to see the predicted label along with a probability bar.
3. **Settings** – choose OpenAI or Gemini and enter your API key for generating training data.

When training finishes, `TextClassifier.mlmodel` is saved to your Documents folder.
