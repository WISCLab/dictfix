# dictfix

`DictFix.txt`: Corrections to our phonetic dictionary.

As part of our intelligibility computation pipeline, we convert English words 
into their pronunciations using an automatic *grapheme-to-phoneme* conversion 
step. We can provide the converter with a list of "dictionary fixes" to specify 
how to convert certain words. This repository houses that list of exceptions in 
the file `DictFix.txt`. 


## Notes

When I update the list, I just put the new entries on the bottom and then sort
the file. The included bash script `sort.sh` sorts the dictionary file,
 checks for duplicate entries with *conflicting* pronunciations, and validates
the format of the entries.

```
./sort.sh
```

One can also just sort and deduplicate with the built-in sort.

```
sort --unique DictFix.txt --output DictFix.txt
```

To download the latest dictionary from GitHub, use the following:

```
curl -s https://raw.githubusercontent.com/WISCLab/dictfix/master/DictFix.txt > DictFix.txt
```


## Extras

The directory `mfa` includes an additional set of pronunciation fixes for the 
dictionary provided by the Montreal Forced Aligner. It has its own README.md 
file.

Scripts:

`util-unzip-files.sh` will unzip all .zip files in a directory. Control files 
from the lab's database come in .zip files so this script automates the task of 
unzipping all of the files in a folder.

`util-delete-empty-rating-files.sh` is a helper for dealing with
listening experiment data downloaded from our lab's database. It deletes a 
listener rating files when they contain 0 rows. (They should not contain 
0 rows --- so it's a sign that data is missing somewhere.) It's useful to have
around when running ShowAndTell on a large number of files. 
