#!/bin/bash

#SBATCH --account=carney-ashenhav-condo
#SBATCH --time=700:00:00
#SBATCH --mem=48G
#SBATCH -n 1
#SBATCH -c 5
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ivan_grahek@brown.edu
#SBATCH -J Exp7_modelMixed3_no_interaction
#SBATCH -o R-%x.%j.out
module purge
module load anaconda
source activate /users/igrahek/anaconda/pyHDDM
python ../../script/model_fitting_extended.py ../../models/modelMixed3_no_interaction.json
python ../../script/model_posterior_predictive_check.py Mixed 0 modelMixed3_no_interaction DDM_Mixed_nSubs_38.csv 500
