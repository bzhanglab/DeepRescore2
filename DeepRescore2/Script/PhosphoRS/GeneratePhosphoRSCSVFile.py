#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov 10 08:50:16 2021

@author: yixinpei
"""

import pandas as pd
import sys

#pathin = '/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/ManuscriptRevison_MCP/FirstRound/ResponseCode/DeepRescore2Pipeline/UCEC/Features_maxquant/features_maxquant_2.txt'
pathin = sys.argv[1]
data = pd.read_csv(pathin,sep='\t')

data2 = data.loc[data['Modification'].notnull()]
data_Phos = data2.loc[data2['Modification'].str.contains('Phospho', case=False)]

SpectrumName = data_Phos['Title']
mods = list(data_Phos['Modification'])

file = [i.split('.')[0] for i in SpectrumName]
scan = [i.split('.')[1] for i in SpectrumName]
charge = [i.split('.')[3] for i in SpectrumName]

Mod_Sequence_for_phosphoRS = list(data_Phos['Mod_Sequence_for_phosphoRS'])

info = {}
for i in range(len(file)):
    if file[i] not in info.keys():
        info[file[i]] = {}
        info[file[i]][scan[i]] = {'file':file[i],'scan':scan[i],'charge':charge[i],'peptide':Mod_Sequence_for_phosphoRS[i]}
    else:
        if scan[i] not in info[file[i]].keys():
            info[file[i]][scan[i]] = {'file':file[i],'scan':scan[i],'charge':charge[i],'peptide':Mod_Sequence_for_phosphoRS[i]}
        else:
            print(scan[i])

#pathout = '/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/ManuscriptRevison_MCP/FirstRound/ResponseCode/DeepRescore2Pipeline/UCEC/PhosphoRS_maxquant/TXT'
pathout = sys.argv[2]
for file in info.keys():
    fp = open(pathout + '/' + file + '.txt' , 'w')
    fp.write('file' + '\t')
    fp.write('scan' + '\t')
    fp.write('charge' + '\t')
    fp.write('peptide' + '\n')
    result = info[file]
    for spectrum in result.keys():
        fp.write(result[spectrum]['file'] + '\t')
        fp.write(result[spectrum]['scan'] + '\t')
        fp.write(result[spectrum]['charge'] + '\t')
        fp.write(result[spectrum]['peptide'] + '\n')
    fp.close()

