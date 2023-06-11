#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov 10 10:11:11 2021

@author: yixinpei
"""
import pandas as pd
import sys

import re

#pathin = '/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/ManuscriptRevison_MCP/FirstRound/ResponseCode/DeepRescore2Pipeline/tmp/UCEC/features_comet.txt'
#data = pd.read_csv(pathin,sep='\t')
#pathout = '/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/ManuscriptRevison_MCP/FirstRound/ResponseCode/DeepRescore2Pipeline/UCEC/Features_comet/features.txt'
#Mods = '1,Oxidation,M,15.994919,1;2,Phospho,S,79.966331,2;3,Phospho,T,79.966331,2;4,Phospho,Y,79.966331,2;5,Carbamidomethyl,C,57.021464,3;6,TMT6plex,K,229.162932,4;7,TMT6plex,AnyN-term,229.162932,5'
#ModsReplace = '[79.966331],Phospho;[229.162932],TMT6plex;N-term,AnyN-term'

pathin = sys.argv[1]
data = pd.read_csv(pathin,sep='\t')
pathout = sys.argv[2]
Mods = sys.argv[3]
ModsReplace = sys.argv[4]

ModsInfo = Mods.split(';')
ModInfo = {}
for mod in  ModsInfo:
    tmp = mod.split(',')
    Number = tmp[0]
    name = tmp[1]
    aa = tmp[2]
    mass = tmp[3]
    sym = tmp[4]
    name2 = name + '[' + aa + ']'
    if aa != 'AnyN-term':
        ModInfo[name2] = {'Number':Number,'name':name,'aa':aa,'mass':mass,'sym':sym}

if ModsReplace != 'null':
    ModsReplaceInfo = ModsReplace.split(';')
    ModReplaceInfo = {}
    for mod in ModsReplaceInfo:
        tmp = mod.split(',')
        name1 = tmp[0]
        name2 = tmp[1]
        ModReplaceInfo[name1] = name2
        
if ModsReplace != 'null':
    tmp1 = data['Modification']
    for name1 in ModReplaceInfo.keys():
        
        escaped_name1 = re.escape(name1)
        
        tmp1 = tmp1.apply(lambda x: re.sub(escaped_name1, ModReplaceInfo[name1], x) if isinstance(x, str) else x)
        #tmp1 = re.sub(escaped_name1,ModReplaceInfo[name1],tmp1)
    
    data['Modification'] = tmp1
    
    tmp2 = data['modification']
    for name1 in ModReplaceInfo.keys():
        escaped_name1 = re.escape(name1)
        
        tmp2 = tmp2.apply(lambda x: re.sub(escaped_name1, ModReplaceInfo[name1], x) if isinstance(x, str) else x)
        #tmp2 = tmp2.str.replace(name1,ModReplaceInfo[name1])
    
    data['modification'] = tmp2


Peptides = data['Peptide']
mods = list(data['Modification'])
Mod_Sequence2 = []
Mod_Sequence3 = []

tmp = []
for indexx in Peptides.index:
    Peptide = data.loc[indexx]['Peptide']
    pep2 = Peptide
    pep3 = Peptide
    mod = data.loc[indexx]['Modification']
    
    if mod != mod:
        Mod_Sequence2.append(Peptide)
        Mod_Sequence3.append(Peptide)
        tmp.append(indexx)
        continue

    if 'pyro-Glu' in mod or 'Acetyl' in mod or 'Ammonia-loss' in mod:
        continue
        
    tmp.append(indexx)
    
    mod = mod[0:len(mod)-1]
    modInfo = mod.split(';')
    for mod2 in modInfo:
        for name2  in ModInfo.keys():
            if name2 in mod2:
                mod3 = mod2.replace(',' + name2, '')
                pep2 = pep2[0:int(mod3)-1] + ModInfo[name2]['Number'] + pep2[int(mod3):len(pep2)]
                pep3 = pep3[0:int(mod3)-1] + ModInfo[name2]['Number'] + pep3[int(mod3):len(pep3)]
    Mod_Sequence2.append(pep2)

    for name2 in ModInfo.keys():
        pep3 = pep3.replace(ModInfo[name2]['Number'],ModInfo[name2]['aa']+ModInfo[name2]['sym'])
    Mod_Sequence3.append(pep3)

data = data.loc[tmp]

data['Mod_Sequence_for_phosphoRS'] = Mod_Sequence3
data.to_csv(pathout,sep='\t',index=False)

