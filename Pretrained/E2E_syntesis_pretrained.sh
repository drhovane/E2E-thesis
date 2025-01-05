#!/bin/bash
#PBS -N E2E_syntesis_pretrained
#PBS -l select=1:ncpus=1:ngpus=1:mem=8gb:scratch_local=10gb
#PBS -l walltime=0:5:00 
# The 4 lines above are options for the scheduling system

# This script runs the Python script `E2E_syntesis_pretrained.py` within a Singularity container

# define a DATADIR variable: directory where the input files are taken from and where the output will be copied to
DATADIR=/E2E-thesis/Pretrained/ # substitute later for dataset and scripts location

# append a line to a file "jobs_info.txt" containing the ID of the job, the hostname of the node it is run on, and the path to a scratch directory
# this information helps to find a scratch directory in case the job fails, and you need to remove the scratch directory manually 
echo "$PBS_JOBID is running on node `hostname -f` in a scratch directory $SCRATCHDIR" >> $DATADIR/jobs_info.txt

# Copy the container file to the scratch directory
cp $DATADIR/container.sif $SCRATCHDIR

# Verify that the SCRATCHDIR environment variable is set; exit if it is not
test -n "$SCRATCHDIR" || { echo >&2 "Variable SCRATCHDIR is not set!"; exit 1; }

# Copy the Python script to the scratch directory; exit if copying fails
cp $DATADIR/E2E_syntesis_pretrained.py  $SCRATCHDIR || { echo >&2 "Error while copying input file(s)!"; exit 2; }

# move into scratch directory
cd $SCRATCHDIR

# Create an output directory for storing results
mkdir outfiles

# Execute the Python script using Singularity with GPU support
singularity exec --nv container.sif python E2E_syntesis_pretrained.py

# Copy the results to the output folder in the user's data directory; exit if copying fails
cp -R outfiles/* $DATADIR/outputs/ || { echo >&2 "Result file(s) copying failed (with a code $?) !!"; exit 4; }

# Clean up the scratch directory to free up resources
clean_scratch
