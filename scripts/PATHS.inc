##########################################################################################################################
##########################################################################################################################
##########################################################################################################################

MAIN=/u/$USER/malphaplex

LOC_SCRIPTS=${MAIN}/scripts               # Specify where the scripts   are located
LOC_FASTA=${MAIN}/fasta_files             # Specify where fasta_files   are located
LOC_FEATURES=${MAIN}/feature_files        # Specify where feature_files are located
LOC_OUT=${MAIN}/output_files/$OUT_NAME    # Specify where your outputs  are located
LOC_FEA_GEN=${MAIN}/scripts/feaGen        # Specify where feature generating scripts are located
LOC_LISTS=${MAIN}/scripts/lists           # Specify where list files    are located

##########################################################################################################################
##########################################################################################################################
##########################################################################################################################

PYTHON_PATH=~/miniconda3/envs/fishy/bin
AF_DIR=~/af2complex/src
AF2_DIR=/mpcdf/soft/SLE_15/packages/x86_64/alphafold/2.3.0
DATA_DIR=/raven/ri/public_sequence_data/alphafold2/git-v2.3.0/data/
TARGET_LST_FILE=${LOC_SCRIPTS}/myRuns/$FILE/target.lst                 # a list of target with stoichiometry
FEA_DIR=${LOC_FEATURES}                                                # input feature pickle files of individual monomers under $INP_DIR/$monomer
OUT_DIR=${MAIN}/output_files                                         # model output files will be under $out_dir/$target

mkdir -p ${LOC_SCRIPTS}/myRuns            # Ensure that you have a folder where myRuns are located
mkdir -p ${LOC_SCRIPTS}/lists             # Ensure that you have a folder where lists are located
mkdir -p ${MAIN}/output_files             # Ensure that you have a folder where outputs are located
mkdir -p ${MAIN}/feature_files            # Ensure that you have a folder where feature files are located

##########################################################################################################################
##########################################################################################################################
##########################################################################################################################

# PATHS FOR MSA
FASTA_PATHS=${MAIN}/fasta_files/$FILE.fasta
OUTPUT_DIR=${MAIN}/feature_files/
TOOL_DIR=/mpcdf/soft/SLE_15/packages/x86_64/alphafold/2.3.0/bin

# Preset for alphafold, passed via --db_preset
#PRESET="full_dbs"
PRESET="reduced_dbs"
