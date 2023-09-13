#!/bin/bash

#SBATCH --account=carney-ashenhav-condo
#SBATCH --time=800:00:00
#SBATCH --mem=48G
#SBATCH -n 1
#SBATCH -c 5
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ivan_grahek@brown.edu
#SBATCH -J Exp6_modelMixed2
#SBATCH -o R-%x.%j.out
module load anaconda/3-5.2.0
source activate pyHDDM 
python ../../script/model_fitting_extended.py ../../models/modelMixed2.json
python ../../script/model_posterior_predictive_check.py Mixed 0 modelMixed2 DDM_Mixed_nSubs_50.csv 500
