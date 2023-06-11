#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov 10 10:11:11 2021

@author: yixinpei
"""
import pandas as pd
import sys
import os

import re

#pathin = '/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/ManuscriptRevison_MCP/FirstRound/ResponseCode/DeepRescore2Pipeline/UCEC/Features_maxquant/features_maxquant.txt'
#data = pd.read_csv(pathin,sep='\t')
#MGFPathin = '/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/ManuscriptRevison_MCP/FirstRound/ResponseCode/DeepRescore2Pipeline/tmp/InputData_UCEC/MGF'
#pathout = '/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/ManuscriptRevison_MCP/FirstRound/ResponseCode/DeepRescore2Pipeline/UCEC/Features_maxquant/features_maxquant_2.txt'
#Mods = '1,Oxidation,M,15.994919,1;2,Phospho,S,79.966331,2;3,Phospho,T,79.966331,2;4,Phospho,Y,79.966331,2;6,TMT6plex,K,229.162932,4;5,Carbamidomethyl,C,57.021464,3;7,TMT6plex,AnyN-term,229.162932,5' 
#ModsReplace = 'TMT 10-plex,TMT6plex;peptide N-term,AnyN-term'

pathin = sys.argv[1]
data = pd.read_csv(pathin,sep='\t')
MGFPathin = sys.argv[2]
pathout = sys.argv[3]
Mods = sys.argv[4]
ModsReplace = sys.argv[5]

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
for i in range(len(Peptides)):
    Peptide = Peptides[i]
    pep2 = Peptide
    pep3 = Peptide
    mod = mods[i]
    
    if mod != mod:
        Mod_Sequence2.append(Peptide)
        Mod_Sequence3.append(Peptide)
        continue
    
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

data['Mod_Sequence_for_phosphoRS'] = Mod_Sequence3
#data['Mod_Sequence_for_autort'] = Mod_Sequence2

FileNames = os.listdir(MGFPathin)
MGFInfo = {}
for FileName in FileNames:
    if '.DS_Store' in FileName:
        continue
    filePath = MGFPathin + '/' + FileName
    file = open(filePath)
    lines = file.readlines()
    for line in lines:
        tmp = line.replace('\n','')
        if line.startswith('TITLE='):
            info = tmp.replace('TITLE=','')
            info2 = info.split('.')
            key = info2[0] + '.' + info2[1] + '.' + info2[2]
            if key not in MGFInfo.keys():
                MGFInfo[key] = {'SpectrumName':info,'Charge':info2[3]}
            else:
                print(info)

tmp = {}
for indexx in data.index:
    Score = data.loc[indexx]['Score']
    SpectrumName = data.loc[indexx]['Title']
    
    SpectrumNameInfo = SpectrumName.split('.')
    SpectrumNameInfo2 = SpectrumNameInfo[0] + '.' + SpectrumNameInfo[1] + '.'+ SpectrumNameInfo[2]
    if SpectrumNameInfo2 not in MGFInfo.keys():
        print(SpectrumNameInfo2)
    else:
        SpectrumName2 = MGFInfo[SpectrumNameInfo2]['SpectrumName']
    if SpectrumName2 not in tmp.keys():
        tmp[SpectrumName2] = {'Score':Score,'Index':indexx,'Charge':MGFInfo[SpectrumNameInfo2]['Charge']}
    else:
        if Score > tmp[SpectrumName2]['Score']:
            tmp[SpectrumName2] = {'Score':Score,'Index':indexx,'Charge':MGFInfo[SpectrumNameInfo2]['Charge']}

tmp2 = []
Title2 = []
Charge2 = []
for SpectrumName2 in tmp.keys():
    tmp2.append(tmp[SpectrumName2]['Index'])
    Title2.append(SpectrumName2)
    Charge2.append(tmp[SpectrumName2]['Charge'])

data = data.loc[tmp2]
data['Title'] = Title2
data['Charge'] = Charge2



#data.to_csv('/data/xyi/DeepRescore/DeepRescore2/BuildPipeline/PXD023665/MSGF/Features/features.txt', 
#            sep='\t', index=False)
data.to_csv(pathout,sep='\t',index=False)

