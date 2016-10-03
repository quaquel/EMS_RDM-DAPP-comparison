'''
Created on Oct 15, 2015

@author: jhkwakkel
'''


from em_framework import ModelEnsemble
from util import ema_logging
from util.util import save_results


from model_interface import WaasModel, SMALL, LARGE, XLARGE

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

if __name__ == '__main__':
    ema_logging.log_to_stderr(ema_logging.INFO)
    
    
    ensemble = ModelEnsemble()
    model = WaasModel('./model', 'waas')
    
    ensemble.model_structure = model
    
    pathway_data = [[  5,  20,  10,   2,   2],
                    [  7,  12,   9,   0,   1],
                    [  4,  19,  16,   2,   0],
                    [  4,   5,  16,   2,   0],
                    [ 10,  19,  18,   0,   2],
                    [  1,  20,  19,   1,   0],
                    [ 17,  20,  19,   2,   0],
                    [ 18,  20,  19,   1,   0],
                    [  6,   4,  19,   2,   0],
                    [  0,  20,  19,   1,   0],
                    [  3,  19,  19,   0,   0]]
    
    pathways = []
    for i, pathway in enumerate(pathway_data):
        
            # map vars to policy levers
        pathway = {'action_1': policies[pathway[0]],
                   'action_2': policies[pathway[1]],
                   'action_3': policies[pathway[2]],
                   'rule_1': rules[pathway[3]],
                   'rule_2': rules[pathway[4]],
                   'name': str(i)}
        pathways.append(pathway)
    ensemble.policies = pathways
    
    ensemble.parallel = True
    ensemble.processes = 48
    
    results = ensemble.perform_experiments(5000)
    
    fn = "./data/pathways with timing.tar.gz"
    save_results(results, fn)