# Audio Quantization and Huffman Coding

This project demonstrates audio quantization and Huffman coding for efficient audio compression using MATLAB. The script reads an audio file, quantizes its amplitude levels, applies Huffman coding, and then reconstructs and plays back the audio to demonstrate the effectiveness of the compression.

## Features

- **audio Quantization**: Reduces the number of unique amplitude levels in the audio signal.
- **probability Calculation**: Determines the probability of each quantized level.
- **huffman Coding**: Applies Huffman coding to compress the audio data based on the probabilities of quantized levels.
- **entropy Calculation**: Calculates the entropy of the quantized levels.
- **efficiency Calculation**: Determines the efficiency of the Huffman coding.
- **audio Playback**: Plays back both the original and decoded (compressed and then decompressed) audio.

## Prerequisites

- MATLAB installed on your machine.
- An audio file named `1.wav` in the same directory as the script.

## How to Run the Script

1. **Clone the repository or download the script** to your local machine.
2. Ensure you have an audio file named `1.wav` in the same directory as the script.
3. Open MATLAB and navigate to the directory containing the script.
4. Run the script by typing `main` in the MATLAB command window.

## Detailed Steps

1. **Reading the Audio File**: The script reads the audio data from `1.wav`.
   ```matlab
   [audio, fs] = audioread('1.wav');
