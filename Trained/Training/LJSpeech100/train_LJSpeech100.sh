 #!/bin/bash
#PBS -N train_LJSpeech100
#PBS -l select=1:ncpus=2:ngpus=1:mem=64gb:scratch_local=40gb:cl_galdor=True
#PBS -l walltime=300:00:00 
# The 4 lines above are options for the scheduling system

# This script runs the Tacotron2 training for the full LJSpeech dataset.

# define a DATADIR variable: directory where the input files are taken from and where the output will be copied to
DATADIR=/speechbrain_test # substitute later for train.py script location

# append a line to a file "jobs_info.txt" containing the ID of the job, the hostname of the node it is run on, and the path to a scratch directory
# this information helps to find a scratch directory in case the job fails, and you need to remove the scratch directory manually 
echo "$PBS_JOBID is running on node `hostname -f` in a scratch directory $SCRATCHDIR" >> $DATADIR/jobs_info.txt

# Copy the container file to the scratch directory
cp $DATADIR/container.sif $SCRATCHDIR

# test if the scratch directory is set
# if scratch directory is not set, issue error message and exit
test -n "$SCRATCHDIR" || { echo >&2 "Variable SCRATCHDIR is not set!"; exit 1; }

# Copy the SpeechBrain repository to the scratch directory
cp -r $DATADIR/speechbrain $SCRATCHDIR

# Copy the LJSpeech dataset archive to the scratch directory
cp -r $DATADIR/dataset/LJSpeech-1.1.tar.bz2 $SCRATCHDIR

# Navigate to the scratch directory
cd $SCRATCHDIR

# Extract the dataset
tar -xjf LJSpeech-1.1.tar.bz2

# Move to the Tacotron2 recipe directory in the SpeechBrain repository
cd $SCRATCHDIR/speechbrain/recipes/LJSpeech/TTS/tacotron2/

# Run the Tacotron2 training using the Singularity container
singularity exec --nv $SCRATCHDIR/test_latest.sif python train.py --device=cuda:0 --max_grad_norm=1.0 --data_folder=$SCRATCHDIR/LJSpeech-1.1 hparams/train.yaml

# Generate a timestamp for uniquely naming the output folder
date=$(date '+%Y%m%d%H%M%S')
mkdir $DATADIR/$date

# Copy the training results to the output directory
cp -r results/tacotron2/* $DATADIR/$date/long_outputs/

# Clean up the scratch directory to free up resources
clean_scratch
