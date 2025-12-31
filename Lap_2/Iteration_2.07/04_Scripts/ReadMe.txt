
Processing the forcing file:
Scripts to process climate forcing
1_Crop_OURANOS_Forcing.sh :Clip Ouranos foring file to the extent of the required domain
2_Easymore_remapping.sh : Remapping of the forcing to subbasin using Easymore
3_submit_pipeline.sh : Submit this pipeline, this will run other bash script in order 
   merge_and_leap.sh : solve leap year issue (adding Feb 29),
   calc_uv_from_merged.sh : calculate wind speed (uvs) and 
   final_merge.sh : merge all the files
   
Running the MESH v 1.5.5:
MESH is run by chunking the domain size and forcing dataset.
Use the scripts from Lap0\MESH_Model_Setup\MERIT\6-chunk_mesh_runs   
The required folder for the runs are: subbasin_ddb, subbasin_master and subbasin_params
MESH will runs in two steps: 1) running the land surface scheme 2) running the routing mode
