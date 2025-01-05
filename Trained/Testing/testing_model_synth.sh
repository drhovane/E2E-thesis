#!/bin/bash
#PBS -N test_LJSpeech_model
#PBS -l select=1:ncpus=1:ngpus=1:mem=64gb:scratch_local=20gb
#PBS -l walltime=3:00:00 
# The 4 lines above are options for the scheduling system

# define a DATADIR variable: directory where the input files are taken from and where the output will be copied to
# substitute later for dataset and scripts location
SCRIPT_DIR=/E2E-thesis/Trained/Testing/             # directory of the python sript to run
OUTDATA_DIR=$SCRIPT_DIR                             # directory of outputs
CONTAINER_DIR=/E2E-thesis/Container/                #directory of the used container
MODEL_DIR=                                          #directory of trained model
SPEECH_BRAIN_DIR=/E2E-thesis/Trained/speechbrain    #directory of the speechbrain library
DATASET_DIR=/E2E-thesis/Dataset/                    #directory of dataset -> .csv for generation

# append a line to a file "jobs_info.txt" containing the ID of the job, the hostname of the node it is run on, and the path to a scratch directory
# this information helps to find a scratch directory in case the job fails, and you need to remove the scratch directory manually 
echo "$PBS_JOBID is running on node `hostname -f` in a scratch directory $SCRATCHDIR" >> $OUTDATA_DIR/jobs_info.txt

# Copy the container from its directory to the scratch directory
cp $CONTAINER_DIR/container.sif $SCRATCHDIR

# if scratch directory is not set, issue error message and exit
test -n "$SCRATCHDIR" || { echo >&2 "Variable SCRATCHDIR is not set!"; exit 1; }

# Copy the Python script (testing_model_synth.py) to the scratch directory
cp $SCRIPT_DIR/testing_model_synth.py  $SCRATCHDIR || { echo >&2 "Error while copying .py file!"; exit 2; }

# Copy the SpeechBrain library to the scratch directory
cp -r $SPEECH_BRAIN_DIR $SCRATCHDIR

# Copy the trained model weights to the scratch directory
cp $MODEL_DIR/model.ckpt $SCRATCHDIR

# Copy the evaluation dataset (LJSpeech_10.tar.gz) to the scratch directory
cp -r $DATASET_DIR/LJSpeech_10.tar.gz $SCRATCHDIR
cd $SCRATCHDIR
tar -xzf LJSpeech_10.tar.gz # un-tar the database

# move into scratch directory
cd $SCRATCHDIR

# Create output directories for the WAV and Tacotron2 files
mkdir outs_wav outs_taco2

# Run the Python script for testing the model in container
singularity exec --nv container.sif python testing_model_synth.py

# move the output to user's DATADIR or exit in case of failure
cp -R outs_* $OUTDATA_DIR/ || { echo >&2 "Result file(s) copying failed (with a code $?) !!"; exit 4; }

# clean the SCRATCH directory
clean_scratch
