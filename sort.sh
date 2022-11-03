#! /bin/bash
cat DictFix.txt | sort | uniq > d.txt
mv d.txt DictFix.txt
