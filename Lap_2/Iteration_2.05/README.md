
---

# Iteration 2.05

## Model Setup and Metadata

**MESH Version:** 1.5.5

**Time Period:** 1980–2023

**Run Method:** Lumped Parametrization, Domain Chunking

**Forcing:** CaSR 3.1 + Forecast Prec

This lap includes a MESH model setup for all of Canada, including transboundary basins

GRU parameterization: Derived GRUs average MESH parameter value are used 


## Data Description

### Forcing Data

The model uses 7 key climate forcing variables from the **Canadian Surface Reanalysis (CaSR v3.1)** dataset and forecast precipitation. More information on the dataset can be retrieved from [(here)](https://datatool.readthedocs.io/en/latest/datasets.html#summary)

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

### Forcing File (`Lap_2\Iteration_2.05\01_Forcing`)

Stored locally (not hosted on GitHub due to size)

Size: Unavailable

### Model Output (`Lap_2\Iteration_2.05\03_Model_Results`)

Stored locally (not hosted on GitHub due to size) 

Size: 55.8 GB

```
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----        11/13/2025   8:50 AM     6162371529 merged_ALWSSOL_D_IG1_GRD.nc
-a----        11/13/2025   8:50 AM     6162371529 merged_ALWSSOL_D_IG2_GRD.nc
-a----        11/13/2025   8:50 AM     6162371529 merged_ALWSSOL_D_IG3_GRD.nc
-a----        11/13/2025   8:49 AM     6162371529 merged_ALWSSOL_D_IG4_GRD.nc
-a----        11/13/2025   9:46 AM     6162371518 merged_ET_D_GRD.nc
-a----        11/13/2025   9:14 AM     6162371529 merged_LQWSSNO_D_GRD.nc
-a----        11/13/2025   9:12 AM     6162371521 merged_RFF_D_GRD.nc
-a----        11/13/2025   9:15 AM     6162371521 merged_SNO_D_GRD.nc
-a----        11/13/2025   8:15 AM         176377 MESH_output_echo_print.txt
-a----        11/18/2025   4:08 PM     1499661581 MESH_output_streamflow.csv
-a----        11/13/2025   8:45 AM      187498975 mesh_rte.log
-a----        11/18/2025   4:56 PM           1745 metrics_description.txt
-a----        11/18/2025   4:56 PM        1001381 metrics_MESH_CaSRv3p1_Average_GRU_Params_MESH_1p5p5_pr_forcast.csv
-a----        11/13/2025   8:15 AM     4839948035 QO_D_GRD.nc
-a----        11/13/2025   8:44 AM            336 run_mesh_lss.sh
```

Forcing dataset and Model outputs can be provided upon request. Please contact the project team for access.

---
