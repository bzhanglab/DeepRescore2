#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Oct 13 10:08:45 2021

@author: yixinpei
"""
from AAMass import AAMass
import math
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import itertools
from CalculateSimilarity2 import CalculateSimilarity2
import sys

from scipy.stats.stats import pearsonr, spearmanr, kendalltau
import numpy as np
import math
import matplotlib.pyplot as plt
import statistics
from numpy import linalg as LA

import spectral_entropy

aamass = AAMass()

def calc_mod_mass_list(peptide, modinfo):
    items = modinfo.split(";")
    modlist = []
    for mod in items:
        if mod != '':
            site, modname = mod.split(",")
            site = int(site)
            modlist.append( (site, modname) )
    modlist.sort()
    
    modmass = [0]*(len(peptide)+2)
    lossmass = [0]*(len(peptide)+2)
    for mod in modlist:
        modmass[mod[0]] = aamass.mod_mass_dict[mod[1]][0]
        lossmass[mod[0]] = aamass.mod_mass_dict[mod[1]][1]
    return modmass,lossmass

def calc_b_ions(peptide, modinfo):
    modmass_list, modloss_list = calc_mod_mass_list(peptide, modinfo)
    b_ions = []
    mass_nterm = modmass_list[0]
    for i in range(len(peptide)-1):
        mass_nterm += aamass.aa_mass_dict[peptide[i]] + modmass_list[i+1]
        b_ions.append(mass_nterm)
    pepmass = b_ions[-1] + aamass.aa_mass_dict[peptide[-1]] + modmass_list[len(peptide)] + modmass_list[len(peptide)+1] + aamass.mass_H2O
    return b_ions, pepmass

def calc_y_from_b(bions, pepmass):
    return [pepmass - b for b in bions]

def calc_ion_modloss(ions, peptide, modinfo, N_term = True):
    # site_lossmass_list is list of multiple mod sites
    modmass_list, modloss_list = calc_mod_mass_list(peptide, modinfo)
    ret = [0]*len(ions)
    if N_term:
        loss_nterm = modloss_list[0]
        if modloss_list[1] != 0: loss_nterm = modloss_list[1]
        for i in range(len(ions)):
            if modloss_list[i+1] != 0: loss_nterm = modloss_list[i+1]
            if loss_nterm != 0:
                ret[i] = ions[i] - loss_nterm
            else:
                ret[i] = 0
    else:
        loss_cterm = modloss_list[len(peptide)+1]
        if modloss_list[len(peptide)] != 0: loss_cterm = modloss_list[len(peptide)]
        for i in range(len(ions)-1, -1, -1):
            if modloss_list[i+1] != 0: loss_cterm = modloss_list[i+1]
            if loss_cterm != 0:
                ret[i] = ions[i] - loss_cterm
            else:
                ret[i] = 0
        ret = ret[::-1]
    return ret

def generateMGFFile(pathin,true,trueMGF):
    
    file = open(pathin,'r')
    numrlt = 0
    
    dot_products = []
    sr_dot_products = []
    spectral_contrast_angles = []
    pearson_correlations = []
    unweighted_entropys = []
    entropys = []
    
    totalData = {}
    
    Spectra = []
    names = []
    while True:
        
        numrlt += 1
        
        if numrlt % 10000 == 0:
            print(numrlt)
        
        line = file.readline()
        tmp = line.replace('\n', '')
        if tmp.startswith('TITLE='):
            tmp = tmp.replace('TITLE=','')
            name = tmp
            info = tmp.split('|')
            
            peptide = info[0]
            modInfo = info[1]
            charge = info[2]
            
            [b_ions,pepmass] = calc_b_ions(peptide,modInfo)
            y_ions = calc_y_from_b(b_ions,pepmass)
            b_ions_ModLoss = calc_ion_modloss(b_ions, peptide, modInfo)
            y_ions_ModLoss = calc_ion_modloss(y_ions, peptide, modInfo)
            
            name = name + '|' + str(pepmass/int(charge)+aamass.mass_proton)
            totalData[name] = {}
            
            b_1 = []
            b_2 = []
            y_1 = []
            y_2 = []
            b_1_ModLoss = []
            b_2_ModLoss = []
            y_1_ModLoss = []
            y_2_ModLoss = []
            for item in b_ions:
                b_1.append(item/1 + aamass.mass_proton)
                b_2.append(item/2 + aamass.mass_proton)
            for item in y_ions:
                y_1.append(item/1 + aamass.mass_proton)
                y_2.append(item/2 + aamass.mass_proton)
            for item in b_ions_ModLoss:
                b_1_ModLoss.append(item/1 + aamass.mass_proton)
                b_2_ModLoss.append(item/2 + aamass.mass_proton)
            for item in y_ions_ModLoss:
                y_1_ModLoss.append(item/1 + aamass.mass_proton)
                y_2_ModLoss.append(item/2 + aamass.mass_proton)
            
            b_1_Intensity = []
            b_2_Intensity = []
            y_1_Intensity = []
            y_2_Intensity = []
            b_1_ModLossIntensity = []
            b_2_ModLossIntensity = []
            y_1_ModLossIntensity = []
            y_2_ModLossIntensity = []
        
        if tmp.startswith('b+1='):
            tmp = tmp.replace('b+1=','')
            info = tmp.split(',')
            for intensity in info:
                b_1_Intensity.append(intensity)
            
            for count in range(len(b_1)):
                key = 'b' + str(count+1) + '+' + '1'
                mass = b_1[count]
                intensity = b_1_Intensity[count]
                totalData[name][key] = {'mass':mass,'intensity':intensity}
        if tmp.startswith('b+2='):
            tmp = tmp.replace('b+2=','')
            info = tmp.split(',')
            for intensity in info:
                b_2_Intensity.append(intensity)
            
            for count in range(len(b_2)):
                key = 'b' + str(count+1) + '+' + '2'
                mass = b_2[count]
                intensity = b_2_Intensity[count]
                totalData[name][key] = {'mass':mass,'intensity':intensity}
        if tmp.startswith('y+1='):
            tmp = tmp.replace('y+1=','')
            info = tmp.split(',')
            for intensity in info:
                y_1_Intensity.append(intensity)
            
            y_1.reverse()
            y_1_Intensity.reverse()
            
            for count in range(len(y_1)):
                key = 'y' + str(count+1) + '+' + '1'
                mass = y_1[count]
                intensity = y_1_Intensity[count]
                totalData[name][key] = {'mass':mass,'intensity':intensity}
        if tmp.startswith('y+2='):
            tmp = tmp.replace('y+2=','')
            info = tmp.split(',')
            for intensity in info:
                y_2_Intensity.append(intensity)
            
            y_2.reverse()
            y_2_Intensity.reverse()
            
            for count in range(len(y_2)):
                key = 'y' + str(count+1) + '+' + '2'
                mass = y_2[count]
                intensity = y_2_Intensity[count]
                totalData[name][key] = {'mass':mass,'intensity':intensity}
        if tmp.startswith('b+1-ModLoss='):
            tmp = tmp.replace('b+1-ModLoss=','')
            info = tmp.split(',')
            for intensity in info:
                b_1_ModLossIntensity.append(intensity)
            
            for count in range(len(b_1_ModLoss)):
                key = 'b' + str(count+1) + '-ModLoss+' + '1'
                mass = b_1_ModLoss[count]
                intensity = b_1_ModLossIntensity[count]
                totalData[name][key] = {'mass':mass,'intensity':intensity}
        if tmp.startswith('b+2-ModLoss='):
            tmp = tmp.replace('b+2-ModLoss=','')
            info = tmp.split(',')
            for intensity in info:
                b_2_ModLossIntensity.append(intensity)
            
            for count in range(len(b_2_ModLoss)):
                key = 'b' + str(count+1) + '-ModLoss+' + '2'
                mass = b_2_ModLoss[count]
                intensity = b_2_ModLossIntensity[count]
                totalData[name][key] = {'mass':mass,'intensity':intensity}
        if tmp.startswith('y+1-ModLoss='):
            tmp = tmp.replace('y+1-ModLoss=','')
            info = tmp.split(',')
            for intensity in info:
                y_1_ModLossIntensity.append(intensity)
            
            y_1_ModLoss.reverse()
            y_1_ModLossIntensity.reverse()
            
            for count in range(len(y_1_ModLoss)):
                key = 'y' + str(count+1) + '-ModLoss+' + '1'
                mass = y_1_ModLoss[count]
                intensity = y_1_ModLossIntensity[count]
                totalData[name][key] = {'mass':mass,'intensity':intensity}
        if tmp.startswith('y+2-ModLoss='):
            tmp = tmp.replace('y+2-ModLoss=','')
            info = tmp.split(',')
            for intensity in info:
                y_2_ModLossIntensity.append(intensity)
            
            y_2_ModLoss.reverse()
            y_2_ModLossIntensity.reverse()
            
            for count in range(len(y_2_ModLoss)):
                key = 'y' + str(count+1) + '-ModLoss+' + '2'
                mass = y_2_ModLoss[count]
                intensity = y_2_ModLossIntensity[count]
                totalData[name][key] = {'mass':mass,'intensity':intensity}
        
        
            result = totalData[name]
            result2 = {}
            totalData2 = {}
            for key in result.keys():
                intensity = result[key]['intensity']
                if float(intensity) > 1e-8:
                    result2[key] = result[key]
            result3 = sorted(result2.items(), key=lambda x:x[1]['mass'])
            totalData2[name] = result3
        
            spec_mz_Intensity_predict = []
            predict = totalData2[name]
            for i in range(len(predict)):
                spec_mz_Intensity_predict.append([predict[i][1]['mass'],float(predict[i][1]['intensity'])])
        
            tmp1 = name.split('|')
            name2 = tmp1[0] + '|' + tmp1[1] + '|' + tmp1[2]
            tmp2 = true[name2]
            for spectrum in tmp2.keys():
                
                Spectra.append(spectrum)
                names.append(name)
                
                specmz_real = trueMGF[spectrum]['mass']
                specIntensity_real = trueMGF[spectrum]['intensity']
                
                spec_mz_Intensity_real = []
                
                for i in range(len(specmz_real)):
                    spec_mz_Intensity_real.append([specmz_real[i],specIntensity_real[i]])
            
                spec_query = np.array(spec_mz_Intensity_predict, dtype=np.float32)
                spec_reference = np.array(spec_mz_Intensity_real, dtype=np.float32)
            
                # Calculate spectrum similarity:
                # dot product (cosine)
                dot_product = spectral_entropy.similarity(spec_query, spec_reference, method="dot_product",ms2_da=0.02)
                # square root dot product
                sr_dot_product = spectral_entropy.similarity(spec_query, spec_reference, method="dot_product_reverse",ms2_da=0.02)
                # spectral contrast angle
                spectral_contrast_angle = spectral_entropy.similarity(spec_query, spec_reference, method="spectral_contrast_angle",ms2_da=0.02,need_clean_spectra=False)
                # pearson correlation (spearman correlation coefficient)
                pearson_correlation = spectral_entropy.similarity(spec_query, spec_reference, method="pearson_correlation",ms2_da=0.02)
                # unweighted entropy
                unweighted_entropy = spectral_entropy.similarity(spec_query, spec_reference, method="unweighted_entropy",ms2_da=0.02)
                # entropy
                entropy = spectral_entropy.similarity(spec_query, spec_reference, method="entropy",ms2_da=0.02)
                
                dot_products.append(dot_product)
                sr_dot_products.append(sr_dot_product)
                spectral_contrast_angles.append(spectral_contrast_angle)
                pearson_correlations.append(pearson_correlation)
                unweighted_entropys.append(unweighted_entropy)
                entropys.append(entropy)
                totalData = {}
        
        if not line:
            break
    
    pDeep3PredictionResults = {}
    for i in range(len(Spectra)):
        spectrum = Spectra[i]
        name = names[i]
        dot_product = dot_products[i]
        sr_dot_product = sr_dot_products[i]
        spectral_contrast_angle = spectral_contrast_angles[i]
        pearson_correlation = pearson_correlations[i]
        unweighted_entropy = unweighted_entropys[i]
        entropy = entropys[i]
            
        pDeep3PredictionResults[i] = {'spectrum':spectrum,'name':name,
                                      'dot_product':dot_product,
                                      'sr_dot_product':sr_dot_product,
                                      'spectral_contrast_angle':spectral_contrast_angle,
                                      'pearson_correlation':pearson_correlation,
                                      'unweighted_entropy':unweighted_entropy,
                                      'entropy':entropy,
                                      }

    
    return pDeep3PredictionResults


if __name__ == "__main__":    
    
    PredictInputDataPathin = sys.argv[1]
    MGFPathin = sys.argv[2]
    pDeep3PredictResultsPath1 = sys.argv[3]
    pDeep3PredictResultsPath2 = sys.argv[4]
    
    #PredictInputDataPathin = '/Users/yixinpei/Documents/PostDocResearch/DeepRescore2/BuildPipeline/PXD000138/MaxQuant2/generate_train_prediction/pDeep3_prediction/pdeep3_prediction.nonPhospho.txt'
    #MGFPathin = '/Users/yixinpei/Documents/PostDocResearch/DeepRescore2/BuildPipeline/PXD000138/MaxQuant2/InputData/1_11.mgf'
    #pDeep3PredictResultsPath1 = '/Users/yixinpei/Documents/PostDocResearch/DeepRescore2/BuildPipeline/PXD000138/MaxQuant2/pDeep3/pDeep3_Predict.nonPhospho.txt'
    #pDeep3PredictResultsPath2 = '/Users/yixinpei/Documents/PostDocResearch/DeepRescore2/BuildPipeline/PXD000138/MaxQuant2/pDeep3/test/pDeep3PredictionResults.nonPhospho.txt'
    
    true = CalculateSimilarity2.GetInputPeptideInfo(pathin=PredictInputDataPathin)
    trueMGF = CalculateSimilarity2.ReadMGF(MGFPathin=MGFPathin)
    pDeep3PredictionResults = generateMGFFile(pDeep3PredictResultsPath1,true,trueMGF)
    
    fp = open(pDeep3PredictResultsPath2,'w')
    fp.write('SpectrumName' + '\t')
    fp.write('Peptide' + '\t')
    fp.write('ModInfo' + '\t')
    fp.write('Charge' + '\t')
    fp.write('dot_product' + '\t')
    fp.write('sr_dot_product' + '\t')
    fp.write('spectral_contrast_angle' + '\t')
    fp.write('pearson_correlation' + '\t')
    fp.write('unweighted_entropy' + '\t')
    fp.write('entropy' + '\n')
    for i in pDeep3PredictionResults.keys():
        spectrum = pDeep3PredictionResults[i]['spectrum']
        name = pDeep3PredictionResults[i]['name']
        dot_product = pDeep3PredictionResults[i]['dot_product']
        sr_dot_product = pDeep3PredictionResults[i]['sr_dot_product']
        spectral_contrast_angle = pDeep3PredictionResults[i]['spectral_contrast_angle']
        pearson_correlation = pDeep3PredictionResults[i]['pearson_correlation']
        unweighted_entropy = pDeep3PredictionResults[i]['unweighted_entropy']
        entropy = pDeep3PredictionResults[i]['entropy']
        
        nameInfo = name.split('|')
        peptide = nameInfo[0]
        modInfo = nameInfo[1]
        charge = nameInfo[2]
        
        fp.write(spectrum + '\t')
        fp.write(peptide + '\t')
        fp.write(modInfo + '\t')
        fp.write(charge + '\t')
        fp.write(str(dot_product) + '\t')
        fp.write(str(sr_dot_product) + '\t')
        fp.write(str(spectral_contrast_angle) + '\t')
        fp.write(str(pearson_correlation) + '\t')
        fp.write(str(unweighted_entropy) + '\t')
        fp.write(str(entropy) + '\n')
    fp.close()
    
    
    
