library(tidyverse)
library(data.table)

args <- commandArgs(T)
pep_pga_results <- fread(args[1]) %>% select(peptide)
psm_pga_results <- fread(args[2]) %>% select(index, peptide, evalue)
all_features <- fread(args[3])
Method1ResultsPath <- args[4]

if (FALSE){
pep_pga_results = fread('E:/Project/DeepRescore2/test/PXD000138/PGA/peptide_level/pga-peptideSummary.txt') %>% select(peptide)
psm_pga_results = fread('E:/Project/DeepRescore2/test/PXD000138/PGA/psm_level/pga-peptideSummary.txt') %>% select(index, peptide, evalue)
all_features <- fread('E:/Project/DeepRescore2/test/PXD000138/Features/Features.Localization.entropy.txt')
}

psm_pga_results <- psm_pga_results %>% filter(peptide %in% pep_pga_results$peptide)
colnames(psm_pga_results)[1] <- "Title"

data <- left_join(psm_pga_results, all_features, by="Title")


data_PhosphoRS <- data[data$PhosphoLabel==1,]
tmp = c()
for (i in 1:nrow(data_PhosphoRS)){
  if (grepl(',', data_PhosphoRS$PhosphoRS_SiteProbability[i], fixed = TRUE)){
    index = 0
    probs = unlist(strsplit(data_PhosphoRS$PhosphoRS_SiteProbability[i],','))
    for (j in 1:length(probs)){
      if (as.double(probs[j])>=0.75){
        index = index + 1
      }
    }
    if (index == 2){
      tmp = c(tmp,i)
    }
  }else{
    prob = as.double(data_PhosphoRS$PhosphoRS_SiteProbability[i])
    if (as.double(prob)>=0.75){
      tmp = c(tmp,i)
    }
  }
  print(i)
}
data_PhosphoRS = data_PhosphoRS[tmp,]


data_AutoRT <- data[data$AutoRTProb>=0.75,]
data_pDeep <- data[data$pDeepProb>=0.75,]
data_AutoRT_pDeep <- data[data$autort_pDeep_Prob>=0.75,]

print(paste0('PhosphoRS:',toString(nrow(data_PhosphoRS))))
print(paste0('AutoRT:',toString(nrow(data_AutoRT))))
print(paste0('pDeep:',toString(nrow(data_pDeep))))
print(paste0('AutoRT_pDeep:',toString(nrow(data_AutoRT_pDeep))))

write.table(data_PhosphoRS,
            Method1ResultsPath,
            sep = '\t',
            row.names = FALSE,
            quote = FALSE
            )




