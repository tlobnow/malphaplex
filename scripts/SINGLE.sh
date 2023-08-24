#!/usr/bin/env bash

# This script is used to manage and check the progress of protein modeling jobs.

### SELECT #######################################
# MODE determines the action this script will perform.
# MODE=1: Start new jobs
# MODE=2: Provide a progress report on existing jobs

MODE=1
#MODE=2

# Print the selected mode to the console.
case "$MODE" in
        1) printf "******************* MODE 1: STARTING JOBS *******************\n" ;;
        2) printf "******************* MODE 2: STARTING PROGRESS REPORT ********\n" ;;
        *) printf "******************* Unknown mode: %s ************************\n" "$MODE" ;;
esac

# Initialize a counter to track the number of models that have finished.
PREDICTION_TICKER=0
##################################################

# Load required modules for the environment.
module purge
module load jdk/8.265 gcc/10 impi/2021.2 fftw-mpi R/4.0.2

# Source required configuration and function files.
source "./01_SOURCE.inc"
source "./02_PATHS.inc"
source "./03_FUNCTIONS"

# Retrieve stoichiometry from the arguments or use the default.
stoichiometry="${1:-$STOICHIOMETRY}"
# Initialize flags to determine if processing should continue and if fasta files exist.
CONTINUE="TRUE"
FASTA_EXISTS="TRUE"

# Check if stoichiometry is provided.
if [ -z "$STOICHIOMETRY" ]; then
        printf "${RED}/(x.x)\\ ${GRAY}STOICHIOMETRY is required${NC}\n" >&2
fi

# Split the stoichiometry into individual feature-count pairs and check if all monomers are prepped.
IFS='/' read -ra stoichiometry_pairs <<< "$STOICHIOMETRY"
for pair in "${stoichiometry_pairs[@]}"; do
        check_and_process_fasta "${stoichiometry_pairs[@]}"
done

wait_for_jobs_completion "${MSA_JOBIDS[@]}"

# If all required monomers are prepped, proceed with the modeling.
if [ "$CONTINUE" = "TRUE" ]; then
        # Initialize the output directory with the template and set the initial files.
        initialize_run_dir "$LOC_SCRIPTS" "$OUT_NAME"
        # Assess the current status of model files in the output directory.
        assess_model_files "$LOC_OUT" "$OUT_NAME"
        cd ${LOC_SCRIPTS}/runs/${OUT_NAME}
        # Check if any models exist. If none exist, start the modeling process.
        if [[ ($OUT_RLX_MODEL_COUNT -eq 0 ) && ( $MODEL_COUNT -eq 0 ) && ( $OUT_MODEL_COUNT -eq 0 ) && ( $MOVED_OUT_MODEL_COUNT -eq 0 ) ]] ; then
		# Start 1 large job or 5 small jobs depending on setup size (sum of all aa in setup)
                submit_jobs_based_on_mode "$MODE" "$LOC_FASTA" "$LOC_FEATURES" "$STOICHIOMETRY"
                PREDICTION_STATUS="FAIL"
        else
                # If some models exist, check their progress.
                for i in {1..5}; do
                        evaluate_prediction_for_model "$LOC_OUT" "$OUT_NAME" "$i" "$LOC_SCRIPTS" "$FILE" "$MODE"
                        [ "$PREDICTION_STATUS" = "PASS" ] && ((PREDICTION_TICKER++))
                done
        fi
        # Process the results and manage files accordingly.
        process_prediction "$PREDICTION_TICKER" "$LOC_OUT" "$LOC_SCRIPTS" "$OUT_NAME" "$OUT_DIR" "$STORAGE"
else
        printf "${YELLOW}" "/(-.-)\\ ${GRAY}WAITING FOR ${YELLOW}${OUT_NAME} ${GRAY}MSA TO FINISH. ${NC}\n"
fi

wait_for_jobs_completion "${MODELING_JOBIDS[@]}"

printf "Done!\n"
