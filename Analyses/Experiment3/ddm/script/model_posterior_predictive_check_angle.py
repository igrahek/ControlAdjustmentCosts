
"""
Script for generating posterior predictions
Command line input:

1. Model name # 
2. Data file name
3. Number of data samples per posterior point
Author:
    Xiamin Leng, May 2021, xiamin_leng@brown.edu


1. Version or Study folder in the output folder 
2. Is random errors included in the data: 0 = No, 1 = Yes
3. Model name - which model are you running the posterior predictive check on this will be used to set the path to the model
4. Participants data file 
5.  Number of data samples per posterior point

"""




import hddm
import sys
from kabuki.utils import concat_models
from kabuki.analyze import gelman_rubin
import pymc as pm
import numpy as np
import pymc.progressbar as pbar
import pandas as pd
import multiprocessing


version = sys.argv[1]
isRandomIncluded = int(sys.argv[2])
model_name = sys.argv[3]
subjDataFile= sys.argv[4]
nPPC = int(sys.argv[5])

# File paths

if isRandomIncluded:
    model_path= '../../output/' + version + '/' + 'all_errors/' + model_name + '/' + model_name
    datafile_name= '../../data/' + version + '/' + 'all_errors/' + subjDataFile
else:
    model_path= '../../output/' + version + '/' + 'ae_only/' + model_name + '/' + model_name
    datafile_name= '../../data/' + version + '/' + 'ae_only/' + subjDataFile


df = pd.read_csv(datafile_name,low_memory=False)
data = hddm.utils.flip_errors(df)

model_list = []

for model_index in range(5):
    sub_model_name = model_path + '_' + str(model_index) + '.pickle' 
    sub_model = hddm.load(sub_model_name)
    model_list.append(sub_model)

m_comb = concat_models(model_list)

print("DIC: %f" %m_comb.dic)

print("BPIC: %f" %(m_comb.dic_info['pD'] + m_comb.dic))

def _parents_to_random_posterior_sample(bottom_node, pos=None):
    """Walks through parents and sets them to pos sample."""
    for i, parent in enumerate(bottom_node.extended_parents):
        if not isinstance(parent, pm.Node): # Skip non-stochastic nodes
            continue

        if pos is None:
            # Set to random posterior position
            pos = np.random.randint(0, len(parent.trace()))

        assert len(parent.trace()) >= pos, "pos larger than posterior sample size"
        parent.value = parent.trace()[pos]

def _post_pred_generate(bottom_node, samples=500, data=None, append_data=False):
    """Generate posterior predictive data from a single observed node."""
    datasets = []

    ##############################
    # Sample and generate stats
    for sample in range(samples):
        _parents_to_random_posterior_sample(bottom_node)
        # Generate data from bottom node
        sampled_data = bottom_node.random()
        sampled_data.reset_index(inplace=True)
        if append_data and data is not None:
            sampled_data = sampled_data.join(data.reset_index(), lsuffix='_sampled')
        datasets.append(sampled_data)

    return datasets

def post_pred_gen(model, groupby=None, samples=500, append_data=False, progress_bar=True):
    """Run posterior predictive check on a model.
    :Arguments:
        model : kabuki.Hierarchical
            Kabuki model over which to compute the ppc on.
    :Optional:
        samples : int
            How many samples to generate for each node.
        groupby : list
            Alternative grouping of the data. If not supplied, uses splitting
            of the model (as provided by depends_on).
        append_data : bool (default=False)
            Whether to append the observed data of each node to the replicatons.
        progress_bar : bool (default=True)
            Display progress bar
    :Returns:
        Hierarchical pandas.DataFrame with multiple sampled RT data sets.
        1st level: wfpt node
        2nd level: posterior predictive sample
        3rd level: original data index
    :See also:
        post_pred_stats
    """
    results = {}

    # Progress bar
    if progress_bar:
        n_iter = len(model.get_observeds())
        bar = pbar.progress_bar(n_iter)
        bar_iter = 0
    else:
        print("Sampling...")

    if groupby is None:
        iter_data = ((name, model.data.iloc[obs['node'].value.index]) for name, obs in model.iter_observeds())
    else:
        iter_data = model.data.groupby(groupby)

    for name, data in iter_data:
        node = model.get_data_nodes(data.index)

        if progress_bar:
            bar_iter += 1
            bar.update(bar_iter)

        if node is None or not hasattr(node, 'random'):
            continue # Skip

        ##############################
        # Sample and generate stats
        datasets = _post_pred_generate(node, samples=samples, data=data, append_data=append_data)
        results[name] = pd.concat(datasets, names=['sample'], keys=list(range(len(datasets))))

    if progress_bar:
        bar_iter += 1
        bar.update(bar_iter)

    return pd.concat(results, names=['node'])

ppc_data_list = []

nPPC_per_thread = int(nPPC/5)

def ppcFunc(id):
    ppc_data =  post_pred_gen(m_comb,append_data=True,samples=nPPC_per_thread)
    ppc_data.index = pd.MultiIndex.from_tuples([(x[0],x[1] + nPPC_per_thread * id,x[2]) for x in ppc_data.index],names=['node','sample',None])
    return ppc_data


pool = multiprocessing.Pool()
ppc_data_list = pool.map(ppcFunc,range(5))
pool.close()

ppc_data_comb = pd.concat(ppc_data_list)
ppc_data_comb = ppc_data_comb.sort_index(level=['node','sample',None])
ppc_data_comb.to_csv(model_path + '_simData.csv')

ppc_stats = hddm.utils.post_pred_stats(data,ppc_data_comb)
ppc_stats.to_csv(model_path+'_ppc_stats.csv')

m_rhat = gelman_rubin(model_list)
pd.DataFrame.from_dict(m_rhat, orient='index').to_csv(model_path+'_RHat.csv')

m_comb_export = m_comb.get_traces()
m_comb_export.to_csv(model_path+'_traces.csv')
print("DIC: %f" %m_comb.dic)

results = m_comb.get_traces()
results.to_csv(model_path+'_Results.csv')
summary = m_comb.gen_stats()
summary.to_csv(model_path+'_Summary.csv')