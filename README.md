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
Open scripts/Features.sh and change the parameters:

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
Open scripts/PhosphoRS.sh and change the parameters:

```R
featurePath = '{PATH_TO_FEATURE}' # Path to the generated feature file
outputPath = '{OUTPUT_PATH}' # Path to the localization results
```
Save and run the script
```sh
$ sh PhosphoRS.sh
```

#### Step 3: Sequence quality control using PGA

```sh
$ sh PGA.sh
```

#### Step 4: Generate train and prediction datasets

```sh
$ sh generate_train_prediction.sh
```

#### Step 5: RT prediction using AutoRT

```sh
$ sh AutoRT.sh
```

#### Step 6: Spectrum prediction using pDeep3

```sh
$ sh pDeep3.sh
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
