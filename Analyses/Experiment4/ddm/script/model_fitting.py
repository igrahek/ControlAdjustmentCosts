#built from Jasons code anotated by Mahalia with info from http://ski.clps.brown.edu/hddm_docs


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
sys.setrecursionlimit(10000000)


# to run this script you will need to have a csv file formated correctly 
#hddm expects:
#subject as subj_idx 
# trialNum
#rt
#response
#the arguments to match up with the column names for the arguments ie if I am varying reward and have coded that as 1 and -1 for two levels and that column is named Rewlvl then my argument list must call Rewlvl

#it expects the following arguments 
# argument 1 file name
# argument 2 version of study 
# argument 3 Is random errors included in the data: 0 = No, 1 = Yes
# argument 4 n sample
# argument 5 n burned
# argument 6 vFormula
# argument 7 aFormula
# argument 8 tFormula
# argument 9 zFormula
# argument 10 itvFormula: what to include  for intertrial variability options are: 'sv', 'st', 'sz'
	#sv is inter-trial variability in drift-rate
	#st is inter-trial variability in non-decision time
	#sz is inter-trial variability in starting-point.
	#p_outier is 

#NOTE ON DDM parameter formulas : 
   # - each input is X-digits, x is the number of conditions for example, if you are varying reinforcement magnitude, penalty, reinforcement type, and congruency then there are 3 things and it expects a 4 digit string  '0001'
   # 0: Not included, 1: Included Main Effect 2:Include Interaction Effect
   # to know what digit corresponds to which variable look at your argument list order
   # 1st digit -> reward
   # 2nd digit -> penalty
   # 3rd digit -> Reinforcement
   # 4th digit -> congruence

filename=sys.argv[1]
version = sys.argv[2]
isRandomIncluded = int(sys.argv[3])==1
nSample = int(sys.argv[4])
nBurned = int(sys.argv[5])
vFormula = sys.argv[6]
aFormula = sys.argv[7]
tFormula = sys.argv[8]
zFormula = sys.argv[9]
zFormula = sys.argv[9]
itvFormula = sys.argv[10]

if isRandomIncluded:
    filepath= '../../data/' + version + '/' + 'all_errors/' +sys.argv[1]
else:
     filepath= '../../data/' + version + '/' + 'ae_only/' +sys.argv[1]


df = pd.read_csv(filepath,low_memory=False) # read in the csv with pd this will take the first argument passed in the bash script  the csv file
data = hddm.utils.flip_errors(df)  #flip_errors is used to flip error RTs to be negative. so if someone makes a mistake the rt is negative

def savePatch(self, fname):
    import pickle
    with open(fname, 'wb') as f:
        pickle.dump(self, f)

hddm.HDDM.savePatch = savePatch
modelDict = {'v':vFormula,'a':aFormula,'t':tFormula,'z':zFormula} # takes the  values that you pass 
argList = ['+Rewlvl','+Punlvl','+Reinlvl','+Congruency'] # main 
mulList = ['*Rewlvl','*Punlvl','*Reinlvl','*Congruency'] # interaction 
modelList = []
modelName = ''
includeBias = True

study = sys.argv[1]

# v= drift rate a= thresholds t=non decision time z= bias

for dv in ['v','a','t','z']:  
                                # ex: 'v'
    modelString = modelDict[dv]  # ex: modelstring is set to = the valye in model Dict for 'v' which is equal too the 5th argument you pass in the bash script
    modelEquation = ''            #ex: 
    modelNamePart = ''

    if modelString == '0000':     # if it is 000 and you are on the z then bias is fixed at default .5
        if dv == 'z':
            includeBias = False   # if false 
        continue
    else:                       #otherwise keep going

        for i in range(4):    #modified to 4 from 3  # for each element in the 3 digit item you pass as as an argument and then is stored in the model Dict
            if modelString[i] == '1':   # if it is 1 set the model equation to the space plus the current index argument soEx if i=1 then it would be "  V"
                modelEquation = modelEquation + argList[i]
                modelNamePart = modelNamePart + argList[i][1] # if you passs a 0 it does not do anything 
            if modelString[i] == '2':
                modelEquation = modelEquation + mulList[i]
                modelNamePart = modelNamePart + '_' + argList[i][1]

        modelEquation = dv + ' ~ ' + modelEquation[1:]
        modelNamePart = dv + modelNamePart

    modelList.append(modelEquation)
    modelName = modelName + modelNamePart

modelName = modelName + '_' + version + '_' + sys.argv[3] + '_' + sys.argv[4] + '_' + sys.argv[5]
print(modelName)

if isRandomIncluded:
    outputPath = '../../output/' + version + '/all_errors/' + modelName
    figurePath = '../../figures/' + version + '/all_errors/' + modelName
else:
    outputPath = '../../output/' + version + '/ae_only/' + modelName
    figurePath = '../../figures/' + version + '/ae_only/' + modelName






if not os.path.exists(outputPath):
    os.makedirs(outputPath)
if not os.path.exists(figurePath):
    os.makedirs(figurePath)

def run_model(id):
    m = hddm.HDDMRegressor(data, modelList,bias=includeBias,
        include=itvFormula,group_only_regressors = False)




    m.find_starting_values()
    m.sample(nSample, burn=nBurned, dbname=outputPath + '/' + modelName+'_'+str(id)+'.db', db='pickle')
    m.savePatch(outputPath + '/' +modelName+'_'+str(id))
    return m

pool = multiprocessing.Pool()
models = pool.map(run_model, range(5))
pool.close()

m_rhat = gelman_rubin(models) # this gets the convergence of the model provides the Gelman-Rubin statistic for convergence: compares the intra-chain variance to the intra-chain variance of different runs of the same model.
pd.DataFrame.from_dict(m_rhat, orient='index').to_csv(outputPath + '/'+modelName+'_RHat.csv') # the output is a dictionary that provides the R-hat for each parameter:

m_comb = concat_models(models)
m_comb_export = m_comb.get_traces()
m_comb_export.to_csv(outputPath + '/' + modelName+'_traces.csv')
print("DIC: %f" %m_comb.dic)

results = m_comb.get_traces()
results.to_csv(outputPath + '/' + modelName+'_Results.csv')
summary = m_comb.gen_stats()
summary.to_csv(outputPath + '/' + modelName+'_Summary.csv')
