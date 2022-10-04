# DeepRescore2

## Overview

#### DeepRescore2: a novel post-processing tool by combing deep learning derived predictions, retention time and spectrum similarity, to facilitate the phosphosite localization and rescore peptide spectrum matches. 


## Pipeline

![DeepRescore2 pipeline](Images/Figure1.png)


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

#### Step 8: Rescoring using Percolation

```sh
$ sh Percolator.sh
```

#### Step 9: TMT quantification

```sh
$ sh TMTQuantification.sh
```
