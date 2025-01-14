#!/bin/bash

#SBATCH --account=carney-ashenhav-condo
#SBATCH --time=700:00:00
#SBATCH --mem=48G
#SBATCH -n 1
#SBATCH -c 5
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ivan_grahek@brown.edu
#SBATCH -J Exp5_modelMixed3_no_switch
#SBATCH -o R-%x.%j.out
module purge
module load anaconda
source activate /users/igrahek/anaconda/pyHDDM 
python ../../script/model_fitting_extended.py ../../models/modelMixed3_no_switch.json
python ../../script/model_posterior_predictive_check.py Mixed 0 modelMixed3_no_switch DDM_Mixed_nSubs_55.csv 500
