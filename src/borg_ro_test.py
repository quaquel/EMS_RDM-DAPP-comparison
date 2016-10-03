'''
Created on May 15, 2015

@author: jhkwakkel@tudelft.net
'''
import math
import functools
import numpy as np
from borg_python import borg

from em_framework import ModelEnsemble, UNION
from util import ema_logging

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
    
rules = [SMALL, LARGE, XLARGE]


# normalization for flood damage and casualties is based
# on 5000 runs with doing nothing
# costs is based on 'Dike 1:500 +0.5m, Dike Climate dikes' for 5000 runs
normalization_data = {'Number of casualties': {'mean':756.9814067, 
                                               'std': 388.78367684},
                      'Flood damage (Milj. Euro)': {'mean':34608.543, 
                                                    'std': 17107.6871672},
                      'Costs':{'mean':1111.92459913, 'std':52.2242060867}}



class memoized(object):

    def __init__(self, func):
        self.func = func
        self.cache = {}
    
    def __call__(self, *args):
        instance, pathway = args
        pathway_name = pathway['name']
        
        if pathway_name in self.cache:
            return self.cache[pathway_name]
        else:
            value = self.func(instance, pathway)
            self.cache[pathway_name] = value
            return value

    def __repr__(self):
        '''Return the function's docstring.'''
        return self.func.__doc__
    
    def __get__(self, obj, objtype):
        '''Support instance methods.'''
        return functools.partial(self.__call__, obj)

class ProblemSetup(object):
    
    def __init__(self):
        np.random.seed(123456789)
        self.i = 0
    
        ema_logging.log_to_stderr(ema_logging.INFO)
        
        model = WaasModel(r'./model', "waas")
        self.ensemble = ModelEnsemble()
        self.ensemble.set_model_structure(model)
        self.ensemble.parallel = True
        self.ensemble.processes = 48

        # let's generate the 200 cases we want to use to test the pathways on
        samples = self.ensemble._generate_samples(200, UNION)[0]
        self.ensemble.add_policy({"name":None})
        experiments = [entry for entry in self.ensemble._generate_experiments(samples)]
        for entry in experiments:
            entry.pop("model")
            entry.pop("policy")
        self.cases = experiments

    @staticmethod
    def cast_policy_var(var):
        index = var
        index = int(math.floor(index))
        try:
            policy = policies[index]
        except IndexError:
            ema_logging.warning("{} {}".format(var, index)) 
            raise
        return policy
    
    @staticmethod
    def cast_rule_var(var):
        index = var
        index = int(math.floor(index))
        
        try:
            rule = rules[index]
        except IndexError:
            ema_logging.warning("{} {}".format(var, index)) 
            raise
        
        return rule

    @staticmethod
    def make_name(pathway):
        name = "{}; {}; {}; {}; {}".format(pathway['action_1']['name'],
                                           pathway['action_2']['name'],
                                           pathway['action_3']['name'],
                                           pathway['rule_1'],
                                           pathway['rule_2'])
        return name

    @staticmethod
    def calculate_robustness(outcomes):
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
      
        objs = [float(entry) for entry in [score_1, score_2, score_3, score_4, score_5, score_6]]
        return objs

    @memoized
    def evaluate_pathway(self, pathway):
        self.ensemble._policies = [pathway]
        outcomes = self.ensemble.perform_experiments(self.cases)[1]
        robustness_scores = self.calculate_robustness(outcomes)
        return robustness_scores

    def obj_func(self, *vars):
        self.i += 1 
        ema_logging.info("called: {}".format(self.i))
        
        # map vars to policy levers
        pathway = {'action_1': self.cast_policy_var(vars[0]),
                   'action_2': self.cast_policy_var(vars[1]),
                   'action_3': self.cast_policy_var(vars[2]),
                   'rule_1': self.cast_rule_var(vars[3]),
                   'rule_2': self.cast_rule_var(vars[4]),
                   }
        pathway['name'] = self.make_name(pathway)
        
        robustness_scores = self.evaluate_pathway(pathway)
        
        # return performance
        return robustness_scores
        

if __name__ == '__main__':
    ps = ProblemSetup()

    nvars = 5       
    nobjs = 6
    borg_algorithm = borg.Borg(nvars, nobjs, 0, ps.obj_func)
    borg_algorithm.epsilons[:] = 0.01
    borg_algorithm.bounds[0:3] = 0, len(policies)-0.000001
    borg_algorithm.bounds[3::] = 0, len(rules)-0.0000001
        
    result = borg_algorithm.solve(maxEvaluations=1000,
                                  initialPopulationSize=10,
                                  minimumPopulationSize=10,
                                  frequency=5)
    
    res = result.to_dataframe()
    stats = result.statistics
    
    res.to_csv('./data/archive501.csv')
    stats.to_csv('./data/statistics501.csv')

    