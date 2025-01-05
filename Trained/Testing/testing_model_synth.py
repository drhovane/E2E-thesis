# This code generates mel-spectrograms from 10% of the LJSpeech dataset (evaluation set)
# using a trained Tacotron2 model, trained for 750 epochs.
# It loads IDs and text transcriptions from the metadata.csv file
# and saves the results (mel-spectrograms, lengths, and alignments) in .npy format.
# Based on these mel-spectrograms, audio in WAV format is synthesized using the WaveGlow model.


import torch
import torchaudio
from speechbrain.inference.TTS import Tacotron2
import copy
import numpy as np
from scipy.io.wavfile import write

# Function to sort text and corresponding file names by the length of text (descending order)
def sort_inputs(n, t):
    names = copy.deepcopy(n)
    texts = copy.deepcopy(t)
    data = []
    for i in range(len(names)):
        data.append((names[i], texts[i]))                       # Pairing names and texts
    data = sorted(data, key=lambda x: len(x[1]), reverse=True)  # Sorting by text length in descending order
    for i in range(len(data)):
        names[i], texts[i] = data[i][0], data[i][1]             # Reassigning sorted names and texts
    return names, texts

# Function to load metadata from a CSV file
def load_metadata(metadata_file):

    names = []
    texts = []
    with open(metadata_file, 'r', encoding='utf-8') as csvfile:
        for row in csvfile:
            line = row.split('|')           # Data is separated by '|'
            names.append(line[0])           # ID (1st column in CSV)
            texts.append(line[2][:-1])      # Normalized transcription (3rd column in CSV)
    names, texts = sort_inputs(names, texts)     # Sorting texts and IDs by length
    return names, texts

# Function to load Tacotron2 model weights from a saved checkpoint
def load_weights(model_path):
    checkpoint = torch.load(model_path,weights_only=True)       # Loading model weights
    keycopy = copy.deepcopy(list(checkpoint.keys()))            # Creating a copy of checkpoint keys
    for key in keycopy:
        checkpoint[f"mods.model.{key}"] = checkpoint.pop(key)   # Adding 'mods.model.' to each key for compatibility
    return checkpoint

# Function to generate mel-spectrograms and save them in .npy format
def generate_mels(metadata_file, tacotron2, out_dir):
    _, texts = load_metadata(metadata_file)

    # Generate mel-spectrograms, lengths, and alignments for all texts
    mels, mel_lengths, alignments = tacotron2.encode_batch(texts)    # Generate mel-spectrograms in batch

    # Save the outputs into .npy files
    mel_out_np = mels.cpu().detach().numpy()
    np.save(f"{out_dir}/mels", mel_out_np)

    mel_len_np = mel_lengths.cpu().detach().numpy()
    np.save(f"{out_dir}/mel_lengths", mel_len_np)

    alignments_np = alignments.cpu().detach().numpy()
    np.save(f"{out_dir}/alignments", alignments_np)

    print(f"Outputs saved to directory: {out_dir}")

def main():
    metadata_file = 'LJSpeech_10/metadata.csv'  # Path to the metadata file
    mels_out_dir = 'outs_taco2'                 # Directory to save mel-spectrograms
    sound_out_dir = 'outs_wav'                  # Directory to save generated WAV files

    torch.cuda.empty_cache()

    # Načtení modelu Tacotron2
    tacotron2 = Tacotron2.from_hparams(source="speechbrain/tts-tacotron2-ljspeech", savedir="tmpdir_tts") # from https://speechbrain.readthedocs.io/en/latest/tutorials/basics/what-can-i-do-with-speechbrain.html#speech-synthesis-text-to-speech

    # Load custom model weights
    tacotron2.load_state_dict(load_weights('model.ckpt'))

    # Load the WaveGlow model for audio synthesis
    waveglow = torch.hub.load('NVIDIA/DeepLearningExamples:torchhub', 'nvidia_waveglow', model_math='fp16')
    waveglow = waveglow.remove_weightnorm(waveglow)
    waveglow = waveglow.to('cuda')
    waveglow.eval()

    fs = 22050  # Sampling frequency for WAV files

    # Process the metadata and generate audio from mel-spectrograms
    with open(metadata_file, 'r', encoding='utf-8') as csvfile:
        for row in csvfile:
            line = row.split('|')
            name = line[0]          # ID (1st column in CSV)
            text = line[2][:-1]     # Normalized transcription (3rd column in CSV)

            # Generate mel-spectrogram for the current text
            mel, _, _ = tacotron2.encode_batch([text])
            mel = mel.cuda()

            # Synthesize audio from mel-spectrogram using WaveGlow
            audio = waveglow.infer(mel)

            # Save the generated audio as a .wav file
            audio_numpy = audio[0].data.cpu().numpy()
            write(f"{sound_out_dir}/{name}.wav", fs, audio_numpy)

            torch.cuda.empty_cache()     # Clear GPU memory to avoid running out of memory

if __name__=="__main__":
    main()
