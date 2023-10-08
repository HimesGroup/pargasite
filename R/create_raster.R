create_grid <- function(map_source = c("TIGER", "GADM"),
                        minlat = 24, maxlat = 50, minlon = -124, maxlon = -66,
                        crs = 6350, # CONUS Albers 6350; Puerto Rico 6566
                        cell_size = 10000) {
  map_source <- match.arg(map_source)
  map_crs <- if (map_source == "TIGER") 4269 else 4326 # TL: NAD83; GADM: WGS84
  wkt_filter <- .get_wkt_filter(minlon = minlon, maxlon = maxlon,
                                minlat = minlat, maxlat = maxlat, crs = map_crs)
  if (map_source == "TIGER") {
    us_shape <- get_tl_shape(wkt_filter = wkt_filter)
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

.get_wkt_filter <- function(minlat, maxlat, minlon, maxlon, crs) {
  ## crs argument may not be necessary
  bounding_box <- st_bbox(c(xmin = minlon, xmax = maxlon,
                            ymin = minlat, ymax = maxlat),
                          crs = st_crs(crs))
  st_as_text(st_as_sfc(bounding_box))
}

get_raster <- function(parameter_code, pollutant_standard = NULL,
                       year,  by_month = FALSE,
                       minlat = 24, maxlat = 50, minlon = -124, maxlon = -66,
                       crs = 6350, cell_size = 10000,
                       aqs_email = get_aqs_email(), aqs_key = get_aqs_key(),
                       nmax = 5, download_chunk_size = c("month", "2-week")) {
  ## Check package first; it wouldn't be necessary if raqs is 'imported'.
  if (!requireNamespace("raqs", quietly = TRUE)) {
    stop("Package 'raqs' is not available. Please install and try again.")
  }
  ## Validate parameter code
  parameter_code <- as.character(parameter_code)
  if (length(parameter_code) != 1) {
    stop("Only one parameter code is allowed:")
  }
  if (parameter_code %ni% unique(.criteria_pollutants$parameter_code)) {
    stop(
      "Only the following parameter codes are allowed:\n",
      .capture_df(unique(.criteria_pollutants[, c("parameter_code", "parameter")]))
    )
  }
  ## Validate pollutant standard string
  if (is.null(pollutant_standard)) {
    pollutant_standard <- list_pollutant_standards(parameter_code)$pollutant_standard
  }
  pollutant_standard <- match.arg(
    pollutant_standard,
    list_pollutant_standards(parameter_code)$pollutant_standard,
    several.ok = TRUE
  )
  ## Verify year format
  year <- .verify_year(year)
  ## Create grid
  us_grid <- create_grid(
    minlat = minlat, maxlat = maxlat, minlon = minlon, maxlon = maxlon,
    crs = crs, cell_size = cell_size
  )
  ## Delay between API requests
  if (by_month || length(year) > 1) {
    message("[", getOption("raqs.delay_between_req"),
            "-second delay between API requests]\n")
  }

  ## Underlying function for data processing
  if (length(year) == 1) {
    out <- .get_and_process_aqs_data(
      parameter_code = parameter_code, pollutant_standard = pollutant_standard,
      year = year, by_month = by_month, crs = crs,
      aqs_email = aqs_email, aqs_key = aqs_key,
      minlat = minlat, maxlat = maxlat, minlon = minlon, maxlon = maxlon,
      us_grid = us_grid, nmax = nmax, download_chunk_size = download_chunk_size
    )
    if (is.null(out)) {
      invisible(NULL)
    } else {
      c(out, along = list("year" = year))
    }
  } else {
    out <- .mget_and_process_aqs_data(
      param = parameter_code, pollutant_standard = pollutant_standard,
      year = year, by_month = by_month, crs = crs,
      aqs_email = aqs_email, aqs_key = aqs_key,
      minlat = minlat, maxlat = maxlat, minlon = minlon, maxlon = maxlon,
      us_grid = us_grid, nmax = nmax, download_chunk_size = download_chunk_size
    )
    if (.is_nulllist(out)) {
      return(invisible(NULL))
    }
    nonnull_idx <- sapply(out, Negate(is.null))
    do.call(c, c(setNames(out[nonnull_idx], year[nonnull_idx]), along = "year"))
  }
}

## ## Error handling for NULL
## .get_and_process_aqs_data <- function(parameter_code, pollutant_standard,
##                                       year, by_month, crs,
##                                       aqs_email, aqs_key, minlat, maxlat,
##                                       minlon, maxlon, us_grid, nmax,
##                                       download_chunk_size) {

##   ## Fetching data from AQS
##   message("Processing year: ", year)
##   aqs_variables <- list(
##     email = aqs_email, key = aqs_key, param = parameter_code,
##     bdate = paste0(year, "0101"), edate = paste0(year, "1231"),
##     minlat = minlat, maxlat = maxlat, minlon = minlon, maxlon = maxlon
##   )
##   if (by_month) {
##     date_seq <- .gen_dl_chunk_seq(year, download_chunk_size)
##     d <- Map(function(x, y, z) {
##       aqs_variables <- replace(aqs_variables, c("bdate", "edate"), c(x, y))
##       current_chunk <- paste0(.to_ymd(x), "-", .to_ymd(y))
##       message("- requesting: ", current_chunk)
##       aqs_data <- raqs::aqs_dailydata("byBox", aqs_variables, header = FALSE)
##       if (is.null(aqs_data)) {
##         ## No matched data
##         return(NULL)
##       }
##       aqs_data <- aqs_data[aqs_data$pollutant_standard %in% pollutant_standard, ]
##       aqs_data$month <- format(as.Date(as.character(aqs_data$date_local)), "%m")
##       if (getOption("raqs.delay_between_req") > 0 &&
##           z != length(date_seq$bdate)) {
##         .sys_sleep_pb(getOption("raqs.delay_between_req"))
##       }
##       aqs_data
##     }, date_seq$bdate, date_seq$edate, seq_along(date_seq$bdate),
##     USE.NAMES = FALSE)
##     d <- do.call(rbind, d)
##     if (is.null(d)) {
##       ## No matched data
##       return(NULL)
##     }
##     d <- aggregate(
##       arithmetic_mean ~ latitude + longitude + pollutant_standard + month + datum,
##       FUN = mean, data = d
##     )
##     d <- .aqs_transform(d, target_crs = crs)
##     d <- by(d, d$pollutant_standard, function(x) {
##       out <- by(x, x$month, function(y) .run_idw(y, us_grid, nmax), simplify = FALSE)
##       do.call(c, c(out, along = "month"))
##     }, simplify = FALSE)
##     setNames(do.call(c, d), .make_names(names(d)))
##   } else {
##     d <- raqs::aqs_annualdata("byBox", aqs_variables, header = FALSE)
##     if (is.null(d)) {
##       ## No matched data
##       return(NULL)
##     }
##     d <- d[d$pollutant_standard %in% pollutant_standard, ]
##     d <- aggregate(
##       arithmetic_mean ~ latitude + longitude + pollutant_standard + datum,
##       FUN = mean, data = d
##     )
##     d <- .aqs_transform(d, target_crs = crs)
##     d <- by(d, d$pollutant_standard, function(x) .run_idw(x, us_grid, nmax),
##             simplify = FALSE)
##     setNames(do.call(c, d), .make_names(names(d)))
##   }
## }

## .mget_and_process_aqs_data <- function(parameter_code, pollutant_standard,
##                                        year, by_month, crs,
##                                        aqs_email, aqs_key, minlat, maxlat,
##                                        minlon, maxlon, us_grid, nmax,
##                                        download_chunk_size) {
##   Map(function(x, y) {
##       aqs_data <- .get_and_process_aqs_data(
##         parameter_code = parameter_code, pollutant_standard = pollutant_standard,
##         year = x, by_month = by_month, crs = crs,
##         aqs_email = aqs_email, aqs_key = aqs_key,
##         minlat = minlat, maxlat = maxlat, minlon = minlon, maxlon = maxlon,
##         us_grid = us_grid, nmax = nmax, download_chunk_size = download_chunk_size
##       )
##       if (getOption("raqs.delay_between_req") > 0 && y != length(year)) {
##         .sys_sleep_pb(getOption("raqs.delay_between_req"))
##       }
##       aqs_data
##   }, year, seq_along(year), USE.NAMES = FALSE)
## }

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
