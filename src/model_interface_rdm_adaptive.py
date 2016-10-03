'''
Created on Aug 22, 2012

@author: jhkwakkel
'''
import os
import tempfile
import subprocess

import scipy as sp
sp=sp

from ema_workbench.em_framework import (ModelEnsemble, ParameterUncertainty, 
                                        CategoricalUncertainty,
                                        Outcome, ModelStructureInterface)
from ema_workbench.util import ema_logging, save_results, CaseError

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
    
    year_of_emergence = [28, 22, 13, 43, 16, 13, 14, 35, 17, 35]
    step_size = 5
    timing = []
    
    def model_init(self, policy, kwargs):
        #specify the commands to be run relative to the working directory
        self.sequence = policy
        self.initialize_policy(policy)
       
        #change the working directory to the working directory
        ema_logging.debug("changing dir")
        os.chdir(self.working_directory)
        
    def initialize_policy(self, policy):
        if type(policy['params']) is list:
            policies = policy['params']
            self.policy = policies[0]
            self.option = policies[1]
        else:
            self.policy = policy
            self.option = None

    def run_model(self, case):
        self.timing.append((self.policy['name'], 1))
        
        #make empty outcomes
        for outcome in self.outcomes:
            name = outcome.name
            self.output[name] = np.zeros((100,))
        
        # make input file
        bindings = self._make_binding(case)
        
        # make the tables
        self._make_damfact(case)
        self._make_fragtbl(case, bindings)

        # check if wplus:
        clim_scen = case['climate scenarios']
        wplus = False
        if clim_scen >=21:
            wplus = True
            year = self.year_of_emergence[clim_scen - 21]
            
        #run model
        steps = [(x, x+self.step_size-1) for x in\
                 range(1,101-self.step_size, self.step_size)]

        for entry in steps:

            if wplus and self.option:
                if year>=entry[0] and year<entry[1]:
                    self.timing.append((self.option['name'], entry[0]))
                    
                    params = self.option['params']
                    for key, value in params.items():
                        self.policy["params"][key] = value
            
            return_code = self._run(case, entry)

            #check if everything performed correctly
            if return_code != 0:
                #something went wrong
                for outcome in self.outcomes:
                    #make an empty return value, the 100 is conditions on the runtime
                    #this also assumes all outcomes are time series
                    self.output[outcome.name] = np.zeros((entry[1]-entry[0]+1,))
                raise CaseError("run not completed", case, self.policy)
            else:
                self.time = entry[1]
                self._parse_output(entry)
        
        self._determine_costs(case)
  
        for entry in ["Flood damage (Milj. Euro)", "Number of casualties"]:
            self.output[entry] = np.sum(self.output[entry])

    def _run(self, case, entry):
        command = r'pcrcalc -f %s\RAMImiSUI_final.mod -b %s\bindings.txt %d %d %s' % (self.working_directory,
                                                                                      self.working_directory,
                                                                                      entry[0],
                                                                                      entry[1], 
                                                                                      case["climate scenarios"]) 
        # run model and process results
        file_object = tempfile.TemporaryFile()
        
        ema_logging.debug("executing %s" % command)
        return_code = subprocess.Popen(command, stderr=file_object).wait()
#        return_code = subprocess.Popen(command).wait()
        file_object.close()
        return return_code


    def reset_model(self):
        """
        Method for reseting the model to its initial state. The default
        implementation only sets the outputs to an empty dict. 

        """
        super(WaasModel, self).reset_model()
        self.timing = []
        self.time = 1
        self.initialize_policy(self.sequence)

    def _determine_costs(self, case):
        durations = []
        for i, entry in enumerate(self.timing):
            policy, start_time = entry
            names = policy.split(", ")
            
            try:
                end_time = self.timing[i+1][1]
                end_time -= 1 # policy ends a year earlier
            except IndexError:
                end_time = 100
                
            for name in names:
                name = name.strip()
                if name in DIKE:
                    durations.append((name, (start_time, end_time)))
                else:
                    durations.append((name, (start_time, 100)))

        costs = 0
        for name, duration in durations:
           
            if name not in DIKE:
                costs += measure_costs[name]
            else:
                costs_dike = dike_costs[name]
                costs += np.sum(costs_dike[duration[0]:duration[1]+1, case['climate scenarios'] ])    
        
        self.output['Costs'] = costs

        
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
            result[result==1e31] = 0
            
            try:
                result =  result[entry[0]-1::]
                self.output[name][entry[0]-1:entry[1]] = result
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
    
    policies = [{'name':'no policy' , 'params':{}},
                {'name':'Dike 1:500 +0.5m', 
                 'params':{'MHW': 'rundir\\MHW500new.txt', 
                           'MHWFactor': '1', 
                           'DEMdijk': 'rundir\\dem7.pcr', 
                           'OphoogMHW': '0.5'}},  
                {'name':'Dike 1:1000', 
                 'params':{'MHW': 'rundir\\MHW1000new.txt', 
                           'MHWFactor': '1', 
                           'DEMdijk': 'rundir\\dem7.pcr', 
                           'OphoogMHW': '0.5'}}, 
                {'name':'Dike 1:500 +0.5m, 1:1000', 
                 'params':[{'name':'Dike 1:500 +0.5m',
                           'params': {'MHW': 'rundir\\MHW500new.txt', 
                                      'MHWFactor': '1', 
                                      'DEMdijk': 'rundir\\dem7.pcr', 
                                      'OphoogMHW': '0.5'}},
                           {'name': 'Dike 1:1000',
                            'params': {'MHW': 'rundir\\MHW1000new.txt', 
                                       'MHWFactor': '1', 
                                       'DEMdijk': 'rundir\\dem7.pcr', 
                                       'OphoogMHW': '0.5'}}                          
                           ]}, 
                {'name':'Dike 1:500 +0.5m, Dike Climate dikes, 1:1000', 
                 'params':[{'name':'Dike 1:500 +0.5m, Dike Climate dikes',
                           'params': {'FragTbl': 
                                      'rundir\\FragTab50lsmSD.tbl',
                                      'MHW': 'rundir\\MHW500new.txt', 
                                      'MHWFactor': '1', 
                                      'DEMdijk': 'rundir\\dem7.pcr', 
                                      'OphoogMHW': '0.5'}},
                           {'name':'Dike 1:1000',
                            'params': {'MHW': 'rundir\\MHW1000new.txt', 
                                      'MHWFactor': '1', 
                                      'DEMdijk': 'rundir\\dem7.pcr', 
                                      'OphoogMHW': '0.5'}}                             
                           ]}
               ]

#     policies = [{'name':'Dike 1:500 +0.5m', 
#                  'params':{'MHW': 'rundir\\MHW500new.txt', 
#                            'MHWFactor': '1', 
#                            'DEMdijk': 'rundir\\dem7.pcr', 
#                            'OphoogMHW': '0.5'}},  
#                 {'name':'Dike 1:500 +0.5m, 1:1000', 
#                  'params':[{'name':'Dike 1:500 +0.5m',
#                            'params': {'MHW': 'rundir\\MHW500new.txt', 
#                                       'MHWFactor': '1', 
#                                       'DEMdijk': 'rundir\\dem7.pcr', 
#                                       'OphoogMHW': '0.5'}},
#                            {'name': 'Dike 1:1000',
#                             'params': {'MHW': 'rundir\\MHW1000new.txt', 
#                                        'MHWFactor': '1', 
#                                        'DEMdijk': 'rundir\\dem7.pcr', 
#                                        'OphoogMHW': '0.5'}}                          
#                            ]}
#                ]
    
    workdir = "./model"
    ensemble = ModelEnsemble()
    model = WaasModel(workdir, "waas")
    ensemble.parallel = True
    ensemble.model_structure = model
    ensemble.policies = policies
    
    nr_runs = 5000
    results = ensemble.perform_experiments(nr_runs, reporting_interval=1000)
    
    fn = r'./data/fourth iteration {} policies {} runs.tar.gz'
    save_results(results, fn.format(len(policies), nr_runs))

if __name__ == '__main__':
    generate_data()
