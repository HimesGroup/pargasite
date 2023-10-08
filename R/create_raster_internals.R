.map_param_to_standard <- function(param) {
  idx <- .criteria_pollutants$parameter == param
  .criteria_pollutants$pollutant_standard[idx]
}

.map_standard_to_field <- function(standard) {
  switch(
    standard,
    "CO 1-hour 1971" = "second_max_value",
    "CO 8-hour 1971" = "second_max_nonoverlap_value",
    "SO2 1-hour 2010" = "ninety_ninth_percentile",
    "NO2 1-hour 2010" = "ninety_eighth_percentile",
    "NO2 Annual 1971" = "arithmetic_mean",
    "Ozone 8-hour 2015" = "fourth_max_value",
    "PM10 24-hour 2006" = "primary_exceedance_count",
    "PM25 24-hour 2012" = "ninety_eighth_percentile",
    "PM25 Annual 2012" = "arithmetic_mean"
  )
}

## CO 1-hour: annual second maximum nonoverlapping 1-hour average; second_max_value
## CO 8-hour: annual second maximum nonoverlapping 8-hour average; second_max_nonoverlap_value
## SO2 1-hour: annual 99th percentile of the daily maximum 1-hour concentration; ninety_ninth_percentile
## NO2 1-hour: annual 98th percentile of the daily maximum 1-hour concentration values; ninety_eighth_percentile
## NO2 Annual: annual average of the hourly concentration values; arithmetic_mean
## Ozone 8-hour: annual 4th highest daily maximum 8-hour ozone concentration; fourth_max_value
## PM10 24-hour 2006: annual estimated number of exceedances; primary_exceedance_count
## PM25 24-hour 2012: annual 98th percentile concentration; ninety_eighth_percentile
## PM25 Annual 2012: annual mean concentration; arithmetic_mean
## Lead 3-Month 2009: too few site; exclude

.get_and_process_aqs_data <- function(parameter_code, pollutant_standard,
                                      value_column, year, by_month, crs,
                                      aqs_email, aqs_key, minlat, maxlat,
                                      minlon, maxlon, us_grid, nmax,
                                      download_chunk_size) {

  ## Fetching data from AQS
  message("Processing year: ", year)
  aqs_variables <- list(
    email = aqs_email, key = aqs_key, param = parameter_code,
    bdate = paste0(year, "0101"), edate = paste0(year, "1231"),
    minlat = minlat, maxlat = maxlat, minlon = minlon, maxlon = maxlon
  )
  if (by_month) {
    date_seq <- .gen_dl_chunk_seq(year, download_chunk_size)
    d <- Map(function(x, y, z) {
      aqs_variables <- replace(aqs_variables, c("bdate", "edate"), c(x, y))
      current_chunk <- paste0(.to_ymd(x), "-", .to_ymd(y))
      message("- requesting: ", current_chunk)
      aqs_data <- raqs::aqs_dailydata("byBox", aqs_variables, header = FALSE)
      if (is.null(aqs_data)) {
        ## No matched data
        return(NULL)
      }
      aqs_data <- aqs_data[aqs_data$pollutant_standard %in% pollutant_standard, ]
      aqs_data <- aqs_data[aqs_data$event_type %in% c("Events Excluded", "No Events"), ]
      aqs_data$month <- format(as.Date(as.character(aqs_data$date_local)), "%m")
      if (getOption("raqs.delay_between_req") > 0 &&
          z != length(date_seq$bdate)) {
        .sys_sleep_pb(getOption("raqs.delay_between_req"))
      }
      aqs_data
    }, date_seq$bdate, date_seq$edate, seq_along(date_seq$bdate),
    USE.NAMES = FALSE)
    d <- do.call(rbind, d)
    if (is.null(d)) {
      ## No matched data
      return(NULL)
    }
    d <- aggregate(
      arithmetic_mean ~ latitude + longitude + pollutant_standard + month + datum,
      FUN = mean, data = d
    )
    d <- .aqs_transform(d, target_crs = crs)
    d <- by(d, d$pollutant_standard, function(x) {
      out <- by(x, x$month, function(y) .run_idw(y, us_grid, "arithmetic_mean", nmax), simplify = FALSE)
      do.call(c, c(out, along = "month"))
    }, simplify = FALSE)
    setNames(do.call(c, d), .make_names(names(d)))
    ## d <- by(d, d$pollutant_standard, function(x) {
    ##   field <- .map_standard_to_field(unique(x$pollutant_standard))
    ##   aggr_fml <- as.formula(paste0(
    ##     field, " ~ latitude + longitude + month + datum"
    ##   ))
    ##   x <- aggregate(aggr_fml, FUN = mean, data = x)
    ##   x <- .aqs_transform(x, target_crs = crs)
    ##   out <- by(x, x$month, function(y) .run_idw(y, us_grid, field, nmax), simplify = FALSE)
    ##   do.call(c, c(out, along = "month"))
    ## }, simplify = FALSE)
    ## setNames(do.call(c, d), .make_names(names(d)))
  } else {
    d <- raqs::aqs_annualdata("byBox", aqs_variables, header = FALSE)
    if (is.null(d)) {
      ## No matched data
      return(NULL)
    }
    d <- d[d$pollutant_standard %in% pollutant_standard, ]
    d <- d[d$event_type %in% c("Events Excluded", "No Events"), ]
    ## d <- aggregate(
    ##   arithmetic_mean ~ latitude + longitude + pollutant_standard + datum,
    ##   FUN = mean, data = d
    ## )
    ## d <- .aqs_transform(d, target_crs = crs)
    d <- by(d, d$pollutant_standard, function(x) {
      field <- .map_standard_to_field(unique(x$pollutant_standard))
      aggr_fml <- as.formula(paste0(field, " ~ latitude + longitude + datum"))
      x <- aggregate(aggr_fml, FUN = mean, data = x)
      x <- .aqs_transform(x, target_crs = crs)
      .run_idw(x, us_grid, field, nmax)
    }, simplify = FALSE)
    setNames(do.call(c, d), .make_names(names(d)))
  }
}


.mget_and_process_aqs_data <- function(parameter_code, pollutant_standard,
                                       year, by_month, crs,
                                       aqs_email, aqs_key, minlat, maxlat,
                                       minlon, maxlon, us_grid, nmax,
                                       download_chunk_size) {
  Map(function(x, y) {
    aqs_data <- .get_and_process_aqs_data(
      parameter_code = parameter_code, pollutant_standard = pollutant_standard,
      year = x, by_month = by_month, crs = crs,
      aqs_email = aqs_email, aqs_key = aqs_key,
      minlat = minlat, maxlat = maxlat, minlon = minlon, maxlon = maxlon,
      us_grid = us_grid, nmax = nmax, download_chunk_size = download_chunk_size
    )
    if (getOption("raqs.delay_between_req") > 0 && y != length(year)) {
      .sys_sleep_pb(getOption("raqs.delay_between_req"))
    }
    aqs_data
  }, year, seq_along(year), USE.NAMES = FALSE)
}


## mozone <- get_raster(44201, NULL, year = 2020:2022, nmax = Inf, cell_size = 10000)
## mozone <- get_raster(44201, NULL, year = 2022, nmax = Inf, cell_size = 10000, by_month = TRUE, download_chunk_size = "2-week")
## mno2 <- get_raster(42602, NULL, year = 2005:2007, nmax = 10, cell_size = 20000)
## .yy <- c(mozone, mno2)

