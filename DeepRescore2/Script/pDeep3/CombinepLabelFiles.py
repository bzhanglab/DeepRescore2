import os
import sys

pLabelPath = sys.argv[1]
pathout = sys.argv[2]
#pathin = '/data/xyi/DeepRescore/DeepRescore2/PXD000138/pDeep3/data/pLabel/TrainingData'
FileNames = os.listdir(pLabelPath)
#pathout = '/data/xyi/DeepRescore/DeepRescore2/PXD000138/pDeep3/data/pLabel/TrainingData.psmlabel'
fp = open(pathout,'w')
numrlt = 0
for FileName in FileNames:
    if '.swp' in FileName:
        continue
    print(FileName)

    filePath = pLabelPath + '/' + FileName
    file = open(filePath)
    lines = file.readlines()
    for line in lines:
        if line.startswith('spec'):
            if numrlt == 0:
                fp.write(line)
                numrlt = 1
            continue
        fp.write(line)
fp.close()

