# DeepRescore2

## Overview

#### DeepRescore2: a novel post-processing tool by combing deep learning derived predictions, retention time and spectrum similarity, to facilitate the phosphosite localization and rescore peptide spectrum matches. 


## Pipeline

![DeepRescore2 pipeline](Images/Figure1.png)

## Table of contents:

- [Installation](#installation)
- [Usage](#Usage)
- [How to cite](#how-to-cite)

## Installation

#### Download DeepRescore2

```shell
$ git clone https://github.com/bzhanglab/DeepRescore2
```

#### System requirements

* Windows systems
* Java
* R
* python >= 3.5 with pandas module

#### Install software

* Install [Docker](https://docs.docker.com/install/) (>=19.03).
* Install [pDeep3](https://github.com/pFindStudio/pDeep3)
* Install [AutoRT](https://github.com/bzhanglab/AutoRT)

## Usage
#### Step 1: Extract features from peptide identifications

The search engine independent and specific features used in Percolator were extract from peptide identifications. The current version supports four search engines, MS-GF+, Comet, X!Tandem, MaxQuant.
Open Script/Features/Step1.R and change the parameters:

```R
identificationFile = '{PATH_TO_IDENTIFICATION_FILE}' # Path to the search engine identification file
fileFormat = '{FILE_FORMAT}' # Identification file format (mzIdentML: 1, pepXML: 2, proBAM: 3, txt: 4, maxQuant: 5, TIC: 6)
spectraPath = '{PATH_TO_MGF}' # Path to the MS/MS spectra (MGF) directory
featurePath = '{PATH_TO_FEATURE}' # Path to the generated feature file
tmpPath = './tmp' # Path to store temporary file
decoyPrefix = '{DECOY_PREFIX}' # Decoy prefix used for searching. Default is XXX_
```
Save and run the script
```R
source("{PATH_TO_CODE}/Script/Features/Step1.R")
```

#### Step 2: Phosphosite localization using PhosphoRS
PhosphoRS was used to do phosphosite localization based on search engine identifications. Here we provide a code to transfer search engine identifications into PhosphoRS format and run PhopshoRS command line to do phosphosite localization.
Open Script/PhosphoRS/Step2.R and change the parameters:

```R
spectraPath = '{PATH_TO_MGF}' # Path to the MS/MS spectra (MGF) directory
featurePath = '{PATH_TO_FEATURE}' # Path to the generated feature file
tmpPath = './tmp' # Path to store temporary file
```
Save and run the script
```R
source("{PATH_TO_CODE}/Script/PhosphoRS/Step2.R")
```

The PhosphoRS localization results are stored in the tmp directory.
* tmp/Results

#### Step 3: Sequence quality control using PGA
PGA R package loading by docker (proteomics/pga) was used to calculate both PSM and peptide level FDR of the search engine identifications.
Open Script/PGA/Step3.R and change the parameters:

```R
featurePath = '{PATH_TO_FEATURE}' # Path to the generated feature file
databasePath = '{PATH_TO_DATABASE}' # Path to the database used for searching
software = {SOFTWARE} # Four different search engines supported (msgf, comet, xtandem, maxquant)
decoyPrefix = '{DECOY_PREFIX}' # Decoy prefix used for searching. Default is XXX_
PGAPath = './PGA' # Path to store PGA results
```
Save and run the script
```R
source("{PATH_TO_CODE}/Script/PGA/Step3.R")
```

#### Step 4: Generate train and prediction datasets
The R environment of PGA docker (proteomics/pga) was used to generate train and prediction data used for both AutoRT and pDeep3.
Open Script/generate_train_prediction/Step4.R and change the parameters:

```R
PGAPath = './PGA' # Path to store PGA results
featurePath = '{PATH_TO_FEATURE}' # Path to the generated feature file
dataPath = '{PATH_TO_TRAIN_PREDICTION}' # Path to the train and prediction data used for both AutoRT and pDeep3
```

Save and run the script
```R
source("{PATH_TO_CODE}/Script/generate_train_prediction/Step4.R")
```

#### Step 5: RT prediction using AutoRT
Use AutoRT to train RT prediction model and to do the RT prediction.
Open Script/AutoRT/Step5.R and change the parameters:

```R
dataPath = '{PATH_TO_TRAIN_PREDICTION}' # Path to the train and prediction data used for both AutoRT and pDeep3
autoRT_resultsPath = '{PATH_TO_AUTORT_RESULTS}' # Path to the AutoRT prediction results
```
Save and run the script
```R
source("{PATH_TO_CODE}/Script/AutoRT/Step5.R")
```

#### Step 6: Spectrum prediction using pDeep3
Use pDeep3 to train spectrum ion intensity prediction model and to do the spectrum ion intensity prediction.
Open Script/pDeep3/Step6.R and change the parameters:

```R
dataPath = '{PATH_TO_TRAIN_PREDICTION}' # Path to the train and prediction data used for both AutoRT and pDeep3
rawSpectraPath = {PATH_TO_RAW_SPECTRA} # Path to the raw spectral files
tmpPath = './tmp' # Path to store temporary file
pDeep3_resultsPath = {PDEEP3_RESULTS_PATH} # Path to pDeep3 results file
```

Save and run the script
```R
source("{PATH_TO_CODE}/Script/pDeep3/Step6.R")
```

#### Step 7: Deep-relocalization

```sh
$ sh DeepLocalization.sh
```

#### Step 8: Rescoring using Percolator

```sh
$ sh Percolator.sh
```

#### Step 9: TMT quantification

```sh
$ sh TMTQuantification.sh
```
