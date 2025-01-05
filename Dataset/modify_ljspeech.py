# This script takes an original LJSpeech dataset, splits it into subsets (50%, 25%, and 10% of the data),
# and saves the metadata and corresponding audio files for each subset in separate directories.

import random
import shutil

def main():
    # Path to the original dataset
    original_dataset = 'LJSpeech-1.1/'

    # Open the original metadata file for reading
    orig = open(original_dataset+'metadata.csv', 'r')

    # Open new metadata files for the 50%, 25%, and 10% subsets
    mod50 = open('LJSpeech_50/metadata.csv', 'w')
    mod25 = open('LJSpeech_25/metadata.csv', 'w')
    mod10 = open('LJSpeech_10/metadata.csv', 'w')


    for line in orig:
        # Randomly draw a number between 1 and 100 for assigning the current line
        draw = random.randint(1, 100)
        # If the random draw is less than 51, the line is included in the 50% subset
        if draw < 51:
            mod50.write(line)
            shutil.copyfile(f'{original_dataset}wavs/'+line.split('|')[0]+'.wav', f'LJSpeech_50/wavs/'+line.split('|')[0]+'.wav')
            # If the draw is also less than 26, the line is included in the 25% subset
            if draw < 26:
                mod25.write(line)
                shutil.copyfile(f'{original_dataset}wavs/'+line.split('|')[0]+'.wav', f'LJSpeech_25/wavs/'+line.split('|')[0]+'.wav')
        # If the draw is greater than 90, the line is included in the 10% subset (for evaluation)
        elif draw > 90:
            mod10.write(line)
            shutil.copyfile(f'{original_dataset}wavs/'+line.split('|')[0]+'.wav', f'LJSpeech_10/wavs/'+line.split('|')[0]+'.wav')

    # Close all file handlers
    orig.close()
    mod50.close()
    mod25.close()
    mod10.close()


if __name__=="__main__":
    main()
