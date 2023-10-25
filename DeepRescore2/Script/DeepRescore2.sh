#!/bin/bash

echo "DeepRescore2!"

##Parameter path
#param_path="E:/Project/DeepRescore2/Github/DeepRescore2/Parameters/PXD023665_comet.param"

if [ -n "$1" ]; then
    param_path="$1"
else
    echo "Please give parameter path"
    exit 1
fi


#=======================================Step0: Preparation===========================#

echo "Step0: Preparation"

##Read parameter file
###Parameters used for identification
while read -r Name Value || [ -n "$Name" ]; do
  declare "$Name=$Value"
done < "$param_path"
scriptPath="$DeepRescore2Path/Script"
phosphoRSPath="$scriptPath/PhosphoRS/phosphoRS-cli/phosphoRS.exe"
pDeep3_modelPath="$scriptPath/pDeep3/PreTrainedPhosphoModel/transfer-phos-wb-QE.ckpt"
##New generated data
###Path to the PhosphoRS results file
phosphoRSResultsPath="$outputPath/PhosphoRS" 
TXTPath="$phosphoRSResultsPath/TXT"
xmlPath="$phosphoRSResultsPath/xml"
ResultsPath="$phosphoRSResultsPath/Results"
ResultsAddIsoformSequencePath="$phosphoRSResultsPath/Results_AddIsoformSequence"
## Path to the generated feature file
featurePath="$outputPath/Features"
## Path to the PGA filtering results file
PGAPath="$outputPath/PGA"
PGA_peptide_level_Path="$PGAPath/peptide_level"
PGA_psm_level_Path="$PGAPath/psm_level"
## Path for AutoRT and pDeep3 training and prediction data
dataPath="$outputPath/generate_train_prediction"
autoRT_trainPath="$dataPath/autoRT_train"
autoRT_predictionPath="$dataPath/autoRT_prediction"
pDeep3_trainPath="$outputPath/generate_train_prediction/pDeep3_train"
pDeep3_predictionPath="$outputPath/generate_train_prediction/pDeep3_prediction"
autoRT_resultsPath="$outputPath/autoRT_Results"
tf_modelPath="$autoRT_resultsPath/tf_model"
tf_predictionPath="$autoRT_resultsPath/tf_prediction"
pDeep3_resultsPath="$outputPath/pDeep3_Results"
pLabelPath="$pDeep3_resultsPath/pLabel"
PercolatorPath="$outputPath/Percolator"
Method1ResultsPath=$outputPath
DeepRescore2ResultsPath="$PercolatorPath/DeepRescore2"
###Modifications
if [ "$FixedMods" != "null" ]; then
  Mods="$VariableMods;$FixedMods"
else
  Mods="$VariableMods"
fi
###Judge folder exit or not if not build it
folders=($phosphoRSResultsPath $TXTPath $xmlPath $ResultsPath $ResultsAddIsoformSequencePath
         $featurePath $PGAPath $PGA_peptide_level_Path $PGA_psm_level_Path
         $dataPath $autoRT_trainPath $autoRT_predictionPath $pDeep3_trainPath $pDeep3_predictionPath
         $autoRT_resultsPath $tf_modelPath $tf_predictionPath $pDeep3_resultsPath $pLabelPath $PercolatorPath
         $Method1ResultsPath $DeepRescore2ResultsPath)

for folder in "${folders[@]}"; do
  if [ ! -d "$folder" ]; then
    mkdir -p "$folder"
    #echo "Folder $folder created."
  fi
done

cat "$spectraPath"/*.mgf > "$outputPath/Combined.mgf"

###Add information into feature table

source $anacondaPath/etc/profile.d/conda.sh
conda activate R_env

####MaxQuant
if [ "$searchEngine" = "maxquant" ]; then
  AddModificationAdjustChargeCommand="python $scriptPath/Features/AddModifedSequenceAdjustCharge.py \
    \"$inputFeaturePath\" \
    \"$spectraPath\" \
    \"$featurePath/features.txt\" \
    \"$Mods\" \
    \"$ModsReplace\""
  eval "$AddModificationAdjustChargeCommand"
fi
####Comet, MSGF, X!Tandem
if [ "$searchEngine" = "comet" ] || [ "$searchEngine" = "msgf" ] || [ "$searchEngine" = "xtandem" ]; then
  AddModifedSequenceCommand="python $scriptPath/Features/AddModifedSequence.py \
    \"$inputFeaturePath\" \
    \"$featurePath/features.txt\" \
    \"$Mods\" \
    \"$ModsReplace\""
  eval "$AddModifedSequenceCommand"
fi

#====================================================================================#

#=======================================Step1: Phosphosite localization using PhosphoRS===========================#

echo "Step1: Phosphosite localization using PhosphoRS"
echo "Step1.1: Generate PhosphoRS input"
GeneratePhosphoRSInput_Command1="python $scriptPath/PhosphoRS/GeneratePhosphoRSCSVFile.py $featurePath/features.txt $TXTPath"
$GeneratePhosphoRSInput_Command1

GeneratePhosphoRSInput_Command2="Rscript $scriptPath/PhosphoRS/generate_phosphoRS_input_xml_folder.R \
                                \"$TXTPath\" \
                                \"$spectraPath\" \
                                \"$xmlPath\" \
                                \"$Mods\""
eval "$GeneratePhosphoRSInput_Command2"

echo "Step1.2: Run PhosphoRS"
files=$(ls $xmlPath)
for file in $files; do
  file_path="$xmlPath/$file"
  name="${file/.xml/.csv}"
  output_path="$ResultsPath/$name"

  RunPhosphoRS_Command="$phosphoRSPath -i $file_path -o $output_path"

  $RunPhosphoRS_Command

  echo "Processing File: $name"
done

echo "Step1.3: Add Isoform Sequence"
AddIsoformSequence_Command="python $scriptPath/PhosphoRS/AddIsoformSequenceForPhosphoRSResults.py \
\"$TXTPath\" \
\"$ResultsPath\" \
\"$featurePath/features.txt\" \
\"$ResultsAddIsoformSequencePath\" \
\"$featurePath/features2.txt\" \
\"$Mods\""
eval "$AddIsoformSequence_Command"

echo "Step1.4: Combine PhosphoRS Results"
CombinePhosphoRSResults_Command="python $scriptPath/PhosphoRS/CombinePhosphoRSResults.py \
$ResultsAddIsoformSequencePath $phosphoRSResultsPath/PhosphoRS.txt"
eval "$CombinePhosphoRSResults_Command"

echo "Step1.5: Add PhosphoRS Results To Features"
AddPhosphoRSToFeatures_Command="Rscript $scriptPath/PhosphoRS/combine_features_withlocalization.R \
$featurePath/features2.txt \
$phosphoRSResultsPath/PhosphoRS.txt \
$featurePath/features.PhosphoRS.txt"
eval "$AddPhosphoRSToFeatures_Command"

echo "Step1.6: Add PhosphoRS Probability"
AddPhosphoRSProbability_Command="python $scriptPath/PhosphoRS/GetPhosphoRSSiteProbability.py \
$featurePath/features.PhosphoRS.txt \
$featurePath/features.PhosphoRS.txt"
eval "$AddPhosphoRSProbability_Command"

#====================================================================================#

#=======================================Step2: Sequence quality control using PGA===========================#

echo "Step 2: Sequence quality control using PGA"
echo "Step2.1: Generate PGA input"

GeneratePGAInput_Command="Rscript $scriptPath/PGA/got_pga_input.R \
$featurePath/features.PhosphoRS.txt \
$searchEngine \
$PGAPath/pga-rawPSMs.txt"
eval "$GeneratePGAInput_Command"

conda deactivate

echo "Step2.2: Docker run PGA"
docker_Command="docker run -it --rm -v $outputPath:/opt/ -t proteomics/pga:latest Rscript"
cp "$scriptPath/PGA/calculate_fdr.R" "$PGAPath/"
cd "$outputPath"
Calculate_FDR_Command="$docker_Command ./PGA/calculate_fdr.R \
\"./PGA/\" \
\"pga\" \
\"$decoyPrefix\" \
\"FALSE\""
eval "$Calculate_FDR_Command"
rm $outputPath/PGA/calculate_fdr.R

#====================================================================================#

#=======================================Step 3: Generate train and prediction datasets===========================#

echo "Step 3: Generate train and prediction datasets"

source $anacondaPath/etc/profile.d/conda.sh
conda activate R_env

generate_train_prediction_Command="Rscript $scriptPath/generate_train_prediction/got_train_prediction.R \
\"$PGAPath/peptide_level/pga-peptideSummary.txt\" \
\"$PGAPath/psm_level/pga-peptideSummary.txt\" \
\"$featurePath/features.PhosphoRS.txt\" \
\"$autoRT_trainPath/\" \
\"$autoRT_predictionPath/\" \
\"$pDeep3_trainPath/\" \
\"$pDeep3_predictionPath/\" \
\"$PGAPath/pga-rawPSMs.txt\" \
\"$phosphoRSResultsPath/PhosphoRS.txt\" \
\"$VariableMods\" \
\"$FixedMods\""
eval "$generate_train_prediction_Command"

conda deactivate

#====================================================================================#

#=======================================Step 4: RT prediction using AutoRT===========================#

echo "Step 4: RT prediction using AutoRT"

source $anacondaPath/etc/profile.d/conda.sh
conda activate AutoRT

echo "Step 4.1: AutoRT Train"
autoRT_train_Command="python $scriptPath/AutoRT/autort.py train -i $autoRT_trainPath/auto_rt_train.txt -o $tf_modelPath/ -e 40 -b 64 -u m -m $scriptPath/AutoRT/models/ptm_base_model/phosphorylation_sty/model.json -rlr -n 10 -g 1"
$autoRT_train_Command
echo "Step 4.2: AutoRT Predict Phospho"
autoRT_predict_phospho_Command="python $scriptPath/AutoRT/autort.py predict -t $autoRT_predictionPath/auto_rt_prediction.Phospho.txt -s $tf_modelPath/model.json -o $tf_predictionPath/ -p phospho.prediction"
$autoRT_predict_phospho_Command
echo "Step 4.3: AutoRT Predict nonPhospho"
autoRT_predict_nonPhospho_Command="python $scriptPath/AutoRT/autort.py predict -t $autoRT_predictionPath/auto_rt_prediction.nonPhospho.txt -s $tf_modelPath/model.json -o $tf_predictionPath/ -p nonPhospho.prediction"
$autoRT_predict_nonPhospho_Command

conda deactivate

#====================================================================================#

#=======================================Step 5: Spectrum prediction using pDeep3===========================#

echo "Step 5: Spectrum prediction using pDeep3"

source $anacondaPath/etc/profile.d/conda.sh
conda activate pDeep3

echo "Step 5.1: Generate pDeep3 parameters"
generate_pLabel_parameters_Command="python $scriptPath/pDeep3/generate_pLabel_parameters.py $pDeep3_trainPath/pdeep3_train.txt $rawSpectraPath $pLabelPath $pDeep3_resultsPath/pLabelParams.cfg $pDeep3_resultsPath/Train.Phospho.cfg $pDeep3_predictionPath/pdeep3_prediction.Phospho.txt $pDeep3_resultsPath/TrainingData.psmlabel $pDeep3_resultsPath/TrainingData.psmlabel $pDeep3_modelPath $pDeep3_resultsPath/Train.nonPhospho.cfg $pDeep3_predictionPath/pdeep3_prediction.nonPhospho.txt"
$generate_pLabel_parameters_Command
echo "Step 5.2: Run psmLabel"
cd "$scriptPath/pDeep3/pDeep3/pDeep/psmLabel/"
psmLabel_Command="./psmLabel.exe $pDeep3_resultsPath/pLabelParams.cfg"
eval "$psmLabel_Command"
echo "Step 5.3: Combine pLabel"
combine_pLabel_Command="python $scriptPath/pDeep3/CombinepLabelFiles.py $pLabelPath $pDeep3_resultsPath/TrainingData.psmlabel"
$combine_pLabel_Command
echo "Step 5.4: pDeep3 for Phospho"
run_Phospho_Command="python $scriptPath/pDeep3/Run/run.py $pDeep3_resultsPath/Train.Phospho.cfg $pDeep3_resultsPath/pDeep3_Predict.Phospho.txt"
eval "$run_Phospho_Command"
echo "Step 5.5: pDeep3 for nonPhospho"
run_nonPhospho_Command="python $scriptPath/pDeep3/Run/run.py $pDeep3_resultsPath/Train.nonPhospho.cfg $pDeep3_resultsPath/pDeep3_Predict.nonPhospho.txt"
eval "$run_nonPhospho_Command"
echo "Step 5.6: Run Spectral Entropy"
cd "$scriptPath/pDeep3/SpectralEntropy/"
build_SpectralEntropy_Command="python setup.py build_ext --inplace"
$build_SpectralEntropy_Command
run_Phospho_SpectralEntropy_Command="python $scriptPath/pDeep3/SpectralEntropy/program.py $pDeep3_predictionPath/pdeep3_prediction.Phospho.txt $outputPath/Combined.mgf $pDeep3_resultsPath/pDeep3_Predict.Phospho.txt $pDeep3_resultsPath/pDeep3PredictionResults.Phospho.txt"
$run_Phospho_SpectralEntropy_Command
run_nonPhospho_SpectralEntropy_Command="python $scriptPath/pDeep3/SpectralEntropy/program.py $pDeep3_predictionPath/pdeep3_prediction.nonPhospho.txt $outputPath/Combined.mgf $pDeep3_resultsPath/pDeep3_Predict.nonPhospho.txt $pDeep3_resultsPath/pDeep3PredictionResults.nonPhospho.txt"
$run_nonPhospho_SpectralEntropy_Command

conda deactivate

#====================================================================================#

#=======================================Step 6: Deep-relocalization===========================#

echo "Step 6: Deep-relocalization"

source $anacondaPath/etc/profile.d/conda.sh
conda activate R_env

run_DeepLocalization_Command="Rscript $scriptPath/DeepRelocalization/calculate_localization_probability_entropy.R \
\"$phosphoRSResultsPath/PhosphoRS.txt\" \
\"$autoRT_resultsPath/tf_prediction/phospho.prediction.tsv\" \
\"$pDeep3_resultsPath/pDeep3PredictionResults.Phospho.txt\" \
\"$featurePath/features.PhosphoRS.txt\" \
\"$featurePath/Features.Localization.entropy.txt\" \
\"$VariableMods\" \
\"$FixedMods\""
eval "$run_DeepLocalization_Command"

#====================================================================================#

#=======================================Step 7: Rescoring using Percolator===========================#

echo "Step 7: Rescoring using Percolator"
echo "Step 7.1: Method1 Results"

Method1Results_Command="Rscript $scriptPath/Percolator/PhosphoRSResults.R $PGAPath/peptide_level/pga-peptideSummary.txt $PGAPath/psm_level/pga-peptideSummary.txt $featurePath/Features.Localization.entropy.txt $Method1ResultsPath/Method1Results.txt"
$Method1Results_Command
echo "Step 7.2: Generate Percolator Input"
GeneratePercolatorInput_Command="Rscript $scriptPath/Percolator/format_percolator_input_DeepRescore2.R \
\"$featurePath/Features.Localization.entropy.txt\" \
\"$PGAPath/pga-rawPSMs.txt\" \
\"$PercolatorPath/DeepRescore2.pin\" \
\"$searchEngine\" \
\"$phosphoRSResultsPath/PhosphoRS.txt\" \
\"$pDeep3_resultsPath/pDeep3PredictionResults.Phospho.txt\" \
\"$pDeep3_resultsPath/pDeep3PredictionResults.nonPhospho.txt\" \
\"$autoRT_resultsPath/tf_prediction/phospho.prediction.tsv\" \
\"$autoRT_resultsPath/tf_prediction/nonPhospho.prediction.tsv\" \
\"$VariableMods\" \
\"$FixedMods\""
eval "$GeneratePercolatorInput_Command"

conda deactivate

echo "Step 7.3: Run Percolator"
docker_Command="docker run -it --rm -v $outputPath/:/data/ -t bzhanglab/percolator:3.4 percolator"
Percolator_Command="$docker_Command ./Percolator/DeepRescore2.pin -r ./Percolator/DeepRescore2/DeepRescore2.pep.txt -m ./Percolator/DeepRescore2/DeepRescore2.psms.txt -w ./Percolator/DeepRescore2/DeepRescore2.weights.txt -M ./Percolator/DeepRescore2/DeepRescore2.decoy.psms.txt"
eval "$Percolator_Command"

#====================================================================================#

#=======================================Step 8: Get DeepRescore2 Results===========================#
echo "Step 8: DeepRescore2 Results"

source $anacondaPath/etc/profile.d/conda.sh
conda activate R_env

DeepRescore2Results_Command="Rscript $scriptPath/Percolator/GetDeepRescore2Results.R $featurePath $DeepRescore2ResultsPath $outputPath"
$DeepRescore2Results_Command

conda deactivate

#====================================================================================#


