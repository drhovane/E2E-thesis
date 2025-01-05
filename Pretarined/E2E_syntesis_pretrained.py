# This code uses NVIDIA's Tacotron2 and WaveGlow models to convert a list of text sentences into audio files.
# Each text is converted into a waveform (.wav) and its corresponding mel-spectrogram is saved as a numpy array (.npy).

import torch
import numpy as np
from PIL import Image
from scipy.io.wavfile import write

# Load the Tacotron2 model from NVIDIA TorchHub for text-to-mel-spectrogram conversion
tacotron2 = torch.hub.load('NVIDIA/DeepLearningExamples:torchhub', 'nvidia_tacotron2', model_math='fp16')
tacotron2 = tacotron2.to('cuda')    # Move the model to GPU (CUDA)
tacotron2.eval()                    # Set the model to evaluation mode

# Load the WaveGlow model from NVIDIA TorchHub for mel-spectrogram to audio waveform conversion
waveglow = torch.hub.load('NVIDIA/DeepLearningExamples:torchhub', 'nvidia_waveglow', model_math='fp16')
waveglow = waveglow.remove_weightnorm(waveglow) # Remove weight normalization for inference
waveglow = waveglow.to('cuda')                  # Move the model to GPU (CUDA)
waveglow.eval()                                 # Set the model to evaluation mode

# List of file names and corresponding text inputs; chosen from LJSpeech Database
names = ['LJ001-0024', 'LJ001-0007', 'LJ001-0045', 'LJ001-0091', 'LJ001-0092', 'LJ001-0122','LJ001-0152','LJ002-0008', 'LJ002-0015', 'LJ002-0124']

texts = ['But the first Bible actually dated (which also was printed at Maintz by Peter Schoeffer in the year fourteen sixty-two)', 'the earliest book printed with movable types, the Gutenberg, or "forty-two line Bible" of about fourteen fifty-five,','fourteen sixty-nine, fourteen seventy;','so far as fine printing is concerned, though paper did not get to its worst till about eighteen forty.','The Chiswick press in eighteen forty-four revived Caslon\'s founts, printing for Messrs. Longman the Diary of Lady Willoughby.','that he has a five, an eight, or a three before him, unless the press work is of the best:','The modern printer, in the teeth of the evidence given by his own eyes, considers the single page as the unit, and prints the page in the middle of his paper','On the fourteenth June, eighteen hundred, there were one hundred ninety-nine debtors and two hundred eighty-nine felons in the prison.', 'three hundred debtors and nine hundred criminals in Newgate, or twelve hundred prisoners in all.', 'Quite half of the foregoing writs and arrests applied to sums under thirty pounds.']

# Load utility functions for preparing text sequences
utils = torch.hub.load('NVIDIA/DeepLearningExamples:torchhub', 'nvidia_tts_utils')
rate = 22050        # Sampling rate for audio

# Iterate through each text and convert it to audio and mel-spectrogram
for j, text in enumerate(texts):
    # Prepare the text sequence for the Tacotron2 model
    sequences, lengths = utils.prepare_input_sequence([text])

    # Generate the mel-spectrogram using Tacotron2
    with torch.no_grad():
        mel, _, _ = tacotron2.infer(sequences, lengths)  # Generate mel-spectrogram
        audio = waveglow.infer(mel)                      # Generate audio waveform from the mel-spectrogram using WaveGlow

    # Convert the audio waveform to a numpy array
    audio_numpy = audio[0].data.cpu().numpy()
        
    # Save the audio waveform as a .wav file
    write(f"outfiles/{names[j]}.wav", rate, audio_numpy)

    # Convert the mel-spectrogram to a numpy array and save it as a .npy file
    mel_np = mel[0].cpu().numpy()
    np.save(f"outfiles/{names[j]}", mel_np)
