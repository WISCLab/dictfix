#!/bin/bash

# created with help of ChatGPT

input_file="DictFix.txt"
conflict_found=false

# Format validation
awk -F'\t' '
{
  sub(/\r$/, "", $0)                 # strip CR for CRLF files
  if ($0 ~ /^[[:space:]]*$/) next    # skip blank lines

  if (NF != 2) {
    printf("Format error (line %d): expected exactly 2 tab-separated fields\n  >> %s\n\n", NR, $0) > "/dev/stderr"
    bad_fmt = 1
    next
  }
  if ($1 !~ /^[A-Za-z'\''\-]+$/) {
    printf("Format error (line %d): first field must be letters, hypens or apostrophes only\n  >> %s\n\n", NR, $0) > "/dev/stderr"
    bad_fmt = 1
  }
  if ($2 !~ /^[A-Za-z0-9@^-]+$/) {
    printf("Format error (line %d): second field must be WiscBet characters only\n  >> %s\n\n", NR, $0) > "/dev/stderr"
    bad_fmt = 1
  }
}
END {
  if (bad_fmt) exit 2
}
' "$input_file"

if [[ $? -eq 2 ]]; then
  echo "Aborting: format errors detected. Fix the lines above and rerun." >&2
  exit 2
fi

# Check for duplicates with different pronunciations
awk -F'\t' '
{
    if (seen[$1] && seen[$1] != $2) {
        print "Conflict: word \"" $1 "\" has pronunciations \"" seen[$1] "\" and \"" $2 "\""
        conflict_found = 1
    } else {
        seen[$1] = $2
    }
}
END {
    if (conflict_found) {
        exit 1
    }
}' "$input_file"

# Check if conflicts were found
if [[ $? -eq 1 ]]; then
    echo "Deduplication failed due to conflicting pronunciations."
    read -p "Press Enter to continue..."
    exit 1
fi



sort --unique "$input_file" --output="$input_file"
