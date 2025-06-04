# Text Trainer Mac App

This directory contains a SwiftUI application that lets you build a simple offline text classifier using Apple's Create ML framework. Create labeled sections, paste or generate training text, train the model entirely on your Mac, and test predictions.

## Requirements
- macOS 13+
- Xcode 15 or later

## Building
Open this folder in Xcode as a Swift package:

1. `File` → `Open` and choose the `mac_text_trainer` directory.
2. Select the `TextTrainer` scheme and build/run the app.

The window is split into two tabs:

1. **Train** – manage labeled sections. Each section shows one sample line of text and a menu to add, paste, or generate more data. Press **Train** to animate each section while a model is created.
2. **Test** – enter text to classify and see a probability chart for each label. Test cases can be saved and loaded from the sidebar.

Use the gear toolbar button to open **Settings** where you pick OpenAI or Gemini and provide an API key for data generation.

When training finishes, `TextClassifier.mlmodel` is saved to your Documents folder.
