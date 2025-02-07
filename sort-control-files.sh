#!/bin/bash

# Check if an argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <input_folder>"
    exit 1
fi

# Get the absolute path of the input folder
input_folder=$(realpath "$1")

# Run the R script, passing the input folder as an argument
Rscript "$(dirname "$0")/sort-control-files.R" "$input_folder"