# DeepRescore2

## Overview

#### DeepRescore2: a novel post-processing tool by combing deep learning derived predictions, retention time and spectrum similarity, to facilitate the phosphosite localization and rescore peptide spectrum matches. 


## Pipeline

![DeepRescore2 pipeline](Images/Figure1.png)


## Usage
#### Step 1: Extract features from peptide identifications

The current version supports four search engines, MS-GF+, Comet, X!Tandem, MaxQuant.

```sh
 $ nextflow run neoflow_db.nf --help
N E X T F L O W  ~  version 19.10.0
Launching `neoflow_db.nf` [irreverent_faggin] - revision: 741bf1a931
=========================================
neoflow => variant annotation and customized database construction
=========================================
Usage:
nextflow run neoflow_db.nf
Arguments:
  --vcf_file              A txt file contains VCF file(s)
  --annovar_dir           ANNOVAR folder
  --protocol              The parameter of "protocol" for ANNOVAR, default is "refGene"
  --ref_dir               ANNOVAR annotation data folder
  --ref_ver               The genome version, hg19 or hg38, default is "hg19"
  --out_dir               Output folder, default is "./output"
  --cpu                   The number of CPUs
  --help                  Print help message
```

#### Step 2: Phosphosite localization using PhosphoRS

#### Step 3: Sequence quality control using PGA

#### Step 4: Generate train and prediction datasets

#### Step 5: RT prediction using AutoRT

#### Step 6: Spectrum prediction using pDeep3

#### Step 7: Deep-relocalization

#### Step 8: Rescoring using Percolation

#### Step 9: TMT quantification