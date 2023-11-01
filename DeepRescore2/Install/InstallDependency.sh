#!/bin/bash

echo "Installing..."

##Parameter path
#DeepRescore2Path="E:/Project/DeepRescore2/Github/DeepRescore2"
#anacondaPath="/C/ProgramData/anaconda3"
#scriptPath="$DeepRescore2Path/Script"


if [ -n "$1" ]; then
    DeepRescore2Path="$1"
else
    echo "Please give DeepRescore2Path"
    exit 1
fi

if [ -n "$2" ]; then
    anacondaPath="$2"
else
    echo "Please give anacondaPath"
    exit 2
fi

scriptPath="$DeepRescore2Path/Script"

#====================================Download==========================================#
##1. AutoRT

git clone https://github.com/bzhanglab/AutoRT.git
mv AutoRT $DeepRescore2Path/Script

##2. pDeep3
git clone https://github.com/pFindStudio/pDeep3.git
mv pDeep3 $DeepRescore2Path/Script/pDeep3

##3. PhosphoRS
curl -o phosphoRS-cli.zip -LJ https://github.com/lmsac/phosphoRS-cli/releases/download/v1.0.0/phosphoRS-cli.zip
unzip phosphoRS-cli.zip -d phosphoRS-cli
mv phosphoRS-cli $DeepRescore2Path/Script/PhosphoRS
rm phosphoRS-cli.zip

##4. SpectralEntropy
git clone https://github.com/YuanyueLi/SpectralEntropy.git
mv SpectralEntropy $DeepRescore2Path/Script/pDeep3

#=====================================Install==========================================#
##1.AutoRT

source $anacondaPath/etc/profile.d/conda.sh
autort_env="AutoRT"

if conda env list | grep -q $autort_env; then
    echo "AutoRT environment already exists."
else
    echo "Creating AutoRT environment..."
    conda create -p $anacondaPath/envs/AutoRT python=3.10

    echo "AutoRT environment created and activated."
fi

conda activate AutoRT
python --version

conda install tensorflow
#git clone https://github.com/bzhanglab/AutoRT
pip install -r $scriptPath/AutoRT/requirements.txt

conda deactivate

##2.pDeep3

source $anacondaPath/etc/profile.d/conda.sh
pdeep3_env="pDeep3"

if conda env list | grep -q $pdeep3_env; then
    echo "pDeep3 environment already exists."
else
    echo "Creating pDeep3 environment..."
    conda create -p $anacondaPath/envs/pDeep3 python=3.6

    echo "pDeep3 environment created and activated."
fi

conda activate pDeep3
python --version

conda install tensorflow==1.13.1
pip install $scriptPath/pDeep3/pDeep3/.
pip install -e $scriptPath/pDeep3/pDeep3/.
pip install Cython

conda deactivate

sourceDir="$scriptPath/pDeep3/SpectralEntropyScripts/"
destinationDir="$scriptPath/pDeep3/SpectralEntropy/"

if [ -d "$sourceDir" ] && [ -d "$destinationDir" ]; then
    for file in "$sourceDir"*
    do
        if [ -f "$file" ]; then
            baseName="$(basename $file)"
            destinationPath="$destinationDir$baseName"
            
            if [ ! -f "$destinationPath" ]; then
                cp "$file" "$destinationPath"
                echo "Copied $baseName to $destinationDir"
            else
                echo "File $baseName already exists in $destinationDir"
            fi
        fi
    done
else
    echo "Source and/or destination directory does not exist."
fi

sourceDir="$scriptPath/pDeep3/pDeep3Scripts/tune_and_predict.py"
destinationDir="$scriptPath/pDeep3/pDeep3/pDeep/cmd/"

cp "$sourceDir" "$destinationDir"

sourceDir="$scriptPath/pDeep3/pDeep3Scripts/load_data.py"
destinationDir="$scriptPath/pDeep3/pDeep3/pDeep/"

cp "$sourceDir" "$destinationDir"

##3.R environment

##3.R environment

source $anacondaPath/etc/profile.d/conda.sh
r_env="R_env"

if conda env list | grep -q $r_env; then
    echo "R_env environment already exists."
else
    echo "Creating R_env environment..."
    conda env create -f $DeepRescore2Path/Install/environment_R.yml --prefix $anacondaPath/envs/R_env

    echo "R_env environment created and activated."
fi

