#!/usr/bin/env python3

import os
import sys
import argparse
import subprocess
from easymore import Easymore

def preprocess_and_remap(input_file, output_dir, shapefile, remapping_nc, temp_dir, failed_log=None):
    filename = os.path.basename(input_file)
    case_name = "remapped"
    preprocessed_file = os.path.join(temp_dir, f"pre_{filename}")
    expected_output = os.path.join(output_dir, f"{case_name}_{filename}")

    if os.path.exists(expected_output):
        print(f"? Skipping (already processed): {expected_output}")
        return

    unit_updates = {
        "CaSR_v3.1_A_PR0_SFC": "mm s-1",
        "CaSR_v3.1_P_PR0_SFC": "mm s-1",
        "CaSR_v3.1_P_TT_09975": "K",
        "CaSR_v3.1_P_P0_SFC": "Pa",
        "CaSR_v3.1_P_HU_09975": "kg/kg",
        "CaSR_v3.1_P_UVC_09975": "m s-1",
        "CaSR_v3.1_P_UUC_09975": "m s-1",
        "CaSR_v3.1_P_VVC_09975": "m s-1",
    }
    cdo_expr = (
        "CaSR_v3.1_A_PR0_SFC = CaSR_v3.1_A_PR0_SFC / 3.6;"
        "CaSR_v3.1_P_PR0_SFC = CaSR_v3.1_P_PR0_SFC / 3.6;"
        "CaSR_v3.1_P_TT_09975 = CaSR_v3.1_P_TT_09975 + 273.15;"
        "CaSR_v3.1_P_P0_SFC = CaSR_v3.1_P_P0_SFC * 100.0;"
        "CaSR_v3.1_P_UVC_09975 = CaSR_v3.1_P_UVC_09975 * 0.51444444444444;"
        "CaSR_v3.1_P_UUC_09975 = CaSR_v3.1_P_UUC_09975 * 0.51444444444444;"
        "CaSR_v3.1_P_VVC_09975 = CaSR_v3.1_P_VVC_09975 * 0.51444444444444"
    )
    selected_vars = ",".join([
        "CaSR_v3.1_A_PR0_SFC","CaSR_v3.1_P_FB_SFC","CaSR_v3.1_P_FI_SFC",
        "CaSR_v3.1_P_P0_SFC","CaSR_v3.1_P_HU_09975","CaSR_v3.1_P_TT_09975",
        "CaSR_v3.1_P_UVC_09975","CaSR_v3.1_P_PR0_SFC","CaSR_v3.1_P_UUC_09975",
        "CaSR_v3.1_P_VVC_09975"
    ])

    try:
        # Apply unit changes
        for var, unit in unit_updates.items():
            subprocess.run(["ncatted", "-O", "-a", f"units,{var},o,c,{unit}", input_file], check=True)

        # Apply arithmetic
        subprocess.run([
            "cdo", "-s", "-L", "-f", "nc4c", "-z", "zip",
            "-aexpr," + cdo_expr,
            f"-select,name={selected_vars}",
            input_file, preprocessed_file
        ], check=True)

        # EASYMORE remapping
        esmr = Easymore()
        esmr.case_name = case_name
        esmr.temp_dir = temp_dir
        esmr.target_shp = shapefile
        esmr.target_shp_ID = "Rank"
        esmr.source_nc = preprocessed_file
        esmr.var_names = selected_vars.split(",")
        esmr.var_lon = "lon"
        esmr.var_lat = "lat"
        esmr.var_time = "time"
        esmr.remapped_var_id = "subbasin"
        esmr.remapped_dim_id = "subbasin"
        esmr.output_dir = output_dir
        esmr.format_list = ["f4"]
        esmr.fill_value_list = ["-9999.00"]
        esmr.complevel = 9
        esmr.remap_nc = remapping_nc
        esmr.nc_remapper()

        print(f"? Success: {input_file}")

    except Exception as e:
        print(f"? Error: {input_file}  {e}")
        if failed_log:
            with open(failed_log, 'a') as f:
                f.write(input_file + '\n')
    finally:
        if os.path.exists(preprocessed_file):
            os.remove(preprocessed_file)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Preprocess and remap a NetCDF file using EASYMORE")
    parser.add_argument("input_file", help="Path to input NetCDF file")
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--temp-dir", required=True)
    parser.add_argument("--shapefile", required=True)
    parser.add_argument("--remapping-nc", required=True)
    parser.add_argument("--failed-log", help="Optional path to log failed files")
    args = parser.parse_args()

    os.makedirs(args.output_dir, exist_ok=True)
    os.makedirs(args.temp_dir, exist_ok=True)

    preprocess_and_remap(
        args.input_file,
        args.output_dir,
        args.shapefile,
        args.remapping_nc,
        args.temp_dir,
        args.failed_log
    )