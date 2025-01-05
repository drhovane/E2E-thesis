 #!/bin/bash
#PBS -N modify_ljspeech
#PBS -l select=1:ncpus=1:ngpus=0:mem=8gb:scratch_local=20gb
#PBS -l walltime=00:30:00
# The 4 lines above are options for the scheduling system

# This script modifies the LJSpeech dataset by creating 50%, 25%, and 10% subsets.
# It extracts the original dataset, processes it using a Python script, compresses the subsets, and saves the results to the user’s data directory.

# Define a DATADIR variable: directory where the input files are taken from and where the output will be copied to
DATADIR=/Dataset # substitute later for dataset and scripts location

# append a line to a file "jobs_info.txt" containing the ID of the job, the hostname of the node it is run on, and the path to a scratch directory
# this information helps to find a scratch directory in case the job fails, and you need to remove the scratch directory manually
echo "$PBS_JOBID is running on node `hostname -f` in a scratch directory $SCRATCHDIR" >> $DATADIR/jobs_info.txt

# test if the scratch directory is set
# if scratch directory is not set, issue error message and exit
test -n "$SCRATCHDIR" || { echo >&2 "Variable SCRATCHDIR is not set!"; exit 1; }

# Copy the LJSpeech dataset archive to the scratch directory
cp -r $DATADIR/LJSpeech-1.1.tar.bz2 $SCRATCHDIR

# Navigate to the scratch directory
cd $SCRATCHDIR
# Extract the LJSpeech dataset archive
tar -xjf LJSpeech-1.1.tar.bz2

# Copy the Python script for modifying the dataset to the scratch directory
cp $DATADIR/modify_ljspeech.py $SCRATCHDIR

# Create directories for the 50%, 25%, and 10% subsets, including subdirectories for audio files
mkdir LJSpeech_50 LJSpeech_25 LJSpeech_10
mkdir LJSpeech_50/wavs LJSpeech_25/wavs LJSpeech_10/wavs

# Execute the Python script to generate the modified subsets
python modify_ljspeech.py

# Compress the resulting 50%, 25%, and 10% subsets into tar.gz archives
tar -czf LJSpeech_50.tar.gz LJSpeech_50
tar -czf LJSpeech_25.tar.gz LJSpeech_25
tar -czf LJSpeech_10.tar.gz LJSpeech_10

# move the output to user's DATADIR or exit in case of failure
cp LJSpeech_*.tar.gz $DATADIR/ || { echo >&2 "Result file(s) copying failed (with a code $?) !!"; exit 4; }

# clean the SCRATCH directory
clean_scratch
