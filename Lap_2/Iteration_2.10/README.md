
---

# Iteration 2.10

## Model Setup and Metadata

**Version:** 1.5.5

**Period:** 2015–2100

**Run Method:** Lumped Parametrization (2.01), Domain Chunking

**Scenario:** CanESM5 SSP3-7.0

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

### Forcing File (`Lap_2\Iteration_2.10\01_Forcing`)

Stored locally (not hosted on GitHub due to size)

Size: Unavailable

### Model Output (`Lap_2\Iteration_2.10\03_Model_Results`)

Stored locally (not hosted on GitHub due to size) 

Size: 109 GB

```
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----         12/4/2025   2:06 AM    12323792969 merged_ALWSSOL_D_IG1_GRD.nc
-a----         12/4/2025   2:06 AM    12323792969 merged_ALWSSOL_D_IG2_GRD.nc
-a----         12/4/2025   2:05 AM    12323792969 merged_ALWSSOL_D_IG3_GRD.nc
-a----         12/4/2025   2:04 AM    12323792969 merged_ALWSSOL_D_IG4_GRD.nc
-a----         12/4/2025   2:41 PM    12323792958 merged_ET_D_GRD.nc
-a----         12/4/2025   2:26 AM         450025 merged_LQWSSNO_D_GRD.nc
-a----         12/4/2025   2:35 PM    12323792961 merged_RFF_D_GRD.nc
-a----         12/4/2025   2:39 PM    12323792961 merged_SNO_D_GRD.nc
-a----         12/4/2025   3:15 PM     2879011500 MESH_output_streamflow.csv
-a----         12/4/2025   2:38 PM     9594836867 QO_D_GRD.nc
```

Forcing dataset and Model outputs can be provided upon request. Please contact the project team for access.

---
