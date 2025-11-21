# Patching an MFA pronunciation dictionary

In this document, we show how to patch an MFA pronunciation dictionary.
For this example, our patches to the dictionary are in the file 
`english_us_arpa_patch.dict`.


## Identifying out-of-vocabulary words

In the MFA project (wherever we are running the `mfa` commands from 
for forced alignment), we check the corpus for out-of-vocabulary (OOV)
words. These are words that are not in the pronunciation dictionary:

```bash
mfa find_oovs 00-data english_us_arpa . --use_mp
```

In this example, `00-data` is the name of the folder that we want 
to force align. The final `.` is for the output directory, and using `.` 
tells MFA to drop the files with the OOV information in the current folder.


## Inspecting the dictionary and its patch

We force a fresh download of the English US pronunciation dictionary. 
`--ignore_cache` forces the download:

```bash
mfa model download dictionary english_us_arpa --ignore_cache
```

Assuming that MFA set up its cache folder in the user's `Documents`
folder, we can read in the dictionary file into R.

```{r}
path_mfa_dict <- fs::path_home(
  "Documents/MFA/pretrained_models/dictionary/english_us_arpa.dict"
)

file.exists(path_mfa_dict)
file.mtime(path_mfa_dict)
file.size(path_mfa_dict)
```

The dictionary file is a nonstandard tab-separated data file because
the number of columns may differ from line to line. We can get around
this quirk by counting tabs and processing the batches of lines 
separately.

```{r}
library(tidyverse)

lines <- path_mfa_dict |> 
  readr::read_lines()

data_dict <- lines |> 
  split(stringr::str_count(lines, "\t")) |> 
  # read the character vectors as literal lines of data
  lapply(I) |> 
  lapply(readr::read_tsv, col_names = FALSE, show_col_types = FALSE) |> 
  lapply(select, where(is.character)) |> 
  lapply(setNames, c("word", "pronunciation")) |> 
  dplyr::bind_rows()
```

We can see that our patched words are not in the pronunciation dictionary:

```{r}
data_patch <- readr::read_tsv(
  "mfa/english_us_arpa_patch.dict", 
  col_names = c("word", "pronunciation")
)
intersect(data_dict, data_patch)
```


## Patching the dictionary

We can download the patched pronunciations from GitHub if we need them in an 
MFA project:

```bash
curl -s https://raw.githubusercontent.com/WISCLab/dictfix/master/mfa/english_us_arpa_patch.dict > english_us_arpa_patch.dict
```

Add the patched words to the pronunciation dictionary:

```bash
mfa model add_words english_us_arpa english_us_arpa_patch.dict
```

We can confirm that the words are now in the dictionary by reading in the
same dictionary file as before and comparing to the previous dictionary:

```{r}
lines2 <- path_mfa_dict |> 
  readr::read_lines()

data_dict_new <- lines2 |> 
  split(stringr::str_count(lines2, "\t")) |> 
  lapply(I) |> 
  lapply(readr::read_tsv, col_names = FALSE, show_col_types = FALSE) |> 
  lapply(select, where(is.character)) |> 
  lapply(setNames, c("word", "pronunciation")) |> 
  dplyr::bind_rows()

setdiff(data_dict_new, data_dict)
```

Now we can try to check the corpus again. We want this step to take as long as 
the first time we ran it. (If it goes too quickly, MFA might be using a cached 
version of the corpus.)

```bash
mfa find_oovs 00-data english_us_arpa . --use_mp
```

Be sure to check the output files to see if the listed OOVs are different.
If the number of OOVs did not decrease, try cleaning out the cache for the corpus 
in the MFA cache folder. For this example, it would be the 
directory `~/Documents/MFA/00-data`. 
