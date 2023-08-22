#!/bin/bash

set -e

JOBID1=$(sbatch --parsable script_model_3.sh)

echo "Submitted jobs"
echo "    ${JOBID1} (PRED 3)"
