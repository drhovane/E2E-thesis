# This code downloads the pretrained Tacotron2 model from NVIDIA, which converts text into a mel-spectrogram.
# The resulting mel-spectrogram is saved as an image in PNG format.

import torch
import numpy as np
from PIL import Image

# Load the Tacotron2 model from TorchHub (by NVIDIA)
tacotron2 = torch.hub.load('NVIDIA/DeepLearningExamples:torchhub', 'nvidia_tacotron2', model_math='fp16')

# Move the model to GPU (CUDA)
tacotron2 = tacotron2.to('cuda')

# Set the model to evaluation mode (for inference, not training)
tacotron2.eval()

# The text to be converted into a mel-spectrogram
text = "Hello world, I missed you so much."

# Load utility functions from NVIDIA TorchHub
utils = torch.hub.load('NVIDIA/DeepLearningExamples:torchhub', 'nvidia_tts_utils')

# Prepare the text sequence for the model input
sequences, lengths = utils.prepare_input_sequence([text])

# Perform inference (generate the mel-spectrogram) using the model
with torch.no_grad():
    mel, _, _ = tacotron2.infer(sequences, lengths)

# Convert the mel-spectrogram to a numpy array and normalize it
mel_np = mel[0].cpu().numpy()       # Move data to CPU and convert to a numpy array
mel_np = mel_np - np.min(mel_np)    # Shift values so the minimum is zero
mel_np = 255*mel_np/np.max(mel_np)  # Normalize values to the range [0, 255]

melimg = Image.fromarray(mel_np)    # Convert the numpy array to an image
melimg = melimg.convert('RGB')      # Convert the image to RGB format
melimg.save("mel.png")              # Save the mel-spectrogram image to a file named "mel.png"
