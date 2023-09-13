#!/bin/bash

#SBATCH --account=carney-ashenhav-condo
#SBATCH --time=100:00:00
#SBATCH --mem=48G
#SBATCH -n 1
#SBATCH -c 5
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ivan_grahek@brown.edu
#SBATCH -J Exp1_modelMixed3
#SBATCH -o R-%x.%j.out
module load anaconda/3-5.2.0
source activate pyHDDM 
python ../../script/model_fitting_extended.py ../../models/modelMixed3.json
python ../../script/model_posterior_predictive_check.py Mixed 0 modelMixed3 DDM_Mixed_nSubs_44.csv 500

