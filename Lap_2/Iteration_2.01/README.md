
---

# Iteration 2.01

## Model Setup and Metadata

**Version:** 1.5.5

**Period:** 1980–2018

**Run Method:** Lumped Parametrization, Domain Chunking

This lap includes a MESH model setup for all of Canada, including transboundary basins

GRU parameterization: Derived GRUs average MESH parameter value are used 


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
- **GDSE** - Global gridded dataset of soil properties

### Benchmarks

- Kling-Gupta Efficiency (KGE)
- Nash-Sutcliffe Efficiency (NSE)
- Bias distribution for CAMELS-SPAT network

---

## Data Storage and Access

### Forcing File (`Lap_2\Iteration_2.01\01_Forcing`)

Stored locally (not hosted on GitHub due to size)

Size: Unavailable

### Model Output (`Lap_2\Iteration_2.01\03_Model_Results`)

Stored locally (not hosted on GitHub due to size) 

Size: 55.1 GB

```
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----        11/18/2025   4:58 PM          40182 excluded_stations_kge.txt
-a----        11/18/2025   4:58 PM          40182 excluded_stations_nse.txt
-a----        11/18/2025   4:59 PM          40182 excluded_stations_pbias.txt
-a----        11/13/2025   8:23 AM     6162363337 merged_ALWSSOL_D_IG1_GRD.nc
-a----        11/13/2025   7:48 AM     6162363337 merged_ALWSSOL_D_IG2_GRD.nc
-a----        11/13/2025   7:48 AM     6162363337 merged_ALWSSOL_D_IG3_GRD.nc
-a----        11/13/2025   8:24 AM     6162363337 merged_ALWSSOL_D_IG4_GRD.nc
-a----        11/13/2025   8:34 AM     6162363326 merged_ET_D_GRD.nc
-a----        11/13/2025   7:51 AM     6162363337 merged_LQWSSNO_D_GRD.nc
-a----        11/13/2025   7:51 AM     6162363329 merged_RFF_D_GRD.nc
-a----        11/13/2025   8:31 AM     6162363329 merged_SNO_D_GRD.nc
-a----        11/13/2025   7:47 AM         176377 MESH_output_echo_print.txt
-a----        11/18/2025   3:11 PM     1339792617 MESH_output_streamflow.csv
-a----        11/13/2025   7:48 AM      159989659 mesh_rte.log
-a----        11/18/2025   4:52 PM           1745 metrics_description.txt
-a----        11/18/2025   4:52 PM         999785 metrics_MESH_CaSRv2p1_Average_GRU_Params_MESH_1p5p5.csv
-a----        11/13/2025   7:47 AM         586994 model_lss.log
-a----        11/13/2025   8:12 AM     4277323963 QO_D_GRD.nc
```

Forcing dataset and Model outputs can be provided upon request. Please contact the project team for access.

---
