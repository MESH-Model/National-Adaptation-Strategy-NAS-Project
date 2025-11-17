#!/bin/bash
#SBATCH --account=rpp-kshook
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=64G
#SBATCH --time=02:00:00
#SBATCH --job-name=CanRCM_WFDEI
#SBATCH --error=errors_CanRCM_WFDEI
##
module load cdo
module load nco
##
# for vars in ET PREC ROF PRECRN SNO LQWSSNO QO DSTGW STGW 
# do
# cd /gpfs/mdiops/gwf/gwf_cmt/zkt451/CanTrans_MESH_model/OBASINAVG
# cdo -select,startdate=2018-09-03,enddate=2018-09-30 "$vars"_D_GRD.nc "$vars"_D_GRD1.nc
# cdo -select,startdate=2018-09-01,enddate=2018-10-01 "$vars"_M_GRD.nc "$vars"_M_GRD1.nc
# cdo -select,startdate=2018-01-01,enddate=2018-10-30 "$vars"_Y_GRD.nc "$vars"_Y_GRD1.nc
# done
##
# for vars in ALWSSOL_D ALWSSOL_M ALWSSOL_Y
# do
# cd /gpfs/mdiops/gwf/gwf_cmt/zkt451/CanTrans_MESH_model/OBASINAVG
# cdo -select,startdate=2018-09-03,enddate=2018-09-30 "$vars"_IG1_GRD.nc "$vars"_IG1_GRD1.nc
# cdo -select,startdate=2018-09-03,enddate=2018-09-30 "$vars"_IG2_GRD.nc "$vars"_IG2_GRD1.nc
# cdo -select,startdate=2018-09-03,enddate=2018-09-30 "$vars"_IG3_GRD.nc "$vars"_IG3_GRD1.nc
# cdo -select,startdate=2018-09-03,enddate=2018-09-30 "$vars"_IG4_GRD.nc "$vars"_IG4_GRD1.nc
# done

# for vars in ET PREC ROF SNO LQWSSNO QO DSTGW STGW 
# do
# cd /gpfs/mdiops/gwf/gwf_cmt/zkt451/CanTrans_MESH_model
# cdo -v -z zip mergetime /gpfs/mdiops/gwf/gwf_cmt/zkt451/CanTrans_MESH_model/OBASINAVG_1/"$vars"_Y_GRD.nc /gpfs/mdiops/gwf/gwf_cmt/zkt451/CanTrans_MESH_model/OBASINAVG/"$vars"_Y_GRD1.nc "$vars"_Y_GRD.nc 
# done
##
# for vars in ALWSSOL_D ALWSSOL_M ALWSSOL_Y
# do
# cd /gpfs/mdiops/gwf/gwf_cmt/zkt451/CanTrans_MESH_model
# cdo -v -z zip mergetime /gpfs/mdiops/gwf/gwf_cmt/zkt451/CanTrans_MESH_model/OBASINAVG_1/"$vars"_IG1_GRD.nc /gpfs/mdiops/gwf/gwf_cmt/zkt451/CanTrans_MESH_model/OBASINAVG/"$vars"_IG1_GRD1.nc "$vars"_IG1_GRD.nc
# cdo -v -z zip mergetime /gpfs/mdiops/gwf/gwf_cmt/zkt451/CanTrans_MESH_model/OBASINAVG_1/"$vars"_IG2_GRD.nc /gpfs/mdiops/gwf/gwf_cmt/zkt451/CanTrans_MESH_model/OBASINAVG/"$vars"_IG2_GRD1.nc "$vars"_IG2_GRD.nc
# cdo -v -z zip mergetime /gpfs/mdiops/gwf/gwf_cmt/zkt451/CanTrans_MESH_model/OBASINAVG_1/"$vars"_IG3_GRD.nc /gpfs/mdiops/gwf/gwf_cmt/zkt451/CanTrans_MESH_model/OBASINAVG/"$vars"_IG3_GRD1.nc "$vars"_IG3_GRD.nc
# cdo -v -z zip mergetime /gpfs/mdiops/gwf/gwf_cmt/zkt451/CanTrans_MESH_model/OBASINAVG_1/"$vars"_IG4_GRD.nc /gpfs/mdiops/gwf/gwf_cmt/zkt451/CanTrans_MESH_model/OBASINAVG/"$vars"_IG4_GRD1.nc "$vars"_IG4_GRD.nc 
# done

cdo ymonmean SNO_M_GRD.nc SNO_MeanM_GRD.nc
cdo ymonmean LQWSSNO_M_GRD.nc LQWSSNO_MeanM_GRD.nc

cdo add SNO_MeanM_GRD.nc LQWSSNO_MeanM_GRD.nc SNO_LQWSSNO_MeanM_GRD.nc

