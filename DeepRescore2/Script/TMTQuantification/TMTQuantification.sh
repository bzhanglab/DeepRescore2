#!/bin/sh

set -e -x

python ./Script/TMTQuantification/generate_MASCIParameters.py ./RAW ./Script/TMTQuantification/Run_MASCI.sh ./OutputData/QuantificationResults TMT10

sh ./Script/TMTQuantification/Run_MASCI.sh


