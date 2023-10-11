##' @export
create_pargasite_data <- function(pollutant = c("CO", "SO2", "NO2", "Ozone",
                                                "PM2.5", "PM10"),
                                  event_filter = c("Events Included",
                                                   "Events Excluded",
                                                   "Concurred Events Excluded"),
                                  year, by_month = FALSE, cell_size = 10000,
                                  nmax = Inf, aqs_email = get_aqs_email(),
                                  aqs_key = get_aqs_key(),
                                  download_chunk_size = c("2-week", "month")) {
  ## Verify pollutant input
  pollutant <- match.arg(pollutant)
  ## Convert string to param code
  parameter_code <- .map_pollutant_to_param(pollutant)
  ## Create raster for US CONUS in EPSG 6350 (NAD83 / Conus Albers)
  create_raster(
    parameter_code = parameter_code, year = year, by_month = by_month,
    cell_size = cell_size, nmax = nmax,
    download_chunk_size = download_chunk_size
  )
}

## This is a more general version of raster creation function with a
## user-specified bounding box.
create_raster <- function(parameter_code, pollutant_standard = NULL,
                          event_filter = c("Events Included", "Events Excluded",
                                           "Concurred Events Excluded"),
                          year,  by_month = FALSE,
                          minlat = 24, maxlat = 50, minlon = -124, maxlon = -66,
                          crs = 6350, cell_size = 10000,
                          aqs_email = get_aqs_email(), aqs_key = get_aqs_key(),
                          nmax = 5, download_chunk_size = c("2-week", "month")) {
  ## Check package first; it wouldn't be necessary if raqs is 'imported'.
  ## if (!requireNamespace("raqs", quietly = TRUE)) {
  ##   stop("Package 'raqs' is not available. Please install and try again.")
  ## }
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
  ## Verify event handle
  event_filter <- match.arg(event_filter)
  ## Verify year format
  year <- .verify_year(year)
  ## Verify cell size
  .is_nonnegative_number(cell_size)
  ## Create grid
  us_grid <- .create_grid(
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
      event_filter = event_filter, year = year, by_month = by_month, crs = crs,
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
      event_filter = event_filter, year = year, by_month = by_month, crs = crs,
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
