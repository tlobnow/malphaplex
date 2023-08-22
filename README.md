## PROTEIN COMPLEX PREDICTION ON MPCDF RAVEN


### FIRST TIME SETUP

1. Download and install Miniconda 

        curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
        chmod + x Miniconda3-latest-Linux-x86_64.sh
        ./Miniconda3-latest-Linux-x86_64.sh


3. Create a new environment:

        conda create --name fishy python=3.8


4. Activate the environment:

        conda activate fishy

    To automatically activate the environment at login, add `conda activate fishy` to your ~/.bashrc file. (Type `nano ~/.bashrc` and paste the line at the end of the file, save and exit using `ctrl+x` and `y`)

5. Clone required Github repositories and run the `setup.sh` script:

        cd ~
        git clone https://github.com/FreshAirTonight/af2complex.git
        git clone https://github.com/tlobnow/malphaplex.git
        cd malphaplex
        ./setup.sh


### FOR EVERY NORMAL SESSION

1. Activate the environment and update scripts:

        conda activate fishy
        cd malphaplex
        git pull


2. Enter the folder containing `fasta_files`:
    - Add new fasta files or folders
    - Only fasta files in the main folder will be prepared
    - Copy all fasta files into the main `fasta_files` directory for preparation


3. Enter the `scripts` folder and run the `prepYourFeatures.sh` script:

        ./prepYourFeatures.sh


4. Supervise the progress of slurm jobs:
    - Use `check_squeue.sh` to view currently running jobs (refreshes every 10 seconds)
    - Use `squeue.sh` to view currently running jobs without refreshing


5. Check the `feature_files` folder:
    - Each prepared fasta should have a folder containing a `features.pkl` file


6. Choose one of the following run options:
    - Open `01_source.inc` file.
    - Select the desired run method:
        - For a single setup with variable stoichiometry and output name:
        - Set `RUN=SINGLE`.
        - Set complex stoichiometry and output name.
    - For multiple samples following a set stoichiometry:
        - Set `RUN=MULTI`.
        - Set the `FOLDER` name (folder with protein fasta files of interest).
        - Set stoichiometry structure and output name structure.
    - For checking stoichiometric relationships between two proteins:
        - Set `RUN=MATRIX`.
        - Set the monomers to run in the setup (FILE_A and FILE).
        - Adjust additional matrix options in `MATRIX.sh`.
        

7. Start runs and submit jobs by executing the main script

        ./main.sh


8. While the slurm jobs are running:
    - Check progress of running jobs as described in step 4.
    - Check finished or outstanding jobs per run folder:
        - Change `MODE` in each respective run script (`SINGLE.sh`, `MULTI.sh`, `MATRIX.sh`) to `MODE=2`.
        - Change the mode back to `MODE=1` to submit new jobs.


9. Once the model predictions have finished:
    - Restart `main.sh` to confirm that all jobs finished successfully

