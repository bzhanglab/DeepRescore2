library(tidyverse)
library(data.table)

args <- commandArgs(T)
features <- fread(args[1])
raw_psms <- fread(args[2]) %>% select(index)
output <- args[3]
software <- args[4]
phosphors <- fread(args[5])
pdeep_phospho <- fread(args[6])
pdeep_nonphospho <- fread(args[7])
autort_phospho <- fread(args[8])
autort_nonphospho <- fread(args[9])
VariableMods <- args[10]
FixedMods <- args[11]

if (FALSE){
features <- fread('/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/BuildPipeline/PXD023665_Part3/Comet2/Features/Features_Localization/Features.Localization.entropy.txt')
raw_psms <- fread('/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/BuildPipeline/PXD023665_Part3/Comet2/PGA/pga-rawPSMs.txt') %>% select(index)
output <- '/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/ManuscriptRevison_MCP/FirstRound/ResponseCode/DeepRescore2Pipeline/test/DeepRescore2.pin'
software='maxquant'
phosphors <- fread('/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/BuildPipeline/PXD023665_Part3/Comet2/PhosphoRS/PhosphoRS.txt')
pdeep_phospho <- fread('/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/BuildPipeline/PXD023665_Part3/Comet2/pDeep3/pDeep3PredictionResults.Phospho.txt')
pdeep_nonphospho <- fread('/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/BuildPipeline/PXD023665_Part3/Comet2/pDeep3/pDeep3PredictionResults.nonPhospho.txt')
autort_phospho <- fread('/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/BuildPipeline/PXD023665_Part3/Comet2/AutoRT/autoRT_Results/tf_prediction/phospho.prediction.tsv')
autort_nonphospho <- fread('/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/BuildPipeline/PXD023665_Part3/Comet2/AutoRT/autoRT_Results/tf_prediction/nonPhospho.prediction.tsv')
VariableMods = '1,Oxidation,M,15.994919,1;2,Phospho,S,79.966331,2;3,Phospho,T,79.966331,2;4,Phospho,Y,79.966331,2' # Identification modifications
FixedMods = '5,Carbamidomethyl,C,57.021464,3' # Identification modifications
}

VariableModsInfo = unlist(strsplit(VariableMods,';',fixed = TRUE))
if (FixedMods!='null'){
  FixedModsInfo = unlist(strsplit(FixedMods,';',fixed = TRUE))
}

pdeep_phospho <- left_join(phosphors, pdeep_phospho, by = c("Spectrum.Name" = "SpectrumName", "IsoformModification" = "ModInfo")) %>% select(Spectrum.Name, IsoformSequence,entropy)
colnames(pdeep_phospho)[1] <- 'Title'
pdeep_nonphospho<- left_join(pdeep_nonphospho,features[features$PhosphoLabel==0,],by=c("SpectrumName" = "Title")) %>% select(SpectrumName,Mod_Sequence_for_phosphoRS,entropy)
colnames(pdeep_nonphospho)[1] <- 'Title'
colnames(pdeep_nonphospho)[2] <- 'IsoformSequence'

for (i in 1:length(VariableModsInfo)){
  tmp = VariableModsInfo[i]
  tmp2 = unlist(strsplit(tmp,',',fixed = TRUE))
  number = tmp2[1]
  name = tmp2[2]
  aa = tmp2[3]
  mass = tmp2[4]
  sym = tmp2[5]
  if (name!='Phospho'){
    pdeep_nonphospho$IsoformSequence <- gsub(paste0(aa,sym),number,pdeep_nonphospho$IsoformSequence)
  }
}
if (FixedMods!='null'){
  for (i in 1:length(FixedModsInfo)){
    tmp = FixedModsInfo[i]
    tmp2 = unlist(strsplit(tmp,',',fixed = TRUE))
    number = tmp2[1]
    name = tmp2[2]
    aa = tmp2[3]
    mass = tmp2[4]
    sym = tmp2[5]
    
    if (aa == 'AnyN-term'){
      next
    }
    
    if (name!='Phospho'){
      pdeep_nonphospho$IsoformSequence <- gsub(paste0(aa,sym),number,pdeep_nonphospho$IsoformSequence)
    }
  }
}
#pdeep_nonphospho$IsoformSequence <- str_replace_all(pdeep_nonphospho$IsoformSequence,c("M1" = "1", "C3" = "5"))

pdeep <- merge(pdeep_phospho,pdeep_nonphospho,all = TRUE)

colnames(autort_phospho)[1] <- 'IsoformSequence'

if (FixedMods!='null'){
  for (i in 1:length(FixedModsInfo)){
    tmp = FixedModsInfo[i]
    tmp2 = unlist(strsplit(tmp,',',fixed = TRUE))
    number = tmp2[1]
    name = tmp2[2]
    aa = tmp2[3]
    mass = tmp2[4]
    sym = tmp2[5]
    
    if (aa == 'AnyN-term'){
      next
    }
    
    if (name!='Phospho'){
      autort_phospho$IsoformSequence <- gsub(aa,number,autort_phospho$IsoformSequence)
    }
  }
}
#autort_phospho$IsoformSequence <- str_replace_all(autort_phospho$IsoformSequence,c("C" = "5"))


autort_nonphospho<- left_join(autort_nonphospho,features[features$PhosphoLabel==0,],by=c("index" = "Title")) %>% select(index,Mod_Sequence_for_phosphoRS,y,y_pred)
colnames(autort_nonphospho)[2] <- 'IsoformSequence'

for (i in 1:length(VariableModsInfo)){
  tmp = VariableModsInfo[i]
  tmp2 = unlist(strsplit(tmp,',',fixed = TRUE))
  number = tmp2[1]
  name = tmp2[2]
  aa = tmp2[3]
  mass = tmp2[4]
  sym = tmp2[5]
  if (name!='Phospho'){
    autort_nonphospho$IsoformSequence <- gsub(paste0(aa,sym),number,autort_nonphospho$IsoformSequence)
  }
}
if (FixedMods!='null'){
  for (i in 1:length(FixedModsInfo)){
    tmp = FixedModsInfo[i]
    tmp2 = unlist(strsplit(tmp,',',fixed = TRUE))
    number = tmp2[1]
    name = tmp2[2]
    aa = tmp2[3]
    mass = tmp2[4]
    sym = tmp2[5]
    
    if (aa == 'AnyN-term'){
      next
    }
    
    if (name!='Phospho'){
      autort_nonphospho$IsoformSequence <- gsub(paste0(aa,sym),number,autort_nonphospho$IsoformSequence)
    }
  }
}
#autort_nonphospho$IsoformSequence <- str_replace_all(autort_nonphospho$IsoformSequence,c("M1" = "1", "C3" = "5"))

autort <- merge(autort_phospho,autort_nonphospho,all = TRUE)


input_features <- features %>% filter(Title %in% raw_psms$index)
input_features$Modification <- NULL
input_features$modification <- NULL
input_features$Mod_Sequence <- NULL
#input_features$Peptide <- NULL
input_features$Mod_Sequence_for_phosphoRS <- NULL
input_features$PhosphoLabel <- NULL
#input_features$PhosphoRS_IsoformScore <- NULL
#input_features$PhosphoRS_IsoformProbability <- NULL
#input_features$IsoformSequence_autort_pDeep <- NULL
#input_features$autort_pDeep_Prob <- NULL
input_features$IsoformSequence_pDeep <- NULL
input_features$pDeepProb <- NULL
input_features$IsoformSequence_AutoRT <- NULL
input_features$AutoRTProb <- NULL
input_features$IsoformSequence_PhosphoRS <- NULL
input_features$RT <- NULL

colnames(input_features)[3] <- "CalcMass"
colnames(input_features)[ncol(input_features)-1] <- "ModifiedPeptide"

input_features <- left_join(input_features, pdeep, by = c('Title' = 'Title', 'ModifiedPeptide' = 'IsoformSequence'))
input_features <- left_join(input_features, autort, by = c('Title' = 'index', 'ModifiedPeptide' = 'IsoformSequence'))
input_features[is.na(input_features$entropy),]$entropy <- 0
input_features$ratio <- ifelse(input_features$y_pred>=input_features$y, input_features$y/input_features$y_pred, input_features$y_pred/input_features$y)
input_features$y <- NULL
input_features$y_pred <- NULL

input_features$PhosphoRS_IsoformScore <- NULL
input_features$PhosphoRS_IsoformProbability <- NULL
input_features$PhosphoRS_IsoformSites <- NULL
input_features$PhosphoRS_SitePrediction <- NULL
input_features$PhosphoRS_SiteProbability <- NULL
input_features$ModifiedPeptide <- NULL
input_features$autort_pDeep_Prob <- NULL
colnames(input_features)[ncol(input_features)-1] <- 'similarity'
input_features <- input_features %>% select(-similarity, similarity)



if (software == "msgf"){
  input_features$`MS-GF:EValue` <- -log(input_features$`MS-GF:EValue`)
} else if (software == "xtandem"){
  input_features$`X\\!Tandem:expect` <- -log(input_features$`X\\!Tandem:expect`)
} else if (software == "comet"){
  input_features$expect <- -log(input_features$expect)
}

#output_format <- left_join(input_features, auto_rt_similarity, by="Title")
output_format <- input_features
output_format <- output_format %>% select(-Peptide, Peptide)
output_format <- output_format %>% select(-Proteins, Proteins)
output_format$Label <- ifelse(output_format$Proteins == "", -1, output_format$Label)
output_format$Proteins <- ifelse(output_format$Proteins == "", "REV_Decoy", output_format$Proteins)

write.table(output_format, output, row.names=F, quote=F, sep="\t")



