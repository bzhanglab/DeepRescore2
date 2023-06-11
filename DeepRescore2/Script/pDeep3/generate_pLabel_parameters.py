#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov 11 08:09:22 2021

@author: yixinpei
"""
# pDeep3 parameters

# pLabel
import sys
import os

psmPathin = sys.argv[1]
RawFilePath = sys.argv[2]
outputFolder = sys.argv[3]
paramFile = sys.argv[4]

print(psmPathin)


fp = open(paramFile,'w')

fp.write('psm_type = none' + '\n')
fp.write('mode = pDeep' + '\n')
fp.write('num_psm_file = 1' + '\n')
fp.write('psm_file1 = ' + psmPathin + '\n')
fp.write('ms2_type = raw' + '\n')

FileNames = os.listdir(RawFilePath)
RawFilesNum = len(FileNames)
fp.write('num_ms2_file = ' + str(RawFilesNum) + '\n')
numrlt = 0
for FileName in FileNames:
    numrlt = numrlt + 1
    fp.write('ms2_file' + str(numrlt) + ' = ' + RawFilePath + '/' + FileName + '\n')
fp.write('output_folder = ' + outputFolder + '\n')
fp.write('NH3_loss = true' + '\n')
fp.write('H2O_loss = true' + '\n')
fp.write('Mod_loss = true' + '\n')
fp.write('num_ion_type = 2' + '\n')
fp.write('iontype1 = b|N_term|0' + '\n')
fp.write('iontype2 = y|C_term|0' + '\n')
fp.write('num_new_aa = 0' + '\n')
fp.write('aa1 = c|160.030654|C' + '\n')
fp.write('aa2 = n|115.026946|N' + '\n')
fp.write('aa3 = m|147.035405|M' + '\n')

fp.close()

# Training model: phospho

TrainingParamFile = sys.argv[5]
predict_input = sys.argv[6]
tune_psmlabels = sys.argv[7]
test_psmlabels = sys.argv[8]
model_path = sys.argv[9]
fp = open(TrainingParamFile,'w')
fp.write('model = ' + model_path + '\n')
fp.write('\n')
fp.write('threads = 4' + '\n')
fp.write('\n')
fp.write('###### predict ######' + '\n')
fp.write('mod_no_check = Carbamidomethyl[C]' + '\n')
fp.write('mod_check = Oxidation[M],Phospho[Y],Phospho[S],Phospho[T]' + '\n')
fp.write('min_mod_check = 0' + '\n')
fp.write('max_mod_check = 3' + '\n')
fp.write('# format: peptide filename | instrument | NCE' + '\n')
fp.write('predict_input =' + predict_input + '\n')
fp.write('###### Data for fine-tuning, no tuning if it is empty. Files are seperated by ' + '\n')
fp.write('tune_psmlabels = ' + tune_psmlabels + '\n')
fp.write('###### Data for testing, no testing if it is empty. Files are seperated by ' + '\n')
fp.write('test_psmlabels = ' + test_psmlabels + '\n')

fp.close()


# Training model: nonPhospho

TrainingParamFile = sys.argv[10]
predict_input = sys.argv[11]
fp = open(TrainingParamFile,'w')
fp.write('model = ' + model_path + '\n')
fp.write('\n')
fp.write('threads = 4' + '\n')
fp.write('\n')
fp.write('###### predict ######' + '\n')
fp.write('mod_no_check = Carbamidomethyl[C]' + '\n')
fp.write('mod_check = Oxidation[M]' + '\n')
fp.write('min_mod_check = 0' + '\n')
fp.write('max_mod_check = 3' + '\n')
fp.write('# format: peptide filename | instrument | NCE' + '\n')
fp.write('predict_input =' + predict_input + '\n')
fp.write('###### Data for fine-tuning, no tuning if it is empty. Files are seperated by ' + '\n')
fp.write('tune_psmlabels = ' + tune_psmlabels + '\n')
fp.write('###### Data for testing, no testing if it is empty. Files are seperated by ' + '\n')
fp.write('test_psmlabels = ' + test_psmlabels + '\n')

fp.close()









