source 00_user_parameters.inc

FILE=$FILE

# Comma-separated list of protein data, passed to alphafold via --fasta_paths
FASTA_PATHS=~/malphaplex/fasta_files/$FILE.fasta

# Output directory to write the results to, passed via --output
#OUTPUT_DIR=~/malphaplex/feature_files/
OUTPUT_DIR=/ptmp/$USER/feature_files

# Preset for alphafold, passed via --db_preset
#PRESET="full_dbs"
PRESET="reduced_dbs"

PYTHON_PATH=~/miniconda3/envs/malpha/bin
AF_DIR=~/af2complex/src
AF2_DIR=/mpcdf/soft/SLE_15/packages/x86_64/alphafold/2.3.0
DATA_DIR=/raven/ri/public_sequence_data/alphafold2/git-v2.3.0/data/

TOOL_DIR=/mpcdf/soft/SLE_15/packages/x86_64/alphafold/2.3.0/bin
