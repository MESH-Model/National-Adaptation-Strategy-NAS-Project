
---

# Iteration 2.06

## Model Setup and Metadata

**Version:** 1.5.5

**Period:** 1980–2023

**Run Method:** Distributed Parametrization, Domain Chunking

This lap includes a MESH model setup for all of Canada, including transboundary basins

Distributed parameterization: Derived subbasin average MESH parameter values are used 


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

### Forcing File (`Lap_2\Iteration_2.06\01_Forcing`)

Stored locally (not hosted on GitHub due to size)

Size: Unavailable

### Model Output (`Lap_2\Iteration_2.06\03_Model_Results`)

Stored locally (not hosted on GitHub due to size) 

Size: 55.7 GB

```
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----        11/13/2025   8:51 AM     6162371529 merged_ALWSSOL_D_IG1_GRD.nc
-a----        11/13/2025   8:54 AM     6162371529 merged_ALWSSOL_D_IG2_GRD.nc
-a----        11/13/2025   8:19 AM     6162371529 merged_ALWSSOL_D_IG3_GRD.nc
-a----        11/13/2025   8:19 AM     6162371529 merged_ALWSSOL_D_IG4_GRD.nc
-a----        11/13/2025   9:47 AM     6162371518 merged_ET_D_GRD.nc
-a----        11/13/2025   8:54 AM     6162371529 merged_LQWSSNO_D_GRD.nc
-a----        11/13/2025   8:55 AM     6162371521 merged_RFF_D_GRD.nc
-a----        11/13/2025   9:49 AM     6162371521 merged_SNO_D_GRD.nc
-a----        11/13/2025   8:15 AM         176378 MESH_output_echo_print.txt
-a----        11/18/2025   4:36 PM     1526106314 MESH_output_streamflow.csv
-a----        11/18/2025   4:58 PM           1745 metrics_description.txt
-a----        11/18/2025   4:58 PM        1007373 metrics_MESH_CaSRv3p1_Distributed_GRU_Params_MESH_1p5p5.csv
-a----        11/13/2025   9:22 AM         661861 model_lss.log
-a----        11/13/2025   9:27 AM     4839948035 QO_D_GRD.nc
```

Forcing dataset and Model outputs can be provided upon request. Please contact the project team for access.

---
