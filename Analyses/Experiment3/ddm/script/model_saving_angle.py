"""
Script for model fitting
Command line inputs:
1. relative path from the place the job is running to the model json file
Output files will be stored in ../output/, relative to the place the job is running
Author:
    Xiamin Leng, July 2021, xiamin_leng@brown.edu
Adjusted for the angle model by Ivan Grahek, March 2022, ivan_grahek@brown.edu
"""


import matplotlib
matplotlib.use('agg')
import hddm
import pandas as pd
import matplotlib.pyplot as plt
from kabuki.analyze import gelman_rubin
from kabuki.utils import concat_models
import sys
import os
import multiprocessing
import json


sys.setrecursionlimit(10000000)



version = sys.argv[1]
isRandomIncluded = int(sys.argv[2])
model_name = sys.argv[3]

# File paths

if isRandomIncluded:
    model_path= '../../output/' + version + '/' + 'all_errors/' + model_name + '/' + model_name
else:
    model_path= '../../output/' + version + '/' + 'ae_only/' + model_name + '/' + model_name

outputPath = model_path

models = []

for model_index in range(1,6):
    sub_model_name = model_path + '_' + str(model_index)
    sub_model = hddm.load(sub_model_name)
    models.append(sub_model)

m_rhat = gelman_rubin(models)
pd.DataFrame.from_dict(m_rhat, orient='index').to_csv(outputPath + '_RHat.csv')

m_comb = concat_models(models)
m_comb_export = m_comb.get_traces()
m_comb_export.to_csv(outputPath + '_traces.csv')
print("DIC: %f" %m_comb.dic)

results = m_comb.get_traces()
results.to_csv(outputPath + '_Results.csv')
summary = m_comb.gen_stats()
summary.to_csv(outputPath + '_Summary.csv')





