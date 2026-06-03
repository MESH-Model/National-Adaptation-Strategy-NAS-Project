#!/usr/bin/env python3
"""
Post-calibration analysis script for MESH model experiments.

Compares model outputs (RFF) against observations for every station
listed in eval.json. Produces:
  1. Time-series plots (observed vs simulated) per station
  2. Performance metrics (KGE_2012, KGE_2009, NSE, Volume BIAS %) per station
  3. eCDF plots of each metric across all stations (calibration period only)
  4. Box plots of each metric
  5. A final summary report sheet

Usage:
    # Load modules and activate venv first, e.g.:
    #   ml r scimods
    #   source /home/kasra545/virtual-envs/fiat/bin/activate
    python3 analyze_results.py /path/to/experiment_directory
"""

import argparse
import json
import os
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
import numpy as np
import pandas as pd
import xarray as xr


# ──────────────────────────────────────────────────────────────────────
# Performance metrics
# ──────────────────────────────────────────────────────────────────────

def _kge_components(obs, sim):
    """Return (r, alpha, beta_mu) shared by both KGE formulations."""
    mu_o = np.mean(obs)
    mu_s = np.mean(sim)
    sigma_o = np.std(obs, ddof=0)
    sigma_s = np.std(sim, ddof=0)
    if sigma_o == 0 or sigma_s == 0:
        r = np.nan
    else:
        r = np.corrcoef(obs, sim)[0, 1]
    alpha = sigma_s / sigma_o if sigma_o != 0 else np.nan
    beta = mu_s / mu_o if mu_o != 0 else np.nan
    return r, alpha, beta, mu_o, mu_s, sigma_o, sigma_s


def kge_2009(obs, sim):
    """Kling-Gupta Efficiency (2009)."""
    r, alpha, beta, *_ = _kge_components(obs, sim)
    return 1.0 - np.sqrt((r - 1.0)**2 + (alpha - 1.0)**2 + (beta - 1.0)**2)


def kge_2012(obs, sim):
    """Kling-Gupta Efficiency (2012) – uses CV ratio (gamma) instead of alpha."""
    r, alpha, beta, mu_o, mu_s, sigma_o, sigma_s = _kge_components(obs, sim)
    if mu_o == 0 or mu_s == 0:
        gamma = np.nan
    else:
        gamma = (sigma_s / mu_s) / (sigma_o / mu_o)
    return 1.0 - np.sqrt((r - 1.0)**2 + (gamma - 1.0)**2 + (beta - 1.0)**2)


def nse(obs, sim):
    """Nash-Sutcliffe Efficiency."""
    denom = np.sum((obs - np.mean(obs))**2)
    if denom == 0:
        return np.nan
    return 1.0 - np.sum((obs - sim)**2) / denom


def volume_bias(obs, sim):
    """Percent volume bias: 100 * (sum(sim) - sum(obs)) / sum(obs)."""
    s_obs = np.sum(obs)
    if s_obs == 0:
        return np.nan
    return 100.0 * (np.sum(sim) - s_obs) / s_obs


# ──────────────────────────────────────────────────────────────────────
# Plotting helpers
# ──────────────────────────────────────────────────────────────────────

def add_outlier_inset(ax, vals, ecdf_y, xlim_lo=-1.0):
    """Add an inset scatter plot showing eCDF outliers below *xlim_lo*.

    Clips the main axis to [xlim_lo, 1] and draws a small inset in the
    top-left (below the legend) with the outlier points as individual dots.
    """
    ax.set_xlim(xlim_lo, 1)
    outlier_mask = vals < xlim_lo
    if not outlier_mask.any():
        return
    ox = vals[outlier_mask]
    oy = ecdf_y[outlier_mask]
    inset = ax.inset_axes([0.08, 0.55, 0.30, 0.32])  # top-left, below legend
    inset.scatter(ox, oy, s=18, color=ax.get_lines()[0].get_color(),
                  edgecolors="k", linewidths=0.4, zorder=3)
    inset.set_xlim(ox.min() - 0.5, xlim_lo)
    inset.set_xticks(list(inset.get_xticks()) + [xlim_lo])
    inset.set_xlim(ox.min() - 0.5, xlim_lo)  # restore after set_xticks
    inset.set_ylim(-0.02, oy.max() + 0.05)
    inset.set_title(f"{len(ox)} outlier(s)", fontsize=7, pad=2)
    inset.tick_params(labelsize=6)
    inset.grid(True, alpha=0.3)


# ──────────────────────────────────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────────────────────────────────

def load_eval_json(path):
    """Load eval.json and return parsed dict."""
    with open(path, "r") as f:
        return json.load(f)


def get_station_ids(eval_cfg):
    """Extract station IDs from eval.json objective_functions._helpers."""
    helpers = eval_cfg["objective_functions"]["_helpers"]
    station_ids = []
    for var_key, metrics in helpers.items():
        for metric_key, ids in metrics.items():
            if isinstance(ids, list) and len(ids) > 0 and isinstance(ids[0], str):
                # Check it's actual station IDs, not formula strings
                if not any(op in ids[0] for op in ["/", "*", "+", "-", "(", ")"]):
                    station_ids.extend(ids)
    return list(dict.fromkeys(station_ids))  # deduplicate, preserve order


def get_calibration_periods(eval_cfg):
    """Return list of (start, end) datetime tuples from eval.json dates."""
    periods = []
    for d in eval_cfg["dates"]:
        periods.append((
            pd.Timestamp(d["start"]),
            pd.Timestamp(d["end"]),
        ))
    return periods


def mask_calibration(time, periods):
    """Return boolean mask for time values falling within any calibration period."""
    mask = np.zeros(len(time), dtype=bool)
    for start, end in periods:
        mask |= (time >= start) & (time <= end)
    return mask


# ──────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────

def main():
    # ── CLI arguments ─────────────────────────────────────────────────
    parser = argparse.ArgumentParser(
        description="Post-calibration analysis for MESH model experiments.")
    parser.add_argument("exp_dir",
                        help="Path to the experiment directory "
                             "(contains eval.json, model/, observations.nc)")
    parser.add_argument("--obs", default=None,
                        help="Path to observations NetCDF (default: "
                             "<exp_dir>/observations.nc)")
    args = parser.parse_args()

    exp_dir = os.path.abspath(args.exp_dir)
    if not os.path.isdir(exp_dir):
        sys.exit(f"ERROR: directory not found: {exp_dir}")

    eval_path = os.path.join(exp_dir, "eval.json")
    if not os.path.isfile(eval_path):
        sys.exit(f"ERROR: eval.json not found in {exp_dir}")

    obs_path = args.obs or os.path.join(exp_dir, "observations.nc")
    if not os.path.isfile(obs_path):
        sys.exit(f"ERROR: observations file not found: {obs_path}")

    # Find model output RFF file
    results_dir = os.path.join(exp_dir, "model", "results")
    rff_candidates = sorted(f for f in os.listdir(results_dir)
                            if f.startswith("RFF") and f.endswith(".nc"))
    if len(rff_candidates) == 0:
        sys.exit(f"ERROR: no RFF*.nc file found in {results_dir}")
    sim_path = os.path.join(results_dir, rff_candidates[0])
    if len(rff_candidates) > 1:
        print(f"Multiple RFF files found, using first: {rff_candidates[0]}")
    print(f"Found model output: {sim_path}")

    # ── Load config ──────────────────────────────────────────────────
    eval_cfg = load_eval_json(eval_path)
    station_ids = get_station_ids(eval_cfg)
    cal_periods = get_calibration_periods(eval_cfg)
    print(f"\nStations from eval.json: {len(station_ids)}")
    print(f"Calibration period(s): "
          + ", ".join(f"{s} to {e}" for s, e in cal_periods))

    # Determine output variable name from eval.json
    output_var = list(eval_cfg["objective_functions"]["_helpers"].keys())[0]

    # ── Output directories ───────────────────────────────────────────
    exp_name = os.path.basename(os.path.normpath(exp_dir))
    out_base = os.path.join(exp_dir, "analysis_output")
    ts_dir = os.path.join(out_base, "timeseries")
    os.makedirs(ts_dir, exist_ok=True)
    print(f"Output will be saved to: {out_base}")

    # ── Load drainage database for GridArea (time-series plot unit conversion) ─
    drainage_db_path = os.path.join(exp_dir, "model", "MESH_drainage_database.nc")
    if not os.path.isfile(drainage_db_path):
        sys.exit(f"ERROR: MESH_drainage_database.nc not found in {os.path.join(exp_dir, 'model')}")
    ds_drain = xr.open_dataset(drainage_db_path)
    drain_rank = ds_drain["Rank"].values.flat
    drain_area = ds_drain["GridArea"].values.flat   # m²
    rank_to_area = {int(r): float(a) for r, a in zip(drain_rank, drain_area)}
    ds_drain.close()
    print(f"Loaded GridArea for {len(rank_to_area)} subbasins from drainage database")

    # ── Open datasets ────────────────────────────────────────────────
    print("\nLoading datasets (this may take a moment) ...")
    ds_obs = xr.open_dataset(obs_path)
    ds_sim = xr.open_dataset(sim_path)

    obs_names = ds_obs.coords["name"].values   # station names per subbasin
    obs_subbasins = ds_obs.coords["subbasin"].values

    # Build station -> obs subbasin index mapping
    station_to_obs_idx = {}
    for i, name in enumerate(obs_names):
        station_to_obs_idx[str(name)] = i

    # Build obs subbasin value -> sim subbasin index mapping
    # Sim subbasins are 1..N (float), obs subbasins are integers
    sim_subbasins = ds_sim.coords["subbasin"].values  # [1., 2., ...]

    # ── Compute metrics & plot ───────────────────────────────────────
    metrics_records = []
    n_stations = len(station_ids)
    skipped = []

    for si, stn in enumerate(station_ids):
        print(f"\r  Processing station {si+1}/{n_stations}: {stn}", end="", flush=True)

        if stn not in station_to_obs_idx:
            skipped.append((stn, "not found in observations"))
            continue

        obs_idx = station_to_obs_idx[stn]
        obs_subbasin_val = obs_subbasins[obs_idx]

        # Find matching sim subbasin index
        sim_match = np.where(np.isclose(sim_subbasins, float(obs_subbasin_val)))[0]
        if len(sim_match) == 0:
            skipped.append((stn, f"subbasin {obs_subbasin_val} not in simulation"))
            continue
        sim_idx = sim_match[0]

        # Extract time-series
        obs_ts = ds_obs[output_var].isel(subbasin=obs_idx)
        sim_ts = ds_sim[output_var].isel(subbasin=sim_idx)

        # Align on common time
        # Note: both obs and sim are in the same units (mm/hr) — no conversion needed.
        obs_time = pd.DatetimeIndex(obs_ts.coords["time"].values)
        sim_time = pd.DatetimeIndex(sim_ts.coords["time"].values)
        common_time = obs_time.intersection(sim_time)
        if len(common_time) == 0:
            skipped.append((stn, "no overlapping time steps"))
            continue

        obs_series = obs_ts.sel(time=common_time).values.astype(float)
        sim_series = sim_ts.sel(time=common_time).values.astype(float)

        # ── Calibration-period mask ──────────────────────────────────
        cal_mask = mask_calibration(common_time, cal_periods)
        if cal_mask.sum() == 0:
            skipped.append((stn, "no data in calibration period"))
            continue

        obs_cal = obs_series[cal_mask]
        sim_cal = sim_series[cal_mask]

        # Remove NaN pairs
        valid = np.isfinite(obs_cal) & np.isfinite(sim_cal)
        if valid.sum() < 10:
            skipped.append((stn, f"only {valid.sum()} valid data points"))
            continue
        obs_v = obs_cal[valid]
        sim_v = sim_cal[valid]

        # Compute metrics
        kge12_val = kge_2012(obs_v, sim_v)
        rec = {
            "station": stn,
            "n_valid": int(valid.sum()),
            "KGE_2012": kge12_val,
            "KGE_2012_prime": 1.0 / (2.0 - kge12_val) if not np.isnan(kge12_val) else np.nan,
            "KGE_2009": kge_2009(obs_v, sim_v),
            "NSE": nse(obs_v, sim_v),
            "Volume_BIAS": volume_bias(obs_v, sim_v),
        }
        metrics_records.append(rec)

        # ── Time-series plot (calibration period only, in m³/s) ──────
        cal_time = common_time[cal_mask]
        # Convert mm/hr -> m³/s for plotting: m³/s = mm/hr * area_m² / (1000 * 3600)
        sim_subbasin_val = int(sim_subbasins[sim_idx])
        if sim_subbasin_val in rank_to_area:
            conv = rank_to_area[sim_subbasin_val] / (1000.0 * 3600.0)
        else:
            conv = 1.0  # fallback: plot in original units
        obs_plot = obs_series[cal_mask] * conv
        sim_plot = sim_series[cal_mask] * conv

        fig, ax = plt.subplots(figsize=(14, 4))
        ax.plot(cal_time, obs_plot, color="black", lw=0.6, alpha=0.8, label="Observed")
        ax.plot(cal_time, sim_plot, color="dodgerblue", lw=0.6, alpha=0.7, label="Simulated")
        ax.set_title(f"{stn}  |  KGE₁₂={rec['KGE_2012']:.3f}  "
                     f"KGE₁₂'={rec['KGE_2012_prime']:.3f}  "
                     f"NSE={rec['NSE']:.3f}  BIAS={rec['Volume_BIAS']:.1f}%")
        ax.set_ylabel("Discharge (m³/s)")
        ax.legend(loc="upper right", fontsize=8)
        ax.xaxis.set_major_locator(mdates.YearLocator())
        ax.xaxis.set_major_formatter(mdates.DateFormatter("%Y"))
        fig.autofmt_xdate()
        fig.tight_layout()
        fig.savefig(os.path.join(ts_dir, f"{stn}.png"), dpi=150)
        plt.close(fig)

    print()  # newline after progress

    # ── Save metrics table ───────────────────────────────────────────
    if len(metrics_records) == 0:
        print("WARNING: no valid metrics computed for any station.")
        ds_obs.close()
        ds_sim.close()
        return

    df_metrics = pd.DataFrame(metrics_records)
    csv_path = os.path.join(out_base, "performance_metrics.csv")
    df_metrics.to_csv(csv_path, index=False, float_format="%.6f")
    print(f"\nMetrics saved to: {csv_path}")

    # Print summary statistics
    print("\n── Summary Statistics (calibration period) ──")
    for col in ["KGE_2012", "KGE_2012_prime", "KGE_2009", "NSE", "Volume_BIAS"]:
        vals = df_metrics[col].dropna()
        print(f"  {col:16s}:  median={vals.median():.3f}  "
              f"mean={vals.mean():.3f}  "
              f"min={vals.min():.3f}  max={vals.max():.3f}")

    # ── eCDF plots ───────────────────────────────────────────────────
    metric_cols = ["KGE_2012", "KGE_2012_prime", "KGE_2009", "NSE", "Volume_BIAS"]
    metric_labels = {
        "KGE_2012": "KGE 2012",
        "KGE_2012_prime": "KGE 2012'",
        "KGE_2009": "KGE 2009",
        "NSE": "NSE",
        "Volume_BIAS": "Volume BIAS (%)",
    }

    # Individual eCDF per metric
    for col in metric_cols:
        vals = np.sort(df_metrics[col].dropna().values)
        ecdf_y = np.arange(1, len(vals) + 1) / len(vals)

        fig, ax = plt.subplots(figsize=(6, 5))
        ax.step(vals, ecdf_y, where="post", color="steelblue", lw=1.5)
        ax.set_xlabel(metric_labels[col], fontsize=12)
        ax.set_ylabel("eCDF", fontsize=12)
        ax.set_title(f"eCDF of {metric_labels[col]} — {len(vals)} stations", fontsize=12)
        ax.set_ylim(0, 1.02)
        ax.grid(True, alpha=0.3)

        # Mark median
        med = np.median(vals)
        ax.axvline(med, color="red", ls="--", lw=0.8, label=f"median = {med:.3f}")
        if col == "KGE_2012_prime":
            mn = np.mean(vals)
            ax.axvline(mn, color="blue", ls=":", lw=0.8, label=f"mean = {mn:.3f}")

        # Focus KGE/NSE plots on [-1, 1] with outlier inset; legend bottom-right
        if col in ("KGE_2012", "KGE_2009", "NSE"):
            ax.legend(loc="lower right", fontsize=9)
            add_outlier_inset(ax, vals, ecdf_y)
        else:
            ax.legend(fontsize=9)

        fig.tight_layout()
        fig.savefig(os.path.join(out_base, f"eCDF_{col}.png"), dpi=150)
        plt.close(fig)

    # Combined eCDF (all metrics in one figure)
    fig, axes = plt.subplots(2, 3, figsize=(18, 9))
    colors = ["steelblue", "teal", "darkorange", "seagreen", "crimson"]
    for ax, col, clr in zip(axes.flat, metric_cols, colors):
        vals = np.sort(df_metrics[col].dropna().values)
        ecdf_y = np.arange(1, len(vals) + 1) / len(vals)

        ax.step(vals, ecdf_y, where="post", color=clr, lw=1.5)
        ax.set_xlabel(metric_labels[col], fontsize=11)
        ax.set_ylabel("eCDF", fontsize=11)
        ax.set_title(metric_labels[col], fontsize=12)
        ax.set_ylim(0, 1.02)
        ax.grid(True, alpha=0.3)
        med = np.median(vals)
        ax.axvline(med, color="red", ls="--", lw=0.8, label=f"median = {med:.3f}")
        if col == "KGE_2012_prime":
            mn = np.mean(vals)
            ax.axvline(mn, color="blue", ls=":", lw=0.8, label=f"mean = {mn:.3f}")
        if col in ("KGE_2012", "KGE_2009", "NSE"):
            ax.legend(loc="lower right", fontsize=9)
            add_outlier_inset(ax, vals, ecdf_y)
        else:
            ax.legend(fontsize=9)

    # Hide unused subplot (6th in 2x3 grid)
    axes.flat[5].set_visible(False)

    fig.suptitle(f"Performance Metrics — {exp_name} (n={len(df_metrics)} stations)",
                 fontsize=14, y=1.01)
    fig.tight_layout()
    fig.savefig(os.path.join(out_base, "eCDF_combined.png"), dpi=150,
                bbox_inches="tight")
    plt.close(fig)

    print(f"\neCDF plots saved to: {out_base}/")

    # ── Box plots ─────────────────────────────────────────────────────
    # Individual box plots
    for col in metric_cols:
        vals = df_metrics[col].dropna().values
        fig, ax = plt.subplots(figsize=(4, 6))
        bp = ax.boxplot(vals, patch_artist=True, widths=0.5,
                        boxprops=dict(facecolor="lightsteelblue", edgecolor="steelblue"),
                        medianprops=dict(color="red", lw=1.5),
                        whiskerprops=dict(color="steelblue"),
                        capprops=dict(color="steelblue"),
                        flierprops=dict(marker="o", markersize=3, alpha=0.4,
                                        markerfacecolor="grey"))
        ax.set_ylabel(metric_labels[col], fontsize=12)
        ax.set_title(f"{metric_labels[col]} (n={len(vals)})", fontsize=12)
        ax.set_xticks([])
        ax.grid(True, axis="y", alpha=0.3)
        med = np.median(vals)
        ax.annotate(f"median = {med:.3f}", xy=(1, med),
                    xytext=(1.3, med), fontsize=9, color="red",
                    arrowprops=dict(arrowstyle="-", color="red", lw=0.5))
        if col == "KGE_2012_prime":
            mn = np.mean(vals)
            ax.axhline(mn, color="blue", ls=":", lw=0.8)
            ax.annotate(f"mean = {mn:.3f}", xy=(1, mn),
                        xytext=(1.3, mn + (med - mn) * 0.5), fontsize=9, color="blue",
                        arrowprops=dict(arrowstyle="-", color="blue", lw=0.5))
        fig.tight_layout()
        fig.savefig(os.path.join(out_base, f"boxplot_{col}.png"), dpi=150)
        plt.close(fig)

    # Combined box plot (all metrics in one figure)
    fig, axes = plt.subplots(1, 5, figsize=(20, 6))
    for ax, col, clr in zip(axes.flat, metric_cols, colors):
        vals = df_metrics[col].dropna().values
        bp = ax.boxplot(vals, patch_artist=True, widths=0.5,
                        boxprops=dict(facecolor=clr, alpha=0.3, edgecolor=clr),
                        medianprops=dict(color="red", lw=1.5),
                        whiskerprops=dict(color=clr),
                        capprops=dict(color=clr),
                        flierprops=dict(marker="o", markersize=3, alpha=0.4,
                                        markerfacecolor="grey"))
        ax.set_title(metric_labels[col], fontsize=12)
        ax.set_xticks([])
        ax.grid(True, axis="y", alpha=0.3)
        med = np.median(vals)
        ax.annotate(f"med={med:.3f}", xy=(1, med),
                    xytext=(1.3, med), fontsize=8, color="red",
                    arrowprops=dict(arrowstyle="-", color="red", lw=0.5))
        if col == "KGE_2012_prime":
            mn = np.mean(vals)
            ax.axhline(mn, color="blue", ls=":", lw=0.8)
            ax.annotate(f"mean={mn:.3f}", xy=(1, mn),
                        xytext=(1.3, mn + (med - mn) * 0.5), fontsize=8, color="blue",
                        arrowprops=dict(arrowstyle="-", color="blue", lw=0.5))
    fig.suptitle(f"Box Plots — {exp_name} (n={len(df_metrics)} stations)",
                 fontsize=14, y=1.01)
    fig.tight_layout()
    fig.savefig(os.path.join(out_base, "boxplot_combined.png"), dpi=150,
                bbox_inches="tight")
    plt.close(fig)

    print(f"Box plots saved to: {out_base}/")

    # ── Final report sheet ────────────────────────────────────────────
    fig_report = plt.figure(figsize=(18, 24))
    gs = fig_report.add_gridspec(4, 3, hspace=0.35, wspace=0.3,
                                 top=0.93, bottom=0.03, left=0.07, right=0.97)

    # Row 0: summary statistics table
    ax_table = fig_report.add_subplot(gs[0, :])
    ax_table.axis("off")
    table_data = []
    for col in metric_cols:
        vals = df_metrics[col].dropna()
        table_data.append([
            metric_labels[col],
            f"{len(vals)}",
            f"{vals.median():.3f}",
            f"{vals.mean():.3f}",
            f"{vals.std():.3f}",
            f"{vals.min():.3f}",
            f"{vals.max():.3f}",
            f"{vals.quantile(0.25):.3f}",
            f"{vals.quantile(0.75):.3f}",
        ])
    col_headers = ["Metric", "N", "Median", "Mean", "Std", "Min", "Max",
                   "Q25", "Q75"]
    tbl = ax_table.table(cellText=table_data, colLabels=col_headers,
                         loc="center", cellLoc="center")
    tbl.auto_set_font_size(False)
    tbl.set_fontsize(10)
    tbl.scale(1, 1.8)
    for (row, col_idx), cell in tbl.get_celld().items():
        if row == 0:
            cell.set_facecolor("steelblue")
            cell.set_text_props(color="white", fontweight="bold")
        else:
            cell.set_facecolor("#f0f4f8" if row % 2 == 0 else "white")
    cal_str = ", ".join(f"{s.strftime('%Y-%m-%d')} to {e.strftime('%Y-%m-%d')}"
                        for s, e in cal_periods)
    avg_kge_prime = df_metrics["KGE_2012_prime"].dropna().mean()
    ax_table.set_title(f"Calibration period: {cal_str}\n"
                       f"Stations evaluated: {len(df_metrics)}  |  "
                       f"Skipped: {len(skipped)}  |  "
                       f"Average KGE 2012' (all basins): {avg_kge_prime:.3f}",
                       fontsize=11, loc="left", pad=15)

    # Rows 1-2: eCDF plots (5 metrics in 2x3 grid, last cell empty)
    for i, (col, clr) in enumerate(zip(metric_cols, colors)):
        row = 1 + i // 3
        col_idx = i % 3
        ax = fig_report.add_subplot(gs[row, col_idx])
        vals = np.sort(df_metrics[col].dropna().values)
        ecdf_y = np.arange(1, len(vals) + 1) / len(vals)
        ax.step(vals, ecdf_y, where="post", color=clr, lw=1.5)
        ax.set_xlabel(metric_labels[col], fontsize=11)
        ax.set_ylabel("eCDF", fontsize=11)
        ax.set_title(f"eCDF — {metric_labels[col]}", fontsize=12)
        ax.set_ylim(0, 1.02)
        ax.grid(True, alpha=0.3)
        med = np.median(vals)
        ax.axvline(med, color="red", ls="--", lw=0.8, label=f"median = {med:.3f}")
        if col == "KGE_2012_prime":
            mn = np.mean(vals)
            ax.axvline(mn, color="blue", ls=":", lw=0.8, label=f"mean = {mn:.3f}")
        if col in ("KGE_2012", "KGE_2009", "NSE"):
            ax.legend(loc="lower right", fontsize=9)
            add_outlier_inset(ax, vals, ecdf_y)
        else:
            ax.legend(fontsize=9)

    # Row 3: box plots (1x4)
    for i, (col, clr) in enumerate(zip(metric_cols, colors)):
        ax = fig_report.add_subplot(gs[3, 0]) if i < 2 else fig_report.add_subplot(gs[3, 1])
        # Re-use combined box in last row – place all 4 in a single axes pair
        break
    # Actually create a proper 1x4 layout in the bottom row
    gs_bottom = gs[3, :].subgridspec(1, 5, wspace=0.35)
    for i, (col, clr) in enumerate(zip(metric_cols, colors)):
        ax = fig_report.add_subplot(gs_bottom[0, i])
        vals = df_metrics[col].dropna().values
        bp = ax.boxplot(vals, patch_artist=True, widths=0.5,
                        boxprops=dict(facecolor=clr, alpha=0.3, edgecolor=clr),
                        medianprops=dict(color="red", lw=1.5),
                        whiskerprops=dict(color=clr),
                        capprops=dict(color=clr),
                        flierprops=dict(marker="o", markersize=3, alpha=0.4,
                                        markerfacecolor="grey"))
        ax.set_title(metric_labels[col], fontsize=10)
        ax.set_xticks([])
        ax.grid(True, axis="y", alpha=0.3)

    fig_report.suptitle(f"Performance Report — {exp_name}",
                        fontsize=16, fontweight="bold")
    report_path = os.path.join(out_base, "report_sheet.png")
    fig_report.savefig(report_path, dpi=200, bbox_inches="tight")
    plt.close(fig_report)
    print(f"Report sheet saved to: {report_path}")

    # Report skipped stations
    if skipped:
        print(f"\nSkipped {len(skipped)} station(s):")
        for stn, reason in skipped:
            print(f"  {stn}: {reason}")

    ds_obs.close()
    ds_sim.close()
    print("\nDone.")


if __name__ == "__main__":
    main()
