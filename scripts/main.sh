#!/usr/bin/env bash

# This script is a part of the Ideal Fishstick pipeline, which is used for processing and analyzing 
# protein sequences. This script controls the execution flow of the pipeline and has three modes of operation: 
# SINGLE, MULTI, and MATRIX. The mode of operation is controlled by the "RUN" variable, which must be 
# defined in the "01_source.inc" file.

# Load the GNU Parallel module for parallel processing
module load parallel

# Load the path and setting variables
source ~/malphaplex/scripts/02_PATHS.inc
source ~/malphaplex/scripts/01_source.inc

# Print a waiting message
echo "      . . .    Please   "
echo "       :.:     Wait!    "
echo "    ____:____     _  _  "
echo "   |         \   | \/ | "
echo "   |          \   \  |  "
echo "   |  O        \__/ |   "
echo " ~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^~^"

# If the "RUN" variable is set to "SINGLE", execute the SINGLE.sh script
if [ "$RUN" = "SINGLE" ]; then

	sh ~/malphaplex/scripts/SINGLE.sh

# If the "RUN" variable is set to "MULTI", execute the MULTI.sh script on each .fasta file in parallel
elif [ "$RUN" = "MULTI" ]; then

	# Create a list of all fasta files in the designated folder
	IND_LIST="${LOC_LISTS}/${FOLDER}_inds"
	# Create a list of all fasta files (without the extension)
	for i in ${LOC_FASTA}/${FOLDER}/*.fasta; do echo $(basename -a -s .fasta $i); done > "$IND_LIST"
	# Create missing run directories and copy templates
	while read -r LINE; do
		RUN_DIR="${LOC_SCRIPTS}/runs/${LINE}"
		if [ ! -d "$RUN_DIR" ]; then
			echo "creating folder $LINE"
			cp -r "${LOC_SCRIPTS}/template" "$RUN_DIR"
			# Remove template folder if it was copied into the new folder by mistake
			[ -d "${RUN_DIR}/template" ] && rm -rf "${RUN_DIR}/template"
		else
			echo "checking file $LINE!"
		fi
	done < "$IND_LIST"
	# Copy fasta files from the designated folder into the main fasta folder
	cp "${LOC_FASTA}/${FOLDER}"/*.fasta "${LOC_FASTA}"
	echo "running MULTI.sh based on $IND_LIST"
	# Run MULTI.sh on each fasta file in parallel
	parallel "sh /u/\$USER/malphaplex/scripts/MULTI.sh {}" :::: "$IND_LIST"

# If the "RUN" variable is set to "MATRIX", execute the MATRIX.sh script
elif [ "$RUN" = "MATRIX" ]; then

	sh /u/${USER}/malphaplex/scripts/MATRIX.sh

else

	# If "RUN" is not set to "SINGLE", "MULTI", or "MATRIX", print an error message
	echo "Please adjust the run settings in 01_source.inc"

fi
