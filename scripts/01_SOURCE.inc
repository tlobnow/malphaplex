#!/bin/bash

# Load necessary paths
source /u/${USER}/malphaplex/scripts/02_PATHS.inc

# Remove the file if it already exists from previous runs
[   -f $INFO_LIST ] && rm $INFO_LIST
# Initialization
[ ! -f $INFO_LIST ] && echo -e "OUT_NAME\tSTOICHIOMETRY" > $INFO_LIST

# Set configurations based on the run mode
case "$RUN_MODE" in
    SINGLE)
	# Configuration for SINGLE mode
        #STOICHIOMETRY=MYD88_MOUSE:1/IRAK4_MOUSE:1
	STOICHIOMETRY=MYD88_MOUSE:1/P68373:1
        #OUT_NAME=MYD88_MOUSE_x1_IRAK4_MOUSE_x1
	OUT_NAME=MYD88_MOUSE_x1_P68373_x1
	echo -e "${OUT_NAME}\t${STOICHIOMETRY}" >> "$INFO_LIST"
        ;;

    MULTI)
        # Configuration for MULTI mode
        A=MYD88_MOUSE                       # File to model against all files in the folder
        N_A=1
        N_B=1

	# Automatically generate stoichiometry and output name
	for i in ${LOC_FASTA}/${FOLDER}/*.fasta; do
        	file_name=$(basename -a -s .fasta $i)
        	echo -e "${A}_x${N_A}_${file_name}_x${N_B}\t${A}:${N_A}/${file_name}:${N_B}" >> "$INFO_LIST"
	done
        ;;

    MATRIX)
        # Configuration for MATRIX mode
        FILE_A=MYD88_MOUSE
        FILE_B=IRAK4_MOUSE
        START_A=2; END_A=3
        START_B=2; END_B=3
        # For more details on matrix combinations, view MATRIX.sh
	# Automatically generate stoichiometry and output name
    	for i in $(seq $START_A $END_A); do
        	for j in $(seq $START_B $END_B); do
        	    echo -e "${A}_x${i}_${B}_x${j}\t${A}:${i}/${B}:${j}" >> "$INFO_LIST"
        	done
    	done
        ;;
    *)
        echo "ERROR: Please specify a valid RUN mode."
        exit 1
        ;;
esac

# Documentation
# For more on stoichiometry in this pipeline, refer to: https://github.com/FreshAirTonight/af2complex

# ==== That's it. Nothing to adjust below  ====

# Count lines to get NUM (subtract 1 for header)
NUM=$(( $(wc -l < "$INFO_LIST") - 1 ))
echo "Number of structures:" $NUM

# add NUM column to INFO_LIST that enumerates each row
awk -F'\t' 'BEGIN {OFS="\t"} NR==1 {print $0, "NUM"} NR>1 {print $0, NR-1}' \
  "$INFO_LIST" > temp && mv temp "$INFO_LIST"

# Iterate through each line of the combined list (skipping the header), creating or checking run directories.
while IFS=$'\t' read -r OUT_NAME STOICHIOMETRY ROW_NUM; do
    [[ "$OUT_NAME" == "OUT_NAME" ]] && continue  # Skip header
    run_dir="${LOC_SCRIPTS}/runs/${OUT_NAME}"
    if [ ! -d "$run_dir" ]; then
        echo "Creating folder $OUT_NAME"; cp -r "${LOC_SCRIPTS}/template" "$run_dir"
        [[ -d "${run_dir}/template" ]] && rm -rf "${run_dir}/template"  # Remove mistakenly copied template folder
    else
        echo "Checking file $OUT_NAME!"
    fi
done < "$INFO_LIST"

# Copy fasta files
[ -d "${LOC_FASTA}/${FOLDER}" ] && cp "${LOC_FASTA}/${FOLDER}"/*.fasta "${LOC_FASTA}"
