#!/bin/bash

set -e

JOBID1=$(sbatch --parsable script_msa.sh)

echo "Submitted jobs"
echo "    ${JOBID1} (MSA)"
