import pDeep.cmd.tune_and_predict
import sys
from AAMass import AAMass

paramFile = sys.argv[1]
pathout = sys.argv[2]

predictResults = pDeep.cmd.tune_and_predict.run(paramFile)
#predictResults = pDeep.cmd.tune_and_predict.run('/data/xyi/DeepRescore/DeepRescore2/PXD000138/pDeep3/sh/pDeep-tune_TestData_Total.cfg')

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

#pathout = '/data/xyi/DeepRescore/DeepRescore2/PXD000138/pDeep3/data/PredictionResults/PredictMGF_TestData_Total.txt'

fp = open(pathout,'w')
for pepinfo, intensities in predictResults.peptide_intensity_dict.items():
    b_1_Intensity = []
    b_2_Intensity = []
    y_1_Intensity = []
    y_2_Intensity = []
    b_1_ModLossIntensity = []
    b_2_ModLossIntensity = []
    y_1_ModLossIntensity = []
    y_2_ModLossIntensity = []
    for i in range(len(intensities)):
        tmp = intensities[i]
        b_1_Intensity.append(tmp[0])
        b_2_Intensity.append(tmp[1])
        y_1_Intensity.append(tmp[2])
        y_2_Intensity.append(tmp[3])
        b_1_ModLossIntensity.append(tmp[4])
        b_2_ModLossIntensity.append(tmp[5])
        y_1_ModLossIntensity.append(tmp[6])
        y_2_ModLossIntensity.append(tmp[7])
    fp.write('BEGIN IONS'+'\n')
    fp.write('TITLE='+pepinfo+'\n')
    fp.write('pepinfo='+pepinfo+'\n')
    fp.write('b+1=')
    for i in range(len(b_1_Intensity)-1):
        fp.write(str(b_1_Intensity[i])+',')
    fp.write(str(b_1_Intensity[len(b_1_Intensity)-1])+'\n')
    fp.write('b+2=')
    for i in range(len(b_2_Intensity)-1):
        fp.write(str(b_2_Intensity[i])+',')
    fp.write(str(b_2_Intensity[len(b_2_Intensity)-1])+'\n')
    fp.write('y+1=')
    for i in range(len(y_1_Intensity)-1):
        fp.write(str(y_1_Intensity[i])+',')
    fp.write(str(y_1_Intensity[len(y_1_Intensity)-1])+'\n')
    fp.write('y+2=')
    for i in range(len(y_2_Intensity)-1):
        fp.write(str(y_2_Intensity[i])+',')
    fp.write(str(y_2_Intensity[len(y_2_Intensity)-1])+'\n')
    fp.write('b+1-ModLoss=')
    for i in range(len(b_1_ModLossIntensity)-1):
        fp.write(str(b_1_ModLossIntensity[i])+',')
    fp.write(str(b_1_ModLossIntensity[len(b_1_ModLossIntensity)-1])+'\n')
    fp.write('b+2-ModLoss=')
    for i in range(len(b_2_ModLossIntensity)-1):
        fp.write(str(b_2_ModLossIntensity[i])+',')
    fp.write(str(b_2_ModLossIntensity[len(b_2_ModLossIntensity)-1])+'\n')
    fp.write('y+1-ModLoss=')
    for i in range(len(y_1_ModLossIntensity)-1):
        fp.write(str(y_1_ModLossIntensity[i])+',')
    fp.write(str(y_1_ModLossIntensity[len(y_1_ModLossIntensity)-1])+'\n')
    fp.write('y+2-ModLoss=')
    for i in range(len(y_2_ModLossIntensity)-1):
        fp.write(str(y_2_ModLossIntensity[i])+',')
    fp.write(str(y_2_ModLossIntensity[len(y_2_ModLossIntensity)-1])+'\n')
    fp.write('END IONS' + '\n')
fp.close()




