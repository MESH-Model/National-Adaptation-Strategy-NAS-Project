
---

# Iteration 1.01

## Model Setup and Metadata

**MESH Version:** 1860_ME_ZT

**Time Period:** 1980–2018

**Forcing:** CaSR 2.1

This lap includes a MESH model setup for all of Canada, including transboundary basins

Default parameter value from CLASS 3.6 Technical documentation, MESH-setup with additional outlet [(CLASS 3.6 Technical documentation)](https://mesh-model.atlassian.net/wiki/spaces/USER/pages/6390880/Canadian+Land+Surface+Scheme+CLASS)



## Data Description

### Forcing Data

The model uses 7 key climate forcing variables from the **Canadian Surface Reanalysis (CaSR v2.1)** dataset, formerly known as RDRS2.1. More information on the dataset can be retrieved from [(here)](https://datatool.readthedocs.io/en/latest/datasets.html#summary)

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

### Benchmarks

- Kling-Gupta Efficiency (KGE)
- Nash-Sutcliffe Efficiency (NSE)
- Bias distribution for CAMELS-SPAT network

---

## Data Storage and Access

### Forcing File (`Lap_1\Iteration_1.01\01_Forcing`)

Stored locally (not hosted on GitHub due to size)

Size: 566.2 GB

```
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----         4/17/2025   8:46 PM   566181074422 MESH_input_CanTrans_CaSRv2p1_1980_2018.nc
```

### Model Output (`Lap_1\Iteration_1.01\03_Model_Results`)

Stored locally (not hosted on GitHub due to size) 

Size: 67.1 GB

```
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----        12/17/2025  12:09 PM     3958374400 merged_ALWSSOL_D_IG1_GRD.nc
-a----        12/17/2025  12:09 PM     4287889408 merged_ALWSSOL_D_IG2_GRD.nc
-a----        12/17/2025  11:49 AM     6162363337 merged_ALWSSOL_D_IG3_GRD.nc
-a----        12/17/2025  12:09 PM     3440115712 merged_ALWSSOL_D_IG4_GRD.nc
-a----        12/17/2025  12:09 PM    49285693440 merged_RFF_H_GRD.nc
```

Forcing dataset and Model outputs can be provided upon request. Please contact the project team for access.

---
