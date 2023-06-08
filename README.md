# DeepRescore2

## Overview

#### DeepRescore2: a novel post-processing tool by combing deep learning derived predictions, retention time and spectrum similarity, to facilitate the phosphosite localization and rescore peptide spectrum matches. 


## Pipeline

![DeepRescore2 pipeline](Images/Figure1.png)

## Table of contents:

- [Installation](#Installation)
- [Usage](#Usage)
- [How to cite](#How-to-cite)

## Installation
DeepRescore2 is built based on python, R and docker on the Windows system. Its dependencies can be installed via
```shell
$ pip install -r requirements.txt
```

#### Download DeepRescore2

```shell
$ git clone https://github.com/bzhanglab/DeepRescore2
```

#### System requirements

* Windows systems

#### Install software

* Install Java
* Install R with [tidyverse](https://www.tidyverse.org/packages/), [XML](https://cran.r-project.org/web/packages/XML/index.html) package installed.
* Install python >= 3.5 with pandas module
* Install [Docker](https://docs.docker.com/install/) (>=19.03).
* Install [pDeep3](https://github.com/pFindStudio/pDeep3) under conda environment named 'pDeep3'. The tensorflow version is 1.13.1.
* Install [AutoRT](https://github.com/bzhanglab/AutoRT). The tensorflow version is 2.6.0.


## Usage

The user has to edit the DeepRescore2 parameter file named "DeepRescore2.param" before using DeepRescore2. The command line to run DeepRescore2 is:
```R
Rscript DeepRescore2.R DeepRescore2.param
```

All the parameters are list as follows:
```R
decoyPrefix = '{DECOY_PREFIX}' # Decoy prefix used for searching. Default is XXX_
searchEngine = '{SEARCH_ENGINE}' # four search engines, msgf, comet, xtandem, maxquant, are supported
inputPath = '{INPUT_DIR}' # Input directory including all the input files: MS/MS spectra (RAW and MGF), feature matrix, database
rawSpectraPath = '{RAW_DIR}' # Path to the MS/MS spectra (RAW) directory
spectraPath = '{MGF_DIR}' # Path to the MS/MS spectra (MGF) directory
databasePath = '{DATABASE_DIR}' # Path to the database used for searching
inputFeaturePath = '{FEATURE_DIR}' # Path to the feature matrix
outputPath = '{OUT_DIR}' # Output directory
VariableMods = '{VAR_MOD}' # Variable modifications used for searching, e.g. '1,Oxidation,M,15.994919,1;2,Phospho,S,79.966331,2;3,Phospho,T,79.966331,2;4,Phospho,Y,79.966331,2'
FixedMods = '{Fix_MOD}' # Fixed modifications used for searching, e.g. '5,Carbamidomethyl,C,57.021464,3'. If null, use 'null'
ModsReplace = '{RENAME_MOD}' # Some modifications need to rename, e.g. '\\[79.966331\\],Phospho'. If null, use 'null'
```

## Input

## Output

## How to cite

