#!/usr/bin/env bash

# This script is a part of the Ideal Fishstick pipeline, which is used for processing and analyzing 
# protein sequences. This script controls the execution flow of the pipeline and has three modes of operation: 
# SINGLE, MULTI, and MATRIX. The mode of operation is controlled by the "RUN_MODE" variable, which must be 
# defined in the "01_SOURCE.inc" file.

# Load the GNU Parallel module for parallel processing
module load parallel

# Load the path and setting variables
source "/u/$USER/malphaplex/scripts/PATHS"
source "${LOC_SCRIPTS}/01_SOURCE.inc"

DEFAULT_COLOR='\033[1;37m'  # Default to white color

# Print a waiting message
echo "      . . .    Please                     	 "
echo "       :.:     Wait!                  		 "
echo "    ____:____     _  _             	    	 "
echo "   |         \\   | \\/ |		 _______    	 "
echo "   |          \\   \\  |		|       \\  	 "
echo "   |  O        \\__/ |		|  O     \\ /\\  "
echo " ~^~^~^~^~^~^~^~^~^~^~^~^~~^~^~^~^~^~^~^~^~^~^~^~^~"

tail -n +2 "$INFO_LIST" | parallel --colsep '\t' "source ${LOC_SCRIPTS}/COORDINATOR.sh {1} {2}"
