#####################################################################
# env.py
#
# Functions related to Python environment setup, broken out into a 
# separate file to minimize the number of packages this file depends
# on.

import os

def maybe_install_libs():
    """
    Ensure that all required Python libraries for the notebooks
    in this directory (besides this file) are installed.
    
    NOTE: This function will install packages on the active 
    Python environment if they are not present!
    """
    # Use the presence of Text Extensions for Pandas as an indicator
    # of whether this function has run before.
    try:
        import text_extensions_for_pandas
    except ModuleNotFoundError:
        # Text Extensions for Pandas not found.
        # Install dependencies first.
        # We may be running in a directory below the root. Add ".." to
        # the location of requirements.txt until we find the file.
        
        requirements_loc = "requirements.txt"
        n = 0
        while not os.path.isfile(requirements_loc):
            requirements_loc = "../" + requirements_loc
            n += 1
            if n > 3:
                raise ValueError(
                    f"Couldn't find requirements.txt at or above current "
                    f"working directory {os.getcwd()}.")
        os.system(f"pip install -r {requirements_loc}")
        # Then install Text Extensions directly from the master branch.
        os.system(
            "pip install --upgrade "
            "git+https://github.com/CODAIT/text-extensions-for-pandas")
