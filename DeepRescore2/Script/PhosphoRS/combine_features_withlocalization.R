library(tidyverse)
library(data.table)
library(dplyr)

args <- commandArgs(T)
features <- fread(args[1])
PhosphoRS <- fread(args[2])
output <- args[3]

if (FALSE){
features <- fread('/Users/yixinpei/Documents/PostDocResearch/DeepRescore2/BuildPipeline/PXD000138/MaxQuant3/Features/features2.txt')
PhosphoRS <- fread('/Users/yixinpei/Documents/PostDocResearch/DeepRescore2/BuildPipeline/PXD000138/MaxQuant3/PhosphoRS/PhosphoRS.txt')
output <- '/Users/yixinpei/Documents/PostDocResearch/DeepRescore2/BuildPipeline/PXD000138/MaxQuant3/Features/features.PhosphoRS.txt'
}

# Update features
features$PhosphoLabel <- ifelse(grepl('Phospho',features$Modification), 1, 0)
feature_phos = features[features$PhosphoLabel==1,]
feature_nonphos = features[features$PhosphoLabel==0,]

PhosphoRS2 <- PhosphoRS %>%
  group_by(Spectrum.Name) %>%
  slice(which.max(Isoform.Probability))

PhosphoRS2$Spectrum.ID <- NULL
PhosphoRS2$Spectrum.PrecursorCharge <- NULL
PhosphoRS2$Spectrum.ActivationType <- NULL
PhosphoRS2$Peptide.ID <- NULL
PhosphoRS2$Peptide.Sequence <- NULL
#PhosphoRS2$Peptide.SitePrediction <- NULL
PhosphoRS2$Isoform.ID <- NULL
#PhosphoRS2$Isoform.Sites <- NULL
PhosphoRS2$IsoformSequence <- NULL
PhosphoRS2$IsoformModification <- NULL
PhosphoRS2$Link <- NULL

colnames(PhosphoRS2) = c('Title','PhosphoRS_SitePrediction','PhosphoRS_IsoformSites',
                         'PhosphoRS_IsoformScore','PhosphoRS_IsoformProbability')

feature_phos2 <- left_join(PhosphoRS2, feature_phos, by="Title")
features2 <- merge(feature_nonphos, feature_phos2, all = TRUE)
features2$PhosphoRS_IsoformScore <- ifelse(is.na(features2$PhosphoRS_IsoformScore), 0, features2$PhosphoRS_IsoformScore)
features2$PhosphoRS_IsoformProbability <- ifelse(is.na(features2$PhosphoRS_IsoformProbability), 0, features2$PhosphoRS_IsoformProbability)

write.table(features2, output, row.names=F, quote=F, sep="\t")



