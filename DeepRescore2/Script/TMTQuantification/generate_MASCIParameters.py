import sys
import os

pathin = sys.argv[1]
FileNames = os.listdir(pathin)
pathout = sys.argv[2]
fp = open(pathout,'w')
pathout2 = sys.argv[3]
TMTType = sys.argv[4]

if TMTType == 'TMT10':
    for FileName in FileNames:
        if '.raw' in FileName:
            FilePath = pathin + '/' + FileName
            fp.write('./Script/TMTQuantification/MASCI/MASIC_Console.exe' + ' ' + '/P:"' + './Script/TMTQuantification/MASCI_param/TMT10_LTQ-FT_10ppm_ReporterTol0.003Da_2014-08-06.xml"'
                + ' ' + '/I:"' + FilePath + '"' + ' ' + '/O:"' + pathout2 + '"' + '\n')
    fp.close()

if TMTType == 'TMT11':
    for FileName in FileNames:
        if '.raw' in FileName:
            FilePath = pathin + '/' + FileName
            fp.write('./Script/TMTQuantification/MASCI/MASIC_Console.exe' + ' ' + '/P:"' + './Script/TMTQuantification/MASCI_param/TMT11_LTQ-FT_10ppm_ReporterTol0.003Da_2017-03-17.xml"'
                + ' ' + '/I:"' + FilePath + '"' + ' ' + '/O:"' + pathout2 + '"' + '\n')
    fp.close()


