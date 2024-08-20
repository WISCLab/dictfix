# dictfix

`DictFix.txt`: Corrections to our phonetic dictionary.

As part of our intelligibility computation pipeline, we convert English words into 
their pronunciations using an automatic *grapheme-to-phoneme* conversion step. We 
can provide the converter with a list of "dictionary fixes" to specify how to 
convertcertain words. This repository houses that list of exceptions in the 
file `DictFix.txt`. 

## Notes

When I update the list, I just put the new entries on the bottom and then sort the 
file. Here's how to sort the file in git bash:

```
sort --unique DictFix.txt --output DictFix.txt
```

How to download the file using the command line:

```
curl -s https://raw.githubusercontent.com/WISCLab/dictfix/master/DictFix.txt > DictFix.txt
```
