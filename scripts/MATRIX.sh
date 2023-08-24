#!/usr/bin/env bash

### SELECT #######################################
MODE=1
MODE=2

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
CONTINUE=FALSE # BY DEFAULT FALSE, FIRST CHECK FOR NECESSARY MSA
source "./01_SOURCE.inc" # <- CHANGE MATRIX BOUNDARIES HERE!
source "./02_PATHS.inc"
source "./03_FUNCTIONS"

declare -a stoichiometries=() # Indexed array that stores integers
for i in $(seq $START_A $END_A); do
	for j in $(seq $START_B $END_B); do
		STOICHIOMETRY=${FILE_A}:${i}/${FILE_B}:${j}
		stoichiometries+=("$STOICHIOMETRY")
	done
done
declare -A processed_files=() # Associative array to track processed fasta files (array stores names)
declare -A seen_files=()      # Associative array to track seen (duplicate) fasta files (array stores names)

for STOICHIOMETRY in "${stoichiometries[@]}"; do
	CONTINUE="TRUE"       # Default assumption: Processing can continue
	FASTA_EXISTS="TRUE"   # Default assumption: Fasta file exists

	# Splitting the STOICHIOMETRY string into pairs for processing
	IFS='/' read -ra stoichiometry_pairs <<< "$STOICHIOMETRY"
	# Utilize the function to validate and potentially process fasta and feature files
	check_and_process_fasta "${stoichiometry_pairs[@]}"
	# Loop over each stoichiometry pair
	for pair in "${stoichiometry_pairs[@]}"; do
		# Split the pair into feature and count
		IFS=':' read -r feature count <<< "$pair"
		# Split the feature string into individual fasta files
		IFS=',' read -ra fasta_files <<< "$feature"
		# Loop over each fasta file in the feature
		for fasta_file in "${fasta_files[@]}"; do
			# Avoid processing a fasta file if it's already been seen/processed
			if [ "${seen_files["$fasta_file"]}" ]; then
				continue
			fi
			# Mark the fasta file as seen
			seen_files["$fasta_file"]=1

			# Check if the associated feature file exists
			local feature_file="${LOC_FEATURES}/${fasta_file}/features.pkl"
			# If the feature file exists and extended view is enabled, print a status message
			if [ -f "${feature_file}" ] && [ "$EXTENDED_VIEW" = "TRUE" ]; then
				log_message "${CYAN}" "(^o^)/ READY: $FILE"
				# Mark the fasta_file as processed
				processed_files["$fasta_file"]=1
			fi
		done
	done
done

wait_for_jobs_completion "${MSA_JOBIDS[@]}"

for i in $(seq $START_A $END_A); do
	for j in $(seq $START_B $END_B); do
		# SET THE STOICHIOMETRY, OUT_NAME STRUCTURE
		STOICHIOMETRY=${FILE_A}:${i}/${FILE_B}:${j}
		OUT_NAME=${FILE_A}_x${i}_${FILE_B}_x${j}
		LOC_OUT=${PTMP}/output_files/$OUT_NAME
		# Prep the run
		if [ "$CONTINUE" = "TRUE" ]; then
			# Initialize the output directory with the template and set the initial files.
			initialize_run_dir "$LOC_SCRIPTS" "$OUT_NAME"
			# Assess the current status of model files in the output directory.
			assess_model_files "$LOC_OUT" "$OUT_NAME"
			cd ${LOC_SCRIPTS}/runs/${OUT_NAME}
			if [[ ($OUT_RLX_MODEL_COUNT -eq 0 ) && ( $MODEL_COUNT -eq 0 ) && ( $OUT_MODEL_COUNT -eq 0 ) && ( $MOVED_OUT_MODEL_COUNT -eq 0 ) ]] ; then
				# jobs can be started if the MODE is 1
				submit_jobs_based_on_mode "$MODE" "$LOC_FASTA" "$LOC_FEATURES" "$STOICHIOMETRY"
				PREDICTION_STATUS="FAIL"
			else
				### 5 NEURAL NETWORK MODELS ARE USED - WE LOOP THROUGH 1:5 TO CHECK MODEL PROGRESS
				for m in {1..5}; do
					evaluate_prediction_for_model "$LOC_OUT" "$OUT_NAME" "$m" "$LOC_SCRIPTS" "$FILE" "$MODE"
					[ "$PREDICTION_STATUS" = "PASS" ] && ((PREDICTION_TICKER++))
				done
			fi
			# Process the results and manage files accordingly.
			process_prediction "$PREDICTION_TICKER" "$LOC_OUT" "$LOC_SCRIPTS" "$OUT_NAME" "$OUT_DIR" "$STORAGE"
		else
		    printf "${YELLOW}" "/(-.-)\\ ${GRAY}WAITING FOR ${YELLOW}${OUT_NAME} ${GRAY}MSA TO FINISH. ${NC}\n"
		fi
	done
done

wait_for_jobs_completion "${MODELING_JOBIDS[@]}"

printf "Done!\n"
