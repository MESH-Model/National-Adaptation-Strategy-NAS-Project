
---

# Iteration 2.04

## Model Setup and Metadata

**Version:** 1.5.5

**Period:** 1980–2023

**Run Method:** Lumped Parametrization, Domain Chunking

This lap includes a MESH model setup for all of Canada, including transboundary basins

GRU parameterization: Derived GRUs average MESH parameter value are used 


## Data Description

### Forcing Data

The model uses 7 key climate forcing variables from the **Canadian Surface Reanalysis (CaSR v3.1)** dataset. More information on the dataset can be retrieved from [(here)](https://datatool.readthedocs.io/en/latest/datasets.html#summary)

- Precipitation  
- Specific humidity  
- Air temperature  
- Longwave radiation  
- Shortwave radiation  
- Wind speed  
- Surface pressure  

### Geospatial Datasets

- **MERIT Hydro** – Terrain and river network data
- **WATroute** - Gridded channel and lake routing model
- **Landsat NALCMS 2022** – Land cover data from the North American Land Change Monitoring System
- **GDSE** - Global gridded dataset of soil properties

### Benchmarks

- Kling-Gupta Efficiency (KGE)
- Nash-Sutcliffe Efficiency (NSE)
- Bias distribution for CAMELS-SPAT network

---

## Data Storage and Access

### Forcing File (`Lap_2\Iteration_2.04\01_Forcing`)

Stored locally (not hosted on GitHub due to size)

Size: Unavailable

### Model Output (`Lap_2\Iteration_2.04\03_Model_Results`)

Stored locally (not hosted on GitHub due to size) 

Size: 55.7 GB

``
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----        11/13/2025   7:56 AM     6162371529 merged_ALWSSOL_D_IG1_GRD.nc
-a----        11/13/2025   7:57 AM     6162371529 merged_ALWSSOL_D_IG2_GRD.nc
-a----        11/13/2025   8:34 AM     6162371529 merged_ALWSSOL_D_IG3_GRD.nc
-a----        11/13/2025   8:29 AM     6162371529 merged_ALWSSOL_D_IG4_GRD.nc
-a----        11/13/2025   8:05 AM     6162371518 merged_ET_D_GRD.nc
-a----        11/13/2025   7:59 AM     6162371529 merged_LQWSSNO_D_GRD.nc
-a----        11/13/2025   8:35 AM     6162371521 merged_RFF_D_GRD.nc
-a----        11/13/2025   8:03 AM     6162371521 merged_SNO_D_GRD.nc
-a----        11/13/2025   8:45 AM          36471 MESH_output_echo_print.txt
-a----        11/18/2025   3:40 PM     1518545637 MESH_output_streamflow.csv
-a----        11/18/2025   4:54 PM           1745 metrics_description.txt
-a----        11/18/2025   4:54 PM        1006903 metrics_MESH_CaSRv3p1_Average_GRU_Params_MESH_1p5p5.csv
-a----        11/13/2025   8:44 AM         661860 model_lss.log
-a----        11/13/2025   9:21 AM     4839948035 QO_D_GRD.nc
``

Forcing dataset and Model outputs can be provided upon request. Please contact the project team for access.

---
