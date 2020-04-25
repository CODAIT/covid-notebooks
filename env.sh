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
conda install -y \
    jupyterlab \
    pandas \
    regex \
    matplotlib \
    cython \
    grpcio-tools \
    scikit-learn

################################################################################
# Second-best way to install packages: conda-forge
conda install -y -c conda-forge \
    pyarrow \
    fastparquet \
    plotly

################################################################################
# Third-best way to install packages: pip

# Watson tooling requires pyyaml to be installed this way.
pip install pyyaml

# Temporary until we figure out why dependency installs on the Text Extensions
# for Pandas pip package aren't working properly
pip install memoized-property

# Text Extensions for Pandas doesn't currently have a release, so pip install
# directly off of github
pip install --upgrade git+https://github.com/frreiss/text-extensions-for-pandas

################################################################################
# Least-preferred install method: Custom

# Plotly for JupyterLab
jupyter labextension install jupyterlab-plotly

# Elyra
pip install elyra
jupyter lab build


conda deactivate

echo "Anaconda environment at ./${ENV_DIR} successfully created."
echo "To use, type 'conda activate ./${ENV_DIR}'."

