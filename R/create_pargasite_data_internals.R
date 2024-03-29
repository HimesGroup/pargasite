.map_pollutant_to_param <- function(pollutant) {
  switch(pollutant,
         "CO" = "42101", "SO2" = "42401", "NO2" = "42602",
         "Ozone" = "44201", "PM10" = "81102", "PM2.5" = "88101")
}

.map_param_to_standard <- function(param) {
  idx <- .criteria_pollutants$parameter == param
  .criteria_pollutants$pollutant_standard[idx]
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

.create_grid <- function(map_source = c("TIGER", "GADM"),
                         minlat = 24, maxlat = 50, minlon = -124, maxlon = -66,
                         crs = 6350, # CONUS Albers 6350; Puerto Rico 6566
                         cell_size = 10000) {
  map_source <- match.arg(map_source)
  map_crs <- if (map_source == "TIGER") 4269 else 4326 # TL: NAD83; GADM: WGS84
  wkt_filter <- .get_wkt_filter(minlon = minlon, maxlon = maxlon,
                                minlat = minlat, maxlat = maxlat, crs = map_crs)
  if (map_source == "TIGER") {
    ## Use cartographic boundary file instead of TL due to plot loading time
    us_shape <- get_tl_shape(url = .get_carto_url("state"),
                             wkt_filter = wkt_filter)
  } else {
    us_shape <- get_gadm_shape(admin_level = 2, wkt_filter = wkt_filter)
    us_shape <- us_shape[us_shape$ENGTYPE_2 != "Water body", ]
  }
  ## Use projected coordinate for grid creation and interpolation Be aware that
  ## IDW depends on distance as a way of establishing relationships; distance in
  ## geographic coordinate can vary as we move along latitude.
  us_shape <- st_as_sfc(st_transform(us_shape, crs))
  st_as_stars(st_bbox(us_shape), dx = cell_size, dy = cell_size) |>
    st_crop(us_shape)
}

.get_and_process_aqs_data <- function(parameter_code, pollutant_standard,
                                      event_filter, year, by_month, crs,
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
      aqs_data <- aqs_data[aqs_data$event_type %in% c(event_filter, "No Events"), ]
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
    ## d <- aggregate(
    ##   arithmetic_mean ~ latitude + longitude + pollutant_standard + month + datum,
    ##   FUN = mean, data = d
    ## )
    ## d <- .aqs_transform(d, target_crs = crs)
    d <- by(d, d$pollutant_standard, function(x) {
      out <- by(x, x$month, function(y) {
        out <- lapply(event_filter, function(z) {
          y <- y[y$event_type %in% c(z, "No Events"), ]
          y <- aggregate(arithmetic_mean ~ latitude + longitude + datum,
                         FUN = mean, data = y)
          y <- .aqs_transform(y, target_crs = crs)
          .run_idw(y, us_grid, "arithmetic_mean", nmax)
        })
        names(out) <- event_filter
        do.call(c, c(out, along = "event"))
      }, simplify = FALSE)
      do.call(c, c(out, along = "month"))
    }, simplify = FALSE)
    setNames(do.call(c, d), .make_names(names(d)))
  } else {
    d <- raqs::aqs_annualdata("byBox", aqs_variables, header = FALSE)
    if (is.null(d)) {
      ## No matched data
      return(NULL)
    }
    d <- d[d$pollutant_standard %in% pollutant_standard, ]
    d <- d[d$event_type %in% c(event_filter, "No Events"), ]
    d <- by(d, d$pollutant_standard, function(x) {
      field <- .map_standard_to_field(unique(x$pollutant_standard))
      out <- lapply(event_filter, function(y) {
        x <- x[x$event_type %in% c(y, "No Events"), ]
        aggr_fml <- as.formula(paste0(field, " ~ latitude + longitude + datum"))
        x <- aggregate(aggr_fml, FUN = mean, data = x)
        x <- .aqs_transform(x, target_crs = crs)
        .run_idw(x, us_grid, field, nmax)
      })
      names(out) <- event_filter
      do.call(c, c(out, along = "event"))
      ## aggr_fml <- as.formula(paste0(field, " ~ latitude + longitude + datum"))
      ## x <- aggregate(aggr_fml, FUN = mean, data = x)
      ## x <- .aqs_transform(x, target_crs = crs)
      ## .run_idw(x, us_grid, field, nmax)
    }, simplify = FALSE)
    setNames(do.call(c, d), .make_names(names(d)))
  }
}


.mget_and_process_aqs_data <- function(parameter_code, pollutant_standard,
                                       event_filter, year, by_month, crs,
                                       aqs_email, aqs_key, minlat, maxlat,
                                       minlon, maxlon, us_grid, nmax,
                                       download_chunk_size) {
  Map(function(x, y) {
    aqs_data <- .get_and_process_aqs_data(
      parameter_code = parameter_code, pollutant_standard = pollutant_standard,
      event_filter = event_filter, year = x, by_month = by_month, crs = crs,
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


.get_wkt_filter <- function(minlat, maxlat, minlon, maxlon, crs) {
  ## crs argument may not be necessary
  bounding_box <- st_bbox(c(xmin = minlon, xmax = maxlon,
                            ymin = minlat, ymax = maxlat),
                          crs = st_crs(crs))
  st_as_text(st_as_sfc(bounding_box))
}

.aqs_transform <- function(x, target_crs = 6350) {
  x <- by(x, x$datum, function(y) {
    source_crs <- st_crs(.datum_to_epsg(unique(y$datum)))
    st_as_sf(y, coords = c("longitude", "latitude"), crs = source_crs) |>
      st_transform(target_crs)
  }, simplify = FALSE)
  x <- do.call(rbind, x)
  ## rownames(x) <- NULL # reset rownames
  x[, names(x) %ni% "datum"]
}

.datum_to_epsg <- function(x) {
  switch(x, "NAD83" = 4269, "NAD27" = 4267, "WGS84" = 4326)
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
.gen_dl_chunk_seq <- function(year, download_chunk_size = c("2-week", "month")) {
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
