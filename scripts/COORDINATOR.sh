#!/usr/bin/env bash

# This script is used to manage and check the progress of protein modeling jobs.

### SELECT #######################################
# MODE determines the action this script will perform.
# MODE=1: Start new jobs
# MODE=2: Provide a progress report on existing jobs

MODE=1
#MODE=2

#RESTART="TRUE"
RESTART="FALSE"

RED='\033[1;31m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
BLUE='\033[1;34m'
GRAY='\033[1;37m'
NC='\033[0m' # No Color

# Print the selected mode to the console.
case "$MODE" in
        1) printf "${BLUE}******************* MODE 1: STARTING JOBS *******************${NC}\n" ;;
        2) printf "${BLUE}******************* MODE 2: STARTING PROGRESS REPORT ********${NC}\n" ;;
        *) printf "${BLUE}******************* Unknown mode: %s ************************${NC}\n" "$MODE" ;;
esac

# Load required modules for the environment.
module purge
module load jdk/8.265 gcc/10 impi/2021.2 fftw-mpi R/4.0.2

source "./02_PATHS.inc"
source "./03_FUNCTIONS"

OUT_NAME="$1"
STOICHIOMETRY="$2"

printf "DATE:\t\t%s\n" "$(date +%Y-%m-%d_%H:%M:%S)"
printf "MODE:\t\t%s\n" "$MODE"
printf "OUT_NAME:\t%s\n" "$OUT_NAME"
printf "STOICHIOMETRY:\t%s\n" "$STOICHIOMETRY"
#printf "LOC_FEATURES:\t%s\n" "$LOC_FEATURES"
printf "OUT_DIR:\t%s\n" "$OUT_DIR"
LOC_OUT=${PTMP}/output_files/$OUT_NAME
printf "LOC_OUT:\t%s\n" "$LOC_OUT"
#printf "LOC_FEA_GEN:\t%s\n" "$LOC_FEA_GEN"
printf "LOC_LISTS:\t%s\n" "$LOC_LISTS"
#printf "LOC_SLURMS:\t%s\n" "$LOC_SLURMS"
#printf "LOC_FLAGS:\t%s\n" "$LOC_FLAGS"
printf "INFO_LIST:\t%s\n" "$INFO_LIST"

# Retrieve stoichiometry from the arguments or use the default.
stoichiometry="$STOICHIOMETRY"

# Initialize flags to determine if processing should continue and if fasta files exist.
CONTINUE="TRUE"
FASTA_EXISTS="TRUE"

# Check if stoichiometry is provided.
if [ -z "$STOICHIOMETRY" ]; then
        printf "${RED}STOICHIOMETRY is required${NC}\n" >&2
fi

# Split the stoichiometry into individual feature-count pairs and check if all monomers are prepped.
IFS='/' read -ra stoichiometry_pairs <<< "$STOICHIOMETRY"
for pair in "${stoichiometry_pairs[@]}"; do
        check_and_process_fasta "${stoichiometry_pairs[@]}"
done

if [ "$CONTINUE" = "TRUE" ]; then
    echo "---------------- Initialization ----------------"
    initialize_run_dir "$LOC_SCRIPTS" "$OUT_NAME"
    echo "                 *** Passed *** "

    echo "------------------ Job Submit ------------------"
    cd ${LOC_SCRIPTS}/runs/${OUT_NAME}
    declare -A MODEL_COUNTS # Initialize an associative array to hold the counts for each individual model
    submit_jobs_based_on_mode "$MODE" "$LOC_FASTA" "$LOC_FEATURES" "$STOICHIOMETRY" "$LOC_OUT" "$OUT_NAME" "$LOC_SCRIPTS" "$FILE"

    echo "------------- Checking Model Status ------------"
    echo "ALL_MODELS_PRESENT:" $ALL_MODELS_PRESENT

    if [ "$ALL_MODELS_PRESENT" = "true" ]; then
        echo "------------ Starting File Processing ----------"
        process_prediction "$LOC_OUT" "$LOC_SCRIPTS" "$OUT_NAME" "$OUT_DIR" "$STORAGE"
        echo "------------- Moving SLURM Files ---------------"
        matching_files=($(grep -l "$OUT_NAME" ${LOC_SLURMS}/* 2>/dev/null))
        for file in "${matching_files[@]}"; do
            mv "$file" "$LOC_OUT/"
        done
	if [ "$RESTART" = "TRUE" ]; then
		mv "$LOC_OUT" "$STORAGE"
	elif [ "$RESTART" = "FALSE" ]; then
		cp -r "$LOC_OUT" "$STORAGE"
	else
		echo "PLEASE SET `RESTART` VARIABLE TO TRUE OR FALSE."
	fi
    else
        echo "WAITING FOR ${OUT_NAME} MODELING TO FINISH."
    fi
else
	echo "WAITING FOR ${OUT_NAME} MSA TO FINISH."
fi
echo "-------------------------------------------------"
