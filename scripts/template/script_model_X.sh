#!/bin/bash -l
#SBATCH -J AF2C_Array
#SBATCH --ntasks=1
#SBATCH --constraint="gpu"
#SBATCH --gres=gpu:a100:4
#SBATCH --cpus-per-task=36
#SBATCH --mem=50000
#SBATCH --mail-type=NONE
#SBATCH --mail-user=$USER@mpiib-berlin.mpg.de
#SBATCH --time=6:00:00

set -e

# Accept model number as an argument or use SLURM_ARRAY_TASK_ID
MODEL_NUMBER=${1:-$SLURM_ARRAY_TASK_ID}

### LOAD MODULES #############################################################
module purge
module load cuda/11.4
module load anaconda/3/2021.11

### LIBRARY & AI AVAILABILITY ################################################
export LD_LIBRARY_PATH=${ALPHAFOLD_HOME}/lib:${LD_LIBRARY_PATH}
# put temporary files into a ramdisk
export TMPDIR=${JOB_SHMTMPDIR}

### ENABLE CUDA UNIFIED MEMORY ###############################################
export TF_XLA_FLAGS=--tf_xla_enable_xla_devices
export TF_FORCE_UNIFIED_MEMORY=1
        # Enable jax allocation tweak to allow for larger models, note that
        # with unified memory the fraction can be larger than 1.0 (=100% of single GPU memory):
        # https://jax.readthedocs.io/en/latest/gpu_memory_allocation.html
export XLA_PYTHON_CLIENT_MEM_FRACTION=4

        # run threaded tools with the correct number of threads (MPCDF customization)
export NUM_THREADS=${SLURM_CPUS_PER_TASK}
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}

### TARGETS & LOCATIONS #######################################################
source 00_user_parameters.inc
source 01_user_parameters.inc

# GIVE ECHOS #################################################################
echo "Info: input file name is $FILE"
echo "Info: input target list is $TARGET_LST_FILE"
echo "Info: input feature directory is $FEA_DIR"
echo "Info: result output directory is $OUT_DIR"
echo "Info: model preset is $MODEL_PRESET"
echo "Info: msa pairing is $MSA_PAIRING"
echo "Info: recycling setting is $RECYCLING_SETTING"

# AF2Complex source code directory ###########################################
# Use $MODEL_NUMBER to specify the model to be used
srun $PYTHON_PATH/python3 -u $AF_DIR/run_af2c_mod.py \
  --target_lst_path=$TARGET_LST_FILE \
  --data_dir=$DATA_DIR \
  --output_dir=$OUT_DIR \
  --feature_dir=$FEA_DIR \
  --model_names=model_${MODEL_NUMBER}_multimer_v3 \
  --preset=$PRESET \
  --model_preset=multimer_np\
  --save_recycled=$RECYCLING_SETTING \
  --msa_pairing=$MSA_PAIRING &

srun $PYTHON_PATH/python3 -u $AF_DIR/run_af2c_mod.py \
  --target_lst_path=$TARGET_LST_FILE \
  --data_dir=$DATA_DIR \
  --output_dir=$OUT_DIR \
  --feature_dir=$FEA_DIR \
  --model_names=model_${MODEL_NUMBER}_ptm \
  --preset=$PRESET \
  --model_preset=monomer_ptm\
  --save_recycled=$RECYCLING_SETTING \
  --msa_pairing=$MSA_PAIRING
