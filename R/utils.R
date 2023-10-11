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

.map_standard_to_ulim <- function(standard, scale) {
  switch(
    standard,
    "co_1_hour_1971" = 50,
    "co_8_hour_1971" = 13,
    "so2_1_hour_2010" = 110,
    "no2_1_hour_2010" = 140,
    "no2_annual_1971" = 75,
    "ozone_8_hour_2015" = 0.1,
    "pm10_24_hour_2006" = 220,
    "pm25_24_hour_2012" = 50,
    "pm25_annual_2012" = 18
  )
}


## Custom labelformat for leaflet legend
.labelFormat <- function(prefix = "", suffix = "", between = " &ndash; ",
                         digits = 3, big.mark = ",", transform = identity,
                         trunc_val = NULL) {
    formatNum <- function(x) {
        format(round(transform(x), digits), trim = TRUE, scientific = FALSE,
               big.mark = big.mark)
    }
    function(type, ...) {
      switch(
        type,
        numeric = (function(cuts) {
          ## paste0(prefix, formatNum(cuts), suffix)
          cuts <- sort(cuts, decreasing = TRUE)
          paste0(prefix, formatNum(cuts), ifelse(cuts == trunc_val, "+", ""))
        })(...),
        bin = (function(cuts) {
          n <- length(cuts)
          paste0(prefix, formatNum(cuts[-n]), between, formatNum(cuts[-1]),
                 suffix)
        })(...),
        quantile = (function(cuts, p) {
          n <- length(cuts)
          p <- paste0(round(p * 100), "%")
          cuts <- paste0(formatNum(cuts[-n]), between, formatNum(cuts[-1]))
          paste0("<span title=\"", cuts, "\">", prefix, p[-n],
                 between, p[-1], suffix, "</span>")
        })(...),
        factor = (function(cuts) {
          paste0(prefix, as.character(transform(cuts)), suffix)
        })(...))
    }
}

.colorNumeric <- function (palette, domain, na.color = "#808080", alpha = FALSE, 
                           reverse = FALSE)
{
  rng <- NULL
  if (length(domain) > 0) {
    rng <- range(domain, na.rm = TRUE)
    if (!all(is.finite(rng))) {
      stop("Wasn't able to determine range of domain")
    }
  }
  pf <- safePaletteFunc(palette, na.color, alpha)
  withColorAttr("numeric", list(na.color = na.color), function(x) {
    if (length(x) == 0 || all(is.na(x))) {
      return(pf(x))
    }
    if (is.null(rng))
      rng <- range(x, na.rm = TRUE)
    rescaled <- scales::rescale(x, from = rng)
    if (any(rescaled < 0 | rescaled > 1, na.rm = TRUE))
      warning("Some values were outside the color scale and will be treated as NA")
    if (reverse) {
      rescaled <- 1 - rescaled
    }
    pf(rescaled)
  })
}
