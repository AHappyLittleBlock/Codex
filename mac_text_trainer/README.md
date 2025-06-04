# Text Trainer Mac App

This directory contains a minimal SwiftUI application that lets you build a simple offline text classifier using Apple's Create ML framework. You can enter text examples with labels, train a model on your Mac, and run predictions.

## Requirements
- macOS 11+
- Xcode 13 or later

## Building
Open this folder in Xcode as a Swift package:

1. `File` → `Open` and choose the `mac_text_trainer` directory.
2. Select the `TextTrainer` scheme and build/run the app.

The app will allow you to add training examples (one per line), train the model, and test predictions. When training finishes, `TextClassifier.mlmodel` is saved to your Documents folder.
