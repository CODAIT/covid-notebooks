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
conda install -y jupyterlab
conda install -y numpy


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

# Watson tooling requires pyyaml to be installed this way.
pip install pyyaml

# Text Extensions for Pandas doesn't currently have a release, so pip install
# directly off of github
pip install --upgrade git+https://github.com/CODAIT/text-extensions-for-pandas

################################################################################
# Least-preferred install method: Custom

# Plotly for JupyterLab
jupyter labextension install jupyterlab-plotly --no-build

# Elyra
pip install --upgrade --pre elyra==0.11.0rc2 kfp-notebook==0.8.2
jupyter lab build

elyra-metadata install runtimes --replace=true \
       --schema_name=kfp \
       --name=kfp-cloning \
       --display_name="Kubeflow Pipeline (clonning)" \
       --api_endpoint=http://cloning1.fyre.ibm.com:31380/pipeline \
       --cos_endpoint=http://cloning1.fyre.ibm.com:31671 \
       --cos_username=minio \
       --cos_password=minio123 \
       --cos_bucket=covid

elyra-metadata install  runtime-images --replace=true \
    --schema_name=runtime-image \
    --name=covid-anaconda \
    --display_name="COVID with Anaconda Python 3" \
    --image_name="lresende/anaconda3:latest"

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

