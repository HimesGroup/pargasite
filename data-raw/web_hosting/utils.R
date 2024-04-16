## month20km <- c(
##   c(ozone20km, along = list("month" = "12")),
##   c(ozone20km, along = list("month" = "11")),
##   along = "month"
## )

## Not in
"%ni%" <- function(x, table) match(x, table, nomatch = 0L) == 0L

## Check list with all NULL values
.is_nulllist <- function(x) all(sapply(x, is.null))

## `make.names` with underscore
.make_names <- function(names, ...) {
  gsub("\\.", "_", tolower(make.names(names = names, ...)))
}

## Print data.frame in error message
.capture_df <- function(x) paste(capture.output(x), collapse = "\n")

## Verify non-negativity of integer value
.is_nonnegative_number <- function(x) {
  x <- suppressWarnings(as.numeric(x))
  if (!is.numeric(x) || is.na(x) || x < 0L || length(x) != 1L) {
    stop("Please use a non-negative number of length 1.")
  }
}

## Sleep function with progress bar for API request
.sys_sleep_pb <- function(x) {
  .is_nonnegative_number(x)
  x <- round(x)
  if (x == 0) return(invisible())
  cli_progress_bar(format = "Waiting {x}s {cli::pb_bar}", total = x)
  for (i in seq_len(x)) {
    Sys.sleep(1)
    cli_progress_update()
  }
  cli_progress_done()
  invisible()
}

## Year format
.to_ymd <- function(yyyymmdd) {
  sub("(\\d{4})(\\d{2})(\\d{2})", "\\1/\\2/\\3", yyyymmdd)
}
