# DeepRescore2

#### DeepRescore2 is a novel post-processing tool by combing deep learning derived predictions, retention time and spectrum similarity, to facilitate the phosphosite localization and rescore peptide spectrum matches. 


#### First, based on the confidently identified PSMs from database searching, RT and fragment mass spectrum prediction models are trained using AutoRT and pDeep3, respectively, and then used to predict RTs and MS/MS spectra for all identified peptide sequences with all possible phosphosite localizations (i.e., peptide isoforms). Second, for each peptide isoform, a probability score is computed taking into consideration the PhosphoRS score, RT difference between predicted and experimentally observed RTs, and spectrum similarity between predicted and experimentally observed spectra, and then phosphosite localization is determined based on the combined probability score. Third, PSM rescoring is performed using the semi-supervised Percolator algorithm(29), which integrates search engine specific features, search engine independent features, and the two deep learning-derived features to improve the accuracy and sensitivity of phosphopeptide identification. Finally, identified PSMs can be manually validated using the visualization tool PDV.

![DeepRescore2 pipeline](Images/Figure1.png)