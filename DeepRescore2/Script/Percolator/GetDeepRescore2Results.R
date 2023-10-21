# Get DeepRescore2 results
library(data.table)
library(tidyverse)

args <- commandArgs(T)
featurePath <- args[1]
DeepRescore2ResultsPath <- args[2]
outputPath <- args[3]

#featurePath <- 'E:/Project/DeepRescore2/test/PXD000138/Features'
#DeepRescore2ResultsPath <- 'E:/Project/DeepRescore2/test/PXD000138/Percolator/DeepRescore2'

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