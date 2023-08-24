#!/usr/bin/env bash

### SELECT #######################################
MODE=1
#MODE=2

case "$MODE" in
        1) printf "******************* MODE 1: STARTING JOBS *******************\n" ;;
        2) printf "******************* MODE 2: STARTING PROGRESS REPORT ********\n" ;;
        *) printf "******************* Unknown mode: %s ************************\n" "$MODE" ;;
esac


### INITIATE A TICKER TO COUNT FINISHED MODELS
PREDICTION_TICKER=0
##################################################

module purge
module load jdk/8.265 gcc/10 impi/2021.2 fftw-mpi R/4.0.2

FILE=$1
CONTINUE="FALSE"
source ./01_SOURCE.inc
source ./02_PATHS.inc
source ./03_FUNCTIONS

# Check if MSA needs to be run (starts job if necessary)
stoichiometry="${1:-$STOICHIOMETRY}"
CONTINUE="TRUE"
FASTA_EXISTS="TRUE"

# Check if the stoichiometry is provided
if [ -z "$STOICHIOMETRY" ]; then
	echo "Error: STOICHIOMETRY is required" >&2
fi

# Split the stoichiometry into individual feature-count pairs and check if all monomers are prepped
IFS='/' read -ra stoichiometry_pairs <<< "$STOICHIOMETRY"
for pair in "${stoichiometry_pairs[@]}"; do
	check_and_process_fasta "${stoichiometry_pairs[@]}"
done

if [ "$CONTINUE" = "TRUE" ]; then
	# Initialize the output directory with the template and set the initial files.
	initialize_run_dir "$LOC_SCRIPTS" "$OUT_NAME"
	# Assess the current status of model files in the output directory.
	assess_model_files "$LOC_OUT" "$OUT_NAME"
	cd ${LOC_SCRIPTS}/runs/${OUT_NAME}
	### CHECK MODEL EXISTENCE - IF 0 ARE FOUND, START ALL 5 MODELS IN INDIVIDUAL JOBS OR ALL 5 IN 1 JOB (IF CONSTRUCT SIZE BELOW 2000aa)
	if [[ ($OUT_RLX_MODEL_COUNT -eq 0 ) && ( $MODEL_COUNT -eq 0 ) && ( $OUT_MODEL_COUNT -eq 0 ) && ( $MOVED_OUT_MODEL_COUNT -eq 0 ) ]] ; then
		# jobs can be started if the MODE is 1
		submit_jobs_based_on_mode "$MODE" "$LOC_FASTA" "$LOC_FEATURES" "$STOICHIOMETRY"
		PREDICTION_STATUS="FAIL"
	else
		### 5 NEURAL NETWORK MODELS ARE USED - WE LOOP THROUGH 1:5 TO CHECK MODEL PROGRESS
		for i in {1..5}; do
			evaluate_prediction_for_model "$LOC_OUT" "$OUT_NAME" "$i" "$LOC_SCRIPTS" "$FILE" "$MODE"
			[ "$PREDICTION_STATUS" = "PASS" ] && ((PREDICTION_TICKER++))
		done
	fi
	# Process the results and manage files accordingly.
        process_prediction "$PREDICTION_TICKER" "$LOC_OUT" "$LOC_SCRIPTS" "$OUT_NAME" "$OUT_DIR" "$STORAGE"
else
	log_message "${RED}" "/(-.-)\\ WAITING FOR ${OUT_NAME} MSA TO FINISH."
fi
