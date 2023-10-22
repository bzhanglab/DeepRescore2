import os
import sys

#pathin = '/Users/yixinpei/Documents/PostDocResearch/DeepRescore2/BuildPipeline/PXD000138/MaxQuant3/PhosphoRS/Results_AddIsoformSequence'
#pathout = '/Users/yixinpei/Documents/PostDocResearch/DeepRescore2/BuildPipeline/PXD000138/MaxQuant3/PhosphoRS/PhosphoRS.txt'
pathin = sys.argv[1]
pathout = sys.argv[2]

fp = open(pathout,'w')
FileNames = os.listdir(pathin)
tmp = 1
for FileName in FileNames:
    
    if '.DS_Store' in FileName:
        continue
    
    FilePath = pathin + '/' + FileName
    file = open(FilePath)
    lines = file.readlines()
    for line in lines:
        if line.startswith('Spectrum.ID'):
            if tmp == 1:
                fp.write(line)
                tmp = 2
            continue
        fp.write(line)
fp.close()
