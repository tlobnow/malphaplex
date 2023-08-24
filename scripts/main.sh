#!/usr/bin/env bash

# This script is a part of the Ideal Fishstick pipeline, which is used for processing and analyzing 
# protein sequences. This script controls the execution flow of the pipeline and has three modes of operation: 
# SINGLE, MULTI, and MATRIX. The mode of operation is controlled by the "RUN_MODE" variable, which must be 
# defined in the "01_SOURCE.inc" file.

# Load the GNU Parallel module for parallel processing
module load parallel

# Load the path and setting variables
source "./01_SOURCE.inc"
source "./02_PATHS.inc"
source "./03_FUNCTIONS"

DEFAULT_COLOR='\033[1;37m'  # Default to white color

# Print a waiting message
log_message ${BLUE} "      . . .    Please                     		"
log_message ${BLUE} "       :.:     Wait!              :.    		"
log_message ${BLUE} "    ____:____     _  _            :.: 	    	"
log_message ${BLUE} "   |         \\   | \\/ | 	     ___:___    	"
log_message ${BLUE} "   |          \\   \\  |  	    |       \\   .	"
log_message ${BLUE} "   |  O        \\__/ |   	    |  O     \\ /\\ 	"
log_message ${BLUE} " ~^~^~^~^~^~^~^~^~^~^~^~^~~^~^~^~^~^~^~^~^~^~^~^~^~"

declare -a MSA_JOBIDS
declare -a MODELING_JOBIDS

MSA_JOBIDS=()
MODELING_JOBIDS=()

# Main execution
case "$RUN_MODE" in
    "SINGLE")
        run_single_mode
        ;;
    "MULTI")
        run_multi_mode
        ;;
    "MATRIX")
        run_matrix_mode
        ;;
    *)
        log_message "Please adjust the run settings in 01_SOURCE.inc"
        ;;
esac
