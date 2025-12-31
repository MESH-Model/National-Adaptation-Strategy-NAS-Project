
---

# Iteration 3.01

## Model Setup and Metadata

**MESH Version:** 1.5.5

**Time Period:** 1980–2018

**Run Method:** Lumped Parametrization, Domain Chunking

**Forcing:** CaSR 3.2

This lap includes a MESH model setup for Catchment Attributes and MEteorology for Large-Sample SPATially distributed analysis (CAMELS-SPAT) Basin


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

- **MERIT Hydro** – Terrain and river network data, modified to CAMELS-SPAT
- **WATroute** - Gridded channel and lake routing model
- **Landsat NALCMS 2022** – Land cover data from the North American Land Change Monitoring System
- **GDSE** - Global gridded dataset of soil properties

### Benchmarks

- Kling-Gupta Efficiency (KGE)
- Nash-Sutcliffe Efficiency (NSE)
- Bias distribution for CAMELS-SPAT network

---

## Data Storage and Access

### Forcing File (`Lap_3\Iteration_3.01\01_Forcing`)

Stored locally (not hosted on GitHub due to size)

Size: Unavailable

### Model Output (`Lap_3\Iteration_3.01\03_Model_Results`)

Stored locally (not hosted on GitHub due to size) 

Size: 151 GB

```
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----         12/3/2025   3:07 PM     6162371529 merged_ALWSSOL_D_IG1_GRD.nc
-a----         12/3/2025   3:07 PM     6162371529 merged_ALWSSOL_D_IG2_GRD.nc
-a----         12/3/2025   3:41 PM     6162371529 merged_ALWSSOL_D_IG3_GRD.nc
-a----         12/3/2025   3:53 PM     6162371529 merged_ALWSSOL_D_IG4_GRD.nc
-a----         12/3/2025   3:51 PM     6162371518 merged_ET_D_GRD.nc
-a----         12/3/2025   3:17 PM     6162371529 merged_LQWSSNO_D_GRD.nc
-a----         12/3/2025   3:55 PM     6162371521 merged_RFF_D_GRD.nc
-a----         12/3/2025   3:33 PM   117068312082 merged_RFF_H_GRD.nc
-a----         12/3/2025   3:50 PM     6162371521 merged_SNO_D_GRD.nc
-a----         12/3/2025   3:03 PM          36471 MESH_output_echo_print.txt
-a----         12/3/2025   3:03 PM         662067 model_lss.log
-a----         12/3/2025   3:06 PM     4839948035 QO_D_GRD.nc
```

Forcing dataset and Model outputs can be provided upon request. Please contact the project team for access.

---
