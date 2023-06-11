#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov  3 15:41:39 2021

@author: yixinpei
"""

from scipy.stats.stats import pearsonr, spearmanr, kendalltau
import numpy as np
import math
import matplotlib.pyplot as plt
import statistics
from numpy import linalg as LA

import spectral_entropy

class CalculateSimilarity2:
    '''
    classdocs
    '''
    def __init__(self,pathin=''):
        self.pathin = pathin
    
    def GetInputPeptideInfo(pathin):
        file = open(pathin)
        lines = file.readlines()
        true = {}
        for line in lines:
            if line.startswith('peptide'):
                continue
            tmp = line.replace('\n','')
            info = tmp.split('\t')
            peptide = info[0]
            modinfo = info[1]
            charge = info[2]
            Spectrum = info[3]
    
            key = peptide + '|' + modinfo + '|' + charge
            if key not in true.keys():
                true[key] = {}
                true[key][Spectrum] = Spectrum
            else:
                true[key][Spectrum] = Spectrum
        return true
    
    def ReadMGF(MGFPathin):
        pathin = MGFPathin
        file = open(pathin)
        lines = file.readlines()
        trueMGF = {}
        for line in lines:
            tmp = line.replace('\n','')
            if line.startswith('TITLE='):
                spectrumName = tmp.replace('TITLE=','')
                trueMGF[spectrumName] = {'mass':[],'intensity':[]}
            if line.startswith('BEGIN IONS') or '=' in line or line.startswith('END IONS'):
                continue
    
            info = tmp.split(' ')
            trueMGF[spectrumName]['mass'].append(float(info[0]))
            trueMGF[spectrumName]['intensity'].append(float(info[1]))
        return trueMGF






