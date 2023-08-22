#!/usr/bin/env bash

# YOU CAN PROVIDE A LIST (PATTERN MY_LIST.txt THAT CONTAINS TAB-SEPARATED PROTEIN ACCESSION IDs)
# PROMPT FOR LIST
read -p "Enter your list name [EXAMPLE_LIST.txt]: " PRE_LIST
PRE_LIST=${PRE_LIST:-UNIPROT}
echo "YOU PROVIDED $PRE_LIST"

# REMOVE FILE EXTENSION .txt
LIST=$(basename "$PRE_LIST" .txt)

# CREATE A NEW FOLDER NAMED LIKE THE PROVIDED LIST
mkdir -p $LIST

while read LINE; do
echo "$LINE"
curl -X GET "https://rest.uniprot.org/uniprotkb/${LINE}" -H "accept: text/plain;format=fasta" > $LIST/${LINE}.fasta
done <$LIST.txt

cp -r $LIST/ ../../fasta_files/
