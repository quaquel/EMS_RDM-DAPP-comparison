'''
Created on Aug 22, 2012

@author: jhkwakkel
'''
from __future__ import division
import cPickle

import numpy as np

from em_framework import ModelEnsemble, ema_logging, UNION, MINIMIZE
from em_framework.ema_optimization import epsNSGA2
from model_interface import WaasModel
from model_data import LARGE, XLARGE, SMALL

policies = [{'params': {'RvR': '1', 'LandUseRvR': 'rundir\\landuservrsmall.pcr'}, 'name': 'RfR Small Scale'}, 
            {'params': {'RvR': '2', 'LandUseRvR': 'rundir\\landuservrmed.pcr'}, 'name': 'RfR Medium Scale'}, 
            {'params': {'RvR': '3', 'LandUseRvR': 'rundir\\landuservrlarge.pcr'}, 'name': 'RfR Large Scale'}, 
            {'params': {'RvR': '4', 'LandUseRvR': 'rundir\\landuservrnev.pcr'}, 'name': 'RfR Side channel'}, 
            {'params': {'MHW': 'rundir\\MHW500new.txt', 'MHWFactor': '1', 'DEMdijk': 'rundir\\dem7.pcr', 'OphoogMHW': '0.5'}, 'name': 'Dike 1:500 +0.5m'}, 
            {'params': {'MHW': 'rundir\\MHW00new.txt', 'MHWFactor': '1', 'DEMdijk': 'rundir\\demlijn.pcr', 'OphoogMHW': '0'}, 'name': 'Dike 1:500 extr.'}, 
            {'params': {'MHW': 'rundir\\MHW1000new.txt', 'MHWFactor': '1', 'DEMdijk': 'rundir\\dem7.pcr', 'OphoogMHW': '0.5'}, 'name': 'Dike 1:1000'}, 
            {'params': {'MHW': 'rundir\\MHW00new.txt', 'MHWFactor': '1', 'DEMdijk': 'rundir\\demq20000.pcr', 'OphoogMHW': '0'}, 'name': 'Dike 1:1000 extr.'}, 
            {'params': {'MHW': 'rundir\\MHW500jnew.txt', 'MHWFactor': '1.5', 'DEMdijk': 'rundir\\dem7.pcr', 'OphoogMHW': '0.5'}, 'name': 'Dike 2nd Q x 1.5'}, 
            {'params': {'FragTbl': 'rundir\\FragTab50lsmSD.tbl'}, 'name': 'Dike Climate dikes'}, 
            {'params': {'FragTbl': 'rundir\\FragTab50lsm.tbl'}, 'name': 'Dike Wave resistant'}, 
            {'params': {'maxQLob': '20000'}, 'name': 'Coop Small'}, 
            {'params': {'maxQLob': '18000'}, 'name': 'Coop Medium'}, 
            {'params': {'maxQLob': '14000'}, 'name': 'Coop Large'}, 
            {'params': {'DamFunctTbl': 'rundir\\damfunctionpalen.tbl', 'DEMterp': 'rundir\\dem7.pcr', 'StHouse': '0', 'FltHouse': '0', 'Terp': '0'}, 'name': 'DC Elevated'}, 
            {'params': {'DamFunctTbl': 'rundir\\damfunction.tbl', 'DEMterp': 'rundir\\demdikelcity.pcr', 'StHouse': '0', 'FltHouse': '0', 'Terp': '0'}, 'name': 'DC Dikes'}, 
            {'params': {'DamFunctTbl': 'rundir\\damfunction.tbl', 'DEMterp': 'rundir\\demterpini.pcr', 'StHouse': '0', 'FltHouse': '0', 'Terp': '1'}, 'name': 'DC Mounts'}, 
            {'params': {'DamFunctTbl': 'rundir\\damfunctiondrijf.tbl', 'DEMterp': 'rundir\\dem7.pcr', 'StHouse': '0', 'FltHouse': '0', 'Terp': '0'}, 'name': 'DC Floating'},
            {'params': {'AlarmValue': 20}, 'name': 'Alarm Early'},
            {'params': {}, 'name': 'no policy'},
            {'params': {'AlarmEdu': 1}, 'name': 'Alarm Education'}
            ]
    
policy_levers = {'action_1': {'type':'list', 'values':policies},
                 'action_2': {'type':'list', 'values':policies},
                 'action_3': {'type':'list', 'values':policies},
                 'rule_1': {'type':'list', 'values':[SMALL, LARGE, XLARGE]},
                 'rule_2': {'type':'list', 'values':[SMALL, LARGE, XLARGE]}
                 }

# normalization for flood damage and casualties is based
# on 5000 runs with doing nothing
# costs is based on 'Dike 1:500 +0.5m, Dike Climate dikes' for 5000 runs
normalization_data = {'Number of casualties': {'mean':756.9814067, 
                                               'std': 388.78367684},
                      'Flood damage (Milj. Euro)': {'mean':34608.543, 
                                                    'std': 17107.6871672},
                      'Costs':{'mean':1111.92459913, 'std':52.2242060867}}

def obj_func(outcomes):
    '''
    
    objective function that separates the mean and standard
    deviation as separate objectives
    
    '''
    
    # we want to minimize the median damage and the
    # dispersion of the damage
    # the lower the median, the lower score 1
    # the lower the dispersion, the lower the score
    outcome_1 = outcomes["Flood damage (Milj. Euro)"]
    score_1 = np.mean(outcome_1)/normalization_data["Flood damage (Milj. Euro)"]['mean']
    score_2 = np.std(outcome_1)/normalization_data["Flood damage (Milj. Euro)"]['std']
  
    # we want to minimize the median casualties and the
    # dispersion of the casualties
    # the lower the median, the lower score 1
    # the lower the dispersion, the lower the score
    outcome_2 = outcomes["Number of casualties"]
    score_3 = np.mean(outcome_2)/normalization_data["Number of casualties"]['mean']
    score_4 = np.std(outcome_2)/normalization_data["Number of casualties"]['std']
    
       
    # we want to minimize the median costs and the
    # dispersion of the costs
    # the lower the median, the lower score 1
    # the lower the dispersion, the lower the score
    outcome_3 = outcomes["Costs"]
    score_5 = np.mean(outcome_3)/normalization_data["Costs"]['mean']
    score_6 = np.std(outcome_3)/normalization_data["Costs"]['std']
  
    return score_1, score_2, score_3, score_4, score_5, score_6


def perform_robust_optimization(fn, epsilons):
    np.random.seed(123456789)
    
    ema_logging.log_to_stderr(ema_logging.INFO)
    
    model = WaasModel(r'./model', "waas")
    ensemble = ModelEnsemble()
    ensemble.set_model_structure(model)
    ensemble.parallel = True
    ensemble.processes = 48
    
    # let's generate the 150 cases we want to use to test the pathways on
    samples = ensemble._generate_samples(200, UNION)[0]
    ensemble.add_policy({"name":None})
    experiments = [entry for entry in ensemble._generate_experiments(samples)]
    for entry in experiments:
        entry.pop("model")
        entry.pop("policy")
    cases = experiments
    
    stats_callback, pop = ensemble.perform_robust_optimization(cases=cases,
                                               reporting_interval=1000,
                                               obj_function=obj_func,
                                               weights=(MINIMIZE,)*6,
                                               algorithm=epsNSGA2,
                                               nr_of_generations=250,
                                               pop_size=5,
                                               crossover_rate=0.8, 
                                               mutation_rate=0.05,
                                               policy_levers=policy_levers, 
                                               caching=True,
                                               eps=epsilons
                                               )

    with  open(fn, 'wb') as fh:
        cPickle.dump((stats_callback, cases, pop), fh)


if __name__ == '__main__':
    fn = './data/robust optimizat.cPickle'
    epsilons = (0.05, )*6
         
    perform_robust_optimization(fn, epsilons)



