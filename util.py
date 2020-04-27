#####################################################################
# util.py
#
# Shared utility functions used by the notebooks in this directory.

from typing import *
import pandas as pd
import numpy as np

import matplotlib.pyplot as plt 

import text_extensions_for_pandas as tp

def collapse_time_series(df: pd.DataFrame,
                         ts_cols: Sequence[str]) -> pd.DataFrame:
    """
    Collapse one or more time series in a dataframe into tensors.
    
    :param df: Input dataframe with time series arranged vertically.
     The dataframe must have a 2-level index, and the first level
     containing time series ID and the second level time for each
     row of the time series.
     All time series must be of the same length and have matching 
     times at all points.
    :param ts_cols: Names of one or more columns in `df` containing
     time series data.
     **Currently, all time series must be of the same length.**
     
    :returns: Two items:
     * A transformed version of `df` in which the time series
       that were originally stored "vertically" across rows have been
       collapsed down to 1-D tensors and stored in columns of type
       `TensorType`.
     * A numpy array of the times that correspond to the elements of
       the time series 
    """
    if (not isinstance(df.index, pd.MultiIndex) 
            or len(df.index.names) != 2):
        raise ValueError(f"Dataframe must have a 2-level index, "
                         f"with the first level containing time "
                         f"series ID and the second level position "
                         f"within the time series "
                         f"(index was {df.index}).")
    

    
    # Pass through metadata columns from the original table.
    # We assume that the first value in each time series will suffice.
    meta_cols = [c for c in df.columns if c not in ts_cols]
    result = df.groupby(df.index.names[0]).aggregate({
        c: "first" for c in meta_cols
    })

    # Pull out the time values for the time series' points
    ts_times = df.index.levels[1].values
    ts_times_name = df.index.names[1]
    
    id_values = df.index.levels[0].values
    num_id_values = len(id_values)
    
    # TODO: Figure out why the following code doesn't work
    # result[ts_times_name] = tp.TensorArray(
    #    np.tile(ts_times, num_id_values).reshape([num_id_values, -1])
    # )
    
    for ts_col in ts_cols:
        # Build up a list of numpy views on the source dataframe
        to_stack = [
            df.loc[id_value][ts_col].values for id_value in id_values
        ]
        # Concatenate all the views into a single new array, then
        # wrap that array in a column of our output dataframe.
        result[ts_col] = tp.TensorArray(np.stack(to_stack))

    times = df.index.levels[1].values
        
    return result, times


# Expand the time series in our dataframe back out again.
def explode_time_series(df: pd.DataFrame, dates: np.ndarray):
    """
    Expand out all the time series in a dataframe that encodes each time
    series as a tensor.
    
    :param df: DataFrame of tensors. Must have a 1-level index, not a 
     MultiIndex.
    :param dates: Time values associated with the data points in the tensors
    
    :returns: a dataframe where each tensor of the original 
     dataframe has been expanded vertically into a series of values.
     Also adds back the date information that was stored on the side 
     in `dates`.
    """
    def row_to_dataframe(fips: int):
        # DataFrame.loc[single value] on a 1-level index returns a series.
        # The index of the series contains column names.
        row_as_series = df.loc[fips]
        # Use the dates that we pulled out of the original vertical dataframe
        # to construct a new two-level index
        index = pd.MultiIndex.from_product([[fips], dates], 
                                           names=[df.index.name, "Date"])
        return pd.DataFrame(
            {
                name: row_as_series.loc[name]
                for name in row_as_series.index
            }, index=index)

    return pd.concat([row_to_dataframe(entry) for entry in df.index])



def graph_examples(
    data_df: pd.DataFrame, col_name: str,
    curves: Dict[str, Union[pd.DataFrame, pd.Series]], mask: Any = slice(None), 
    num_to_pick: int = 4, semilog: bool = False):
    """
    Pick a few example time series at random and draw a graph of each,
    showing raw data and a curve fit to that raw data.
    
    :param mask: Boolean mask or slice to apply to all the dataframes
     passed to this function, or none to select everything.
    :param data_df: Dataframe of time series data
    :param col_name: Name of column in `data_df` containing the particular
     time series to display. Also used in chart titles.
    :param curves: Dictionary of curve name to dataframe or series
     of curve information. Dataframes must have the curve in a column
     called "Curve"
    :param num_to_pick: Number of examples to choose at random
    :param semilog: If `True`, draw a semilog plot with a logarithmic Y axis
    """
    df_subset = data_df[mask]
    num_to_pick = min(num_to_pick, len(df_subset.index))
    if num_to_pick == 0:
        print("Nothing to plot")
        return
    
    num_plot_cols = 2
    num_plot_rows = ((num_to_pick - 1) // num_plot_cols) + 1
    
    np.random.seed(42)
    row_indexes = np.random.choice(len(df_subset.index), 
                                   num_to_pick, replace=False)
    
    fig, axs = plt.subplots(num_plot_rows, num_plot_cols)
    fig.set_size_inches((8 * num_plot_cols, 5 * num_plot_rows))
    for i in range(len(row_indexes)):
        plot_row = i // num_plot_cols
        plot_col = i % num_plot_cols
        if num_plot_rows == 1:
            # matplotlib uses a single index when there is only 1 row
            plot_obj = axs[plot_col]
        else: 
            plot_obj = axs[plot_row, plot_col]
        
        ix = row_indexes[i]
        df_row = df_subset.iloc[ix]
        
        if len(curves.keys()) > 0:
            plot_obj.set_title(f"{col_name} Cases in {df_row['County']} County, "
                               f"{df_row['State']} vs {', '.join(curves.keys())}")
        else:
            plot_obj.set_title(f"{col_name} Cases in {df_row['County']} County, "
                               f"{df_row['State']}")
        
        actual_vals = df_row[col_name]
        if semilog:
            plot_obj.set_yscale("log")
            plot_obj.set_ylim(1e-1, 2 * np.max(actual_vals))
            
        # Color-code using the "Outlier" flag if present
        outlier_col_name = col_name + "_Outlier"
        if outlier_col_name in df_subset.columns:
            outlier_mask = df_row[outlier_col_name]
        else:
            outlier_mask = np.zeros_like(actual_vals, dtype=np.int8)
            
        # Note that the meaning of the first argument of np.ma.masked_where()
        # is the opposite of what you might think it is.
        non_outliers = np.ma.masked_where(outlier_mask == 1, actual_vals)
        outliers = np.ma.masked_where(outlier_mask == 0, actual_vals)

        plot_obj.plot(non_outliers, "o", markersize=3, color="brown")
        plot_obj.plot(outliers, "o", color="red")
        
        for name, value in curves.items():
            if isinstance(value, pd.DataFrame):
                value = value["Curve"]
            curve_vals = value[mask].iloc[ix]
            plot_obj.plot(curve_vals, label=name)
            
    plt.show()
    