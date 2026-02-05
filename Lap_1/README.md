# Lap 1: Initial Diagnostic Analysis – Uncalibrated MESH Runs

---

## Lap Overview and Objectives

Building on the configuration framework developed in Lap 0, Lap 1 conducts preliminary, uncalibrated model runs with the goal of identifying baseline flow behaviour and sensitivity to climate forcing. Under the simplified conditions, a configured MESH setup is expected to generate reasonable streamflow behaviour, enabling the comparison of atmospheric forcing datasets for future decision-making.

In addition to the diagnostic streamflow analysis, Lap 1 uniquely investigates the connection between water balance components (e.g. precipitation and evapotranspiration) and relevant discharge patterns. In doing so, it enables identification of inconsistencies in model response between climate forcings, ensuring data quality. Comparative assessment is also conducted between future and historic datasets.

On top of comparing additional input datasets, future runs focus on parameterization, calibration, and implementation of MESH physics. Without advanced or optimized features enabled, Lap 1 serves to inform subsequent runs, while unsuitable for publication itself. It does not include formal performance evaluation or confidence assessment.

## Datasets Used

Lap 1 consists of 9 iterations which evolve in a stepwise manner. Initial runs of Iterations 1.01 to 1.09 were completed between September 24, 2024 and August 21, 2025. Details about each iteration are available their respective subdirectories. Refer to Lap 0 for details on individual datasets, which are summarized in the table below.

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

## Key Observations

