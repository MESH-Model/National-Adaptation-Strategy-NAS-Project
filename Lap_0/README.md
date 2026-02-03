# Lap 0: Model Agnostic Framework – Model Setup

---

## Lap Overview and Objectives

Lap 0 establishes a foundation to the hydrological framework by defining model configuration steps and introducing input datasets. It includes appropriate setup files for the MERIT-Hydro and CLRH geofabrics, as well as documentation and access instructions for additional geospatial and forcing data implemented in future laps. Furthermore, it details scripts and modifications applied to the **Model Agnostic Framework (MAF)**, a reproducible preprocessing workflow developed by Kasra Keshavarz at the University of Calgary. Subsequent Laps reference information provided in this directory.

Model run iterations require a discrete set of input datasets and parameters to function, most of which are provided in Lap 0. Essential datasets for each run can be divided into two categories, listed below.

### Geospatial Data

- **Geofabric (MERIT-Hydro, CLRH, CAMELS-SPAT):** A domain-wide network of subbasin polygons which define basin connectivity, flow routing, lake/reservoir interactions, and provide a baseline for dataset remapping. Constitutes the MESH "grid". Includes stream gauging stations as fixed control points.
- **Landcover Information (NALCMS, ESA WorldCover):** A raster dataset delineating landcover classifications in Canada which are separated into Grouped Response Units (GRUs), parameterized at the sub-grid level. Grid cells include a tile set reflecting the ratio of GRUs within the subbasin, subject to unique land-surface calculations. Landcover has important effects on evapotranspiration, flow rate, and snow accumulation.
- **Soil Information (GSDE, SoilGrids):** Domain-wide raster information including horizon-specific parameters related to soil moisture and type, governing infiltration, baseflow, and runoff dynamics. Aggregated vertically into established depth thresholds, enabling comparability and minimizing dilution of topsoil properties. Assigned to GRUs based on the intersecting average.

### Forcing Data

- **Atmospheric Model (CaSR, ERA5-Land, CMIP):** Nationwide data from ensemble meteorological information systems providing historical and projected values for precipitation, temperature, humidity, pressure, wind speed, and radiation. Variables influence and generate feedback in both the water cycle and the atmospheric energy balance, which are essential components in the MESH model.

## Configuration Workflow – The Model Agnostic Framework (MAF)

An important component of model preprocessing and configuration is the MAF, which ties together the aforementioned datasets into a standardized procedure, ensuring consistency and repeatability. The modular workflow divides the objective into three primary tasks: geofabric preparation, model-agnostic preprocessing, and model-specific configuration. By decoupling preprocessing from model-specific requirements, the procedure enables scalable and systematic incorporation of dataset updates through a High-Performance Computing (HPC) environment.

The NAS project utilizes a range of additional Python scripts in the preprocessing step, including tools for subbasin aggregation and geospatial data remapping. Scripts are available in the corresponding `National-Adaptation-Strategy-NAS-Project/Scripts` directory, and referenced in their respective laps. Details on the MAF structure and script integration are provided in Figure 1. For detailed instructions on setting up and applying the MAF, refer to the [Community Model Workflow Training](https://github.com/CH-Earth/community-modelling-workflow-training).

---

![Modified Model Agnostic Framework](../images/MAF_Strategy.png)  
*Figure 1: The Model Agnostic Framework Workflow, Including Additional Scripts*

---

## List of Geospatial Datasets

### Geofabrics

- **Multi-Error-Removed Improved Terrain Hydro (MERIT-Hydro):** A high-resolution global hydrology dataset developed at the University of Tokyo which corrects common DEM errors. Global availability makes the dataset well-suited for cross-boundary simulations, but less appropriate at localized scales. 

- **Canadian Lake River Hydrofabric (CLRH):** Derived at the University of Waterloo from MERIT-Hydro, the CLRH provides high-quality data at the national scale, tailored for Canadian hydrology and linked with operational gauges from the Water Survey of Canada (WSC). Integration of local datasets and conventions ensure it provides top-quality data, emphasizing Lake-River interactions and connectivity.

- **Catchment Attributes and Meteorology for Large-Sample Spatially Distributed Analysis (CAMELS-SPAT):** Limited to 1426 basins within the domain, CAMELS-SPAT combines the quality of MERIT basins with the gauge-based analysis points of the CLRH, spanning much of North America. Streamflow, atmospheric forcing, and geophysical attributes are also incorporated to support more advanced hydrological studies.

### Land Use

- **North American Land Change Monitoring System (NALCMS):** A standardized 30-meter land cover map for North America which includes 15 unique groups derived from satellite imagery. Cropland, forests, and other classes are inputted into MESH as GRUs. It follows the Land Cover Classification System established by the United Nations.

- **European Space Agency World Land Cover Product (ESA Worldcover):** Global land cover information, distributed into 11 unique types. Suited for comprehensive, transboundary applications, the 10-meter dataset includes satellite-derived classifications such as grassland, herbaceous wetland, and needleleaf forest.

## Soil Data

- **Global Soil Dataset for Earth System Models (GSDE):**

- **SoilGrids:**

## List of Forcing Datasets

### Canadian Surface Reanalysis (CaSR)

### Coupled Model Intercomparison Project (CMIP)

## Preprocessing Scripts

## Model Configuration Criteria
