#! --nondiagonal 

# WD
# Timebegin en Timeend niet via de binding file maar via de params van de commandline
# ClimSenS niet via binding file maar via params op de commandline
# Aanroep voor alle modellen:
# $1 is begintime
# $2 is endtime
# $3 is ClimateChangeScenario
#

binding

##### Externe bindings #############################################################################
# deze bindings zitten al in bindings.txt, wel hier laten staan vanwege beschrijving
#     maxQLob = 30000;    # 17500, 18670, 19840 in 2100 zonder maatregelenin, midden/beschermingsniveau op hetzelfde, hoog/geen fysisch maximum/ hetzelfde beschermingsniveau als NL
#  LandUseRvR = rundir\Land00_2.pcr;
#         RvR = 0;        # vanaf tijdstip 0, 0 = geen rvr maatregelen, 1 = rvr, 2 = rvr middel, 3 = rvr groot 1=0.98,0.99 2=0.94,0.98 3 = 0.9, 0.95
#      StadHa = 0;        # toename ha stad
#       NatHa = 0;        # toename ha natuur
#     GlasbHa = 0;        # toename ha glastuinbouw
#     RecreHa = 0;        # toename ha recreatie
#     LandRnd = 0;        # als 1 dan nieuw landgebruik er random bij ,ansders volgens spread
#     DEMdijk = rundir\dem7.pcr;         # DEM MaatregelDEMWillem2514m3.pcr 14000 m3 DEM14_klBag.pcr 14000 m3 en kleinschalig baggeren
#         MHW = rundir\MHW00new.txt;        #  MHW0$1.txt MHW500$1.txt MHW1000$1.txt; #aanpassing vanwege nieuwe userinterface MHW00new.txt ipv MHW00.txt
#   OphoogMHW = 0.5;      # dijkophooghoogte bij MHW maatregel
#   MHWFactor = 1;        # factor op MHW, voor jaaps strategie
# DamFunctTbl = rundir\damfunction.tbl;  # Relation Land use and Damage function          
#    DEMterp = rundir\dem7.pcr; 	# DEM with ophoging terp
#    FltHouse = 0;        # als 1 dan nieuw gebouwde huizen worden drijvend
#        Terp = -1;       # als <ofgelijk 0 dan niets mee doen, als 1 dan alle nieuwe huizen op een terp zetten    
#    StHouse = 0;         # als 1 dan nieuw gebouwde huizen op palen
#     ShipTbl = rundir\shiptype3.tbl;    # suitability for shipping in relation to water depth
#      DEMriv = rundir\demriver3.pcr;    # dem with dredging
#  AlarmValue = 40;       # fragility value at which alarm to evacuate was set
#     Ophoog1 = 0;        # ophooghoogte voor dijkring1
#     Ophoog2 = 0;        # ophooghoogte voor dijkring2
#     Ophoog3 = 0;        # ophooghoogte voor dijkring3
#     Ophoog4 = 0;        # ophooghoogte voor dijkring4
#     Ophoog5 = 0;        # ophooghoogte voor dijkring5
#     OphoogQ = 0;        # dijkophogen om deze afvoer aan te kunnen,
#     FragTbl = rundir\FragTab01lsm.tbl; # Fragility curve of dykes
#    ImplDuur = 0;        # duur implementatie dijkophogen voor mhw     
#     DredgeQ = -1;       # minimal discharge shipping should be able to cop
# DredgeDepth = 0;        # depth to dredge at level of minimam discharge
# AlarmEdu = 0;           # education of people what to do in case of flood event --> less casualtiesf
     LandUseL1 = 0; 	  # Nieuw landgebruik op locatie 1, wonen = 1. huizen op palen=17, drijvende huizen = 19, recreatie =5, natuur = 8, kassen = 11, mount = 20
     LandUseL2 = 0; 	  # Nieuw landgebruik op locatie 2
     LandUseL3 = 0;	      # Nieuw landgebruik op locatie 3 
#
#### Input Variables #############################################################################
#   timebegin = 1;        # gaat via commandline
#    timeend = 25;        # gaat via commandline
# Enorme hack hier om te zorgen dat de runs vanuit excel parallel blijven lopen aan de runs uit de UI
   ClimScenS = 0$3;       # als 0 dan random trekking, klimaatscenario nummer 1-10 is no change, 11-20 = g, 21-30 = wplus
       DikeQ = -1;        # dijkophogen om deze afvoer aan te kunnen, als -1 dat niet meenemen
     SupDijk = -1;        # als -1 dan niets mee doen, als 1,2,3,4,5 dan bij die dijkring en als 100 dan overal

##### Input Maps #############################################################################
      DEMini = rundir\dem7.pcr;         # DEMini het huidige dem of het dem van de vorige tijdstap
     DEMScen = rundir\demscen.pcr;
   LandUse00 = rundir\Land00_2.pcr;
 LandUseScen = rundir\Land00_2.pcr;     # new landuse 
 LandUseScA = landuse\landuse;
    NaviArea = rundir\demriver3.pcr;    # dem i navigation area
        Case = rundir\case.pcr;         # casestudy gebied
    DikeVlak = rundir\dikevlak.pcr;
    DikeRing = rundir\dikeringsel3.pcr; # ordinal dijkringen bestand, zonder uiterwaarden
    DikeRtot = rundir\dikeringsel2.pcr; # dijkringen met uiterwaard = 0, alleen om uiterwaarden te laten overstromen
     AllDijk = rundir\alldijk1.pcr;
   Riverbln  = rundir\riverbln2.pcr;    # boolean mask 0 buiten 1 er binnen
     SoilSub = rundir\soilsub.pcr;      # bodemdaling m/jaar 
     Levq788 = rundir\levelsq788.pcr;   # waterstand langs waal bij afvoer 788 bij lobith
    Levq7150 = rundir\levelsq7150.pcr;
   Levq16000 = rundir\levelsq16000.pcr;
   Levq20000 = rundir\levelsq20000.pcr;
    PrimDijk = rundir\primdijk2.pcr;    # Locatie primaire dijken langs waallevels met dijkringnummers
     SeaDike = rundir\seadike2.pcr;     # Locatie sea dike
    LandLocs = rundir\lu_changes.pcr;   # Nieuw landgebruiklocaties
    

##### Input Tables #############################################################################
   FragTblSD = rundir\FragTab50lsmSD.tbl; # Fragility curve of dykes  klimaatdijken   
   MaxDamTbl = rundir\maxdam2000.tbl;  # Maximum damage per land use type van Karin
  DamFactTbl = rundir\damfact.tbl;     # Damage factor (0 - 1 depending on land use and water depth) van Karin


##### Input Time Series  #######################################################################                                    
    ClimQmax = rundir\ClimateQMax.tss; # Qmax bij transient klimaatscenarios G, W+ en no change
    ClimShip = rundir\ClimateShipping.tss; # aantal dagen dat bepaalde afvoer voorkomt
     ClimNat = rundir\ClimateNature.tss ;  # afvoer die 365, 150, 50 2 dagen per jaar wordt overschreden.
     RandomR = rundir\RandomReeks2z45.tss; 

##### Output maps ##############################################################################
      DEMt=rundir\demscen.pcr;
    ClimScen = rundir\climscenario.pcr;# Nummer getrokken klimaatscenario
         Dam = rundir\Damage;          # Damage in kEuro
      DEMnew = rundir\demnew;          # DEM
    FloodDpT = rundir\FloodDpT;        # Waterdiepte maximal van methode 2 en kans op doorbraak
     EcoZone = rundir\EcoZone;         # Ecozones 1=hoogwatervrij, 2=hardhout, 3 = zachthout, 4 = droogvallend, 5 = ondiep water, 6 = diep water
      DEMDif = rundir\DEMDif.pcr;      # verschil met ini dem en dem na maatregelen
     LandUse = rundir\Land00_2.pcr;         # landuse laten overschrijven. we doen aan het begin initialisatie LandScO.pcr; 
     LandScen = rundir\LandScen.pcr;
       Qcope = rundir\Qcope.pcr;       # Q die dijken aan kunnen

##### Output time series ############################################################################         
       Qmax = rundir\qmax.tss;        # Maximum discharge a year m3/s
      DQlt4 = rundir\dqlt4.tss;
      DQ4t6 = rundir\dq4t6.tss;
     DQ6t8  = rundir\dq6t8.tss;
    DQ8t10  = rundir\dq8t10.tss;
   DQ10t12  = rundir\dq10t12.tss;              
     DQgt12 = rundir\DQgt12.tss;
      FragT = rundir\FragT.tss;       # Fragility of dyke rings 1 very fragile, 0 not fragile
     AlarmT = rundir\Alarm.tss;       # Alarm given or not 0 or 1
   FloodSum = rundir\FloodSum.tss;    # Summary van overstroming in dijkring, flood = 1 no flooding = 0   
     Floods = rundir\FloodNumber.tss; # Numer of dikerings flooded
     DamSum = rundir\DamSumMeur.tss;  # Total damage study area in Million Euros
  DamRinSum = rundir\DamRingMeur.tss; # Damage per Dike Ring in Million Euros
   DamLuSum = rundir\DamLuMeur.tss;   # Damage per Land Use type in Million Euros
    DamStad = rundir\UrbanFldDikeRKm2.tss; # Urban area affected in km2 per dike ring
    UrbanAf = rundir\UrbanFldTotalkm2.tss; # total urban area affected in km2
    DamShip = rundir\DamShipProcent.tss;   # 100% is geen schade 10% is 10% van de tijd niet varen
    EcoArea = rundir\EcoArea.tss;     # area km2 of each ecozone
   EcoAreaT = rundir\EcoAreaT.tss;    # area km2 of each ecozone
   EcoIndex = rundir\EcoIndex.tss;
      Score = rundir\ScoreTotal.tss;
   ScoreSoc = rundir\ScoreSoc.tss;     
   ScoreEco = rundir\ScoreEco.tss;     
   ScoreEnv = rundir\ScoreEnv.tss;     
     ScoreF = rundir\ScoreFlood.tss;
     ScoreA = rundir\ScoreAlarm.tss;
     ScoreC = rundir\ScoreCity.tss;
     ScoreD = rundir\ScoreDamage.tss;
    ScoreDA = rundir\ScoreDamAgri.tss;
     ScoreS = rundir\ScoreShips.tss;
    ScoreDI = rundir\ScoreEDiversity.tss;
    ScoreEA = rundir\ScoreEcoArea.tss;
    ScoreFA = rundir\ScoreFalsAlarm.tss;
    ScoreLA = rundir\ScoreMissAlarm.tss; 
   ScoreFAT = rundir\ScoreFalsANum.tss;
   ScoreMAT = rundir\ScoreMissANum.tss;				 
      CostT = rundir\Costs.tss;                    		 
       QMHW = rundir\QMHW.tss;					 
    DikeOph = rundir\DikeOph.tss;	
     Qcope2 = rundir\qcope.tss;
     Casual = rundir\casual.tss;
     CasSum = rundir\cassum.tss;
  Implement = rundir\implement.tss;

################################################################################################
########## einde binding #######################################################################
################################################################################################

timer
# define time info, years starting with 1, depending on dt
$1 $2 1;
rep1 = 0,10,20,40;
rep2 = $2;


initial
        DEMini=if($1>1,DEMScen,DEMini);
        DEMlts = DEMini;          
        MHWcont = 0; #als 1 dan continu ophogen als 0 dan niet continue ophogen en dit alleen voor het begin doen.

################################################################################################
########## Pressures  Initialising #############################################################
################################################################################################

	ClimScen = if(ClimScenS>0,ClimScenS,(ordinal(30*mapuniform()))); #Random climate change scenario, opschalen naar 30 en afronden
        ClimScen = if(ClimScen == 0 , 1, ClimScen);
        SeaRise = if(ClimScen <11,0.001,if(ClimScen <21,0.006,0.0085));
        ClimScShip = scalar(ClimScen)*6;  #om reeks voor scheepvaart te selecteren
        ClimScNat = scalar(ClimScen)*4;  #om reeks voor natuur 
        CaseA = nominal(Case+1);
        SeaLevel = SeaDike*0;
        LandUse00=ordinal(LandUse00);
################################################################################################
################       Land use             ####################################################
################################################################################################

# drijvende woningen op plekken van nieuw stedelijk gebied landgebruik 17 maken, andere schade klasse
#        LandUse=if(LandUseScen!=LandUse00,LandUseScen,if(ordinal(LandUseRvR)!=LandUse00,ordinal(LandUseRvR),LandUse00)); 
        LandUse = if(LandUseScen!=LandUse00,LandUseScen);
        LandUse = if(LandUseScen==1,LandUseScen,ordinal(LandUseRvR));

######## compleet random en alles ten koste van landbouw ###################################
# 1-wonen, 5-dagrecreatie,6-werken,8-natuur,9-akkerbouw,11-glastuinbouw,13-infra,14-water,17-wonen op palen,18-dijken, net als grasland,19-nieuwe drijvende woningen
        unifmap = uniform(if(LandUse==9,boolean(1)));
        ordmap = order(unifmap);
        NewStadR = if (ordmap<=StadHa,ordinal(1));
        NewNatR = if((ordmap>StadHa)and(ordmap<=NatHa+StadHa),ordinal(8));
        NewRecreR = if((ordmap>StadHa+NatHa)and(ordmap<=NatHa+StadHa+RecreHa),ordinal(5));
        NewGlasR = if((ordmap>StadHa+NatHa+RecreHa)and(ordmap<=NatHa+StadHa+RecreHa+GlasbHa),ordinal(11));
        NewLandRandom = cover(NewStadR,NewNatR,NewGlasR,NewRecreR,LandUse);

######## aangroeien alles ten koste van landbouw ###########################################
        SprStad = spread(if(LandUse==1,1,0),0,1);
        SprStad2 =if((LandUse==9)and(SprStad<max(StadHa/2,200)),boolean(1));
        UniSpStad = order(uniform(SprStad2));
        NewStadS = if(UniSpStad<=StadHa,ordinal(1));
       
        SprNat = spread(if(LandUse==8,1,0),0,1);
        SprNat2 =if(((LandUse==9)or(LandUse==14))and(cover(NewStadS,0)!=1)and(SprNat<max(NatHa,300)),boolean(1));
        UniSpNat = order(uniform(SprNat2));
        NewNatS = if(UniSpNat<=NatHa,ordinal(8));
       
        SprRecr = spread(if(LandUse==5,1,0),0,1); #
        SprRecr2 =if((LandUse==9)and(cover(NewStadS,0)!=1)and(cover(NewNatS,0)!=8)and(SprRecr<=RecreHa*20),boolean(1));
        UniSpRecr = order(uniform(SprRecr2));
        NewRecrS = if(UniSpRecr<=RecreHa,ordinal(5));
       
        SprGlas = spread(if(LandUse==11,1,0),0,1);
        SprGlas2 =if((LandUse==9)and(cover(NewStadS,0)!=1)and(cover(NewNatS,0)!=8)and(cover(NewRecrS,0)!=5)and(SprGlas<=GlasbHa*20),boolean(1));
        UniSpGlas = order(uniform(SprGlas2));
        NewGlasS = if(UniSpGlas<=GlasbHa,ordinal(11));
        NewLandSpread = cover(NewStadS, NewNatS, NewRecrS, NewGlasS,LandUse);
 
        NewLandFin = if(roundoff(LandRnd)==1,NewLandRandom,NewLandSpread);
        LandUse = if((FltHouse==1)and(LandUse00!=1)and(NewLandFin==1),19,NewLandFin);
        LandUse = if((StHouse==1)and(LandUse00!=1)and(NewLandFin==1),17,NewLandFin);
        
######## ander landgebruik op een van de drie locaties ###################################
	LandL1 = if((LandUseL1>0)and(LandLocs==1),LandUseL1); 
	LandL2 = if((LandUseL2>0)and(LandLocs==2),LandUseL2); 
	LandL3 = if((LandUseL3>0)and(LandLocs==3),LandUseL3); 
	LandTmin1=LandUse00;	

	LandUse = cover(LandL1,LandL2,LandL3,LandUse);
report LandScen = LandUse;

################################################################################################        
############### River levels QH relation #######################################################
################################################################################################
        Fact788 = if(RvR==3,scalar(1),if(RvR==2,scalar(1),if(RvR==1,scalar(1),if(RvR==4,0.9,1))));       
        Fact7150 = if(RvR==3,scalar(0.91),if(RvR==2,scalar(1),if(RvR==1,scalar(1),if(RvR==4,0.95,1))));
	Fact16000 = if(RvR==3,scalar(0.8),if(RvR==2,scalar(0.9),if(RvR==1,scalar(0.94),if(RvR==4,1,1))));
	Fact20000 = if(RvR==3,scalar(0.76),if(RvR==2,scalar(0.86),if(RvR==1,scalar(0.9),if(RvR==4,1,1)))); 
	Dif_2 = (Levq7150*Fact7150)-(Levq788*Fact788);
	Dif_6 = (Levq16000*Fact16000)-(Levq7150*Fact7150);
	Dif_7 = (Levq20000*Fact20000)-(Levq16000*Fact16000);

################################################################################################
########       Dredging for shipping        ####################################################
################################################################################################

        minQLob = if(DredgeQ==-1,100000,DredgeQ); 
        QHrelS = if(minQLob<788,scalar(1),if(minQLob<7150,scalar(2),if(minQLob<16000,6,if(minQLob<20000,7,8))));
        Lev1S = if(QHrelS==1,((Levq788*Fact788)-((Levq788*Fact788)*((788-minQLob)/788))),0);
        Lev2S = if(QHrelS==2,((Levq7150)-(Dif_2*((7150-minQLob)/6362))),0);
        Lev6S = if(QHrelS==6,((Levq16000*Fact16000)-(Dif_6*((16000-minQLob)/8850))),0);
        Lev7S = if(QHrelS==7,((Levq20000*Fact20000)-(Dif_7*((20000-minQLob)/4000))),0);
        Lev8S = if(QHrelS==8,(Levq20000*Fact20000)+((minQLob-20000)*0.00005),0);
        MaxLevelS = Lev1S+Lev2S+Lev6S+Lev7S+Lev8S;
        LevcovS = cover(MaxLevelS,Case);
        SurfS = scalar(spreadzone(nominal(LevcovS*100),0,1))/100; #waterlevel spread
        PotFld = if(DEMini < SurfS then ordinal(1));
        Surf2S = areamaximum((if((DEMini < SurfS)and (cover(PrimDijk,0)>0) then SurfS)),ordinal(DikeRtot)); # max waterstand op dijk, overschatting door secundaire dijken
        PotFld2S = if(DEMini < Surf2S then ordinal(1));#mogelijk overstroomd door max waterstand over dijk
        PotFldA2S = scalar(clump(PotFld2S));
        Flooded2S = areamaximum(ordinal(Riverbln),nominal(PotFldA2S)) eq 1;
        FloodDp2S = cover(if(Flooded2S,((0.8*Surf2S)-DEMini)),if(DikeRtot==0,SurfS-DEMini));
        Surftmp4S = if((spread(nominal(cover(Surf2S,0)*100),0,1)<200),scalar(1)); #waterlevel spread
        Surf4S = 0.8*areaminimum(Surftmp4S*(scalar(spreadzone(nominal(cover(Surf2S,0)*100),0,1))/100),ordinal(DikeRtot)); #waterlevel spread
        PotFldA4S = scalar(clump(if(DEMini < Surf4S then ordinal(1))));#mogelijk overstroomd door max waterstand over dijk
        Flooded4S = areamaximum(ordinal(cover(Flooded2S,0)),nominal(PotFldA4S)) eq 1;
        FloodDp4S = cover(if((Flooded2S)and(0.8*Surf2S-DEMini)>0,0.8*Surf2S-DEMini),if((DikeRtot==0)and(SurfS-DEMini>0),SurfS-DEMini),if((Flooded4S)and(Surf4S-DEMini>0),Surf4S-DEMini));
        
        # Dredge diepte m bij afvoer DredgeQ
        DEMQmin = if((DEMini>-100)and(FloodDp4S<DredgeDepth)and(NaviArea<0),SurfS-DredgeDepth, DEMini);  

################################################################################################        
##########  Raise embankments  #################################################################
################################################################################################        
        QHrelF = if(OphoogQ<788,scalar(1),if(OphoogQ<7150,scalar(2),if(OphoogQ<16000,6,if(OphoogQ<20000,7,8))));
        Lev1F = if(QHrelF==1,((Levq788*Fact788)-((Levq788*Fact788)*((788-OphoogQ)/788))),0);
        Lev2F = if(QHrelF==2,((Levq7150)-(Dif_2*((7150-OphoogQ)/6362))),0);
        Lev6F = if(QHrelF==6,((Levq16000*Fact16000)-(Dif_6*((16000-OphoogQ)/8850))),0);
        Lev7F = if(QHrelF==7,((Levq20000*Fact20000)-(Dif_7*((20000-OphoogQ)/4000))),0);
        Lev8F = if(QHrelF==8,(Levq20000*Fact20000)+(0.00005*(OphoogQ-20000)),0);
        MaxLevelF = Lev1F+Lev2F+Lev6F+Lev7F+Lev8F;
        LevcovF = cover(MaxLevelF,Case);
        SurfF = scalar(spreadzone(nominal(LevcovF*100),0,1))/100; #waterlevel spread

        # dem verhogen om afvoer X te aan te kunnen,halve meter er op
        DEMQmax = cover(if((DEMini<(SurfF+0.5))and(cover(PrimDijk,0)>0)then((PrimDijk*0+1)*(SurfF+0.5))),DEMini);

        # alleen bij dijkring 1,2,3,4 en 5! als 0 dan geen dijkringophoging als 100 dan overal, 0 of kleiner dan geen ophoging
        DEMOphoog = cover(if(PrimDijk==1,DEMini+Ophoog1,if(PrimDijk==2,DEMini+Ophoog2,if(PrimDijk==3,DEMini+Ophoog3,if(PrimDijk==4,DEMini+Ophoog4,if(PrimDijk==5,DEMini+Ophoog5))))),DEMini);     
        # oude formule DEMOphoog = cover(if(DijkrOph <= 0,DEMini,(if(DijkrOph==100,DEMini+Ophoog,(if(PrimDijk==DijkrOph,DEMini+Ophoog))))),DEMini); 
       
        # dem ophogen met 4 m op plekken van nieuw stedelijk gebied

        DEMtrptmp = cover(if(Terp>0,(if((LandTmin1!=1)and(LandScen==1),DEMini+4,DEMini))),DEMini); 
	DEMtrpLoc = if((LandTmin1!=20)and(LandScen==20),DEMini+4,DEMini); 
        DEMTerpN = max(DEMtrptmp,DEMtrpLoc,DEMterp);
        
        # klimaatdijken
        tmp10=if(DikeRing>0,scalar(1));
        tmp11= DikeVlak*tmp10*scalar(if(spread(cover(nominal(PrimDijk),0),0,1)<1000,ordinal(1),0));
        primsupdijk = if(tmp11>0,tmp11);
        tmp12 = if(PrimDijk>0,DEMini);
        tmp13 = scalar(spreadzone(cover(ordinal(tmp12*100),0),0,1))/100; 
        SupDijkAll = cover(max(if(tmp11>0,tmp13),DEMini),DEMini);
        DEMSupdijk=cover(if(SupDijk==tmp11,SupDijkAll,if(SupDijk==100,SupDijkAll,DEMini)),DEMini);

################################################################################################        
########## Prepare DEM #########################################################################
################################################################################################        
             
        DEMtmp = max(DEMini,DEMQmax,DEMOphoog,DEMTerpN,DEMSupdijk,DEMdijk); # combineren van verschillende buitendijkse dem
        DEMnewM = cover(if((DredgeQ>0)and(NaviArea<=0),DEMQmin,(if(NaviArea<=0,DEMriv,DEMtmp))),DEMtmp);
	DEMDif = DEMnewM-DEMini; #DEMscendif.pcr
        #DEMnew = DEMtmp;
        DEMnew = DEMnewM;
         
################################################################################################        
########## Coping Discharge ####################################################################
################################################################################################
        DEMNorth=if((PrimDijk<4)and(PrimDijk>0),DEMnew-0.5,0); #dijkhoogte nemen van de noordkant
        LevDikeN= scalar(spreadzone(nominal(DEMNorth*10000),0,1))/10000; #spread dijkhoogte
 
        LevDikeF = if(LevDikeN<Levq788*Fact788,scalar(1),if(LevDikeN<Levq7150,scalar(2),if(LevDikeN<Levq16000,6,if(LevDikeN<Levq20000,7,8))));
        Lev1F = if(LevDikeF==1,788-((Levq788*Fact788-LevDikeN)*788));
        Lev2F = if(LevDikeF==2,7150-(((Levq7150*Fact7150-LevDikeN)/Dif_2)*6362));
        Lev6F = if(LevDikeF==6,16000-(((Levq16000*Fact16000-LevDikeN)/Dif_6)*8850));
        Lev7F = if(LevDikeF==7,20000-(((Levq20000*Fact20000-LevDikeN)/Dif_7)*4000));
        Lev8F = if(LevDikeF==8,20000+(LevDikeN-Levq20000*Fact20000)/0.00005);
   
        DEMSouth=if(PrimDijk>3,DEMnew-0.5,0); #dijkhoogte nemen van de zuidkant
        LevDikeS= scalar(spreadzone(nominal(DEMSouth*10000),0,1))/100; #spread dijkhoogte

        LevDikeFS = if(LevDikeS<Levq788,scalar(1),if(LevDikeS<Levq7150,scalar(2),if(LevDikeS<Levq16000,6,if(LevDikeS<Levq20000,7,8))));
        Lev1FS = if(LevDikeFS==1,788-((Levq788*Fact788-LevDikeS)*788));
        Lev2FS = if(LevDikeFS==2,7150-(((Levq7150*Fact7150-LevDikeS)/Dif_2)*6362));
        Lev6FS = if(LevDikeFS==6,16000-(((Levq16000*Fact16000-LevDikeS)/Dif_6)*8850));
        Lev7FS = if(LevDikeFS==7,20000-(((Levq20000*Fact20000-LevDikeS)/Dif_7)*4000));
        Lev8FS = if(LevDikeFS==8,20000+(LevDikeS-Levq20000*Fact20000)/0.00005); 
        QcopeN = areaminimum(cover(Lev1F,Lev2F,Lev6F,Lev7F,Lev8F),nominal(Case));
        QcopeS = areaminimum(cover(Lev1FS,Lev2FS,Lev6FS,Lev7FS,Lev8FS),nominal(Case));
        Qcope = min(QcopeN,QcopeS); 
         
         
################################################################################################        
########## Shipping suitability at different Qs ################################################
################################################################################################        
        LevQlt4 = ((Levq788*Fact788)-((Levq788*Fact788)*0.492));                           # level bij 400 m3/s
        DepQlt4 = if(Riverbln,if((LevQlt4-DEMnewM)>0,(LevQlt4-DEMnewM)));    # diepte bij 400 m3/s
        Shiplt4 = lookupscalar(ShipTbl,areaminimum(DepQlt4,Riverbln));     # ?scheepvaart suitability mogelijkheid om te varen
        LevQ4t6 = ((Levq788*Fact788)-((Levq788*Fact788)*0.365));
        DepQ4t6 = if(Riverbln,if((LevQ4t6-DEMnewM)>0,(LevQ4t6-DEMnewM)));
        Ship4t6 = lookupscalar(ShipTbl,areaminimum(DepQ4t6,Riverbln));
        LevQ6t8 = ((Levq788*Fact788)-((Levq788*Fact788)*0.112));
        DepQ6t8 = if(Riverbln,if((LevQ6t8-DEMnewM)>0,(LevQ6t8-DEMnewM)));
        Ship6t8 = lookupscalar(ShipTbl,areaminimum(DepQ6t8,Riverbln));
        LevQ8t10 = ((Levq7150*Fact7150)-(Dif_2*0.982));
        DepQ8t10 = if(Riverbln,if((LevQ8t10-DEMnewM)>0,(LevQ8t10-DEMnewM)));
        Ship8t10 = lookupscalar(ShipTbl,areaminimum(DepQ8t10,Riverbln));
        LevQ10t12 = ((Levq7150*Fact7150)-(Dif_2*0.951));
        DepQ10t12 = if(Riverbln,if((LevQ10t12-DEMnewM)>0,(LevQ10t12-DEMnewM)));
        Ship10t12 = lookupscalar(ShipTbl,areaminimum(DepQ10t12,Riverbln));

################################################################################################
########  Dynamic deel           ###############################################################
################################################################################################        

dynamic

# als implduur gelijk aan de tijd dan nieuwe DEM uit maatregelen nemen. Als DEM als is aangepast door aanpassingen aan MHW moet hier nog mee vergeleken worden
# als die MHWaangepaste DEMnew>DEMnewMaatregel op de plek van primaire dijken dan moet dat DEM worden genoemen. In de andere situaties DEMnew

       LandUseI = timeinput(LandUseScA);
       LandUseT = if((FltHouse==1)and(LandUse00!=1)and(LandUseI==1),19,LandUseI);
report LandUse = if((StHouse==1)and(LandUse00!=1)and(LandUseT==1),17,LandUseT);

################################################################################################
########  Calculate water levels ###############################################################
################################################################################################        
        CheckLev = (DEMnew-0.5);    
report  Qmax = min(maxQLob,(timeinputscalar(ClimQmax,ClimScen))); #Take the timeserie of this scenario 
#       Qmax = 20000;
        QHrel = if(Qmax<788,scalar(1),if(Qmax<7150,scalar(2),if(Qmax<16000,6,if(Qmax<20000,7,8))));
        Lev1 = if(QHrel==1,((Levq788*Fact788)-((Levq788*Fact788)*((788-Qmax)/788))),0);
        Lev2 = if(QHrel==2,((Levq7150*Fact7150)-(Dif_2*((7150-Qmax)/6362))),0);
        Lev6 = if(QHrel==6,((Levq16000*Fact16000)-(Dif_6*((16000-Qmax)/8850))),0);
        Lev7 = if(QHrel==7,((Levq20000*Fact20000)-(Dif_7*((20000-Qmax)/4000))),0);
        Lev8 = if(QHrel==8,(Levq20000*Fact20000)+(0.00005*(Qmax-20000)),0); ## nog aanpassen per 1000 m3 nog 5 cm erbij
        MaxLevel = Lev1+Lev2+Lev6+Lev7+Lev8;
        Levcov = cover(MaxLevel,Case);
        Surf = scalar(spreadzone(nominal(Levcov*100),0,1))/100; #waterlevel spread

################################################################################################
########       Flooding        #################################################################
################################################################################################
        PotFld = if(DEMnew < Surf then ordinal(1));
        Surf2 = areamaximum((if((DEMnew < Surf)and (cover(PrimDijk,0)>0) then Surf)),ordinal(DikeRtot)); # max waterstand op dijk, overschatting door secundaire dijken
        PotFld2 = if(DEMnew < Surf2 then ordinal(1));#mogelijk overstroomd door max waterstand over dijk
        PotFldA2 = scalar(clump(PotFld2));
        Flooded2 = areamaximum(ordinal(Riverbln),nominal(PotFldA2)) eq 1;
        FloodDp2 = cover(if(Flooded2,((0.8*Surf2)-DEMnew)),if(DikeRtot==0,Surf-DEMnew));
        Surftmp4 = if((spread(nominal(cover(Surf2,0)*100),0,1)<200),scalar(1)); 
        #waterlevel spread om te kijken of aangeloten gebieden overstromen, de waterstand is dan nog maar 80% van oorspronkelijek
        Surf4 = 0.8*areaminimum(Surftmp4*(scalar(spreadzone(nominal(cover(Surf2,0)*100),0,1))/100),ordinal(DikeRtot)); #waterlevel spread
        PotFldA4 = scalar(clump(if(DEMnew < Surf4 then ordinal(1))));#mogelijk overstroomd door max waterstand over dijk
        Flooded4 = areamaximum(ordinal(cover(Flooded2,0)),nominal(PotFldA4)) eq 1;
        FloodDp4 = cover(if((Flooded2)and(0.8*Surf2-DEMnew)>0,0.8*Surf2-DEMnew),if((DikeRtot==0)and(Surf-DEMnew>0),Surf-DEMnew),if((Flooded4)and(Surf4-DEMnew>0),Surf4-DEMnew));

################################################################################################
########   Dyke fragility and Alarm to evacuate   ############################################## 
################################################################################################
        TmpFragD =if(PrimDijk>0,(Surf-CheckLev)); #dijkringenkaart met maximale kans op falen
        TmpFrTbl = lookupscalar(FragTbl,TmpFragD);
        FragDike = areamaximum((lookupscalar(FragTbl,TmpFragD)),DikeRing);#dijkringenkaart met maximale kans op falen
        ##########a Alarm waarde ##########
        Alarm = areamaximum((if((lookupscalar(FragTbl,TmpFragD))>AlarmValue/100,scalar(1),0)),DikeRing);#subjectieve beslissing om te evacueren bij bepaalde waterstand onder toetspeil 
report  FragT = timeoutput (DikeRing,cover(FragDike*100,0));#kans op doorbraak
report  AlarmT = timeoutput (DikeRing,cover(Alarm,0)); # alarm of niet
#        KansDoBr = mapuniform(); # random trekking kans op doorbraak
KansDoBr = timeinputscalar(RandomR,1);
        Doorbraak = if (KansDoBr<FragDike,scalar(1),0); #als kans kleiner is dan kans op doorbraak dan doorbraak anders niet
        LevelDB = if((Doorbraak==1)and(FragDike==TmpFrTbl),Surf); #maxwaterpeil van doorbraak
        SurfDB= areamaximum(LevelDB,DikeRing);    #max peil binnen een dijkring
        PotFld3 = if((DEMnew < SurfDB) then ordinal(1));
        PotFldA3 = scalar(clump(PotFld3));
        FloodDp3 = cover(if((PotFldA3>0)and(0.8*SurfDB-DEMnew>0),0.8*SurfDB-DEMnew),if((DikeRtot==0)and(Surf-DEMnew>0),Surf-DEMnew));
	FloodDpT = if((max(cover(FloodDp3,0),cover(FloodDp4,0)))>0,(max(cover(FloodDp3,0),cover(FloodDp4,0))));
report  FloodSum = timeoutput(DikeRing,(cover((if((areamaximum(FloodDpT,DikeRing))>0,nominal(1),0)),nominal(scalar(DikeRing)*0))));
        FloodDR = areamaximum((if(cover(FloodDpT,0)>0,scalar(1),0)),DikeRing);

################################################################################################
########   Casualties                         ##################################################
################################################################################################

        CasTmp = if((Alarm==0)and(FloodDpT>1)and(FloodDpT<2)and(LandUse<=3),16*0.05*(FloodDpT-1),if((FloodDpT>2)and(Alarm==0)and(LandUse<=3),16*0.1,0));
        CasTmp2 = if((Alarm==1)and(FloodDpT>1)and(FloodDpT<2)and(LandUse<=3),16*0.001*(FloodDpT-1),if((FloodDpT>2)and(Alarm==1)and(LandUse<=3),0.01*16,0));
        CasTmp3 = if(CasTmp>0,CasTmp*0.5,if(AlarmEdu==1,CasTmp2*0.01*0.5,CasTmp2*0.5));
report  Casual = timeoutput(DikeRing, (areatotal(CasTmp3,DikeRing)));
report  CasSum = timeoutput(CaseA,(areatotal(CasTmp3,CaseA)));
#geen alarm en een overstroming en stad
################################################################################################
########   Damage to houses and agriculture   ##################################################
################################################################################################
        DamFunct = lookupscalar(DamFunctTbl,LandUse); # Relate landuse with damage functions
        MaxDam = lookupscalar(MaxDamTbl,LandUse); # Max damaage per landuse
        DamFact = lookupscalar (DamFactTbl,FloodDpT,DamFunct); #Damage Factor (1-suitability), afhankelijk van functie en waterdiepte
        Dam = if(DikeRtot>0,(cover((DamFact * MaxDam),Case)),0);
        DamRing = areatotal(Dam,DikeRing);
        DamTot = areatotal(Dam,nominal(Case));
        DamLu = areatotal(Dam,nominal(LandUse));
        DamStadK = areatotal(if((LandUse<=3)and(Dam>0), scalar(0.01),0),nominal(Case)); #0.01 vanweg km2
        DamAgriK = areatotal(if((LandUse>8)and(LandUse<13)and(Dam>0), Dam,0),nominal(Case));         
report  DamStad = timeoutput (DikeRing,(areatotal(if((LandUse <= 3)and(Dam>0), scalar(0.01)),DikeRing))); 
report  UrbanAf = timeoutput(CaseA,roundoff(DamStadK));
report  DamSum = timeoutput(CaseA,roundoff(DamTot));
report  DamRinSum = timeoutput(DikeRing,roundoff(DamRing));  
report  DamLuSum = timeoutput(LandUse,roundoff(DamLu));

################################################################################################
########   Shipping Time available for navigation  #############################################
################################################################################################        
report        DQlt4 = timeinputscalar(ClimShip,ordinal(ClimScShip-5));    # number of days <400 m3/s Take the timeserie of this scenario
report        DQ4t6 = timeinputscalar(ClimShip,ordinal(ClimScShip-4));    # number of days between 400 - 600 m3/s
report        DQ6t8 = timeinputscalar(ClimShip,ordinal(ClimScShip-3));    # 600 - 800 m3/s
report        DQ8t10 = timeinputscalar(ClimShip,ordinal(ClimScShip-2));   # 800 - 1000 m3/s
report        DQ10t12 = timeinputscalar(ClimShip,ordinal(ClimScShip-1));  # 1000 - 1200 m3/s
report        DQgt12 = timeinputscalar(ClimShip,ordinal(ClimScShip));     # >1200 m3/s    
report  DamShip = timeoutput(Riverbln,roundoff(100-((DQlt4*Shiplt4+DQ4t6*Ship4t6+DQ6t8*Ship6t8+DQ8t10*Ship8t10+DQ10t12*Ship10t12+DQgt12)/3.66)));
        DamShipK = 100-((DQlt4*Shiplt4+DQ4t6*Ship4t6+DQ6t8*Ship6t8+DQ8t10*Ship8t10+DQ10t12*Ship10t12+DQgt12)/3.66);

################################################################################################
########   Nature   ############################################################################
################################################################################################        
        Q365 = timeinputscalar(ClimNat,ordinal(ClimScNat-3));       #discharge 364 dagen/jaar overschreden
        Q150 = timeinputscalar(ClimNat,ordinal(ClimScNat-2));       #discharge 150 dagen/jaar overschreden
        Q50 = timeinputscalar(ClimNat,ordinal(ClimScNat-1));        #discharge 50 dagen/jaar overschreden
        Q2 = timeinputscalar(ClimNat,ordinal(ClimScNat));           #discharge 2 dagen/jaar overschreden
        ##
        QHrel = if(Q365<788,scalar(1),if(Q365<7150,scalar(2),if(Q365<16000,6,if(Q365<20000,7,8))));
        Lev1 = if(QHrel==1,((Levq788*Fact788)-((Levq788*Fact788)*((788-Q365)/788))),0);
        Lev2 = if(QHrel==2,((Levq7150)-(Dif_2*((7150-Q365)/6362))),0);
        Lev6 = if(QHrel==6,((Levq16000*Fact16000)-(Dif_6*((16000-Q365)/8850))),0);
        Lev7 = if(QHrel==7,((Levq20000*Fact20000)-(Dif_7*((20000-Q365)/4000))),0);
        Lev8 = if(QHrel==8,(Levq20000*Fact20000)+(0.00005*(Q365-20000)),0);
        MaxLevel.pcr = Lev1+Lev2+Lev6+Lev7+Lev8;
        Levcov = cover(MaxLevel.pcr,Case);
        Surf365 = scalar(spreadzone(nominal(Levcov*100),0,1))/100;
        ##
        QHrel = if(Q150<788,scalar(1),if(Q150<7150,scalar(2),if(Q150<16000,6,if(Q150<20000,7,8))));
        Lev1 = if(QHrel==1,((Levq788*Fact788)-((Levq788*Fact788)*((788-Q365)/788))),0);
        Lev2 = if(QHrel==2,((Levq7150)-(Dif_2*((7150-Q365)/6362))),0);
        Lev6 = if(QHrel==6,((Levq16000*Fact16000)-(Dif_6*((16000-Q365)/8850))),0);
        Lev7 = if(QHrel==7,((Levq20000*Fact20000)-(Dif_7*((20000-Q365)/4000))),0);
        Lev8 = if(QHrel==8,(Levq20000*Fact20000)+(0.00005*(Q150-20000)),0);
        MaxLevel.pcr = Lev1+Lev2+Lev6+Lev7+Lev8;
        Levcov = cover(MaxLevel.pcr,Case);
        Surf150 = scalar(spreadzone(nominal(Levcov*100),0,1))/100;
        ##
        QHrel = if(Q50<788,scalar(1),if(Q50<7150,scalar(2),if(Q50<16000,6,if(Q50<20000,7,8))));
        Lev1 = if(QHrel==1,((Levq788*Fact788)-((Levq788*Fact788)*((788-Q365)/788))),0);
        Lev2 = if(QHrel==2,((Levq7150)-(Dif_2*((2150-Q365)/6362))),0);
        Lev6 = if(QHrel==6,((Levq16000*Fact16000)-(Dif_6*((16000-Q365)/8850))),0);
        Lev7 = if(QHrel==7,((Levq20000*Fact20000)-(Dif_7*((20000-Q365)/4000))),0);
        Lev8 = if(QHrel==8,(Levq20000*Fact20000)+(0.00005*(Q50-20000)),0);
        MaxLevel.pcr = Lev1+Lev2+Lev6+Lev7+Lev8;
        Levcov = cover(MaxLevel.pcr,Case);
        Surf50 = scalar(spreadzone(nominal(Levcov*100),0,1))/100;
        ##
        QHrel = if(Q2<788,scalar(1),if(Q2<2150,scalar(2),if(Q2<16000,6,if(Q2<20000,7,8))));
        Lev1 = if(QHrel==1,((Levq788*Fact788)-((Levq788*Fact788)*((788-Q365)/788))),0);
        Lev2 = if(QHrel==2,((Levq7150)-(Dif_2*((7150-Q365)/6362))),0);
        Lev6 = if(QHrel==6,((Levq16000*Fact16000)-(Dif_6*((16000-Q365)/8850))),0);
        Lev7 = if(QHrel==7,((Levq20000*Fact20000)-(Dif_7*((20000-Q365)/4000))),0);
        Lev8 = if(QHrel==8,(Levq20000*Fact20000)+(0.00005*(Q2-20000)),0);
        MaxLevel.pcr = Lev1+Lev2+Lev6+Lev7+Lev8;
        Levcov = cover(MaxLevel.pcr,Case);
        Surf2 = scalar(spreadzone(nominal(Levcov*100),0,1))/100;
        ##
        EcoZoneS = if(DEMnew>Surf2,scalar(1),(if(DEMnew>Surf50,2,(if(DEMnew>Surf150,3,(if(DEMnew>Surf365,4,(if(Surf365-DEMnew<3,5,6)))))))));
        EcoZone = if(DikeRtot ge 0, (if((LandUse==8) or (LandUse ==14),ordinal(EcoZoneS),0))); #1=hoogwatervrij, 2=hardhout, 3 = zachthout, 4 = droogvallend, 5 = ondiep water, 6 = diep water
report  EcoArea = timeoutput(EcoZone, roundoff(areaarea(EcoZone)/1000000));
        Eco = if((LandUse==8) or (LandUse ==14),nominal(1));
        EcoAmap = areamaximum(if(Eco==1,areaarea(Eco)/1000000),CaseA);
report  EcoAreaT = timeoutput(nominal(cover(Case,0)+1),roundoff(EcoAmap)); 
# weging*min(1,(oppervlak ecotoop/(totale oppervlak/6))
        EcoHW = 1*min(1,(areamaximum(if(EcoZone==1,areaarea(EcoZone)/1000000),CaseA)/(EcoAmap/6)));
        EcoHH = 6*min(1,(areamaximum(if(EcoZone==2,areaarea(EcoZone)/1000000),CaseA)/(EcoAmap/6)));
        EcoZH = 4*min(1,(areamaximum(if(EcoZone==3,areaarea(EcoZone)/1000000),CaseA)/(EcoAmap/6)));
        EcoDZ = 5*min(1,(areamaximum(if(EcoZone==4,areaarea(EcoZone)/1000000),CaseA)/(EcoAmap/6)));
        EcoWW = 3*min(1,(areamaximum(if(EcoZone==5,areaarea(EcoZone)/1000000),CaseA)/(EcoAmap/6)));
        EcoWZ = 2*min(1,(areamaximum(if(EcoZone==6,areaarea(EcoZone)/1000000),CaseA)/(EcoAmap/6)));
#1: < 2, dagen/jaar --> hoogwatervrije zone 
#2: 2 - 50 dagen/jaar --> hardhoutzone
#3: 50 -150 dagen/jaar --> zachthoutzone
#4: 150 - 364 dagen/jaar --> droog vallende zone
#5: >364 dagen per jaar altijd onder water --> als < 3 m dan waterplanten
#6: >364 dagen per jaar altijd onder water --> als > 3 m dan waterplanten

################################################################################################
########   Evaluation  ############################################################################
################################################################################################        
       FloodDR1 = areamaximum((if((cover(FloodDpT,0)>0)and(DikeRtot==1),scalar(1),0)),CaseA);
       FloodDR2 = areamaximum((if((cover(FloodDpT,0)>0)and(DikeRtot==2),scalar(1),0)),CaseA);
       FloodDR3 = areamaximum((if((cover(FloodDpT,0)>0)and(DikeRtot==3),scalar(1),0)),CaseA);
       FloodDR4 = areamaximum((if((cover(FloodDpT,0)>0)and(DikeRtot==4),scalar(1),0)),CaseA);
       FloodDR5 = areamaximum((if((cover(FloodDpT,0)>0)and(DikeRtot==5),scalar(1),0)),CaseA);
       FloodDR6 = areamaximum((if((cover(FloodDpT,0)>0)and(DikeRtot==6),scalar(1),0)),CaseA);
       FloodDR7 = areamaximum((if((cover(FloodDpT,0)>0)and(DikeRtot==7),scalar(1),0)),CaseA);
       FloodDR8 = areamaximum((if((cover(FloodDpT,0)>0)and(DikeRtot==8),scalar(1),0)),CaseA);
       FloodDR9 = areamaximum((if((cover(FloodDpT,0)>0)and(DikeRtot==9),scalar(1),0)),CaseA);
       FloodDR10 = areamaximum((if((cover(FloodDpT,0)>0)and(DikeRtot==10),scalar(1),0)),CaseA);
       FloodDR11 = areamaximum((if((cover(FloodDpT,0)>0)and(DikeRtot==11),scalar(1),0)),CaseA);
       FloodDR12 = areamaximum((if((cover(FloodDpT,0)>0)and(DikeRtot==12),scalar(1),0)),CaseA);    
       FldNum = FloodDR1+FloodDR2+FloodDR3+FloodDR4+FloodDR5+FloodDR6+FloodDR7+FloodDR8+FloodDR9+FloodDR10+FloodDR11+FloodDR12;
       FloodIx = 1-(FldNum/mapmaximum(scalar(DikeRing)));
report Floods =timeoutput(CaseA,FldNum);
       DamIx = min(1,(3578-DamTot)/(3578-150));
       DamAgIx = min(1,(111-DamAgriK)/(111-20));
       StadIx = min(1,(3.54-DamStadK)/(3.54-0.2)); # area flooded
       StadNIx= if(DamStadK>0,scalar(0),1); # number of times flooded
       ShipIx = areamaximum(min(1,(DamShipK/98)),CaseA);
       EcoDIx = (cover(EcoHW,0)+cover(EcoHH,0)+cover(EcoZH,0)+cover(EcoDZ,0)+cover(EcoWW,0)+cover(EcoWZ,0))/15;
       EcoIndex = timeoutput(CaseA,100*EcoDIx);  #diversity index
       EcoAIx = min(1,(EcoAmap/20)); # area index
       FalseDr1 = areamaximum((cover(if((Alarm==1)and(FloodDpT<0)and(DikeRtot==1),scalar(1),0),0)),CaseA);
       FalseDr2 = areamaximum((cover(if((Alarm==1)and(FloodDpT<0)and(DikeRtot==2),scalar(1),0),0)),CaseA);
       FalseDr3 = areamaximum((cover(if((Alarm==1)and(FloodDpT<0)and(DikeRtot==3),scalar(1),0),0)),CaseA);
       FalseDr4 = areamaximum((cover(if((Alarm==1)and(FloodDpT<0)and(DikeRtot==4),scalar(1),0),0)),CaseA);
       FalseDr5 = areamaximum((cover(if((Alarm==1)and(FloodDpT<0)and(DikeRtot==5),scalar(1),0),0)),CaseA);
       FalseDr6 = areamaximum((cover(if((Alarm==1)and(FloodDpT<0)and(DikeRtot==6),scalar(1),0),0)),CaseA);
       FalseDr7 = areamaximum((cover(if((Alarm==1)and(FloodDpT<0)and(DikeRtot==7),scalar(1),0),0)),CaseA);
       FalseDr8 = areamaximum((cover(if((Alarm==1)and(FloodDpT<0)and(DikeRtot==8),scalar(1),0),0)),CaseA);
       FalseDr9 = areamaximum((cover(if((Alarm==1)and(FloodDpT<0)and(DikeRtot==9),scalar(1),0),0)),CaseA);
       FalseDr10 = areamaximum((cover(if((Alarm==1)and(FloodDpT<0)and(DikeRtot==10),scalar(1),0),0)),CaseA);
       FalseDr11 = areamaximum((cover(if((Alarm==1)and(FloodDpT<0)and(DikeRtot==11),scalar(1),0),0)),CaseA);
       FalseDr12 = areamaximum((cover(if((Alarm==1)and(FloodDpT<0)and(DikeRtot==12),scalar(1),0),0)),CaseA);
       FalseNIx = min(1,((5-(FalseDr1+FalseDr2+FalseDr3+FalseDr4+FalseDr5+FalseDr6+FalseDr7+FalseDr8+FalseDr9+FalseDr10+FalseDr11+FalseDr12))/5));
       MissDr1 = areamaximum((cover(if((cover(Alarm,0)==0)and(FloodDpT>0)and(DikeRtot==1),scalar(1),0),0)),CaseA);
       MissDr2 = areamaximum((cover(if((cover(Alarm,0)==0)and(FloodDpT>0)and(DikeRtot==2),scalar(1),0),0)),CaseA);
       MissDr3 = areamaximum((cover(if((cover(Alarm,0)==0)and(FloodDpT>0)and(DikeRtot==3),scalar(1),0),0)),CaseA);
       MissDr4 = areamaximum((cover(if((cover(Alarm,0)==0)and(FloodDpT>0)and(DikeRtot==4),scalar(1),0),0)),CaseA);
       MissDr5 = areamaximum((cover(if((cover(Alarm,0)==0)and(FloodDpT>0)and(DikeRtot==5),scalar(1),0),0)),CaseA);
       MissDr6 = areamaximum((cover(if((cover(Alarm,0)==0)and(FloodDpT>0)and(DikeRtot==6),scalar(1),0),0)),CaseA);
       MissDr7 = areamaximum((cover(if((cover(Alarm,0)==0)and(FloodDpT>0)and(DikeRtot==7),scalar(1),0),0)),CaseA);
       MissDr8 = areamaximum((cover(if((cover(Alarm,0)==0)and(FloodDpT>0)and(DikeRtot==8),scalar(1),0),0)),CaseA);
       MissDr9 = areamaximum((cover(if((cover(Alarm,0)==0)and(FloodDpT>0)and(DikeRtot==9),scalar(1),0),0)),CaseA);
       MissDr10 = areamaximum((cover(if((cover(Alarm,0)==0)and(FloodDpT>0)and(DikeRtot==10),scalar(1),0),0)),CaseA);
       MissDr11 = areamaximum((cover(if((cover(Alarm,0)==0)and(FloodDpT>0)and(DikeRtot==11),scalar(1),0),0)),CaseA);
       MissDr12 = areamaximum((cover(if((cover(Alarm,0)==0)and(FloodDpT>0)and(DikeRtot==12),scalar(1),0),0)),CaseA);
       MissTest = (MissDr1+MissDr2+MissDr3+MissDr4+MissDr5+MissDr6+MissDr7+MissDr8+MissDr9+MissDr10+MissDr11+MissDr12);
       MissNIx = min(1,((5-(MissTest))/5));
       FalseA = cover(if((Alarm==1) and (FloodDpT<0),scalar(1),0),0);
       MissA = cover(if((Alarm==0) and (FloodDpT>0),scalar(1),0),0);
       ScoreK = ((FloodIx+DamIx+DamAgIx+FalseNIx+MissNIx+StadIx+StadNIx+ShipIx+EcoDIx+EcoAIx)/10);
       ScoreSo =  ((FloodIx+FalseNIx+MissNIx+StadIx+StadNIx)/5); #flood
       ScoreEc =  ((DamIx+DamAgIx+ShipIx)/3); # total damage, agri damage, shipping
       ScoreEn =  ((EcoDIx+EcoAIx)/2); #diversity and area
       ScoreF = timeoutput (CaseA,FloodIx);   #score flood
       ScoreFA = timeoutput (nominal(DikeRing),FalseA);
       ScoreLA = timeoutput (nominal(DikeRing),MissA);
       ScoreFAT = timeoutput(CaseA,FalseNIx); #number of false alarms
       ScoreMAT = timeoutput(CaseA,MissNIx);  # number of missed floods
       ScoreC = timeoutput (CaseA,StadIx);    #score city
       ScoreS = timeoutput (CaseA,ShipIx);    #score ship
       ScoreD = timeoutput (CaseA,DamIx);     #score damage total
       ScoreDA = timeoutput (CaseA,DamAgIx);  #score damage agriculture
       ScoreDI = timeoutput (CaseA,EcoDIx);   #diversitye index
       ScoreEA = timeoutput(CaseA,EcoAIx);   #score eco,area
       Score = timeoutput (CaseA,ScoreK);     #total score
       ScoreSoc = timeoutput (CaseA,ScoreSo);     
       ScoreEco = timeoutput (CaseA,ScoreEc);     
       ScoreEnv = timeoutput (CaseA,ScoreEn);     
#
####################################################################################################
       DEMnew = DEMnew - cover(SoilSub,0);
       Qcope2=timeoutput(CaseA,Qcope);

       sSeaLevel = SeaLevel + SeaRise;
       
################################################################################################
########   Strategy  ############################################################################
################################################################################################
       QMHW = MHWFactor*(timeinputscalar(MHW,ClimScenS)); #ClimScenS=$3 is klimaatrun, aanpassing voor userinterface
#oude regel       QMHW = MHWFactor*(timeinputscalar(MHW,1)); #(timeinputscalar(MHW,1))*1.5 
       QHrel = if(QMHW<788,scalar(1),if(QMHW<7150,scalar(2),if(QMHW<16000,6,if(QMHW<20000,7,8))));
       Lev10 = if(QHrel==1,((Levq788*Fact788)-((Levq788*Fact788)*((788-QMHW)/788))),0);
       Lev20 = if(QHrel==2,((Levq7150*Fact7150)-(Dif_2*((7150-QMHW)/6362))),0);
       Lev60 = if(QHrel==6,((Levq16000*Fact16000)-(Dif_6*((16000-QMHW)/8850))),0);
       Lev70 = if(QHrel==7,((Levq20000*Fact20000)-(Dif_7*((20000-QMHW)/4000))),0);
       Lev80 = if(QHrel==8,(Levq20000*Fact20000)+((QMHW-20000)*0.00005),0);
       MHWLevel = Lev10+Lev20+Lev60+Lev70+Lev80;
       LevMHW = cover(MHWLevel,Case);
       SurfMHW = scalar(spreadzone(nominal(LevMHW*10000),0,1))/10000; #waterlevel spread       
report(rep2)       DEMnew = if((DEMnew<(SurfMHW+OphoogMHW))and(cover(PrimDijk,0)>0)then((PrimDijk*0+1)*(SurfMHW+OphoogMHW)) else DEMnew);
       
report       DikeOph=timeoutput(CaseA,(areatotal(cover(if(PrimDijk>0,DEMnew-DEMlts),0),CaseA)*100*100)); #(totale aantal m3 op de dijk)

report	DEMt=if(time()==$2,DEMnew);

