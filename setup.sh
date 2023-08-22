#!/usr/bin/env bash

# copies necessary packages from MPCDF AlphaFold folder (normal pip installation does not work for all necessary packages unfortunately)
cp -r /mpcdf/soft/SLE_15/packages/x86_64/alphafold/2.3.0/lib/python3.8/site-packages ~/miniconda3/envs/fishy/lib/python3.8/

# installs additional package networkx version into your environment
pip install networkx==2.5
pip install decorator
