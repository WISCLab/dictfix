#!/usr/bin/env bash
set -euo pipefail

# Usage: ./util-delete-empty-rating-files.sh <directory> [--recurse] [--delete]
# - Dry-run by default (prints what it would delete)
# - Pass --delete to actually remove files
# - Pass --recurse to search subdirectories

# created with help of ChatGPT

target_dir=""
do_delete=false
recurse=false

# Parse args
for arg in "$@"; do
  case "$arg" in
    --delete)  do_delete=true ;;
    --recurse) recurse=true ;;
    -*)
      echo "Unknown option: $arg"
      echo "Usage: $0 <directory> [--recurse] [--delete]"
      exit 1
      ;;
    *)
      if [[ -z "$target_dir" ]]; then
        target_dir=$arg
      else
        echo "Unexpected argument: $arg"
        echo "Usage: $0 <directory> [--recurse] [--delete]"
        exit 1
      fi
      ;;
  esac
done

if [[ -z "$target_dir" ]]; then
  echo "Usage: $0 <directory> [--recurse] [--delete]"
  exit 1
fi

if [[ ! -d "$target_dir" ]]; then
  echo -e "Error: \033[94m$target_dir\033[0m is not a directory"
  exit 1
fi

# Exact header (with literal TABs)
expected_header=$'Task\tName\tValue\tFile'

would_delete=0
deleted=0
checked=0

# Collect files
if $recurse; then
  mapfile -t files < <(find "$target_dir" -type f -name '*!*')
else
  shopt -s nullglob
  files=("$target_dir"/*'!'*)
fi

for file in "${files[@]}"; do
  [ -f "$file" ] || continue
  checked=$((checked+1))

  # First line (strip CR for CRLF files)
  IFS= read -r first_line < "$file" || first_line=""
  first_line=${first_line%$'\r'}

  [[ "$first_line" == "$expected_header" ]] || continue

  # Any non-blank content after header?
  if tail -n +2 -- "$file" | grep -q '[^[:space:]]'; then
    continue
  fi

  if $do_delete; then
    echo -e "Deleting: \033[94m$file\033[0m"
    rm -f -- "$file"
    deleted=$((deleted+1))
  else
    echo -e "Would delete: \033[94m$file\033[0m"
    would_delete=$((would_delete+1))
  fi
done

if $do_delete; then
  echo "Done. Deleted $deleted / $checked matching file(s)."
else
  echo -e "Dry-run complete. Would delete $would_delete / $checked matching file(s). (Use \033[94m--delete\033[0m to remove files.)"
fi
