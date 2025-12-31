
---

# Iteration 2.03

## Model Setup and Metadata

**MESH Version:** 1.5.5

**Time Period:** 1980–2010

**Run Method:** Lumped Parametrization, Non-Chunking

**Forcing:** CaSR 3.1

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

### Forcing File (`Lap_2\Iteration_2.03\01_Forcing`)

Stored locally (not hosted on GitHub due to size)

Size: Unavailable

### Model Output (`Lap_2\Iteration_2.03\03_Model_Results`)

Stored locally (not hosted on GitHub due to size) 

Size: 4.44 GB

```
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----        11/19/2025   8:11 AM     1059880237 MESH_output_streamflow.csv
-a----         11/2/2025   4:34 AM     3376693929 QO_D_GRD.nc
```

Forcing dataset and Model outputs can be provided upon request. Please contact the project team for access.

---
