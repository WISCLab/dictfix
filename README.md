# dictfix

Corrections to our phonetic dictionary


## Notes

How to sort the file in git bash. I use an intermediate file to avoid 
[messing with the original](http://swcarpentry.github.io/shell-novice/04-pipefilter/index.html#redirecting-to-the-same-file).

```
Tristan@HONEYCOMB MINGW64 ~/Desktop
$ cat DictFix.txt | sort > DictFix-temp.txt

Tristan@HONEYCOMB MINGW64 ~/Desktop
$ mv DictFix-temp.txt DictFix.txt
```

How to download the file using the command line.

```
Tristan@HONEYCOMB MINGW64 ~/Desktop
$ curl -s https://raw.githubusercontent.com/tjmahr/dictfix/master/DictFix.txt > DictFix.txt
```

## TODO

Add phonological symbol definitions...
