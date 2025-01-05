 #!/bin/bash
#PBS -N train_LJSpeech50
#PBS -l select=1:ncpus=1:ngpus=1:mem=64gb:scratch_local=40gb:cl_galdor=True
#PBS -l walltime=300:00:00 
# The 4 lines above are options for the scheduling system

# This script runs the Tacotron2 training for the LJSpeech50 dataset.

# define a DATADIR variable: directory where the input files are taken from and where the output will be copied to
DATADIR=/E2E-thesis/Dataset/                        # substitute later for dataset location
SPDIR=/E2E-thesis/Trained/speechbrain                          # substitute later for speechbrain location
CONDIR=/E2E-thesis/Container/                       # substitute later for container location
OUTDIR=/E2E-thesis/Trained/Training/LJSpeech50/     # substitute later for output location

# append a line to a file "jobs_info.txt" containing the ID of the job, the hostname of the node it is run on, and the path to a scratch directory
# this information helps to find a scratch directory in case the job fails, and you need to remove the scratch directory manually 
echo "$PBS_JOBID is running on node `hostname -f` in a scratch directory $SCRATCHDIR" >> $DATADIR/jobs_info.txt

# Copy the container file to the scratch directory
cp $CONDIR/container.sif $SCRATCHDIR

# test if the scratch directory is set
# if scratch directory is not set, issue error message and exit
test -n "$SCRATCHDIR" || { echo >&2 "Variable SCRATCHDIR is not set!"; exit 1; }

# Copy the SpeechBrain repository to the scratch directory
cp -r $SPDIR $SCRATCHDIR

# Copy the LJSpeech_50 dataset archive to the scratch directory
cp -r $DATADIR/LJSpeech_50.tar.gz $SCRATCHDIR

# Navigate to the scratch directory and extract the dataset
cd $SCRATCHDIR
tar -xzf LJSpeech_50.tar.gz

# Navigate to the Tacotron2 recipe directory within SpeechBrain
cd $SCRATCHDIR/speechbrain/recipes/LJSpeech/TTS/tacotron2/

# Run the Tacotron2 training script using Singularity
singularity exec --nv $SCRATCHDIR/container.sif python train.py --device=cuda:0 --max_grad_norm=1.0 --data_folder=$SCRATCHDIR/LJSpeech_50 hparams/train.yaml

# Create a directory using the current timestamp to save the training results
date=$(date '+%Y%m%d%H%M%S')
mkdir $OUTDIR/$date

# Copy the training results to the output directory
cp -r results/tacotron2/* $OUTDIR/$date/

# clean the SCRATCH directory
clean_scratch
