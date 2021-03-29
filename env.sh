#! /bin/bash


# Create conda environment to run the notebooks in this directory.
#
# By default, the environment will be located in the directory "env"
# immediately under this one. To override that setting,
# pass the subdirectory name as the first argument to this script, i.e.
#
# $ ./env.sh my_dir_name

# Use Python 3.7 for now because TensorFlow and JupyterLab don't support 3.8
# yet.
PYTHON_VERSION=3.7

############################
# HACK ALERT *** HACK ALERT
# The friendly folks at Anaconda thought it would be a good idea to make the
# "conda" command a shell function.
# See https://github.com/conda/conda/issues/7126
# The following workaround will probably be fragile.
if [ -z "$CONDA_HOME" ]
then
    echo "Error: CONDA_HOME not set."
    exit
fi
if [ -e "${CONDA_HOME}/etc/profile.d/conda.sh" ]
then
    # shellcheck disable=SC1090
    . "${CONDA_HOME}/etc/profile.d/conda.sh"
else
    echo "Error: CONDA_HOME (${CONDA_HOME}) does not appear to be set up."
    exit
fi
# END HACK
############################

# Check whether the user specified an environment name.
if [ "$1" != "" ]; then
    ENV_DIR=$1
else
    ENV_DIR="env"
fi
echo "Creating an Anaconda environment at ./${ENV_DIR}"


# Remove the detrius of any previous runs of this script
rm -rf ./${ENV_DIR}

conda create -y -p ${ENV_DIR} python=${PYTHON_VERSION}
conda activate ./${ENV_DIR}

################################################################################
# Preferred way to install packages: Anaconda main

# We currently can't use Anaconda main for most things because of the need for
# a single requirements.txt spanning all packages.
conda install -y -c conda-forge jupyterlab
conda install -y -c conda-forge/label/main nodejs

################################################################################
# Second-best way to install packages: conda-forge

# We currently can't use conda-forge because of the need for a single
# requirements.txt.
# conda install -y -c conda-forge ...

################################################################################
# Third-best way to install packages: pip

# We currently install nearly everything with pip due to the need for a
# single requirements.txt that works outside an Anaconda environment.
pip install -r requirements.txt

################################################################################
# Least-preferred install method: Custom

# Plotly for JupyterLab
jupyter labextension install jupyterlab-plotly --no-build

# Elyra
pip install --upgrade --use-deprecated=legacy-resolver elyra
jupyter lab build

elyra-metadata install  runtime-images --replace=true \
    --schema_name=runtime-image \
    --name=covid-anaconda \
    --display_name="COVID with Anaconda Python 3" \
    --image_name="codait/covid-notebooks-anaconda-py3:latest"

elyra-metadata list runtimes
elyra-metadata list runtime-images

jupyter --version
echo " "
jupyter serverextension list
echo " "
jupyter labextension list
echo " "

conda deactivate

echo "Anaconda environment at ./${ENV_DIR} successfully created."
echo "To use, type 'conda activate ./${ENV_DIR}'."

