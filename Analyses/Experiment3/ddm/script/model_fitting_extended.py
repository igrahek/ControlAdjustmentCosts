"""
Script for model fitting
Command line inputs:
1. relative path from the place the job is running to the model json file
Output files will be stored in ../output/, relative to the place the job is running
Author:
    Xiamin Leng, July 2021, xiamin_leng@brown.edu
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


def savePatch(self, fname):
    import pickle
    with open(fname, 'wb') as f:
        pickle.dump(self, f)

hddm.HDDM.savePatch = savePatch


with open(sys.argv[1]) as f:
    info = json.load(f)

modelName = info['model']

study = info['study']

datafile = info['data']

errorInfo = info['errors']

filepath= '../../data/' + study + '/' +errorInfo+ '/' +datafile +'.csv'



df = pd.read_csv(filepath,low_memory=False)

data = hddm.utils.flip_errors(df)

formula = info['formula']

for variable,setting in info['predictors'].items():
    if setting['type'] == 'category':
        data[variable] = data[variable].astype('category').cat.reorder_categories(setting['levels'])
        for i in range(len(formula)):
            formula[i] = formula[i].replace(variable,'C('+variable+','+setting['contrast']+')')


print(formula)

outputPath = '../../output/' + study + '/' +errorInfo+ '/' + modelName

if not os.path.exists(outputPath):
    os.makedirs(outputPath)

def run_model(id):

    m = hddm.HDDMRegressor(data, formula,bias=info['bias'],
        include=info['includes'],group_only_regressors = False)

    m.find_starting_values()
    m.sample(info['totalsample'], burn=info['burnedsample'],
        dbname=outputPath + '/' + modelName+'_'+str(id)+'.db', db='pickle')
    m.savePatch(outputPath + '/' +modelName+'_'+str(id))
    return m


pool = multiprocessing.Pool()
models = pool.map(run_model, range(5))
pool.close()

m_rhat = gelman_rubin(models)
pd.DataFrame.from_dict(m_rhat, orient='index').to_csv(outputPath + '/'+modelName+'_RHat.csv')

m_comb = concat_models(models)
m_comb_export = m_comb.get_traces()
m_comb_export.to_csv(outputPath + '/' + modelName+'_traces.csv')
print("DIC: %f" %m_comb.dic)

results = m_comb.get_traces()
results.to_csv(outputPath + '/' + modelName+'_Results.csv')
summary = m_comb.gen_stats()
summary.to_csv(outputPath + '/' + modelName+'_Summary.csv')