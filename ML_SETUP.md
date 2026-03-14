# Local ML Model Setup Guide

## Overview
This app supports both cloud AI and local ML recognition. Local ML runs entirely on device without internet.

## Setup Steps

### 1. Download Model Files

Download the following files and place them in `assets/models/`:

#### Option A: MobileNet V3 (Recommended)
- **Model**: `mobilenet_v3.tflite`
- **Labels**: `labels.txt`

Download from:
- TensorFlow Hub: https://tfhub.dev/google/lite-model/imagenet/mobilenet_v3_large_100_224/classification/5
- Or use the quantized version for smaller size

#### Option B: EfficientNet Lite
- Smaller and faster, slightly less accurate
- https://tfhub.dev/tensorflow/efficientnet/lite0/classification/2

### 2. Directory Structure

```
assets/
  models/
    mobilenet_v3.tflite
    labels.txt
  ingredients/
    ...
```

### 3. Update pubspec.yaml

Make sure assets are included:
```yaml
flutter:
  assets:
    - assets/models/
    - assets/ingredients/
```

### 4. Labels File Format

`labels.txt` should contain one label per line:
```
tench
goldfish
great white shark
tiger shark
...
carrot
apple
orange
banana
...
```

### 5. Test the Model

1. Open the app
2. Go to Profile → AI Recognition
3. Select "Local (Offline)" mode
4. Try scanning an ingredient

## Model Performance

| Model | Size | Accuracy | Speed |
|-------|------|----------|-------|
| MobileNet V3 Large | 12MB | Good | Fast |
| MobileNet V3 Small | 4MB | Medium | Very Fast |
| EfficientNet Lite0 | 5MB | Good | Fast |

## Food-Specific Models

For better food recognition, consider:
- **Food-101 dataset model**: https://www.kaggle.com/datasets/kmader/food41
- **Custom trained model**: Train on your own dataset using TensorFlow

## Troubleshooting

### "Model not found" error
- Check that model files are in `assets/models/`
- Run `flutter clean` and rebuild
- Verify pubspec.yaml includes the assets

### Poor recognition accuracy
- Local ML is limited to common objects
- Use "Auto" or "Cloud" mode for better accuracy
- Consider training a custom food-specific model

### App size too large
- Use quantized models (INT8 instead of FP32)
- Use MobileNet V3 Small instead of Large
- Download model on first launch instead of bundling

## Cloud vs Local Comparison

| Feature | Cloud (CloseAI) | Local (TFLite) |
|---------|----------------|----------------|
| Internet | Required | Not needed |
| Accuracy | Excellent | Good |
| Speed | 1-3 seconds | Instant |
| Privacy | Data sent to server | On device only |
| Cost | API fees | Free |
| Ingredients | All types | Common only |

## Switching Between Modes

Users can switch modes anytime:
1. Go to Profile tab
2. Tap "AI Recognition"
3. Select preferred mode

The app remembers the selection for future use.
