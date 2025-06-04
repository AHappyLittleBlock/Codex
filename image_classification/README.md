# Image Classification Example

This folder contains a minimal example of training an image classifier using
TensorFlow **completely offline**. Place your images in a directory structure
like:

```
image_classification/data/train/<class name>/*.jpg
```

The script will automatically split the images into training and validation
sets. After training, it converts the model to Core ML so it can be used in a
Swift app on macOS or iOS.

## Requirements

- Python 3
- `tensorflow`
- `coremltools`

## Training

Run the training script from this directory:

```bash
python train_image_classifier.py
```

This will produce `ImageClassifier.mlmodel` that you can add to your Xcode
project.

## Using in Swift

Add the generated model to your project and use it with `CoreML` and `Vision`:

```swift
import CoreML
import Vision

let model = try VNCoreMLModel(for: ImageClassifier().model)
```

Create a `VNCoreMLRequest` and pass `CGImage` objects to get predictions.
