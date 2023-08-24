##########################################################################################################################
##########################################################################################################################
##########################################################################################################################

# CHECK IF THESE LOCATIONS ARE CORRECT ON YOUR ACCOUNT!
MAIN=/u/$USER/malphaplex
PTMP=/ptmp/$USER
PYTHON_PATH=~/miniconda3/envs/malpha/bin
AF_DIR=~/af2complex/src

# DEFAULT LOCATION FOR FINISHED OUTPUT FOLDERS
STORAGE=${MAIN}/output_files

### MAYBE NEEDS TO BE ADJUSTED IN THE FUTURE IF MPCDF CHANGES STUFF #####################################################
AF2_DIR=/mpcdf/soft/SLE_15/packages/x86_64/alphafold/2.3.1
DATA_DIR=/raven/ri/public_sequence_data/alphafold2/git-v2.3.1/data/
# Preset for alphafold, passed via --db_preset
#PRESET="full_dbs"
PRESET="reduced_dbs"

### RELATIVE PATHS (NO NEED TO CHANGE) ###################################################################################
LOC_SCRIPTS=${MAIN}/scripts             # Specify where the scripts   are located
LOC_FASTA=${MAIN}/fasta_files           # Specify where fasta_files   are located

### ptmp allows MUCH more storage, kept for up to 12 weeks, deleted if not opened (should suffice!) ######################
LOC_FEATURES=${PTMP}/feature_files/     # Specify where feature files are located 
LOC_OUT=${PTMP}/output_files/$OUT_NAME  # Specify where your outputs  are located
LOC_FEA_GEN=${LOC_SCRIPTS}/feaGen       # Specify where feature generating scripts are located
LOC_LISTS=${LOC_SCRIPTS}/lists          # Specify where list files    are located

TARGET_LST_FILE=${LOC_SCRIPTS}/runs/$FILE/target.lst # a list of target with stoichiometry
FEA_DIR=${LOC_FEATURES}                 # input feature pickle files of individual monomers under $INP_DIR/$monomer
OUT_DIR=${PTMP}/output_files            # model output files will be under $out_dir/$target

### check if all necessary folders exist, otherwise create new ###########################################################
mkdir -p ${LOC_SCRIPTS}/runs  
mkdir -p ${LOC_SCRIPTS}/lists 
mkdir -p ${OUT_DIR}           
mkdir -p ${FEA_DIR}           
mkdir -p ${STORAGE}

touch ${STORAGE}/finished_files_will_move_here

# EXTRA PATHS FOR MSA ####################################################################################################
FASTA_PATHS=${MAIN}/fasta_files/$FILE.fasta
OUTPUT_DIR=${LOC_FEATURES}
TOOL_DIR=/mpcdf/soft/SLE_15/packages/x86_64/alphafold/2.3.1/bin
