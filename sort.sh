#!/bin/bash

input_file="DictFix.txt"
conflict_found=false

# Sort the file and check for duplicates with different pronunciations
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
