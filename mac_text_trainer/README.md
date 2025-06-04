# Text Trainer Mac App

This directory contains a SwiftUI application that lets you build a simple offline text classifier using Apple's Create ML framework. Enter a label and paste multiple lines of training text, train the model entirely on your Mac, and run predictions.

## Requirements
- macOS 13+
- Xcode 15 or later

## Building
Open this folder in Xcode as a Swift package:

1. `File` → `Open` and choose the `mac_text_trainer` directory.
2. Select the `TextTrainer` scheme and build/run the app.

The app allows you to add many examples at once, view and delete them, train the model, and test predictions. When training finishes, `TextClassifier.mlmodel` is saved to your Documents folder.
