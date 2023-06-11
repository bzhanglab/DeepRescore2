library(tidyverse)
library(data.table)

args <- commandArgs(T)
pep_pga_results <- fread(args[1]) %>% select(peptide)
psm_pga_results <- fread(args[2]) %>% select(index, peptide, evalue)
all_features <- fread(args[3])
auto_rt_train_folder <- args[4]
auto_rt_prediction_folder <- args[5]
pDeep3_train_folder <- args[6]
pDeep3_prediction_folder <- args[7]
raw_psm <- fread(args[8])
phosphors <- fread(args[9])
VariableMods <- args[10]
FixedMods <- args[11]

if (FALSE){
pep_pga_results = fread('/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/BuildPipeline/PXD023665_Part3/Comet2/PGA/peptide_level/pga-peptideSummary.txt') %>% select(peptide)
psm_pga_results = fread('/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/BuildPipeline/PXD023665_Part3/Comet2/PGA/psm_level/pga-peptideSummary.txt') %>% select(index, peptide, evalue)
all_features <- fread('/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/BuildPipeline/PXD023665_Part3/Comet2/Features/features.PhosphoRS.txt')
auto_rt_train_folder <- '/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/ManuscriptRevison_MCP/FirstRound/ResponseCode/DeepRescore2Pipeline/PXD023665/generate_train_prediction_comet/autoRT_train/'
auto_rt_prediction_folder <- '/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/ManuscriptRevison_MCP/FirstRound/ResponseCode/DeepRescore2Pipeline/PXD023665/generate_train_prediction_comet/autoRT_prediction/'
pDeep3_train_folder <- '/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/ManuscriptRevison_MCP/FirstRound/ResponseCode/DeepRescore2Pipeline/PXD023665/generate_train_prediction_comet/pDeep3_train/'
pDeep3_prediction_folder <- '/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/ManuscriptRevison_MCP/FirstRound/ResponseCode/DeepRescore2Pipeline/PXD023665/generate_train_prediction_comet/pDeep3_prediction/'
raw_psm <- fread('/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/BuildPipeline/PXD023665_Part3/Comet2/PGA/pga-rawPSMs.txt')
phosphors <- fread('/Users/xinpeiyi/Library/Mobile Documents/com~apple~CloudDocs/Documents/PostDocResearch/DeepRescore2/BuildPipeline/PXD023665_Part3/Comet2/PhosphoRS/PhosphoRS.txt')
VariableMods = '1,Oxidation,M,15.994919,1;2,Phospho,S,79.966331,2;3,Phospho,T,79.966331,2;4,Phospho,Y,79.966331,2'
FixedMods = '5,Carbamidomethyl,C,57.021464,3;6,TMT6plex,K,229.162932,4;7,TMT6plex,AnyN-term,229.162932,5' # Identification modifications
}

VariableModsInfo = unlist(strsplit(VariableMods,';',fixed = TRUE))
if (FixedMods!='null'){
  FixedModsInfo = unlist(strsplit(FixedMods,';',fixed = TRUE))
}



colnames(psm_pga_results)[1] <- "Title"
colnames(raw_psm)[1] <- "Title"
phosphors$Spectrum.ID <- NULL
phosphors$Spectrum.PrecursorCharge <- NULL
phosphors$Spectrum.ActivationType <- NULL
phosphors$Peptide.ID <- NULL
phosphors$Peptide.Sequence <- NULL
phosphors$Peptide.SitePrediction <- NULL
phosphors$Isoform.ID <- NULL
phosphors$Link <- NULL

colnames(phosphors) <- c('Title','IsoformSites','IsoformScore','IsoformProbability','IsoformSequence','IsoformModification')
psm_pga_results <- psm_pga_results %>% filter(peptide %in% pep_pga_results$peptide)

all_features$IsoformSequence <- all_features$Mod_Sequence_for_phosphoRS
for (i in 1:length(VariableModsInfo)){
  tmp = VariableModsInfo[i]
  tmp2 = unlist(strsplit(tmp,',',fixed = TRUE))
  number = tmp2[1]
  name = tmp2[2]
  aa = tmp2[3]
  mass = tmp2[4]
  sym = tmp2[5]
  all_features$IsoformSequence <- gsub(paste0(aa,sym), number, all_features$IsoformSequence)
}

#all_features$IsoformSequence <- str_replace_all(all_features$Mod_Sequence_for_phosphoRS,c("M1" = "1", "S2" = "2", "T2" = "3", "Y2" = "4", "C3" = "5", "K4" = "6"))
#all_features$Modification_for_pdeep3 <- str_replace_all(all_features$Modification,c("TMT 10-plex\\[peptide N-term\\]" = "TMT6plex[AnyN-term]", "TMT 10-plex\\[K\\]" = "TMT6plex[K]"))
all_features$Modification_for_pdeep3 <- all_features$Modification

PredictDataSource_Phospho <- merge(all_features[all_features$PhosphoLabel==1,c('Title','Charge','RT','Peptide')], phosphors, all.x=TRUE, by='Title')
PredictDataSource_Phospho$Mod_Sequence_for_autort <- PredictDataSource_Phospho$IsoformSequence
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
    
    PredictDataSource_Phospho$Mod_Sequence_for_autort <- gsub(number,aa,PredictDataSource_Phospho$Mod_Sequence_for_autort)
  }
}

#PredictDataSource_Phospho$Mod_Sequence_for_autort <- str_replace_all(PredictDataSource_Phospho$IsoformSequence,c("5" = "C","6" = "K"))

PredictDataSource_nonPhospho <- all_features[all_features$PhosphoLabel==0,]
PredictDataSource_nonPhospho$Mod_Sequence_for_autort <- PredictDataSource_nonPhospho$Mod_Sequence_for_phosphoRS
for (i in 1:length(VariableModsInfo)){
  tmp = VariableModsInfo[i]
  tmp2 = unlist(strsplit(tmp,',',fixed = TRUE))
  number = tmp2[1]
  name = tmp2[2]
  aa = tmp2[3]
  mass = tmp2[4]
  sym = tmp2[5]
  PredictDataSource_nonPhospho$Mod_Sequence_for_autort <- gsub(paste0(aa,sym), number, PredictDataSource_nonPhospho$Mod_Sequence_for_autort)
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
    
    PredictDataSource_nonPhospho$Mod_Sequence_for_autort <- gsub(paste0(aa,sym), aa, PredictDataSource_nonPhospho$Mod_Sequence_for_autort)
  }
}

#PredictDataSource_nonPhospho$Mod_Sequence_for_autort <- str_replace_all(PredictDataSource_nonPhospho$Mod_Sequence_for_phosphoRS,c("M1" = "1","C3" = "C","K4" = "K"))

all_features$Mod_Sequence_for_autort <- all_features$Mod_Sequence_for_phosphoRS
for (i in 1:length(VariableModsInfo)){
  tmp = VariableModsInfo[i]
  tmp2 = unlist(strsplit(tmp,',',fixed = TRUE))
  number = tmp2[1]
  name = tmp2[2]
  aa = tmp2[3]
  mass = tmp2[4]
  sym = tmp2[5]
  all_features$Mod_Sequence_for_autort <- gsub(paste0(aa,sym),number,all_features$Mod_Sequence_for_autort)
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
    
    all_features$Mod_Sequence_for_autort <- gsub(paste0(aa,sym),aa,all_features$Mod_Sequence_for_autort)
  }
}

#all_features$Mod_Sequence_for_autort <- str_replace_all(all_features$Mod_Sequence_for_phosphoRS,c("M1" = "1", "S2" = "2", "T2" = "3", "Y2" = "4", "C3" = "C", "K4" = "K"))

# AutoRT train data: FDR<1%, PhosphoRS probability > 0.75
auto_rt_train_data <- left_join(psm_pga_results, all_features, by="Title") %>% select(Mod_Sequence_for_autort, RT, Title, evalue, PhosphoRS_IsoformProbability, PhosphoLabel)
auto_rt_train_data <- auto_rt_train_data[auto_rt_train_data$PhosphoLabel==0|auto_rt_train_data$PhosphoRS_IsoformProbability>=0.75,]
auto_rt_train_data$PhosphoRS_IsoformProbability <- NULL
auto_rt_train_data$PhosphoLabel <- NULL
auto_rt_train_data <- separate(auto_rt_train_data, Title, into=c("fraction", NA, NA, NA), sep="\\.", remove=F)
#auto_rt_train_data_split <- split(auto_rt_train_data, auto_rt_train_data$fraction)

# AutoRT predict data: all the isoform and non-phospho
auto_rt_prediction_data_Phospho <- PredictDataSource_Phospho %>% select(Mod_Sequence_for_autort, RT, Title)
auto_rt_prediction_data_Phospho <- separate(auto_rt_prediction_data_Phospho, Title, into=c("fraction", NA, NA, NA), sep="\\.", remove=F)
#auto_rt_prediction_data_Phospho_split <- split(auto_rt_prediction_data_Phospho, auto_rt_prediction_data_Phospho$fraction)

auto_rt_prediction_data_nonPhospho <- PredictDataSource_nonPhospho %>% select(Mod_Sequence_for_autort, RT, Title)
auto_rt_prediction_data_nonPhospho <- separate(auto_rt_prediction_data_nonPhospho, Title, into=c("fraction", NA, NA, NA), sep="\\.", remove=F)
#auto_rt_prediction_data_nonPhospho_split <- split(auto_rt_prediction_data_nonPhospho, auto_rt_prediction_data_nonPhospho$fraction)

# pDeep3 train data: FDR<1%, PhosphoRS probability > 0.75
pdeep3_train_data <- left_join(psm_pga_results, all_features, by="Title") %>% select(Title, Peptide, Modification_for_pdeep3, PhosphoRS_IsoformProbability, PhosphoLabel)
pdeep3_train_data <- pdeep3_train_data[pdeep3_train_data$PhosphoLabel==0|pdeep3_train_data$PhosphoRS_IsoformProbability>=0.75,]
pdeep3_train_data$PhosphoRS_IsoformProbability <- NULL
pdeep3_train_data$PhosphoLabel <- NULL
pdeep3_train_data <- separate(pdeep3_train_data, Title, into=c("raw_name", "scan", NA, "charge"), sep="\\.", remove=F)
colnames(pdeep3_train_data)[5] <- "peptide"
colnames(pdeep3_train_data)[6] <- "modinfo"
pdeep3_train_data <- pdeep3_train_data[,c("raw_name","scan","peptide","modinfo","charge")]
#pdeep3_train_data_split <- split(pdeep3_train_data, pdeep3_train_data$raw_name)

# pDeep3 predict data: all the isoform and non-phospho
pdeep3_prediction_data_Phospho <- PredictDataSource_Phospho %>% select(Peptide, IsoformModification, Charge, Title,IsoformSequence)
colnames(pdeep3_prediction_data_Phospho) <- c("peptide", "modinfo", "charge", "Spectrum",'IsoformSequence')
pdeep3_prediction_data_Phospho <- pdeep3_prediction_data_Phospho %>% distinct()
pdeep3_prediction_data_Phospho <- separate(pdeep3_prediction_data_Phospho, Spectrum, into=c("fraction", NA, NA, NA), sep="\\.", remove=F)
#pdeep3_prediction_data_Phospho_split <- split(pdeep3_prediction_data_Phospho, pdeep3_prediction_data_Phospho$fraction)

pdeep3_prediction_data_nonPhospho <- PredictDataSource_nonPhospho %>% select(Peptide, Modification_for_pdeep3, Charge, Title,IsoformSequence)
colnames(pdeep3_prediction_data_nonPhospho) <- c("peptide", "modinfo", "charge", "Spectrum","IsoformSequence")
pdeep3_prediction_data_nonPhospho <- pdeep3_prediction_data_nonPhospho %>% distinct()
pdeep3_prediction_data_nonPhospho <- separate(pdeep3_prediction_data_nonPhospho, Spectrum, into=c("fraction", NA, NA, NA), sep="\\.", remove=F)
#pdeep3_prediction_data_nonPhospho_split <- split(pdeep3_prediction_data_nonPhospho, pdeep3_prediction_data_nonPhospho$fraction)

one_data <- auto_rt_train_data
one_data <- one_data[order(one_data$Mod_Sequence_for_autort, -(one_data$evalue)), ]
one_data <- one_data[!duplicated(one_data$Mod_Sequence_for_autort), ]
one_data <- one_data %>% select(Mod_Sequence_for_autort, RT, evalue, Title)
colnames(one_data) <- c("x", "y", "evalue", "index")
write.table(one_data, paste(auto_rt_train_folder, "auto_rt_train.txt", sep=""), row.names=F, quote=F, sep="\t")

one_data <- auto_rt_prediction_data_Phospho
one_data <- one_data %>% select(Mod_Sequence_for_autort, RT, Title)
colnames(one_data) <- c("x", "y", "index")
write.table(one_data, paste(auto_rt_prediction_folder, "auto_rt_prediction.Phospho.txt", sep=""), row.names=F, quote=F, sep="\t")

one_data <- auto_rt_prediction_data_nonPhospho
one_data <- one_data %>% select(Mod_Sequence_for_autort, RT, Title)
colnames(one_data) <- c("x", "y", "index")
write.table(one_data, paste(auto_rt_prediction_folder, "auto_rt_prediction.nonPhospho.txt", sep=""), row.names=F, quote=F, sep="\t")

one_data <- pdeep3_train_data
colnames(one_data) <- c("raw_name", "scan", "peptide", "modinfo", "charge")
write.table(one_data, paste(pDeep3_train_folder, "pdeep3_train.txt", sep=""), row.names=F, quote=F, sep="\t")

one_data <- pdeep3_prediction_data_Phospho
one_data <- one_data %>% select(peptide, modinfo, charge, Spectrum, IsoformSequence)
colnames(one_data) <- c("peptide", "modinfo", "charge", "Spectrum", "IsoformSequence")
write.table(one_data, paste(pDeep3_prediction_folder, "pdeep3_prediction.Phospho.txt", sep=""), row.names=F, quote=F, sep="\t")

one_data <- pdeep3_prediction_data_nonPhospho
one_data <- one_data %>% select(peptide, modinfo, charge, Spectrum, IsoformSequence)
colnames(one_data) <- c("peptide", "modinfo", "charge", "Spectrum", "IsoformSequence")
write.table(one_data, paste(pDeep3_prediction_folder, "pdeep3_prediction.nonPhospho.txt", sep=""), row.names=F, quote=F, sep="\t")




