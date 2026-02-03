# Lap 0: Model Agnostic Framework – Model Setup

---

## Lap Overview and Objectives

Lap 0 establishes a foundation to the hydrological framework by defining model configuration steps and introducing input datasets. It includes appropriate setup files for the MERIT-Hydro and CLRH geofabrics, as well as documentation and access instructions for additional geospatial and forcing data implemented in future laps. Furthermore, it details scripts and modifications applied to the **Model Agnostic Framework (MAF)**, a reproducible preprocessing workflow developed by Kasra Keshavarz at the University of Calgary. Subsequent Laps reference information provided in this directory.

Model run iterations require a discrete set of input datasets and parameters to function, most of which are provided in Lap 0. Essential datasets for each run can be divided into two categories, listed below.

### Geospatial Data

- **Geofabric (CLRH, MERIT-Hydro, CAMELS-SPAT, NALRRP):** A domain-wide network of subbasin polygons which define basin connectivity and flow routing, lake/reservoir interactions, and provides a baseline for dataset remapping.
- **Landcover Information (NALCMS, ESA, WorldCover):** A raster dataset delineating landcover classifications in Canada, which are separated into Grouped Response Units (GRUs) and remapped on to subbasin geometry. Landcover has important effects on evapotranspiration, flow rate, and snow accumulation.
- **Soil Information (GSDE, SoilGrids):** Domain-wide raster information including horizon-specific parameters related to soil moisture and type, governing infiltration, baseflow, and runoff dynamics. Aggregated vertically into established depth thresholds, enabling comparability and minimizing dilution of topsoil properties. Remapped into subbasin geometry.

### Forcing Data

- **Atmospheric Model (CaSR, ERA5-Land, CMIP):** Nationwide data from ensemble meteorological information systems providing historical and projected values for precipitation, temperature, humidity, pressure, wind speed, and radiation. Variables influence and generate feedback in both the water cycle and the atmospheric energy balance, which are essential components in the MESH model.

## Configuration Workflow – The Model Agnostic Framework (MAF)

It is important that the conducted research is transparent, physically consistent, and reproducible. Therefore, the repository includes detailed model configurations, metadata, and preliminary outputs from historical and climate-change simulations using the MESH hydrological model.

A modified approach to the MAF is applied, which organizes preprocessing and configuration steps into a repeatable workflow. By decoupling preprocessing from model-specific requirements, the procedure enables scalable 

---

![Modified Model Agnostic Framework](../images/MAF_Strategy.png)  
*Figure 1: The Model Agnostic Framework Workflow, Including Additional Scripts*

---
