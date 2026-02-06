# Lap 1: Initial Diagnostic Analysis – Uncalibrated MESH Runs

---

## Lap Overview and Objectives

Building on the configuration framework developed in Lap 0, Lap 1 conducts preliminary, uncalibrated model runs with the goal of identifying baseline flow behaviour and sensitivity to climate forcing. Under the simplified conditions, a configured MESH setup is expected to generate reasonable streamflow behaviour, enabling the comparison of atmospheric forcing datasets for future decision-making.

In addition to the diagnostic streamflow analysis, Lap 1 uniquely investigates the connection between water balance components (e.g. precipitation and evapotranspiration) and relevant discharge patterns. In doing so, it enables identification of inconsistencies in model response between climate forcings, ensuring data quality. Comparative assessment is also conducted between future and historic datasets.

On top of comparing additional input datasets, future runs focus on parameterization, calibration, and implementation of MESH physics. Without advanced or optimized features enabled, Lap 1 serves to inform subsequent runs, while unsuitable for publication itself. It does not include formal performance evaluation or confidence assessment.

## Datasets Used

Lap 1 consists of 9 iterations which evolve in a stepwise manner. Initial runs of Iterations 1.01 to 1.09 were completed between September 24, 2024 and August 21, 2025. Refer to Lap 0 for details on individual datasets, which are summarized in Table 1.

---

*Table 1: Lap 1 Iteration Dataset Details*
| Iteration | Geofabric   | Landcover | Soils      | Forcing   | Scenario | MESH Version | Period   |
|-----------|-------------|-----------|------------|-----------|----------|--------------|----------|
| 1.01      | MERIT-Hydro | NALCMS    | Out-of-Box | CaSR v2.1 | N/A      | 1860_ME_ZT   | Historic |
| 1.02      | CAMELS-SPAT | NALCMS    | Out-of-Box | CaSR v2.1 | N/A      | 1860_ME_ZT   | Historic |
| 1.03      | CAMELS-SPAT | NALCMS    | Out-of-Box | CaSR v3.1 | N/A      | 1860_ME_ZT   | Historic |
| 1.04      | Benchmark   | NALCMS    | Out-of-Box | CMIP5     | RCP-8.5  | 1860_ME_ZT   | All      |
| 1.05      | Benchmark   | NALCMS    | Out-of-Box | CMIP6     | N/A      | 1860_ME_ZT   | Historic |
| 1.06      | Benchmark   | NALCMS    | Out-of-Box | CMIP6     | SSP1-2.6 | 1860_ME_ZT   | Future   |
| 1.07      | Benchmark   | NALCMS    | Out-of-Box | CMIP6     | SSP2-4.5 | 1860_ME_ZT   | Future   |
| 1.08      | Benchmark   | NALCMS    | Out-of-Box | CMIP6     | SSP3-7.0 | 1860_ME_ZT   | Future   |
| 1.09      | Benchmark   | NALCMS    | Out-of-Box | CMIP6     | SSP5-8.5 | 1860_ME_ZT   | Future   |

---

## Performance Metrics

Kling-Gupta Efficiency (KGE) and Nash-Sutcliffe Efficiency (NSE) are the primary performance indicators used to evaluate the uncalibrated model results against observational data.

$KGE=1-\sqrt{\left(r-1\right)^2+\left(\frac{\mu_s}{\mu_o}-1\right)^2+\left(\frac{\sigma_s}{\sigma_o}-1\right)^2}\qquad NSE=1-\frac{\Sigma_{t=1}^T\left(Q_o^t-Q_m^t\right)^2}{\Sigma_{t=1}^T\left(Q_o^t-\bar{Q_o}\right)^2}$

## Benchmark Basins

Ten basins were subset from the aggregated MERIT-Hydro dataset as benchmarks for future climate scenarios, listed in Table 2.

---

*Table 2: Ten Selected Benchmark Basins in the CTRB*
| Operator | Number   | Station Name                                                           |
|----------|----------|------------------------------------------------------------------------|
| WSC      | 01AK010  | SAINT JOHN RIVER AT MACTAQUAC GENERATING STATION                       |
| WSC      | 02GB001  | GRAND RIVER AT BRANTFORD                                               |
| WSC      | 03KC004  | MELEZES (RIVER AUX) A 7,6 KM EN AMONT DE LA CONFLUENCE AVEC LA KOKSOAK |
| WSC      | 05AD007  | OLDMAN RIVER NEAR LETHBRIDGE                                           |
| WSC      | 05AE027  | ST MARY RIVER AT INTERNATIONAL BOUNDARY                                |
| WSC      | 05BB001  | BOW RIVER AT BANFF                                                     |
| WSC      | 070B001  | HAY RIVER NEAR HAY RIVER                                               |
| WSC      | 10LC017  | HAVIKPAK CREEK NEAR INUVIK                                             |
| WSC      | 11AA031  | MILK RIVER AT EASTERN CROSSING OF INTERNATIONAL BOUNDARY               |
| USGS     | 06174500 | MILK RIVER AT NASHUA MT                                                |

---

## Observations Summary

### Historical Runs

Diagnostic analysis of water balance components identified issues related to the reprojection of climate forcing data. Artefacts in the remapped fields were created in the northwest corner of the CTRB, resultant of spatial discontinuities within the authalic projection. The EASYMORE remapping tool caused the discrepancies, which were resolved through a reduction in model domain.

Expected seasonal and geographic patterns are observed in generated streamflow, such as the spring freshet and orographic enhancement. Additional observations supporting preliminary model plausibility include a peak difference between snowmelt and rainfall-dominated regions, alignment of soil moisture with evaptranspiration, and moderate levels for KGE and NSE. Timing and variation of streamflow are captured by the model, but heterogeneity of efficiency values point to sensitivity to subbasin characteristics. Representative stations (such as LIARD RIVER NEAR THE MOUTH) with higher KGE and NSE values are implemented as benchmarks for future runs.

### Future Runs

Climate change simulations are performed on select Benchmark Basins using CMIP5 and 6, where their responses are evaluated over a range of RCP and SSP emission scenarios. The model is first run on historical data, with the purpose of verifying baseline plausibility, inspiring confidence in future scenario observations. Some discrepancies are observable, and later used to target calibration and enhance representation for specific regions.

Initial iterations using CMIP5 suggest a backward movement of freshet timing, elevated peak magnitudes, and diminishment of late-summer flows, especially in snow-dominated basins. Similar observations are made with CMIP6 forcing, albeit more sensitive and pronounced. Generally, rainier regions exhibit more gradual changes. Figure 1 presents results from Iterations 1.05 and 1.09 in select benchmark basins, with distinction between historical (yellow), modern (violet), and future (red) datasets.

---

![Provisional Benchmark Basin Projected Hydrology](../Images/Lap1_Streamflow_Climatology_Provisional.png)  
*Figure 1: Projected Hydrology Across Select Benchmark Basins Using CMIP6 CanESM5 Forcing (Provisional)*

---

Water balance variables exhibit significant differences between datasets, resultant of precipitation variability. While evapotranspiration is generally stable, runoff differs more greatly. Additionally, with the large temporal scale of the project, it is important to recognize that year-to-year differences can compound over time, leading to largely dissimilar results.

Insight gathered from the water balance analysis informs future decision-making regarding the influence of forcing and region selection on model outputs. For example, high-elevation, snow-dominated regions exhibit less runoff variability than lowland, humid ones. Identifying interbasin differences is an important step towards diagnosing model effects within future phases of the project.

## Project Team

- Zelalem Tesemma, Environment and Climate Change Canada (zelalem.tesemma@ec.gc.ca)
- Sujata Budhathoki, Environment and Climate Change Canada (sujata.budhathoki@ec.gc.ca)
- Riley Damen, Environment and Climate Change Canada (riley.damen@ec.gc.ca)
- Frank Seglenieks, Environment and Climate Change Canada (frank.seglenieks@ec.gc.ca)
- Bruce Davison, Environment and Climate Change Canada (bruce.davison@ec.gc.ca)

## Disclaimer
This is an active research repository. Model configurations, parameters, and outputs are subject to change as improvements are made. Please contact the project team before using this material for publications or decision-making applications.
