import numpy as np
from PIL import Image
from flask import current_app

CLASS_NAMES = [
    "Early_Bacterial_Spot",
    "Early_Cercospora",
    "Early_Leaf_Curl",
    "Early_Yellowing",
    "Healthy",
    "Late_Bacterial_Spot",
    "Late_Cercospora",
    "Late_Leaf_Curl",
    "Late_Yellowing",
]

_CLASS_INFO = {
    "Healthy": (None, None),
    "Early_Leaf_Curl": ("Leaf Curl", "early"),
    "Late_Leaf_Curl": ("Leaf Curl", "late"),
    "Early_Cercospora": ("Cercospora Spot", "early"),
    "Late_Cercospora": ("Cercospora Spot", "late"),
    "Early_Yellowing": ("Yellowing", "early"),
    "Late_Yellowing": ("Yellowing", "late"),
    "Early_Bacterial_Spot": ("Bacterial Spot", "early"),
    "Late_Bacterial_Spot": ("Bacterial Spot", "late"),
}

_model = None


def _load_model():
    global _model
    if _model is None:
        import tensorflow as tf

        _model = tf.keras.models.load_model(current_app.config["MODEL_PATH"])
    return _model


def preprocess_image(filepath, target_size=(224, 224)):
    img = Image.open(filepath).convert("RGB").resize(target_size)
    arr = np.asarray(img, dtype=np.float32) / 255.0
    return np.expand_dims(arr, axis=0)


def predict(filepath):
    model = _load_model()
    batch = preprocess_image(filepath)

    probs = model.predict(batch, verbose=0)[0]
    idx = int(np.argmax(probs))
    class_name = CLASS_NAMES[idx]
    confidence = float(probs[idx])

    disease_type, stage = _CLASS_INFO[class_name]
    is_healthy = class_name == "Healthy"

    return {
        "is_healthy": is_healthy,
        "disease_type": disease_type,
        "stage": stage,
        "confidence": confidence,
    }