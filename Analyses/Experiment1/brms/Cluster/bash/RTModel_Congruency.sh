#!/bin/bash

#SBATCH --account=carney-ashenhav-condo
#SBATCH --time=400:00:00
#SBATCH --mem=48G
#SBATCH -n 1
#SBATCH -c 5
#SBATCH --mail-type=ALL
#SBATCH --mail-user=ivan_grahek@brown.edu
#SBATCH -J Exp1_RT_Model_Congruency
#SBATCH -o R-%x.%j.out 
module load r/4.2.2 glpk/5.0
R CMD BATCH --no-save --quiet --slave ../models/RTModel_Congruency.R 
