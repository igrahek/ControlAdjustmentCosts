#!/bin/bash

#SBATCH --account=carney-ashenhav-condo
#SBATCH --time=100:00:00
#SBATCH --mem=48G
#SBATCH -n 1
#SBATCH -c 5
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ivan_grahek@brown.edu
#SBATCH -J Exp1_modelMixed4_no_interaction
#SBATCH -o R-%x.%j.out
module load anaconda
source activate /users/igrahek/anaconda/pyHDDM
python ../../script/model_fitting_extended.py ../../models/modelMixed4_no_interaction.json
python ../../script/model_posterior_predictive_check.py Mixed 0 modelMixed4_no_interaction DDM_Mixed_nSubs_44.csv 500

