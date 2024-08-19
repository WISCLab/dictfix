# dictfix

Corrections to our phonetic dictionary.

As part of our intelligibility computation pipeline, we convert English words into 
their pronunciations using an automatic *grapheme-to-phoneme* conversion step. We 
can provide the converter with a list of "dictionary fixes" to specify how to 
convert specific words. This repository houses that list of exceptions. 

## Notes

When I update the list, I just put the new entries on the bottom and then sort the 
file. Here's how to sort the file in git bash:

```
Tristan@HONEYCOMB MINGW64 ~/Desktop
$ sort --unique DictFix.txt --output DictFix.txt
```

How to download the file using the command line.

```
Tristan@HONEYCOMB MINGW64 ~/Desktop
$ curl -s https://raw.githubusercontent.com/WISCLab/dictfix/master/DictFix.txt > DictFix.txt
```
