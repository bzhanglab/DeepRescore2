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

#### Step 3: Sequence quality control using PGA

#### Step 4: Generate train and prediction datasets

#### Step 5: RT prediction using AutoRT

#### Step 6: Spectrum prediction using pDeep3

#### Step 7: Deep-relocalization

#### Step 8: Rescoring using Percolation

#### Step 9: TMT quantification
