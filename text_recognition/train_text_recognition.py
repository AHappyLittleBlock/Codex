import tensorflow as tf
import tensorflow_datasets as tfds
from tensorflow.keras import layers, models
import coremltools as ct

# Load EMNIST dataset (letters)
(ds_train, ds_test), ds_info = tfds.load(
    'emnist/letters',
    split=['train', 'test'],
    shuffle_files=True,
    as_supervised=True,
    with_info=True
)

# Preprocess data
num_classes = ds_info.features['label'].num_classes

def preprocess(image, label):
    image = tf.cast(image, tf.float32) / 255.0
    image = tf.reshape(image, (28, 28, 1))
    label = tf.cast(label, tf.int32) - 1  # labels are 1–26
    return image, label

ds_train = ds_train.map(preprocess).batch(128).prefetch(tf.data.AUTOTUNE)
ds_test = ds_test.map(preprocess).batch(128).prefetch(tf.data.AUTOTUNE)

# Build a simple CNN model
model = models.Sequential([
    layers.Conv2D(32, (3,3), activation='relu', input_shape=(28,28,1)),
    layers.MaxPooling2D((2,2)),
    layers.Conv2D(64, (3,3), activation='relu'),
    layers.MaxPooling2D((2,2)),
    layers.Flatten(),
    layers.Dense(128, activation='relu'),
    layers.Dense(num_classes, activation='softmax')
])

model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

model.fit(ds_train, epochs=5, validation_data=ds_test)

# Save Keras model
model.save('TextRecognition.h5')

# Convert to Core ML model for use in Swift
mlmodel = ct.convert(model)
mlmodel.save('TextRecognition.mlmodel')
