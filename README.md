# PROTEIN COMPLEX PREDICTION ON MPCDF RAVEN

## FIRST TIME SETUP

1. **Download and Install Miniconda**
    ```bash
    curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
    chmod +x Miniconda3-latest-Linux-x86_64.sh
    ./Miniconda3-latest-Linux-x86_64.sh
    ```
   
2. **Create a New Environment**
    ```bash
    conda create --name malpha python=3.8
    ```
   
3. **Activate the Environment**
    ```bash
    conda activate malpha
    ```
   
4. **Clone Required Github Repositories and Run Setup**
    ```bash
    cd
    git clone https://github.com/FreshAirTonight/af2complex.git
    git clone https://github.com/tlobnow/malphaplex.git
    cd malphaplex
    ./setup.sh
    ```
   
5. **Load an R Module**
    - Load the latest version on the Cluster, e.g.:
      ```bash
      module load R/4.3
      ```
      
    - Start R, install the `pacman` R package:
      ```bash
      R
      install.package("pacman")
      ```
      
    - Type `yes` and when asked for a specific mirror, enter `1`.
      
    - Once the package is installed, exit without saving the workspace:
      ```R
      quit()
      ```

## FOR EVERY NORMAL SESSION

1. **Enter the `fasta_files` Folder**
    - Add new fasta files or folders.
    - Only fasta files in the main folder will be prepared.
    - Copy all fasta files into the main `fasta_files` directory for preparation.

2. **Choose a Run Option**
    - Open `PATHS` file to specify the "RUN MODE":
        - For a single setup with variable stoichiometry and output name, set `RUN=SINGLE`.
        - For multiple samples following a set stoichiometry, set `RUN=MULTI` and specify the `FOLDER` name (folder with protein fasta files of interest).
        - For checking stoichiometric relationships between two proteins, set `RUN=MATRIX`.

3. **Adjust Settings**
    - Open `01_SOURCE.inc` and set the stoichiometry and output name structures.
    - Open `COORDINATOR.sh` and ensure that the `MODE` is set to `1` (allows to submit new jobs).

4. **Start Runs and Submit Jobs**
    ```bash
    ./main.sh
    ```

5. **Monitor Jobs**
    - While the slurm jobs are running, check progress of running jobs as described in step 4.
    - Check finished or outstanding jobs per run folder: change `MODE` in `COORDINATOR.sh` to `MODE=2` to get a progress report, then change back to `MODE=1` to submit new jobs.

6. **Post-Processing**
    - Once the model predictions have finished, restart `main.sh` to confirm that all jobs finished successfully.
    - This will also process the JSON files, generate a CSV file, and copy your files from `/ptmp/$USER` to your `$STORAGE` destination (adjust in `PATHS`).

7. **Repeat Runs (Optional)**
    - If you wish to repeat the runs, change to `RESTART="TRUE"` in `COORDINATOR.sh`.
    - This will permanently move your output folder to `$STORAGE` and allow new submissions with the same setup.
