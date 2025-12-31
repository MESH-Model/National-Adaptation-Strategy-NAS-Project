
---

# Iteration 2.07

## Model Setup and Metadata

**Version:** 1.5.5

**Period:** 1950–2014

**Run Method:** Lumped Parametrization (2.01), Domain Chunking

**Scenario:** CanESM5 Historical

This lap includes a MESH model setup for all of Canada, including transboundary basins


## Data Description

### Forcing Data

The model uses 7 key climate forcing variables from the **TBD** dataset. More information on the dataset can be retrieved from [(here)](https://datatool.readthedocs.io/en/latest/datasets.html#summary)

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

### Setup Files (`Lap_2\Iteration_2.07\02_Model_Setup`)

The following files are stored locally (not hosted on GitHub due to size):

- `MESH_input_streamflow_latlon.tb0` (1.3 GB)

### Forcing File (`Lap_2\Iteration_2.07\01_Forcing`)

Stored locally (not hosted on GitHub due to size)

Size: Unavailable

### Model Output (`Lap_2\Iteration_2.07\03_Model_Results`)

Stored locally (not hosted on GitHub due to size) 

Size: 78.9 GB

```
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----         12/3/2025  11:57 PM     9243080918 merged_ALWSSOL_D_IG1_GRD.nc
-a----         12/3/2025  11:56 PM     9243080918 merged_ALWSSOL_D_IG2_GRD.nc
-a----         12/3/2025   9:35 PM     9243080918 merged_ALWSSOL_D_IG3_GRD.nc
-a----         12/3/2025  11:57 PM     9243080918 merged_ALWSSOL_D_IG4_GRD.nc
-a----         12/4/2025  12:00 AM     9243080918 merged_ET_D_GRD.nc
-a----         12/4/2025  12:11 AM     9243080918 merged_LQWSSNO_D_GRD.nc
-a----         12/4/2025  12:13 AM     7232322786 merged_RFF_D_GRD.nc
-a----         12/4/2025  12:12 AM     9243080918 merged_SNO_D_GRD.nc
-a----         12/3/2025   9:49 PM     1190921725 MESH_output_streamflow.csv
-a----         12/3/2025  10:32 PM     3855201307 QO_D_GRD.nc
```

Forcing dataset and Model outputs can be provided upon request. Please contact the project team for access.

---
