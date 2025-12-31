
---

# Iteration 2.08

## Model Setup and Metadata

**MESH Version:** 1.5.5

**Time Period:** 2015–2100

**Run Method:** Lumped Parametrization (2.01), Domain Chunking

**Forcing:** TBD

**Scenario:** CanESM5 SSP1-2.6

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

### Setup Files (`Lap_2\Iteration_2.08\02_Model_Setup`)

The following files are stored locally (not hosted on GitHub due to size):

- `MESH_input_streamflow_latlon.tb0` (1.3 GB)
- `MESH_input_streamflow_latlon.tb0.filepart` (0.40 GB)

### Forcing File (`Lap_2\Iteration_2.08\01_Forcing`)

Stored locally (not hosted on GitHub due to size)

Size: Unavailable

### Model Output (`Lap_2\Iteration_2.08\03_Model_Results`)

Stored locally (not hosted on GitHub due to size) 

Size: 109 GB

```
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----         12/4/2025  12:25 AM    12323792969 merged_ALWSSOL_D_IG1_GRD.nc
-a----         12/4/2025  12:25 AM    12323792969 merged_ALWSSOL_D_IG2_GRD.nc
-a----         12/4/2025  12:25 AM    12323792969 merged_ALWSSOL_D_IG3_GRD.nc
-a----         12/4/2025  12:26 AM    12323792969 merged_ALWSSOL_D_IG4_GRD.nc
-a----         12/4/2025  12:55 AM    12323792958 merged_ET_D_GRD.nc
-a----         12/4/2025  12:51 AM    12323792969 merged_LQWSSNO_D_GRD.nc
-a----         12/4/2025  12:49 AM    12323792961 merged_RFF_D_GRD.nc
-a----         12/4/2025  12:51 AM    12323792961 merged_SNO_D_GRD.nc
-a----         12/3/2025   9:38 PM     9594836867 QO_D_GRD.nc
```

Forcing dataset and Model outputs can be provided upon request. Please contact the project team for access.

---
