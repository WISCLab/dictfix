#!/usr/bin/env bash
set -euo pipefail

# created with help of ChatGPT

# Ensure a directory argument was provided
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
  echo "Usage: $0 <directory> [--delete]"
  exit 1
fi

target_dir=$1
delete_zips=false

# Parse optional second argument
if [ $# -eq 2 ]; then
  if [ "$2" = "--delete" ]; then
    delete_zips=true
  else
    echo "Error: unknown option '$2'" >&2
    echo "Usage: $0 <directory> [--delete]" >&2
    exit 1
  fi
fi

# Make sure the directory exists
if [ ! -d "$target_dir" ]; then
  echo "Error: '$target_dir' is not a directory" >&2
  exit 1
fi

# Loop over zip files in the directory
for zipfile in "$target_dir"/*.zip; do
  [ -e "$zipfile" ] || continue  # Skip if there are no .zip files

  echo "Unzipping $zipfile..."
  unzip -o "$zipfile" -d "$target_dir"

  if "$delete_zips"; then
    echo "Deleting $zipfile..."
    rm -- "$zipfile"
  fi
done
