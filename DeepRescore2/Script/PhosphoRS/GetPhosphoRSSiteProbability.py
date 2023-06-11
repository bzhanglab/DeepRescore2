#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Nov 16 14:08:42 2021

@author: yixinpei
"""
import pandas as pd
import sys

#pathin = '/Users/yixinpei/Documents/PostDocResearch/DeepRescore2/BuildPipeline/PXD000138/MaxQuant3/Features/features.PhosphoRS.txt'
#pathout = '/Users/yixinpei/Documents/PostDocResearch/DeepRescore2/BuildPipeline/PXD000138/MaxQuant3/Features/features.PhosphoRS.txt'
pathin = sys.argv[1]
pathout = sys.argv[2]
data = pd.read_csv(pathin,sep='\t')

PhosphoRS_SitePrediction = data['PhosphoRS_SitePrediction']
PhosphoRS_IsoformSites = data['PhosphoRS_IsoformSites']
PhosphoRS_SiteProbability = []
for i in range(len(PhosphoRS_SitePrediction)):
    PhosphoRS_SitePrediction2 = PhosphoRS_SitePrediction[i]
    PhosphoRS_IsoformSites2 = PhosphoRS_IsoformSites[i]
    
    if not PhosphoRS_SitePrediction2 == PhosphoRS_SitePrediction2:
        probability = 0
        PhosphoRS_SiteProbability.append('')
    else:
        PhosphoRS_SitePredictionInfo = PhosphoRS_SitePrediction2.split(' ')
        PhosphoRSPro = {}
        SiteProbability = ''
        for PhosphoRS_SitePredictionInfo2 in PhosphoRS_SitePredictionInfo:
            PhosphoRS_SitePredictionInfo3 = PhosphoRS_SitePredictionInfo2.split('(')
            PhosphoRS_SitePredictionInfo4 = PhosphoRS_SitePredictionInfo3[0]
            PhosphoRS_SitePredictionInfo5 = PhosphoRS_SitePredictionInfo3[1].replace(')','')
            PhosphoRSPro[PhosphoRS_SitePredictionInfo4] = PhosphoRS_SitePredictionInfo5
        PhosphoRS_IsoformSitesInfo = PhosphoRS_IsoformSites2.split(' ')
        for PhosphoRS_IsoformSitesInfo2 in PhosphoRS_IsoformSitesInfo:
            probability = PhosphoRSPro[PhosphoRS_IsoformSitesInfo2]
            SiteProbability = SiteProbability + ',' + probability
        SiteProbability = SiteProbability[1:len(SiteProbability)]
        PhosphoRS_SiteProbability.append(SiteProbability)
data['PhosphoRS_SiteProbability'] = PhosphoRS_SiteProbability
data.to_csv(pathout,sep='\t',index=False)
