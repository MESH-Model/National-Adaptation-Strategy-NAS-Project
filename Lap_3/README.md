# Lap 3: Geospatial Dataset Evaluation

---

## Lap Overview and Objectives

Information in this section will be completed at a later date.

## Datasets Used

Lap 3 consists of 13 iterations which evolve in a stepwise manner. Initial runs of Iterations 3.01 to 2.13 are not yet fully completed. Refer to Lap 0 for details on individual datasets, which are summarized in Table 1.

---

*Table 1: Lap 3 Iteration Dataset Details*
| Iteration | Geofabric   | Landcover | Soils | Forcing Dataset     | Scenario | MESH Version | Period   |
|-----------|-------------|-----------|-------|---------------------|----------|--------------|----------|
| 2.01      | MERIT-Hydro | NALCMS    | GSDE  | CaSR v2.1           | N/A      | 1.5.5        | Historic |
| 2.02      | MERIT-Hydro | NALCMS    | GSDE  | CaSR v3.1           | N/A      | 1860_ME_ZT   | Historic |
| 2.03      | MERIT-Hydro | NALCMS    | GSDE  | CaSR v3.1           | N/A      | 1.5.5        | Historic |
| 2.04      | MERIT-Hydro | NALCMS    | GSDE  | CaSR v3.1           | N/A      | 1.5.5        | Historic |
| 2.05      | MERIT-Hydro | NALCMS    | GSDE  | CaSR v3.1           | N/A      | 1.5.5        | Historic |
| 2.06      | MERIT-Hydro | NALCMS    | GSDE  | CaSR v3.1           | N/A      | 1.5.5        | Historic |
| 2.07      | MERIT-Hydro | NALCMS    | GSDE  | CMIP6/CanESM5       | N/A      | 1.5.5        | Historic |
| 2.08      | MERIT-Hydro | NALCMS    | GSDE  | CMIP6/CanESM5       | SSP1-2.6 | 1.5.5        | Future   |
| 2.09      | MERIT-Hydro | NALCMS    | GSDE  | CMIP6/CanESM5       | SSP2-4.5 | 1.5.5        | Future   |
| 2.10      | MERIT-Hydro | NALCMS    | GSDE  | CMIP6/CanESM5       | SSP3-7.0 | 1.5.5        | Future   |
| 2.11      | MERIT-Hydro | NALCMS    | GSDE  | CMIP6/CanESM5       | SSP5-8.5 | 1.5.5        | Future   |
| 2.12      | MERIT-Hydro | NALCMS    | GSDE  | CaSR v3.1           | N/A      | 1.5.5        | Historic |
| 2.13      | MERIT-Hydro | NALCMS    | GSDE  | ERA5-Land           | N/A      | 1.5.5        | Historic |
| 2.14      | MERIT-Hydro | NALCMS    | GSDE  | CMIP6/MPI-ESM1-2-LR | N/A      | 1.5.5        | Historic |
| 2.15      | MERIT-Hydro | NALCMS    | GSDE  | CMIP6/CNRM-ESM2-1   | N/A      | 1.5.5        | Historic |
| 2.16      | MERIT-Hydro | NALCMS    | GSDE  | CMIP6/NorESM2-MM    | N/A      | 1.5.5        | Historic |
| 2.17      | MERIT-Hydro | NALCMS    | GSDE  | CaSR v3.1           | N/A      | 1.5.6        | Historic |

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
