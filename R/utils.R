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
  cli::cli_progress_bar(format = "Waiting {x}s {cli::pb_bar}", total = x)
  for (i in seq_len(x)) {
    Sys.sleep(1)
    cli::cli_progress_update()
  }
  cli::cli_progress_done()
  invisible()
}

## Year format
.to_ymd <- function(yyyymmdd) {
  sub("(\\d{4})(\\d{2})(\\d{2})", "\\1/\\2/\\3", yyyymmdd)
}

.map_standard_to_ulim <- function(standard, scale = 1) {
  switch(
    standard,
    ## "co_1_hour_1971" = 50,
    ## "co_8_hour_1971" = 13,
    ## "so2_1_hour_2010" = 110,
    ## "no2_1_hour_2010" = 140,
    ## "no2_annual_1971" = 75,
    ## "ozone_8_hour_2015" = 0.1,
    ## "pm10_24_hour_2006" = 220,
    ## "pm25_24_hour_2012" = 50,
    ## "pm25_annual_2012" = 18
    "co_1_hour_1971" = 35 * scale,
    "co_8_hour_1971" = 9 * scale,
    "so2_1_hour_2010" = 75 * scale,
    "no2_1_hour_2010" = 100 * scale,
    "no2_annual_1971" = 53 * scale,
    "ozone_8_hour_2015" = 0.07 * scale,
    "pm10_24_hour_2006" = 150 * scale,
    "pm25_24_hour_2012" = 35 * scale,
    "pm25_annual_2012" = 9 * scale
  )
}
