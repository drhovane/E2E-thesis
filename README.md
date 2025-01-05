# E2E-thesis

This repository contains the scripts utilized in my [diploma thesis](will be linked later) written under the supervision of doc. Petr Pollak at the [Department of Circuit Theory](https://obvody.fel.cvut.cz/), [Faculty of Electrical Engineering](https://fel.cvut.cz/en), [CTU in Prague](https://www.cvut.cz/en).

## Abstract

Speech synthesis plays a key role in applications that allow people to naturally interact with technology, such as assistive systems for people with disabilities or interactive voice assistants. The most prominent approach today is speech synthesis using the End-to-End method, which uses Deep Neural Networks to directly convert text to speech. 

This thesis focuses on the research and basic implementation of an E2E speech synthesis system. The system is based on the Tacotron 2 architecture, which combines mel-spectrogram prediction from text and a modified WaveGlow audio generator. The training of Tacotron2 model was carried out using open source tools and libraries, and was performed on the English LJ Speech database with a total duration of 24 hours of recordings.

Five models were trained on 5 different lengths of the available LJ Speech database. Informative evaluation of the quality of the synthesized speech was performed using the Dynamic Time Warping (DTW) on cepstral coefficients and a an informal listening assessment of the naturalness of the output.

The results confirm the expected result that a larger amount of training data contributes to improving the quality of the synthesized voice, although even smaller datasets can achieve satisfactory results for basic applications.
## How to use

The scripts are somewhat commented and prepared for further utilization. Shell and Python scripts were originally run on [MetaCentrum](https://metavo.metacentrum.cz/), therefore under Debian 13. MATLAB scripts were run on my home PC with Windows 11. All of the scripts should be usable under any system with a little tweaking.

### Prerequisites

The project utilizes [PyTorch](https://pytorch.org/) and [SpeechBrain](https://speechbrain.github.io/) with all of their own prerequisites and all training was performed on [LJSpeech dataset](https://keithito.com/LJ-Speech-Dataset/).

