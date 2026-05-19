# Lap 3: Comprehensive Geospatial Dataset Evaluation

---

## Lap Overview and Objectives

Information in this section will be completed at a later date.

## Datasets Used

Lap 3 consists of 14 iterations which evolve in a stepwise manner. Initial runs of Iterations 3.01 to 3.14 were completed between December 3, 2025 and May 14, 2026. Refer to Lap 0 for details on individual datasets, which are summarized in Table 1.

---

*Table 1: Lap 3 Iteration Dataset Details*
| Iteration | Geofabric   | Landcover | Soils    | Forcing Dataset | Scenario | MESH Version | Period   |
|-----------|-------------|-----------|----------|-----------------|----------|--------------|----------|
| 3.01      | CAMELS-SPAT | NALCMS    | GSDE     | CaSR v3.2       | N/A      | 1.5.5        | Historic |
| 3.02      | CLRH        | NALCMS    | GSDE     | CaSR v3.2       | N/A      | 1.5.5        | Historic |
| 3.03      | CLRH        | NALCMS    | GSDE     | CaSR v3.2       | N/A      | 1.5.5        | Historic |
| 3.04      | MERIT-HYDRO | ESA       | GSDE     | CaSR v3.2       | N/A      | 1.5.5        | Historic |
| 3.05      | MERIT-HYDRO | NALCMS    | SoilGrid | CaSR v3.2       | N/A      | 1.5.5        | Historic |
| 3.06      | MizuRoute   | NALCMS    | GSDE     | CaSR v3.2       | N/A      | 1.5.5        | Historic |
| 3.07      | Raven       | NALCMS    | GSDE     | CaSR v3.2       | N/A      | 1.5.5        | Historic |
| 3.08      | TBD         | TBD       | TBD      | CaSR v3.2       | N/A      | TBD          | Historic |
| 3.09      | Benchmark   | TBD       | TBD      | CMIP6/CanESM5   | SSP1-2.6 | TBD          | Future   |
| 3.10      | Benchmark   | TBD       | TBD      | CMIP6/CanESM5   | SSP2-4.5 | TBD          | Future   |
| 3.11      | Benchmark   | TBD       | TBD      | CMIP6/CanESM5   | SSP3-7.0 | TBD          | Future   |
| 3.12      | Benchmark   | TBD       | TBD      | CMIP6/CanESM5   | SSP5-8.5 | TBD          | Future   |
| 3.13      | TBD         | TBD       | TBD      | CaSR v3.2       | N/A      | TBD          | Historic |
| 3.14      | CAMELS-SPAT | TBD       | TBD      | CaSR v3.2       | N/A      | TBD          | Historic |

---

## Performance Metrics

Kling-Gupta Efficiency (KGE) and Nash-Sutcliffe Efficiency (NSE) are the primary performance indicators used to evaluate the uncalibrated model results against observational data.

$KGE=1-\sqrt{\left(r-1\right)^2+\left(\frac{\mu_s}{\mu_o}-1\right)^2+\left(\frac{\sigma_s}{\sigma_o}-1\right)^2}\qquad NSE=1-\frac{\Sigma_{t=1}^T\left(Q_o^t-Q_m^t\right)^2}{\Sigma_{t=1}^T\left(Q_o^t-\bar{Q_o}\right)^2}$

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
