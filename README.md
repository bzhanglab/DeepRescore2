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
DeepRescore2 is built based on python, R and docker on the Windows system. 
* Install Java
* Install R with [tidyverse](https://www.tidyverse.org/packages/), [XML](https://cran.r-project.org/web/packages/XML/index.html) package installed.
* Install python >= 3.5 with pandas module
* Install [Docker](https://docs.docker.com/install/) (>=19.03).
* Install [pDeep3](https://github.com/pFindStudio/pDeep3) under conda environment named 'pDeep3'. Tensorflow version 1.13.1 is required.
* Install [AutoRT](https://github.com/bzhanglab/AutoRT). Tensorflow version 2.6.0 is required.

#### Download DeepRescore2

```shell
$ git clone https://github.com/bzhanglab/DeepRescore2
```

#### System requirements

* Windows systems

## Usage

The user has to edit the DeepRescore2 parameter file named "DeepRescore2.param" before using DeepRescore2. The command line to run DeepRescore2 is:

```R
Rscript DeepRescore2.R DeepRescore2.param
```

Each column of the parameter file is described as follows (Please change the 'Value' column based on your data):
| Name  | Value | Description |
| -------------  | ------------- | ------------- |
| DeepRescore2Path  | DEEPRESCORE2_DIR  | DeepRescore2 directory |
| javaPath  | JAVA_DIR  | Java directory |
| pythonPath  | PYTHON_DIR  | Python directory |
| decoyPrefix  | DECOY_PREFIX  | Decoy prefix used for searching. Default is XXX_ |
| searchEngine  | SEARCH_ENGINE  | Four search engines, msgf, comet, xtandem, maxquant, are supported |
| inputPath  | INPUT_DIR  | Input directory including all the input files |
| rawSpectraPath  | RAW_DIR  | Path to the MS/MS spectra (RAW) directory |
| spectraPath  | MGF_DIR  | Path to the MS/MS spectra (MGF) directory |
| databasePath  | DATABASE_DIR  | Path to the database used for searching |
| inputFeaturePath  | FEATURE_DIR  | Path to the feature matrix |
| outputPath  | OUT_DIR  | Output directory |
| VariableMods  | VAR_MOD  | Variable modifications used for searching, e.g. '1,Oxidation,M,15.994919,1;2,Phospho,S,79.966331,2;3,Phospho,T,79.966331,2;4,Phospho,Y,79.966331,2' |
| FixedMods  | Fix_MOD  | Fixed modifications used for searching, e.g. '5,Carbamidomethyl,C,57.021464,3'. If null, use 'null' |
| ModsReplace  | RENAME_MOD  | Some modifications need to rename, e.g. '\\[79.966331\\],Phospho'. If null, use 'null' |

As a reference, we prepared three parameters for the three test datasets of four search engines used in our manuscript, including label free dataset (PRIDE ID: PXD000138 and PXD023665) and UCEC TMT dataset, respectively. Please check the 'Parameters' folder.

## Generate feature matrix as input

## Output

## Quantification for TMT dataset

## How to cite

