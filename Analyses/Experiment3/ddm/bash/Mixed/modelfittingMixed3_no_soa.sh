#!/bin/bash

#SBATCH --account=carney-ashenhav-condo
#SBATCH --time=700:00:00
#SBATCH --mem=48G
#SBATCH -n 1
#SBATCH -c 5
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ivan_grahek@brown.edu
#SBATCH -J Exp6_modelMixed3_no_soa
#SBATCH -o R-%x.%j.out
module purge
module load anaconda
source activate /users/igrahek/anaconda/pyHDDM
python ../../script/model_fitting_extended.py ../../models/modelMixed3_no_soa.json
python ../../script/model_posterior_predictive_check.py Mixed 0 modelMixed3_no_soa DDM_Mixed_nSubs_50.csv 500
