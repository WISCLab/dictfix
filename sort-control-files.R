#!/usr/bin/env Rscript

# This script sorts out completed or incompatible files from a folder of
# control files for ShowAndTell.

args <- commandArgs(trailingOnly = TRUE)

if (!requireNamespace("rlang", quietly = TRUE)) {
  stop("'rlang' package is required but is not installed. Please install it using `install.packages('rlang')`.")
}
rlang::check_installed(c("fs", "stringr", "cli"))

if (length(args) == 0) {
  cli::cli_abort(c(
    i = "Script usage: sort-control-files.R {.arg {'input_folder'}}",
    x = "No {.arg {'input_folder'}} provided"
  ))
}


stash_listener_backgrounds <- function(input_folder) {
  bg_dir <- file.path(input_folder, "listener_backgrounds")
  fs::dir_create(bg_dir)

  moved_files <- input_folder |>
    fs::dir_ls(
      type = "file",
      regexp = "listener_background.+[.]txt"
    ) |>
    fs::file_move(bg_dir)

  cli::cli_inform(c(
    "Moving listener background files:",
    "v" = "Moved {length(moved_files)} file{?s} to {.path {bg_dir}}"
  ))

  invisible(moved_files)
}


stash_completed_files <- function(input_folder) {
  parse_control_file_filename <- function(paths) {
    regex <- "(?<prefix>.+)(?<filetype>[-#!=%]|!!)(?<number>\\d+)(?<virtual>v?).(?<ext>.+$)"
    data_paths <- paths |>
      stringr::str_match(regex) |>
      as.data.frame()
    if (nrow(data_paths)) {
      data_paths$family = paste0(
        data_paths$prefix,
        "-",
        data_paths$number,
        data_paths$virtual,
        ".txt"
      )
    } else {
      data_paths$family <- character(0)
    }
    data_paths
  }

  done_dir <- file.path(input_folder, "done")
  fs::dir_create(done_dir)

  cli::cli_inform("Moving completed files:")

  data_control_files <- input_folder |>
    fs::dir_ls(type = "file", regexp = "\\d+v?[.]\\w+") |>
    parse_control_file_filename()

  # .bak files are backup files created by ShowAndTell as it processes
  # a control file. They are cleared when the file is done being processed.
  # So, a .bak file means that ShowAndTell did not finish a file successfully.
  data_bak <- data_control_files |> subset(ext == "bak")
  data_bak_family <- data_control_files |>
    subset(family %in% unique(data_bak$family))

  if (nrow(data_bak) > 0) {
    cli::cli_inform(c(
      "!" = "Found {nrow(data_bak)} file{?s} with .bak extension",
      cli_list(data_bak$V1),
      "i" = "Skipping {nrow(data_bak_family)} file{?s} related to .bak file{?s}"
    ))
  }

  data_control_files <- data_control_files |>
    subset(! family %in% unique(data_bak$family))

  # "=" files are created by ShowAndTell so they provide a sign that the file
  # has been processed by ShowAndTell.
  # TODO: If a "-" file is replaced, then an "=" is outdated, so this heuristic
  # is inaccurate.
  data_completed_files <- data_control_files |> subset(filetype == "=")
  data_completed_files_family <- data_control_files |>
    subset(family %in% unique(data_completed_files$family))

  result <- fs::file_move(data_completed_files_family$V1, done_dir)
  leftover <- fs::dir_ls(input_folder, type = "file", regexp = "\\d+v?[.]txt")

  cli::cli_inform(c(
    "v" = "Moved {length(result)} file{?s} to {.path {done_dir}}",
    "{length(leftover)} file{?s} currently in {.path {done_dir}}"
  ))

  invisible(result)
}

cli_list <- function(paths, max_items = 10, style = ".file") {
  pattern <- paste0("{", style, " %s}")
  if (length(paths) > max_items) {
    part1 <- utils::head(paths, max_items %/% 2)
    part2 <- utils::tail(paths, (max_items %/% 2) - 1)
    c(sprintf(pattern, part1), "…", sprintf(pattern, part2))
  } else {
    sprintf(pattern, paths)
  }
}

input_folder <- args[1]
stash_listener_backgrounds(input_folder)
stash_completed_files(input_folder)
