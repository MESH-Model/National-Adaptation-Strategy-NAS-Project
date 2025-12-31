
---

# Iteration 1.04

## Model Setup and Metadata

**MESH Version:** 1860_ME_ZT

**Time Period:** 1950–2100

**Forcing:** CMIP6 (downscaled, not bias corrected)

This lap includes a MESH model setup for the Climate Change Benchmark Basins

Default parameter value from CLASS 3.6 Technical documentation, MESH-setup with additional outlet [(CLASS 3.6 Technical documentation)](https://mesh-model.atlassian.net/wiki/spaces/USER/pages/6390880/Canadian+Land+Surface+Scheme+CLASS)



## Data Description

### Forcing Data

The model uses 7 key climate forcing variables from the **Coupled Model Intercomparison Project (CMIP5)** dataset **CCRN CanRCM4-WFDEI-GEM-CaPA**, which is downscaled and bias corrected. More information on the dataset can be retrieved from [(here)](https://datatool.readthedocs.io/en/latest/datasets.html#summary)

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

- Comparison between CMIP5 and CMIP6

---

## Data Storage and Access

### Forcing File (`Lap_1\Iteration_1.04\01_Forcing`)

Stored locally (not hosted on GitHub due to size)

Size: 513.2 GB

```
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----        11/16/2025   1:54 PM    34215025613 r10i2p1r1_merged_1951_2100.nc
-a----        11/16/2025  12:38 PM    34215026147 r10i2p1r2_merged_1951_2100.nc
-a----        11/16/2025   1:12 PM    34215027568 r10i2p1r3_merged_1951_2100.nc
-a----        11/16/2025  12:38 PM    34215025869 r10i2p1r4_merged_1951_2100.nc
-a----        11/16/2025   2:02 PM    34215027568 r10i2p1r5_merged_1951_2100.nc
-a----          7/3/2025   5:12 PM    34215027344 r8i2p1r1_merged_1951_2100.nc
-a----        11/18/2025   6:03 PM    34215025783 r8i2p1r2_merged_1951_2100.nc
-a----        11/18/2025   5:51 PM    34215025681 r8i2p1r3_merged_1951_2100.nc
-a----        11/18/2025   6:11 PM    34215025791 r8i2p1r4_merged_1951_2100.nc
-a----        11/18/2025   6:26 PM    34215025789 r8i2p1r5_merged_1951_2100.nc
-a----        11/18/2025   5:15 PM    34215026441 r9i2p1r1_merged_1951_2100.nc
-a----        11/18/2025   5:11 PM    34215025789 r9i2p1r2_merged_1951_2100.nc
-a----        11/18/2025   8:26 PM    34215025789 r9i2p1r3_merged_1951_2100.nc
-a----        11/18/2025   6:18 PM    34215025789 r9i2p1r4_merged_1951_2100.nc
-a----        11/18/2025   5:45 PM    34215025789 r9i2p1r5_merged_1951_2100.nc
```

### Model Output (`Lap_1\Iteration_1.04\03_Model_Results`)

Stored locally (not hosted on GitHub due to size), **with the exception of output streamflow**

Size: Unavailable

Forcing dataset and Model outputs can be provided upon request. Please contact the project team for access.

---
