RUN=SINGLE		# executes SINGLE.sh for simple (single) runs
#RUN=MULTI		# executes main.sh that iterates over MULTI.sh
RUN=MATRIX		# executes stoichiometry scans via MATRIX.sh

if [ "$RUN" = "SINGLE" ]; then
	
	# SET THE STOICHIOMETRY
	STOICHIOMETRY=MYD88_MOUSE:1/IRAK4_MOUSE:1
	#STOICHIOMETRY=T1065s1/T1065s2
	#STOICHIOMETRY=T1072s1:2/T1072s2:2
	#STOICHIOMETRY=T1065s1/T1065s2+T1072s1:2/T1072s2:2
	#STOICHIOMETRY=T1060s3:12
	#STOICHIOMETRY=IRAK4_MOUSE:1/IRAK1_MOUSE:1

	# SET THE OUTPUT NAME
	OUT_NAME=MYD88_MOUSE_x1_IRAK4_MOUSE_x1
	#OUT_NAME=H1065
	#OUT_NAME=H1072
	#OUT_NAME=H1072_H1065
	#OUT_NAME=H1060v4
	#OUT_NAME=IRAK4_IRAK1_x1

elif [ "$RUN" = "MULTI" ]; then

	FOLDER=TEST
			# Specify the folder where your fasta files are located.
			# Folder will be used to create a list of the fasta base names, for which models will be run.

	FILE_A=MYD88_MOUSE
			# Against which file do you want to model all files in the designated folder?
	
	# SET THE STOICHIOMETRY
	N_A=1
	N_B=1
	STOICHIOMETRY=${FILE_A}:${N_A}/${FILE}:${N_B}

	# SET THE OUTPUT NAME
	OUT_NAME=${FILE_A}_x${N_A}_${FILE}_x${N_B}	# standard OUT_NAME
	
elif [ "$RUN" = "MATRIX" ]; then

        # SET THE MATRIX COMPONENTS
        FILE_A=MYD88_MOUSE
        FILE_B=IRAK4_MOUSE        

        # SET THE MATRIX BOUNDARIES
        START_A=1
        END_A=2

        START_B=1
        END_B=2

        # EXAMPLE: I in 1-3 and J in 2-4:
        # (I, J) combinations that will be predicted:
                #(1, 2)
                #(1, 3)
                #(1, 4)
                        #(2, 2)
                        #(2, 3)
                        #(2, 4)
                                #(3, 2)
                                #(3, 3)
                                #(3, 4)
        
        # You can go into MATRIX.sh to adjust the stoichiometry structure
        # CURRENT OUT_NAME STRUCTURE IS ${FILE_A}_x${N_A}_${FILE}_x${N_B}
        # CURRENT STOICHIOMETRY STRUCTURE IS ${FILE_A}:${N_A}/${FILE}:${N_B}

else
	echo "PLEASE SPECIFY THE RUN MODE."
fi

source ~/malphaplex/scripts/02_PATHS.inc

# FOR MORE ON STOICHIOMETRY IN THIS PIPELINE CHECK OUT "https://github.com/FreshAirTonight/af2complex"
