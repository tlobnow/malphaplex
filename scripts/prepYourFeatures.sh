#!/usr/bin/env bash

source ./02_PATHS.inc

for i in $LOC_FASTA/*.fasta; do
        ### if you CAN find a directory named like the file you are currently reading ###
        if [ -d $LOC_FEATURES/$(basename -a -s .fasta $i) ]; then

                ### then look if you can find a features.pkl file in there and echo that the file is prepared ###
                [ -f $LOC_FEATURES/$(basename -a -s .fasta $i)/features.pkl ] && # ||
                        echo " \(^o^)/ $(basename -a -s .fasta $i) READY!" ||
                ### otherwise echo that it's missing ###
                        { ### copy the template folder in the feaGen directory and create a folder for each MSA output ###
                        cp -r $LOC_FEA_GEN/feaGen_template $LOC_FEA_GEN/$(basename -a -s .fasta $i)

                        ### enter the new file folder ###
                        cd $LOC_FEA_GEN/$(basename -a -s .fasta $i)

                        ### and save the file name in 00_user_parameters.inc ###
                        echo FILE=$(basename -a -s .fasta $i) > $LOC_FEA_GEN/$(basename -a -s .fasta $i)/00_user_parameters.inc

                        ### prepare an sbatch job and submit it ###
						JOBID1=$(sbatch --parsable script_msa.sh)
                        echo " /(x.x)\ (${JOBID1}) $(basename -a -s .fasta $i) FEATURES FILE MISSING... STARTING MSA!" 
                        }
                
        ### if you CANNOT find a directory named like the file you are currently reading ###
        ### then echo that it's missing and start the MSA to create one! ###
        else 
                ### copy the template folder in the feaGen directory and create a folder for each MSA output ###
                cp -r $LOC_FEA_GEN/feaGen_template $LOC_FEA_GEN/$(basename -a -s .fasta $i)

                ### enter the new file folder ###
                cd $LOC_FEA_GEN/$(basename -a -s .fasta $i)

                ### and save the file name in 00_user_parameters.inc ###
                echo FILE=$(basename -a -s .fasta $i) > $LOC_FEA_GEN/$(basename -a -s .fasta $i)/00_user_parameters.inc         

                ### prepare an sbatch job and submit it ###
                set -e
                JOBID1=$(sbatch --parsable script_msa.sh)
		echo " /(x.x)\ (${JOBID1}) $(basename -a -s .fasta $i) FEATURES FILE MISSING... STARTING MSA!"
                
        fi
done
