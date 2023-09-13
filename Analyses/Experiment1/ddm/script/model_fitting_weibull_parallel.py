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

with open(sys.argv[1]) as f:
    info = json.load(f)

modelName = info['model']

study = info['study']

datafile = info['data']

errorInfo = info['errors']

filepath= '../../data/' + study + '/' +errorInfo+ '/' +datafile +'.csv'

def savePatch(self, fname):
    import pickle
    with open(fname, 'wb') as f:
        pickle.dump(self, f)

hddm.HDDM.savePatch = savePatch



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

    m = hddm.HDDMnnRegressor(data, formula,bias=info['bias'],
     include=info['includes'],group_only_regressors = False,model='weibull')

    m.find_starting_values()
    m.sample(info['totalsample'], burn=info['burnedsample'], dbname=outputPath + '/' + modelName+'_'+str(id)+'.db', db='pickle')
    m.save(outputPath + '/' +modelName+'_'+str(id)+'.pickle')


pool = multiprocessing.Pool()
models = pool.map(run_model, range(5))
pool.close()

