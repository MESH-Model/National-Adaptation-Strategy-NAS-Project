# Lap 2: Parameter Estimation from Available Data

---

## Lap Overview and Objectives

Lap 2 advances the project timeline by implementing parameter estimation from available datasets and evaluating options for atmospheric forcing. It runs on a newer version of MESH (1.5.5), and replaces blanket, Out-of-Box soil properties with a geospatial datasets, assessing output realism from physically informed parameterization.

The workflow implements lumped parameterization through Grouped Response Units (GRU), combining soil and landcover properties to reduce complexity and eliminate redundant calculations. GRUs are built on the assumption that soil properties are constant across a specific landcover type. To challenge said assumption, a run is conducted using distributed parameterization, which decouples the surface parameters and assesses whether the resultant changes to the output are significant.

As an integrative variable, streamflow is the primary anchor point for model evaluation. Its coupled nature with the range of available hydrological processes represented in the MESH model make it effective at summarizing Lap results, which functions well with the fact that it is widely-understood. Flow rate is also efficient to statistically evaluate and visualize, enabling comparisons with the benchmarks defined in Lap 1.

Similar to the previous Lap, Lap 2 also includes full-domain climate simulations using CMIP6 forcing. While certain patterns are apparent, the runs are conducted as a proof-of-concept, demonstrating model operability and credibility.

## Datasets Used

Lap 2 consists of 17 iterations which evolve in a stepwise manner. Initial runs of Iterations 2.01 to 2.17 were completed between August 21, 2025 and February 25, 2026. Refer to Lap 0 for details on individual datasets, which are summarized in Table 1.

---

*Table 1: Lap 2 Iteration Dataset Details*
| Iteration | Geofabric   | Landcover | Soils | Forcing Dataset     | Scenario | MESH Version | Period     |
|-----------|-------------|-----------|-------|---------------------|----------|--------------|------------|
| 2.01      | MERIT-Hydro | NALCMS    | GSDE  | CaSR v2.1           | N/A      | 1.5.5        | Historical |
| 2.02      | MERIT-Hydro | NALCMS    | GSDE  | CaSR v3.1           | N/A      | 1860_ME_ZT   | Historical |
| 2.03      | MERIT-Hydro | NALCMS    | GSDE  | CaSR v3.1           | N/A      | 1.5.5        | Historical |
| 2.04      | MERIT-Hydro | NALCMS    | GSDE  | CaSR v3.1           | N/A      | 1.5.5        | Historical |
| 2.05      | MERIT-Hydro | NALCMS    | GSDE  | CaSR v3.1/Forecast  | N/A      | 1.5.5        | Historical |
| 2.06      | MERIT-Hydro | NALCMS    | GSDE  | CaSR v3.1           | N/A      | 1.5.5        | Historical |
| 2.07      | MERIT-Hydro | NALCMS    | GSDE  | CMIP6/CanESM5       | N/A      | 1.5.5        | Historical |
| 2.08      | MERIT-Hydro | NALCMS    | GSDE  | CMIP6/CanESM5       | SSP1-2.6 | 1.5.5        | Future     |
| 2.09      | MERIT-Hydro | NALCMS    | GSDE  | CMIP6/CanESM5       | SSP2-4.5 | 1.5.5        | Future     |
| 2.10      | MERIT-Hydro | NALCMS    | GSDE  | CMIP6/CanESM5       | SSP3-7.0 | 1.5.5        | Future     |
| 2.11      | MERIT-Hydro | NALCMS    | GSDE  | CMIP6/CanESM5       | SSP5-8.5 | 1.5.5        | Future     |
| 2.12      | MERIT-Hydro | NALCMS    | GSDE  | CaSR v3.2           | N/A      | 1.5.5        | Historical |
| 2.13      | MERIT-Hydro | NALCMS    | GSDE  | ERA5-Land           | N/A      | 1.5.5        | Historical |
| 2.14      | MERIT-Hydro | NALCMS    | GSDE  | CMIP6/MPI-ESM1-2-LR | N/A      | 1.5.5        | Historical |
| 2.15      | MERIT-Hydro | NALCMS    | GSDE  | CMIP6/NorESM2-MM    | N/A      | 1.5.5        | Historical |
| 2.16      | MERIT-Hydro | NALCMS    | GSDE  | CaSR v3.2           | N/A      | 1.5.6        | Historical |
| 2.17      | MERIT-Hydro | NALCMS    | GSDE  | CaSR v3.2           | N/A      | 1.5.7        | Historical |

---

## Performance Metrics

Kling-Gupta Efficiency (KGE) and Nash-Sutcliffe Efficiency (NSE) are the primary performance indicators used to evaluate the uncalibrated model results against observational data.

$\mathrm{KGE}=1-\sqrt{\left(r-1\right)^2+\left(\frac{\mu_s}{\mu_o}-1\right)^2+\left(\frac{\sigma_s}{\sigma_o}-1\right)^2}\qquad \mathrm{NSE}=1-\frac{\Sigma_{t=1}^T\left(Q_o^t-Q_m^t\right)^2}{\Sigma_{t=1}^T\left(Q_o^t-\bar{Q_o}\right)^2}\qquad \mathrm{NKGE}=\frac{1}{2-\mathrm{KGE}}$

Additionally, Normalized KGE (NKGE) is implemented for visualization and reporting purposes, as it flattens large outliers by restricting the output range to [0, 1]. Simplifying display of the hydrological output enables streamlined comparisons of the Cumulative Distribution Functions (CDFs) of gauging stations for each iteration, which are used to identify model improvement. It is defined below.

## Parameterization Methods

### Lumped Parameterization

A computationally efficient approach which assigns each landcover class with a set of soil properties averaged across its domain, forming a GRU. Parameters are then applied to watersheds at a sub-grid level through evaluating intersection of the polygon with distinct landcover types. Routing properties are then averaged, while land-surface calculations are performed for each GRU within a particular subbasin.
and performing distinct surface scheme calculations.

### Distributed Parameterization

More intensive but precise, distributed parameterization involves extraction of hydrologic parameters directly within a subbasin, instead of through enclosed GRUs. Soil properties are averaged within each tile instead of across GRUs, ensuring parameters more closely represent the local environment.

## Observations Summary

Information in this section will be completed at a later date.

## Project Team

- Zelalem Tesemma, Environment and Climate Change Canada (zelalem.tesemma@ec.gc.ca)
- Sujata Budhathoki, Environment and Climate Change Canada (sujata.budhathoki@ec.gc.ca)
- Riley Damen, Environment and Climate Change Canada (riley.damen@ec.gc.ca)
- Frank Seglenieks, Environment and Climate Change Canada (frank.seglenieks@ec.gc.ca)
- Bruce Davison, Environment and Climate Change Canada (bruce.davison@ec.gc.ca)

## Disclaimer
This is an active research repository. Model configurations, parameters, and outputs are subject to change as improvements are made. Please contact the project team before using this material for publications or decision-making applications.
