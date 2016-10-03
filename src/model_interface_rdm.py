'''
Created on Aug 22, 2012

@author: jhkwakkel
'''
import random
import os
import tempfile
import subprocess
import copy

import numpy as np
import scipy as sp
sp=sp

from em_framework import (ModelEnsemble, ParameterUncertainty, CategoricalUncertainty,
                  Outcome, ModelStructureInterface)
from util import ema_logging
from util.util import save_results
from util.ema_exceptions import CaseError

from model_data import *

 
class WaasModel(ModelStructureInterface):
   
    uncertainties = [ParameterUncertainty((1,30), "climate scenarios",  integer=True),
                     ParameterUncertainty((-0.1, 0.1), "fragility dikes"),
                     ParameterUncertainty((-0.1, 0.1), "DamFunctTbl"),
                     ParameterUncertainty((-0.1, 0.1), "ShipTbl1"),
                     ParameterUncertainty((-0.1, 0.1), "ShipTbl2"),
                     ParameterUncertainty((-0.1, 0.1), "ShipTbl3"),
                     ParameterUncertainty((1, 1.6), "collaboration"),
                     CategoricalUncertainty(("NoChange",                                            
                                             "moreNature",
                                             "Deurbanization",
                                             "sustainableGrowth",
                                             "urbanizationDeurbanization",
                                             "urbanizationLargeAndFast",
                                             "urbanizationLargeSteady"), 
                                             "land use scenarios")
                     ]
    
    outcomes = [Outcome("Flood damage (Milj. Euro)", time=True),
                Outcome("Number of casualties", time=True),
                Outcome("Costs")]

    #helper attribute mapping outcome name to files
    _outcome_files = {"Flood damage (Milj. Euro)": r'DamSumMeur.tss',
                     r"% of non-navigable time": "DamShipProcent.tss",
                      "Nature area": "Summary.asc",
                      "Number of casualties": "cassum.tss",
                      "Number of floods": "floodnumber.tss"}
    
    def model_init(self, policy, kwargs):
        #specify the commands to be run relative to the working directory
        self.policy = policy
       
        #change the working directory to the working directory
        ema_logging.debug("changing dir")
        os.chdir(self.working_directory)

    def run_model(self, case):
        #make empty outcomes
        for outcome in self.outcomes:
            name = outcome.name
            self.output[name] = np.zeros((100,))
        
        # make input file
        bindings = self._make_binding(case)
        
        # make the tables
        self._make_damfact(case)
        self._make_fragtbl(case, bindings)

        runtime = (1,100) # run for hundred years
        return_code = self._run(case, runtime)

        #check if everything performed correctly
        if return_code != 0:
            #something went wrong
            for outcome in self.outcomes:
                #make an empty return value, the 100 is conditions on the runtime
                #this also assumes all outcomes are time series
                self.output[outcome.name] = np.zeros((runtime[1]-runtime[0]+1,))
            raise CaseError("run not completed", case, self.policy)
        else:
            self.time = runtime[1]
            self._parse_output(runtime)
        
        self._determine_costs(case)
        
        return


    def reset_model(self):
        """
        Method for reseting the model to its initial state. The default
        implementation only sets the outputs to an empty dict. 

        """
        super(WaasModel, self).reset_model()
        self.time = 1

    def _determine_costs(self, case):
        name = self.policy['name'] 
    
        names = name.split(", ")
        
        costs = 0
        for name in names:
            name = name.strip()
            if name not in DIKE:
                costs += measure_costs[name]
            else:
                costs_dike = dike_costs[name]
                costs += np.sum(costs_dike[:, case['climate scenarios'] ])            
        
        self.output['Costs'] = np.asarray([costs])
        
    def _run(self, case, entry):
        command = r'pcrcalc -f {0}\RAMImiSUI_final.mod -b {0}\bindings.txt {1} {2} {3}'
        
        command =  command.format(self.working_directory,
                                  entry[0],
                                  entry[1], 
                                  case["climate scenarios"]) 
 
        # run model and process results
        file_object = tempfile.TemporaryFile()
        
#         ema_logging.debug("executing %s" % command)
        return_code = subprocess.Popen(command, stderr=file_object).wait()
#         return_code = subprocess.Popen(command).wait()
        file_object.close()
        return return_code
    
    def _make_fragtbl(self, case, bindings):
        param = case.get("fragility dikes")
        basic_file_name = bindings.get('FragTbl').split('\\')[1]
        
        basic_file = open(self.working_directory+"\\Input\\"+basic_file_name, 'r')
        new_file = open(self.working_directory+r"\\rundir\\"+basic_file_name, 'w')

        for line in basic_file:
            elements = line.strip()
            elements = line.split()
            if elements:
                candidate_value = float(elements[-1])*(1+param)
                candidate_value= max((candidate_value, 0))
                candidate_value = min((candidate_value, 1))
                elements[-1] = str(candidate_value)
                elements = "\t".join(elements)
                new_file.write(elements+"\n")
        basic_file.close()
        new_file.close()
    
    def _make_damfact(self, case):
        basic_file_name = "damfact.tbl"
        basic_file = open(self.working_directory+r"\\Input\\"+basic_file_name, "r")
        output_file = open(self.working_directory+r"\Rundir\\"+basic_file_name, 'w')
        
        param = case.get(("DamFunctTbl"))
        
        for line in basic_file:
            elements = line.strip()
            elements = line.split()
            if elements:
                candidate_value = float(elements[-1])*(1+param)
                candidate_value= max((candidate_value, 0))
                candidate_value = min((candidate_value, 1))
                elements[-1] = str(candidate_value)

                elements = " ".join(elements)
                output_file.write(elements+"\n")
        basic_file.close()
        output_file.close()
        ema_logging.debug("made damfact.tbl")
    
    def _make_binding(self, case):
        ema_logging.debug("making binding.txt")
        
        # write the bindings.txt file
        bindings_file = open(r'%s\bindings.txt' % (self.working_directory), 'w')
        
        bindingDict = {}
        
        for entry in ordering:
            value = self.policy.get("params")
            try:
                value = value[entry]
            except KeyError:
                ema_logging.debug('{} not in case'.format(entry))
                value = bindings.get(entry)
            bindingDict[entry] = value
        
        bindingDict["ClimScenS"] = case["climate scenarios"]
        bindingDict[r'LandUseScA'] = case["land use scenarios"]+r"\landuse"
        bindingDict["maxQLob"] = bindingDict["maxQLob"] * case["collaboration"] 
                
        for entry in ordering:
            value = bindingDict.get(entry)
            bindings_file.write(entry+" = " + str(value)+";\n")
        bindings_file.close()   
        ema_logging.debug("bindings created")
        return bindingDict
    
    def _parse_output(self, entry):
        for outcome in self.outcomes:
            name = outcome.name
            ema_logging.debug("parsing outcome %s" % (name))
            try:
                data_file = self._outcome_files[name]
            except KeyError:
                ema_logging.debug("no parsing function defined for {}".format(name))
                continue
            
            result = self._parsingMethods[name](self,data_file)
            try:
                result =  result[entry[0]-1::]
                result[result==1e31] = 0
                
                self.output[name][entry[0]-1:entry[1]] = np.sum(result)
            except ValueError:
                print entry, name
        ema_logging.debug("outcomes parsed")

    def _parse_timesereries(self, data_file):
        ema_logging.debug("trying to open %s" %(os.path.abspath('rundir\%s' %(data_file))))
        data_file = open(os.path.abspath('rundir\%s' % (data_file)))
        data = data_file.readlines()
        data_file.close()
        data = data[4::]
        data = [entry.replace('1.#INF', '0') for entry in data]
        data = [entry.strip() for entry in data]
        data = [entry.split() for entry in data]
        data = [float(entry[1]) for entry in data]
        return np.asarray(data)

    def _parse_dike_ring_specific_time_series(self, data_file):
        ema_logging.debug("trying to open %s" %(os.path.abspath('rundir\%s' %(data_file))))
        data_file = open(os.path.abspath('rundir\%s' % (data_file)))

        data = data_file.readlines()
        data_file.close()
        data = data[8::]
        data = [entry.strip() for entry in data]
        data = [entry.split() for entry in data]
        data = [entry[1::] for entry in data]
        data = np.asarray(data, dtype=float)
        data[data==1e31]=0
        return data
    
    def _parse_flood_damage(self,file_name):
        return self._parse_timesereries(file_name)
    
    def _parse_non_navigable(self,file_name):
        return self._parse_timesereries(file_name)
    
    def _parse_nature_area(self, file_name):
        ema_logging.debug("trying to open %s" %(os.path.abspath('rundir\%s' %(file_name))))
        res_file = open(os.path.abspath('rundir\%s' % (file_name)))
        data = file.readlines()
        res_file.close()
        data = data[6::]
        data = [entry.strip() for entry in data]
        data = [float(entry) for entry in data]
        data = np.asarray(data)
        return np.asarray(data)
    
    def _parse_casualties(self, file_name):
        return self._parse_timesereries(file_name)
    
    def _parse_nr_floods(self, file_name):
        return self._parse_timesereries(file_name)

    #helper attribute mapping outcome name to parser function
    _parsingMethods = {"Flood damage (Milj. Euro)": _parse_flood_damage,
                        r"% of non-navigable time": _parse_non_navigable,
                        "Nature area": _parse_nature_area,
                        "Number of casualties": _parse_casualties,
                        "Number of floods": _parse_nr_floods}


def generate_data():
    ema_logging.log_to_stderr(ema_logging.INFO)
    
    # let's list all actions
#     policies = [
#                 {'name':'no policy' , 'params':{}},
#                 {'name':'RfR Small Scale' , 'params':{'RvR': '1', 'LandUseRvR': 'rundir\\landuservrsmall.pcr'}}, 
#                 {'name':'RfR Medium Scale', 'params':{'RvR': '2', 'LandUseRvR': 'rundir\\landuservrmed.pcr'}}, 
#                 {'name':'RfR Large Scale' , 'params':{'RvR': '3', 'LandUseRvR': 'rundir\\landuservrlarge.pcr'}}, 
#                 {'name':'RfR Side channel', 'params':{'RvR': '4', 'LandUseRvR': 'rundir\\landuservrnev.pcr'}},  
# 
#                 {'name':'Dike 1:500 +0.5m', 'params':{'MHW': 'rundir\\MHW500new.txt', 'MHWFactor': '1', 'DEMdijk': 'rundir\\dem7.pcr', 'OphoogMHW': '0.5'}},  
#                 {'name':'Dike 1:500 extr.', 'params':{'MHW': 'rundir\\MHW00new.txt', 'MHWFactor': '1', 'DEMdijk': 'rundir\\demlijn.pcr', 'OphoogMHW': '0'}},  
#                 {'name':'Dike 1:1000', 'params':{'MHW': 'rundir\\MHW1000new.txt', 'MHWFactor': '1', 'DEMdijk': 'rundir\\dem7.pcr', 'OphoogMHW': '0.5'}}, 
#                 {'name':'Dike 1:1000 extr.', 'params':{'MHW': 'rundir\\MHW00new.txt', 'MHWFactor': '1', 'DEMdijk': 'rundir\\demq20000.pcr', 'OphoogMHW': '0'}}, 
#                 {'name':'Dike 2nd Q x 1.5', 'params':{'MHW': 'rundir\\MHW500jnew.txt', 'MHWFactor': '1.5', 'DEMdijk': 'rundir\\dem7.pcr', 'OphoogMHW': '0.5'}}, 
#                     
#                 {'name':'Dike Climate dikes', 'params':{'FragTbl': 'rundir\\FragTab50lsmSD.tbl'}}, 
#                 {'name':'Dike Wave resistant', 'params':{'FragTbl': 'rundir\\FragTab50lsm.tbl'}}, 
#                     
#                 {'name':'Coop Small', 'params':{'maxQLob': '20000'}}, 
#                 {'name':'Coop Medium', 'params':{'maxQLob': '18000'}}, 
#                 {'name':'Coop Large', 'params':{'maxQLob': '14000'}}, 
#                     
#                 {'name':'DC Elevated', 'params':{'DamFunctTbl': 'rundir\\damfunctionpalen.tbl', 'DEMterp': 'rundir\\dem7.pcr', 'StHouse': '0', 'FltHouse': '0', 'Terp': '0'}},  
#                 {'name':'DC Dikes', 'params':{'DamFunctTbl': 'rundir\\damfunction.tbl', 'DEMterp': 'rundir\\demdikelcity.pcr', 'StHouse': '0', 'FltHouse': '0', 'Terp': '0'}},  
#                 {'name':'DC Mounts', 'params':{'DamFunctTbl': 'rundir\\damfunction.tbl', 'DEMterp': 'rundir\\demterpini.pcr', 'StHouse': '0', 'FltHouse': '0', 'Terp': '1'}},  
#                 {'name':'DC Floating', 'params':{'DamFunctTbl': 'rundir\\damfunctiondrijf.tbl', 'DEMterp': 'rundir\\dem7.pcr', 'StHouse': '0', 'FltHouse': '0', 'Terp': '0'}}, 
#                     
#                 {'name':'Alarm Early', 'params':{'AlarmValue': 20}},
#                 {'name':'Alarm Late', 'params':{'AlarmValue': 60}},
#                 {'name':'Alarm Education', 'params':{'AlarmEdu': 1}},
#                ]

    policies = [
                {'name':'no policy' , 'params':{}},
                {'name':'Dike 1:500 +0.5m', 'params':{'MHW': 'rundir\\MHW500new.txt', 
                                                      'MHWFactor': '1', 
                                                      'DEMdijk': 'rundir\\dem7.pcr', 
                                                      'OphoogMHW': '0.5'}},  
                {'name':'Dike 1:1000', 'params':{'MHW': 'rundir\\MHW1000new.txt', 
                                                 'MHWFactor': '1', 
                                                 'DEMdijk': 'rundir\\dem7.pcr', 
                                                 'OphoogMHW': '0.5'}}, 
                {'name':'Dike 1:500 +0.5m, RfR Medium Scale', 'params':{'RvR': '2', 
                                                                        'LandUseRvR': 'rundir\\landuservrmed.pcr',
                                                                        'MHW': 'rundir\\MHW500new.txt', 
                                                                        'MHWFactor': '1', 
                                                                        'DEMdijk': 'rundir\\dem7.pcr', 
                                                                        'OphoogMHW': '0.5'
                                                                         }}, 
                {'name':'Dike 1:500 +0.5m, RfR Large Scale', 'params':{'RvR': '3', 
                                                                        'LandUseRvR': 'rundir\\landuservrlarge.pcr',
                                                                        'MHW': 'rundir\\MHW500new.txt', 
                                                                        'MHWFactor': '1', 
                                                                        'DEMdijk': 'rundir\\dem7.pcr', 
                                                                        'OphoogMHW': '0.5'
                                                                         }}, 
                {'name':'Dike 1:500 +0.5m, Dike Climate dikes', 'params':{'FragTbl': 
                                                                              'rundir\\FragTab50lsmSD.tbl',
                                                                              'MHW': 'rundir\\MHW500new.txt', 
                                                                              'MHWFactor': '1', 
                                                                              'DEMdijk': 'rundir\\dem7.pcr', 
                                                                              'OphoogMHW': '0.5'}}, 
                {'name':'Dike 1:500 +0.5m, Alarm Early', 'params':{'AlarmValue': 20,
                                                                    'MHW': 'rundir\\MHW500new.txt', 
                                                                    'MHWFactor': '1', 
                                                                    'DEMdijk': 'rundir\\dem7.pcr', 
                                                                    'OphoogMHW': '0.5'}},
               ]
    
    workdir = "./model"
    ensemble = ModelEnsemble()
    model = WaasModel(workdir, "waas")
    ensemble.parallel = True
    ensemble.model_structure = model
    ensemble.policies = policies
    ensemble.processes = 48
    
    nr_runs = 5000
    results = ensemble.perform_experiments(nr_runs)
    save_results(results, r'./data/third iteration {} policies  {} runs.tar.gz'.format(len(policies), nr_runs))

if __name__ == '__main__':
    generate_data()
