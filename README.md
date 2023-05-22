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
* python >= 3.5
* For pDeep3: 
- tensorflow == 1.13.1 (tensorflow >= 1.13.0, tensorfow 1.x.x is only supported by python <= 3.7)
- .NET Framework == 4.5.2 (or higher? to execute psmLabel)

* For AutoRT:
- tensorflow >=**2.6**

## Usage
#### Step 1: Extract features from peptide identifications

The current version supports four search engines, MS-GF+, Comet, X!Tandem, MaxQuant.

```sh
$ sh Features.sh
```

#### Step 2: Phosphosite localization using PhosphoRS

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
