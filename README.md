## PROTEIN COMPLEX PREDICTION ON MPCDF RAVEN


### FIRST TIME SETUP

1. Download and install Miniconda 

        curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
        chmod +x Miniconda3-latest-Linux-x86_64.sh
        ./Miniconda3-latest-Linux-x86_64.sh


3. Create a new environment:

        conda create --name malpha python=3.8

5. Clone required Github repositories and run the `setup.sh` script:

        cd
        git clone https://github.com/FreshAirTonight/af2complex.git
        git clone https://github.com/tlobnow/malphaplex.git
        cd malphaplex
        ./setup.sh


### FOR EVERY NORMAL SESSION

1. Activate the environment and update scripts:

        cd malphaplex

2. Enter the folder containing `fasta_files`:
    - Add new fasta files or folders
    - Only fasta files in the main folder will be prepared
    - Copy all fasta files into the main `fasta_files` directory for preparation


3. Choose one of the following run options:
    - Open `02_PATHS.inc` file to specify the RUN MODE":
        - For a single setup with variable stoichiometry and output name:
        - Set `RUN=SINGLE`.
    - For multiple samples following a set stoichiometry:
        - Set `RUN=MULTI`.
        - Set the `FOLDER` name (folder with protein fasta files of interest).
    - For checking stoichiometric relationships between two proteins:
        - Set `RUN=MATRIX`.

4. Open `01_SOURCE.inc` and set the stoichiometry and output name structures.

5. Open `COORDINATOR.sh` and ensure that the MODE is set to 1 (allows to submit new jobs).

6. Start runs and submit jobs by executing the main script

        ./main.sh

7. While the slurm jobs are running:
    - Check progress of running jobs as described in step 4.
    - Check finished or outstanding jobs per run folder:
        - Change `MODE` `COORDINATOR.sh` to `MODE=2` to get a progress report.
        - Change the mode back to `MODE=1` to submit new jobs.

8. Once the model predictions have finished:
    - Restart `main.sh` to confirm that all jobs finished successfully
    - This will also process the JSON files and generate a CSV file
    - Additionally, your files will be copied from `/ptmp/$USER` to your `$STORAGE` destination (adjust in `02_PATHS.inc`.

9. If you wish to repeat the runs, change to `RESTART="TRUE"` in `COORDINATOR.sh`
    - This will permanently move your output folder to $STORAGE and allow new submissions with the same setup.

