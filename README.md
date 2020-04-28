# covid-notebooks

Jupyter notebooks that analyze COVID-19 time series data.


## Getting Started

**WARNING: Do not run these notebooks from your system Python environment.**

Use the following steps to create a consistent Python environment for running the
notebooks in this repository:

1. Install [Anaconda](https://docs.anaconda.com/anaconda/install/)
   or [Miniconda](https://docs.conda.io/en/latest/miniconda.html)
1. Navigate to your local copy of this repository.
1. Run the script `env.sh` to create an Anaconda environment in the directory
   `./env`:
   ```console
   $ bash env.sh
   ```
   Note: This script takes a while to run.
1. Activate the new environment and start JupyterLab:
   ```console
   $ conda activate ./env
   $ jupyter lab
   ```

