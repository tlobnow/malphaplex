#!/bin/bash

set -e

JOBID1=$(sbatch --parsable script_model_1.sh)

echo "Submitted jobs"
echo "    ${JOBID1} (PRED 1)"
