#!/bin/bash

# Function to create a directory if it doesn't exist
create_directory() {
  if [ ! -d "$1" ]; then
    echo "Creating directory: $1"
    mkdir -p "$1"
  else
    echo "Directory already exists: $1"
  fi
}

# Function to prompt for deletion of the original file
prompt_for_deletion() {
  read -p "Do you wish to delete the original file $base_name? [y/n] " -n 1 -r
  echo  # Move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Deleting original file: $1"
    rm -f "$1"
  else
    echo "Original file retained."
  fi
}

# Check if an argument was provided
if [ "$1" ]; then
  input_file="$1"
  echo "Using the provided input file: $input_file"
else
  # Prompt the user for the file to extract if no argument was provided
  read -p "Enter the path to the fasta file: " input_file
fi

# Expand tilde to $HOME if necessary
input_file="${input_file/#\~/$HOME}"

# Get the base name of the fasta file without extension
base_name=$(basename "$input_file" | sed 's/\.[^.]*$//')

# Check if the second argument was provided for the output directory
if [ "$2" ]; then
  output_dir="$2"
  echo "Using the provided output directory: $output_dir"
else
  # Define default output directory based on the fasta file base name
  default_output_dir="${HOME}/malphaplex/fasta_files/${base_name}_fasta_output"
  # Prompt for the output directory or use the default
  read -p "Enter the output directory or leave blank for the default [$default_output_dir]: " custom_output_dir
  output_dir=${custom_output_dir:-"$default_output_dir"}
fi

# Create the output directory
create_directory "$output_dir"

# Split the fasta file into individual files
awk '/^>/ {if (x) close(x); x=substr($0,2); gsub(/ /,"_"); x="'"$output_dir"'" "/" x ".fasta"} {print > x;}' "$input_file"

# List the newly created files
echo "The following fasta sequences have been split into individual files:"
for file in "$output_dir"/*.fasta; do
  printf "    %s\n" "$(basename "$file")"
done

# Prompt user for deletion of the original file
prompt_for_deletion "$input_file"
