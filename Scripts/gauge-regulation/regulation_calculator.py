#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
from exactextract import exact_extract
import geopandas as gpd
from time import time


# In[2]:


#print('Enter Directory where the files basins.shp, gauges.shp, and precipitation.tif can be found.\n')

directory = input('Paste directory for data files "basins.shp", "gauges.shp", and "precipitation.tif": ')

start = time() # Record start time of program execution

basins_shape = gpd.read_file(f'{directory}/basins.shp') # Locate and read the 'basin.shp' polygon shapefile
gauges_shape = gpd.read_file(f'{directory}/gauges.shp') # Locate and read the 'gauge.shp' point shapefile
precipitation = f'{directory}/precipitation.tif' # Location the 'precipitation.tif' source raster

basins = basins_shape.drop(columns = 'geometry') # Remove geometry attributes for DI calculation
gauges = gauges_shape.drop(columns = 'geometry') # Data acquired from NALRRP and the Government of Canda


# In[3]:


def basin_finder(basins, row, neighbours):
    '''Returns a list of subbasin IDs from the dataset (basins) which flow into a particular gauge (row). A dictionary (neighbours) identifies linked subbasins.
    The loop pops each subbasin from the stack and appends neighbouring polygons, repeating until the list is empty.'''

    stack = [row['SubId']] # Start with just the starting ID in the stack
    search = stack.copy()

    while stack: # Repeat until stack is empty

        inflows = neighbours.get(stack.pop(), []) # Identify shapes flowing into the starting ID

        for item in inflows: # Add inflows to the stack and basin tree

            search.append(item) # Adds the inflows to both the stack and the subbasin list
            stack.append(item)

    return search # Return the subbasin list


# In[4]:


def basin_map(basins, gauges):
    '''Returns a dictionary map linking every subbasin ID with a list of basins that flow into it (basins). Iterates over each stream gauge (gauges). Calls the
    basin_finder() function repeatedly and provides feedback on search progress.'''
    
    basin_map = {} # Initiate dictionary of gauge basins
    total_gauges = gauges.shape[0] # Precompute the number of gauges to save processing time
    neighbours = basins.groupby('DowSubId')['SubId'].apply(list).to_dict() # Reduce filtering time by creating a dictionary in advance

    for key in list(neighbours.keys()): # Iterates over the dictionary
        
        if int(key) < 0: del neighbours[key] # Removes elements with a negative key, which occurs at the basin mouth
    
    for index, row in gauges.iterrows(): # Iterate over stream gauges
        
        basin_map[row['SubId']] = basin_finder(basins, row, neighbours) # Append the search list to the dictionary
        print(f'Basin networks processed: {len(basin_map)}/{total_gauges} ({100 * len(basin_map)/total_gauges:.2f}%)', end = '\r') # Print visual feedback

    return basin_map # Return dictionary of subbasin lists


# In[5]:


print('Calculating zonal statistics...') # Print visual feedback
precipitation = exact_extract(precipitation, basins_shape, ['mean'], include_cols = ['SubId'], output = 'pandas') # Compute zonal statistics for each subbasin
basins = pd.merge(basins, precipitation, on = 'SubId').rename(columns = {'mean':'Precip_Mean'}) # Join the DataFrames with the 'SubId' field
total_gauges = gauges.shape[0] # Precompute the number of gauges to save processing time


# In[6]:


for index, row in gauges.copy().iterrows(): # Check for stream gauges not represented within the network

    print(f'Gauges validated: {index}/{total_gauges} ({100 * index/total_gauges:.2f}%)', end = '\r') # Print visual feedback
    if not(row['SubId'] in basins['SubId'].values): # Identify gauges without a corresponding basin

        gauges = gauges[gauges['SubId'] != row['SubId']] # Delete the gauge from the dataframe

print() # Print a newline
gauge_map = basin_map(basins, gauges) # Determine the set of drainage polygons for each stream gauge


# In[7]:


basin_storage = {} # Initiate the storage dictionary
print() # Print newline

for index, row0 in gauges.iterrows(): # Calculating the DI value

    numerator = 0 # Initiate the DI numerator [ac-ft]
    precip = 0 # Initiate precipitation value for gauge [mm]
    total_area = row0['DrainArea'] # Total drainage area for the gauge site [m2]
    check_area = 0 # To be compared with total area
    total_gauges = gauges.shape[0] # Precompute the number of gauges to save processing time
    
    basin_builder = gauge_map[row0['SubId']] # Return all subbasins that flow into the station, removing duplicates.
    gauge_basin = basins[basins['SubId'].isin(basin_builder)] # Create a dataframe out of the retrieved values
    subbasin_count = gauge_basin.shape[0] # Precompute the number of subbasins to save processing time
    
    for subindex, subbasin in gauge_basin.iterrows(): # Compute DI for each gauge with the subset of basins retrieved

        precip += (subbasin['BasArea'] * subbasin['Precip_Mean']) / total_area # Portion of the mean precipitation weighted average [m2][mm]/[m2] = [mm]
        check_area += subbasin['BasArea']
        
        if subbasin['Lake_Cat'] == 1 and subbasin['Laketype'] in [2, 3]: # Filter for regulated lakes or reservoirs

            volume_acft = subbasin['LakeVol'] * 810714 # Convert from km3 to ac-ft [ac-ft]
            numerator += volume_acft * (subbasin['DrainArea'] / total_area) # Summation in numerator of DI [ac-ft][m2]/[m2] = [ac-ft]
    
    area_ac = total_area / 4046.86 # Convert from m2 to ac [ac]
    precip /= 304.8 # Convert to ft and convert to average [ft]

    gauges.loc[index, 'DI'] = numerator / (precip * area_ac) # Final DI computation [ac-ft]/[ft]/[ac] = 1
    
    gauges.loc[index, 'CheckArea'] = check_area # For comparison with total area
    basin_storage[index] = gauge_basin # Saving subsets for cross-checking

    print(f'Gauges calculated: {index + 1}/{total_gauges} ({100 * (index + 1)/total_gauges:.2f}%)', end = '\r') # Print visual feedback

gauges.loc[:, 'AreaError'] = abs(gauges['CheckArea'] - gauges['DrainArea']) / gauges['DrainArea'] # Vector computation of percent error
end = time() # Record end time of program execution

print(f'\nExecution time: {end - start:.2f} seconds\nOutput location: "{directory}/gauges_DI.csv"') # Signal completion of the process.
gauges.to_csv(f'{directory}/gauges_DI.csv') # Write to .csv file
    

