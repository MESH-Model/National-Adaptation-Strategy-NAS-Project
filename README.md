# National Adaptation Strategy (NAS) Project – MESH Model Setup

---
## National Adaptation Strategy (NAS) – Hydrological Modeling

This repository contains the initial hydrological modeling setup and metadata for the National Adaptation Strategy (NAS) project led by Environment and Climate Change Canada (ECCC). The project aims to support climate resilience by generating large-scale hydroclimate data and modeling future water availability across Canada's transboundary river basins using the MESH hydrological model.

Key preliminary outputs include historical simulations of streamflow, evapotranspiration, soil moisture, and snow water equivalent. These results form the foundation for assessing future climate change impacts on water resources in Canada’s transboundary basins.


## Project objective and Scope

The objective of this project is to generate accurate, regional-scale projections of hydroclimate variables under various climate change scenarios. Using the MESH hydrological model, the initial phase simulates surface water processes such as streamflow and evapotranspiration across Canada’s transboundary basins.


---


## Study Domain and Dataset

The study domain encompasses all of Canada’s river basins, including **Transboundary River Basins (CanTrans)** that span the Canada–United States border.

Key transboundary systems include:

- Columbia River Basin
- Yukon River Basin
- Mackenzie River Basin
The domain reflects the geographical and hydrological diversity of Canada's river systems, emphasizing those of binational importance. A map of the river basins is provided below.

![Canada Transboundary Basins](images/Picture1.png)  
*Figure 1: Canada's river basins and transboundary systems*

---
## Model Cases and Repository Setup

This repository includes multiple configurations (based on the Model run configuration sequencing strategy) of the MESH hydrological model as part of the initial NAS project analysis:

- **Lap_0** - Model Agnostic Framework (MAF) model setup
- **Lap_1** - Out-of-box parameter MESH runs on version 1860_ME_ZT
	- **Iterations 1.01–1.03** - Base Case 0 run with uncalibrated parameters on CaSR
	- **Iterations 1.04–1.09** - Sub-area initial climate change simulations with parametrization on CMIP
- **Lap_2** - Parameters estimation from available data [MODIS LAI, Soil, DD, SDep]
	- **Iterations 2.01–2.06** - Base Case 1 run with lumped/distributed parametrization on CaSR and chunking
	- **Iterations 2.07–2.11** - Full domain initial climate change simulations with updated parametrization on CMIP
  
Each case includes:
- Configuration files for MESH
- Metadata file



