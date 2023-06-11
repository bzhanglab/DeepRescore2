
#==============Load parameters=================#
args <- commandArgs(T)
paraPath <- args[1]
Parameters <- read.delim(paraPath,sep = '\t')
rownames(Parameters) <- Parameters$Name
# Parameters used for identification
decoyPrefix <- Parameters['decoyPrefix','Value']
searchEngine <- Parameters['searchEngine','Value']
inputPath <- Parameters['inputPath','Value']
rawSpectraPath <- Parameters['rawSpectraPath','Value']
spectraPath <- Parameters['spectraPath','Value']
databasePath <- Parameters['databasePath','Value']
inputFeaturePath <- Parameters['inputFeaturePath','Value']
VariableMods <- Parameters['VariableMods','Value']
FixedMods <- Parameters['FixedMods','Value']
ModsReplace <- Parameters['ModsReplace','Value']
# Software
DeepRescore2Path = Parameters['DeepRescore2Path','Value']
scriptPath = paste0(DeepRescore2Path,'/Script')
javaPath = Parameters['javaPath','Value']
pythonPath = Parameters['pythonPath','Value']
phosphoRSPath = paste0(gsub('/','\\\\',scriptPath),'\\PhosphoRS\\phosphoRS-cli\\phosphoRS.exe')
pDeep3_modelPath = paste0(scriptPath,'/pDeep3/pDeep3/pDeep/tmp/model/PreTrainedPhosphoModel/transfer-phos-wb-QE.ckpt')
# DeepRescore2 output path
outputPath <- Parameters['outputPath','Value']

setwd(DeepRescore2Path)

# New generated data
phosphoRSResultsPath = paste0(outputPath,'/PhosphoRS') # Path to the PhosphoRS results file
TXTPath = paste0(phosphoRSResultsPath,'/TXT')
xmlPath = paste0(phosphoRSResultsPath,'/xml')
ResultsPath = paste0(phosphoRSResultsPath,'/Results')
ResultsAddIsoformSequencePath = paste0(phosphoRSResultsPath,'/Results_AddIsoformSequence')
featurePath = paste0(outputPath,'/Features') # Path to the generated feature file
PGAPath = paste0(outputPath,'/PGA') # Path to the PGA filtering results file
PGA_peptide_level_Path = paste0(PGAPath,'/','peptide_level')
PGA_psm_level_Path = paste0(PGAPath,'/','psm_level')
dataPath = paste0(outputPath,'/generate_train_prediction') # Path for AutoRT and pDeep3 training and prediction data
autoRT_trainPath = paste0(dataPath,'/','autoRT_train')
autoRT_predictionPath = paste0(dataPath,'/','autoRT_prediction')
pDeep3_trainPath = paste0(outputPath,'/generate_train_prediction/','pDeep3_train')
pDeep3_predictionPath = paste0(outputPath,'/generate_train_prediction/','pDeep3_prediction')
autoRT_resultsPath = paste0(outputPath,'/autoRT_Results')
tf_modelPath = paste0(autoRT_resultsPath,'/','tf_model')
tf_predictionPath = paste0(autoRT_resultsPath,'/','tf_prediction')
pDeep3_resultsPath =  paste0(outputPath,'/pDeep3_Results')
pLabelPath = paste0(pDeep3_resultsPath,'/pLabel')
PercolatorPath = paste0(outputPath,'/Percolator')
Method1ResultsPath = outputPath
DeepRescore2ResultsPath = paste0(PercolatorPath, '/DeepRescore2')

if (FixedMods!='null'){
  Mods = paste0(VariableMods,';',FixedMods)
}else{
  Mods = VariableMods
}

# Judge folder exit or not if not build it
print("Preparation")

folders <- c(phosphoRSResultsPath, TXTPath, xmlPath, ResultsPath, ResultsAddIsoformSequencePath,
             featurePath, PGAPath, PGA_peptide_level_Path, PGA_psm_level_Path,
             dataPath, autoRT_trainPath, autoRT_predictionPath, pDeep3_trainPath, pDeep3_predictionPath,
             autoRT_resultsPath, tf_modelPath, tf_predictionPath, pDeep3_resultsPath, pLabelPath, PercolatorPath, 
             Method1ResultsPath, DeepRescore2ResultsPath)

for (folder in folders) {
  if (!dir.exists(folder)) {
    dir.create(folder)
    #cat(paste("Folder", folder, "created.\n"))
  }
}

file_paths <- list.files(spectraPath)
merged_content <- character()
for (file_path in file_paths) {
  content <- readLines(paste0(spectraPath,'/',file_path))
  merged_content <- c(merged_content, content)
}
writeLines(merged_content, paste0(outputPath,'/Combined.mgf'))

if (searchEngine == 'maxquant'){
  AddModificationAdjustChargeCommand <- paste(pythonPath, './Script/Features/AddModifedSequenceAdjustCharge.py',
                                               shQuote(inputFeaturePath),
                                               shQuote(spectraPath),
                                               shQuote(paste0(featurePath, '/features.txt')),
                                               shQuote(Mods),
                                               shQuote(ModsReplace),collapse = " ")
  system(AddModificationAdjustChargeCommand)
}
if (searchEngine == 'comet' || searchEngine == 'msgf' || searchEngine == 'xtandem'){
  AddModifedSequenceCommand <- paste(pythonPath, './Script/Features/AddModifedSequence.py',  
                                     shQuote(inputFeaturePath), 
                                     shQuote(paste0(featurePath, '/features.txt')), 
                                     shQuote(Mods),
                                     shQuote(ModsReplace),collapse = " ")
  system(AddModifedSequenceCommand)
}

# Step 1: Phosphosite localization using PhosphoRS
print("Step 1: Phosphosite localization using PhosphoRS")

GeneratePhosphoRSInput_Command1  <- paste0(pythonPath, ' ./Script/PhosphoRS/GeneratePhosphoRSCSVFile.py', ' ', 
                                           featurePath, '/features.txt', ' ',
                                           TXTPath)
system(GeneratePhosphoRSInput_Command1)

GeneratePhosphoRSInput_Command2  <- paste0('Rscript', ' ', 
                                           './Script/PhosphoRS/generate_phosphoRS_input_xml_folder.R', ' ', 
                                           TXTPath, ' ', 
                                           spectraPath, ' ',
                                           xmlPath, ' ', 
                                           Mods)
system(GeneratePhosphoRSInput_Command2)

files <- list.files(xmlPath)
for (i in 1:length(files)){
  file_path <- paste0(xmlPath,'/',files[i])
  file_path <- gsub('/','\\\\',file_path)
  
  name <- gsub(".xml", ".csv", files[i])
  output_path <- paste0(ResultsPath,'/',name)
  output_path <- gsub('/','\\\\',output_path)
  
  RunPhosphoRS_Command <- paste0(phosphoRSPath, ' -i ', file_path, ' -o ', output_path)
  
  system(RunPhosphoRS_Command)
  
  print(paste0('MGF',i))
}

AddIsoformSequence_Command <- paste0(pythonPath, ' ./Script/PhosphoRS/AddIsoformSequenceForPhosphoRSResults.py', ' ', 
                                     TXTPath, ' ', 
                                     ResultsPath, ' ',
                                     featurePath, '/features.txt', ' ',
                                     ResultsAddIsoformSequencePath, ' ',
                                     featurePath, '/features2.txt', ' ',
                                     Mods
)
system(AddIsoformSequence_Command)

CombinePhosphoRSResults_Command <- paste0(pythonPath, ' ./Script/PhosphoRS/CombinePhosphoRSResults.py', ' ',
                                          ResultsAddIsoformSequencePath, ' ',
                                          phosphoRSResultsPath, '/PhosphoRS.txt'
)
system(CombinePhosphoRSResults_Command)

AddPhosphoRSToFeatures_Command <- paste0('Rscript ./Script/PhosphoRS/combine_features_withlocalization.R', ' ',
                                         featurePath, '/features2.txt', ' ',
                                         phosphoRSResultsPath, '/PhosphoRS.txt', ' ',
                                         featurePath, '/features.PhosphoRS.txt'
)
system(AddPhosphoRSToFeatures_Command)

AddPhosphoRSProbability_Command <- paste0(pythonPath, ' ./Script/PhosphoRS/GetPhosphoRSSiteProbability.py', ' ',
                                          featurePath, '/features.PhosphoRS.txt', ' ',
                                          featurePath, '/features.PhosphoRS.txt')
system(AddPhosphoRSProbability_Command)

# Step 2: Sequence quality control using PGA
print("Step 2: Sequence quality control using PGA")

GeneratePGAInput_Command <- paste0('Rscript ./Script/PGA/got_pga_input.R', ' ',
                                   featurePath, '/features.PhosphoRS.txt', ' ', 
                                   searchEngine, ' ', 
                                   PGAPath, '/pga-rawPSMs.txt')
system(GeneratePGAInput_Command)

docker_Command <- paste0('docker run -it --rm -v', ' ', 
                         outputPath,
                         '/:/opt/ -t proteomics/pga:latest', ' ',
                         'Rscript'
                         )

file.copy(from='./Script/PGA/calculate_fdr.R', to=paste0(PGAPath,'/'), 
          overwrite = TRUE, recursive = FALSE, 
          copy.mode = TRUE)

setwd(outputPath)

Calculate_FDR_Command <- paste0(docker_Command, ' ', './PGA/calculate_fdr.R', ' ', 
                                './PGA/', '/', ' ', 
                                databasePath, ' ', 
                                decoyPrefix, ' FALSE')
system(Calculate_FDR_Command, intern = TRUE)
file.remove('./PGA/calculate_fdr.R')

setwd(DeepRescore2Path)

# Step 3: Generate train and prediction datasets
print("Step 3: Generate train and prediction datasets")

generate_train_prediction_Command <- paste0('Rscript ./Script/generate_train_prediction/got_train_prediction.R', ' ',
                                            PGAPath,'/peptide_level/pga-peptideSummary.txt', ' ',
                                            PGAPath,'/psm_level/pga-peptideSummary.txt', ' ',
                                            featurePath, '/features.PhosphoRS.txt', ' ',
                                            autoRT_trainPath, '/ ',
                                            autoRT_predictionPath, '/ ',
                                            pDeep3_trainPath, '/ ',
                                            pDeep3_predictionPath, '/ ',
                                            PGAPath, '/pga-rawPSMs.txt', ' ',
                                            phosphoRSResultsPath, '/PhosphoRS.txt', ' ',
                                            VariableMods, ' ',
                                            FixedMods
                                            )
system(generate_train_prediction_Command)

# Step 4: RT prediction using AutoRT
print("Step 4: RT prediction using AutoRT")

autoRT_train_Command <- paste0(pythonPath, ' ',
                               './Script/AutoRT/autort.py train -i ',
                               autoRT_trainPath,'/auto_rt_train.txt ',
                               '-o ', tf_modelPath, '/ ',
                               '-e 40 -b 64 -u m -m ',
                               './Script/AutoRT/', 'models/ptm_base_model/phosphorylation_sty/model.json ',
                               '-rlr -n 10 -g 1')
system(autoRT_train_Command)



autoRT_predict_phospho_Command <- paste0(pythonPath, ' ',
                                         './Script/AutoRT/autort.py predict -t ',
                                         autoRT_predictionPath,'/auto_rt_prediction.Phospho.txt ',
                                         '-s ', tf_modelPath, '/model.json ',
                                         '-o ', tf_predictionPath, '/ ',
                                         '-p phospho.prediction')
system(autoRT_predict_phospho_Command)

autoRT_predict_nonPhospho_Command <- paste0(pythonPath, ' ',
                                            './Script/AutoRT/autort.py predict -t ',
                                            autoRT_predictionPath,'/auto_rt_prediction.nonPhospho.txt ',
                                            '-s ', tf_modelPath, '/model.json ',
                                            '-o ', tf_predictionPath, '/ ',
                                            '-p nonPhospho.prediction')
system(autoRT_predict_nonPhospho_Command)


#### Step 5: Spectrum prediction using pDeep3
print("Step 5: Spectrum prediction using pDeep3")

generate_pLabel_parameters_Command <- paste0(pythonPath, ' ',
                                             './Script/pDeep3/generate_pLabel_parameters.py', ' ',
                                             pDeep3_trainPath, '/pdeep3_train.txt', ' ',
                                             rawSpectraPath, ' ',
                                             pLabelPath, ' ',
                                             pDeep3_resultsPath, '/pLabelParams.cfg', ' ',
                                             pDeep3_resultsPath, '/Train.Phospho.cfg', ' ',
                                             pDeep3_predictionPath, '/pdeep3_prediction.Phospho.txt', ' ',
                                             pDeep3_resultsPath, '/TrainingData.psmlabel', ' ',
                                             pDeep3_resultsPath, '/TrainingData.psmlabel', ' ',
                                             pDeep3_modelPath, ' ',
                                             pDeep3_resultsPath, '/Train.nonPhospho.cfg', ' ',
                                             pDeep3_predictionPath, '/pdeep3_prediction.nonPhospho.txt'
)
system(generate_pLabel_parameters_Command)

setwd(paste0(DeepRescore2Path,'/Script/pDeep3/psmLabel'))
pDeep3_resultsPath2 <- gsub('/','\\\\',pDeep3_resultsPath)
psmLabel_Command <- paste0('psmLabel.exe ', pDeep3_resultsPath2, '\\pLabelParams.cfg')
system(psmLabel_Command)

setwd(DeepRescore2Path)
combine_pLabel_Command <- paste0(pythonPath, ' ',
                                 './Script/pDeep3/CombinepLabelFiles.py', ' ',
                                 pLabelPath, ' ',
                                 pDeep3_resultsPath, '/TrainingData.psmlabel'
)
system(combine_pLabel_Command)

run_Phospho_Command <- paste0('./Script/pDeep3/Run/run.py', ' ',
                              pDeep3_resultsPath, '/Train.Phospho.cfg', ' ',
                              pDeep3_resultsPath, '/pDeep3_Predict.Phospho.txt'
)
#system(run_Phospho_Command)
system2(command = "conda", args = c("run", "-n", "pDeep3", "python", run_Phospho_Command))

run_nonPhospho_Command <- paste0('./Script/pDeep3/Run/run.py', ' ',
                                 pDeep3_resultsPath, '/Train.nonPhospho.cfg', ' ',
                                 pDeep3_resultsPath, '/pdeep3_Predict.nonPhospho.txt'
)
#system(run_nonPhospho_Command)
system2(command = "conda", args = c("run", "-n", "pDeep3", "python", run_nonPhospho_Command))

setwd(paste0(DeepRescore2Path,'/Script/pDeep3/SpectralEntropy'))

build_SpectralEntropy_Command <- paste0(pythonPath, ' ',
                                        'setup.py build_ext --inplace'
)
system(build_SpectralEntropy_Command)

run_Phospho_SpectralEntropy_Command <- paste0(pythonPath, ' ',
                                              'program.py', ' ',
                                              pDeep3_predictionPath, '/pdeep3_prediction.Phospho.txt', ' ',
                                              outputPath, '/Combined.mgf', ' ',
                                              pDeep3_resultsPath, '/pDeep3_Predict.Phospho.txt', ' ',
                                              pDeep3_resultsPath, '/pDeep3PredictionResults.Phospho.txt'
)
system(run_Phospho_SpectralEntropy_Command)

run_nonPhospho_SpectralEntropy_Command <- paste0(pythonPath, ' ',
                                                 'program.py', ' ',
                                                 pDeep3_predictionPath, '/pdeep3_prediction.nonPhospho.txt', ' ',
                                                 outputPath, '/Combined.mgf', ' ',
                                                 pDeep3_resultsPath, '/pDeep3_Predict.nonPhospho.txt', ' ',
                                                 pDeep3_resultsPath, '/pDeep3PredictionResults.nonPhospho.txt'
)
system(run_nonPhospho_SpectralEntropy_Command)

# Step 6: Deep-relocalization
print("Step 6: Deep-relocalization")

setwd(DeepRescore2Path)
run_DeepLocalization_Command <- paste0('Rscript ./Script/DeepRelocalization/calculate_localization_probability_entropy.R', ' ',
                                       phosphoRSResultsPath, '/PhosphoRS.txt', ' ',
                                       autoRT_resultsPath, '/tf_prediction/phospho.prediction.tsv', ' ',
                                       pDeep3_resultsPath, '/pDeep3PredictionResults.Phospho.txt', ' ',
                                       featurePath, '/features.PhosphoRS.txt', ' ',
                                       featurePath,'/Features.Localization.entropy.txt', ' ',
                                       VariableMods, ' ',
                                       FixedMods
)
system(run_DeepLocalization_Command)

# Step 7: Rescoring using Percolator
print("Step 7: Rescoring using Percolator")

PhosphoRSResults_Command <- paste0('Rscript ./Script/Percolator/PhosphoRSResults.R', ' ',
                                   PGAPath, '/peptide_level/pga-peptideSummary.txt', ' ',
                                   PGAPath, '/psm_level/pga-peptideSummary.txt', ' ',
                                   featurePath, '/Features.Localization.entropy.txt', ' ',
                                   Method1ResultsPath, '/Method1Results.txt'
)
system(PhosphoRSResults_Command)

GeneratePercolatorInput_Command <- paste0('Rscript ./Script/Percolator/format_percolator_input_DeepRescore2.R', ' ',
                                          featurePath, '/Features.Localization.entropy.txt', ' ',
                                          PGAPath, '/pga-rawPSMs.txt', ' ',
                                          PercolatorPath, '/DeepRescore2.pin', ' ',
                                          searchEngine, ' ',
                                          phosphoRSResultsPath, '/PhosphoRS.txt', ' ',
                                          pDeep3_resultsPath, '/pDeep3PredictionResults.Phospho.txt', ' ',
                                          pDeep3_resultsPath, '/pDeep3PredictionResults.nonPhospho.txt', ' ',
                                          autoRT_resultsPath, '/tf_prediction/phospho.prediction.tsv', ' ',
                                          autoRT_resultsPath, '/tf_prediction/nonPhospho.prediction.tsv', ' ',
                                          VariableMods, ' ',
                                          FixedMods
)
system(GeneratePercolatorInput_Command)

setwd(outputPath)
docker_Command <- paste0('docker run -it --rm -v ', 
                         outputPath,
                         '/:/data/ -t bzhanglab/percolator:3.4 percolator')
Percolator_Command <- paste0(docker_Command, ' ',
                             './Percolator/DeepRescore2.pin', 
                             ' -r ', './Percolator/DeepRescore2', '/DeepRescore2.pep.txt', 
                             ' -m ', './Percolator/DeepRescore2', '/DeepRescore2.psms.txt', 
                             ' -w ', './Percolator/DeepRescore2', '/DeepRescore2.weights.txt' , 
                             ' -M ', './Percolator/DeepRescore2', '/DeepRescore2.decoy.psms.txt')
system(Percolator_Command, intern = TRUE)

# Get DeepRescore2 results
library(data.table)
library(tidyverse)
all_features <- fread(paste0(featurePath,'/Features.Localization.entropy.txt'))
DeepRescore2 <- fread(paste0(DeepRescore2ResultsPath,'/DeepRescore2.psms.txt'))
DeepRescore2 <- DeepRescore2[DeepRescore2$`q-value`<=0.01,]
DeepRescore2 <- all_features %>% filter(Title %in% DeepRescore2$PSMId)
DeepRescore2_Results <- DeepRescore2[DeepRescore2$autort_pDeep_Prob>=0.75,]
write.table(DeepRescore2_Results,
            paste0(outputPath,'/DeepRescore2Results.txt'),
            sep = '\t',
            row.names = FALSE,
            quote = FALSE)


