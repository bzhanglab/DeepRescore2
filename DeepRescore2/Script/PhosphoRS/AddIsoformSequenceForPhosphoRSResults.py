#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Dec  9 12:42:10 2021

@author: yixinpei
"""
# generate_isoform_sequence

import sys
import pandas as pd
import os

pathin1 = sys.argv[1]
pathin2 = sys.argv[2]
pathin3 = sys.argv[3]
pathout1 = sys.argv[4]
pathout2 = sys.argv[5]
Mods = sys.argv[6]

#pathin1 = '/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/BuildPipeline/PXD000138/MaxQuant3/PhosphoRS/TXT'
#pathin2 = '/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/BuildPipeline/PXD000138/MaxQuant3/PhosphoRS/Results'
#pathin3 = '/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/BuildPipeline/PXD000138/MaxQuant3/Features/features.txt'
#pathout1 = '/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/ManuscriptRevison_MCP/FirstRound/ResponseCode/DeepRescore2Pipeline/test/Results_AddIsoformSequence'
#pathout2 = '/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/ManuscriptRevison_MCP/FirstRound/ResponseCode/DeepRescore2Pipeline/test/features2.txt'
#Mods = '1,Oxidation,M,15.994919,1;2,Phospho,S,79.966331,2;3,Phospho,T,79.966331,2;4,Phospho,Y,79.966331,2;6,TMT6plex,K,229.162932,4;5,Carbamidomethyl,C,57.021464,3;7,TMT6plex,AnyN-term,229.162932,5' 

ModsInfo = Mods.split(';')
PhosphoInfo = {}
ModInfo = {}
ModInfo_Nterm = {}
for mod in  ModsInfo:
    tmp = mod.split(',')
    Number = tmp[0]
    name = tmp[1]
    aa = tmp[2]
    mass = tmp[3]
    sym = tmp[4]
    name2 = name + '[' + aa + ']'
    if 'AnyN-term' in aa:
        ModInfo_Nterm[name2] = {'Number':Number,'name':name,'aa':aa,'mass':mass,'sym':sym}
    else:
        ModInfo[name2] = {'Number':Number,'name':name,'aa':aa,'mass':mass,'sym':sym}
    if name == 'Phospho':
        PhosphoInfo[aa] = Number


fp1 = open(pathout2,'w')

file = open(pathin3)
lines = file.readlines()
featuresInfo = {}
for line in lines:
    tmp = line.replace('\n','')
    if line.startswith('Title'):
        fp1.write(tmp + '\t' + 'Link' + '\n')
        continue
    info = tmp.split('\t')
    Title = info[0]
    Mod_Sequence_for_phosphoRS2 = info[len(info)-1]
    
    key = Title + '_' + Mod_Sequence_for_phosphoRS2
    if key not in featuresInfo.keys():
        featuresInfo[key] = {'line':line,'Link':Title}
    else:
        print(line)

links = []
indexs = []
FileNames = os.listdir(pathin1)
for FileName in FileNames:
    
    if '.DS_Store' in FileName:
        continue
    
    name = FileName.replace('.txt','')
    FilePath1 = pathin1 + '/' + name + '.txt'
    FilePath2 = pathin2 + '/' + name + '.csv'
    
    fp = open(pathout1 + '/' + name + '.txt','w')
    
    data1 = pd.read_csv(FilePath1,sep='\t')
    data1['peptide2'] = data1['peptide']
    
    for name2 in ModInfo.keys():
        Number = ModInfo[name2]['Number']
        aa = ModInfo[name2]['aa']
        sym = ModInfo[name2]['sym']
        if sym == '2':
            data1['peptide2'] = data1['peptide2'].str.replace(aa+sym,aa)
        else:
            data1['peptide2'] = data1['peptide2'].str.replace(aa+sym,Number)
    
    data1['Spectrum'] = data1['file'].astype(str) + '.' + data1['scan'].astype(str) + '.' + data1['scan'].astype(str) + '.' + data1['charge'].astype(str)
    
    file = open(FilePath2)
    lines = file.readlines()
    index = 1
    count = 0
    for line in lines:
        
        tmp = line.replace('\n','')
        tmp = tmp.replace('"','')
        tmp2 = tmp.replace(',','\t')
        
        if line.startswith('Spectrum.ID'):
            if index == 1:
                fp.write(tmp2 + '\t' + 'IsoformSequence' + '\t' + 'IsoformModification' + '\t' + 'Link' + '\n')
                index = 2
            continue
        info = tmp2.split('\t')
    
        SpectrumID = info[0]
    
        indexx = int(SpectrumID) - 1
        Mod_Sequence_for_phosphoRS = data1['peptide2'].loc[indexx]
        
        link = SpectrumID + '_' + data1['Spectrum'].loc[indexx]
        
        key  =  data1['Spectrum'].loc[indexx] + '_' + data1['peptide'].loc[indexx]
        if key not in featuresInfo.keys():
            print(key)
        else:
            featuresInfo[key]['Link'] = link
            
        
        #tmp_feature = Features.loc[Features['Title'] == data1['Spectrum'].loc[indexx]]
        #tmp_feature = tmp_feature.loc[tmp_feature['Mod_Sequence_for_phosphoRS']==data1['peptide'].loc[indexx]]
        #indexs.append(tmp_feature.index[0])
        
        IsoformSites = info[8]
        IsoformSiteInfo = IsoformSites.split(' ')
        for IsoformSite2 in IsoformSiteInfo:
            
            for aa in PhosphoInfo:
                if aa in IsoformSite2:
                    IsoformSites3 = int(IsoformSite2.replace(aa,''))
                    Mod_Sequence_for_phosphoRS = Mod_Sequence_for_phosphoRS[:IsoformSites3-1] + PhosphoInfo[aa] + Mod_Sequence_for_phosphoRS[IsoformSites3-1+1:]
        
        numrlt = 0
        modinfo = ''
        for letter in Mod_Sequence_for_phosphoRS:
            numrlt = numrlt + 1
            
            for name2 in ModInfo.keys():
                Number = ModInfo[name2]['Number']
                aa = ModInfo[name2]['aa']
                sym = ModInfo[name2]['sym']
                if letter == Number:
                    modinfo = modinfo + ';' + str(numrlt) + ',' + name2
        for name3 in ModInfo_Nterm.keys():
            modinfo = modinfo + ';' + '1' + ',' + name3
        modinfo = modinfo[1:len(modinfo)]
    
        fp.write(tmp2 + '\t' + Mod_Sequence_for_phosphoRS + '\t' + modinfo + '\t' + link + '\n')
    
        count = count + 1
        if count % 10000 == 0:
            print(count)

    fp.close()

for key in featuresInfo.keys():
    line = featuresInfo[key]['line']
    Link = featuresInfo[key]['Link']
    tmp = line.replace('\n','')
    fp1.write(tmp + '\t' + Link + '\n')
fp1.close()    
    

