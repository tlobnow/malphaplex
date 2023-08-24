#!/bin/bash

# Define the run modes
#RUN_MODE=SINGLE           # Executes SINGLE.sh for simple (single) runs
RUN_MODE=MULTI          # Executes main.sh that iterates over MULTI.sh
#RUN_MODE=MATRIX         # Executes stoichiometry scans via MATRIX.sh

# Set configurations based on the run mode
case "$RUN_MODE" in
    SINGLE)
        # Configuration for SINGLE mode
        #STOICHIOMETRY=MYD88_MOUSE:1/IRAK4_MOUSE:1
	STOICHIOMETRY=A0A1Z4FQN5:3
        #OUT_NAME=MYD88_MOUSE_x1_IRAK4_MOUSE_x1
	OUT_NAME=A0A1Z4FQN5_x3
        ;;

    MULTI)
        # Configuration for MULTI mode
        FOLDER=TEST                              # Folder containing fasta files
	#FOLDER=IRAK4_Protein.IDs
        FILE_A=MYD88_MOUSE                       # File to model against all files in the folder
        N_A=1
        N_B=1
        STOICHIOMETRY=${FILE_A}:${N_A}/${FILE}:${N_B}
        OUT_NAME=${FILE_A}_x${N_A}_${FILE}_x${N_B}
        ;;

    MATRIX)
        # Configuration for MATRIX mode
        FILE_A=MYD88_MOUSE
        FILE_B=IRAK4_MOUSE
        START_A=2; END_A=3
        START_B=2; END_B=3
        # For more details on matrix combinations, view MATRIX.sh
        ;;
    *)
        echo "ERROR: Please specify a valid RUN mode."
        exit 1
        ;;
esac

# Load necessary paths
source ~/malphaplex/scripts/02_PATHS.inc

# Documentation
# For more on stoichiometry in this pipeline, refer to: https://github.com/FreshAirTonight/af2complex
