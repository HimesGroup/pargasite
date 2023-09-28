## Not in
"%ni%" <- function(x, table) match(x, table, nomatch = 0L) == 0L

## Check list with all NULL values
.is_nulllist <- function(x) all(sapply(x, is.null))

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
  cli::cli_progress_bar(format = "Waiting {x}s {cli::pb_bar}", total = x)
  for (i in seq_len(x)) {
    Sys.sleep(1)
    cli::cli_progress_update()
  }
  cli::cli_progress_done()
  invisible()
}

## Check 4-digit year input
.verify_year <- function(x) {
  x <- as.character(x)
  ## First 4 characters are used to define year
  year <- format(as.Date(x, format = "%Y"), format = "%Y")
  ## consider year can be a vector
  is_invalid <- nchar(x) != 4 | is.na(year)
  if (any(is_invalid)) {
    stop("Invalid year(s). Please use 'YYYY' format.")
  }
  x
}

## Generate sequence of dates to slice a time interval for AQS data download
.gen_dl_chunk_seq <- function(year, download_chunk_size = c("month", "2-week")) {
  download_chunk_size <- match.arg(download_chunk_size)
  begin_date <- as.Date(paste0(year, "-01-01"))
  begin_seq <- seq(as.Date(paste0(year, "-01-01")),
                   length.out = 12, by = "month")
  end_seq <- seq(as.Date(paste0(year, "-01-31")) + 1,
                 length.out = 12, by = "month") - 1
  if (download_chunk_size == "2-week") {
    end_seq <- sort(c(end_seq, begin_seq + 14))
    begin_seq <- sort(c(begin_seq, begin_seq + 15))
  }
  ## Re-format to YYYYMMDD
  begin_seq <- format(begin_seq, "%Y%m%d")
  end_seq <- format(end_seq, "%Y%m%d")
  list(bdate = begin_seq, edate = end_seq)
}

.to_ymd <- function(yyyymmdd) {
  sub("(\\d{4})(\\d{2})(\\d{2})", "\\1/\\2/\\3", yyyymmdd)
}

