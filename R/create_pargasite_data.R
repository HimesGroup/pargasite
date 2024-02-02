##' Create a data cube for air pollutant levels covering the conterminous US
##'
##' A function to create a raster-based pollutant concentration input for
##' PARGASITE's shiny application. It downloads pollutant data via the
##' Environmental Protection Agency's (EPA) Air Quality System (AQS) API
##' service, filters the data by exceptional event (e.g., wildfire) status, and
##' performs the inverse distance weighted (IDW) interpolation to estimate
##' pollutant concentrations covering the conterminous United States (CONUS) at
##' user-defined time ranges.
##'
##' By default, it returns yearly-summarized concentrations using AQS's annual
##' data but can also provide monthly-summarized concentrations by aggregating
##' AQS's daily data. Note that the function chooses an appropriate data field
##' for each pollutant to check the air quality status based on the National
##' Ambient Air Quality Standard (NAAQS) for yearly-summarized outputs as
##' follows
##'
##' - CO 1-hour: `second_max_value` field
##' - CO 8-hour: `second_max_nonoverlap` field
##' - SO2 1-hour: `ninety_ninth_percentile` field
##' - NO2 1-hour: `nineth_eighth_percentile` field
##' - NO2 Annual: `arithmetic mean` field
##' - Ozone 8-hour: `fourth_max_value` field
##' - PM10 24-hour: `primary_exceedance_count` field
##' - PM25 24-hour: `ninety_eighth_percentile` field
##' - PM25 Annual: `arithmetic_mean` field
##'
##' For monthly-summarized outputs, it uses the `arithmetic_mean` field of daily
##' data. Please check AQS API `metaData/fieldsByService` (see
##' [raqs::metadata_fieldsbyservice]) and
##' \href{https://aqs.epa.gov/aqsweb/documents/AQS_Data_Dictionary.html}{AQS
##' data dictionary} for the details of field descriptions.
##'
##' For spatial interpolation, the AQS data is projected to EPSG:6350 (NAD83
##' CONUS Albers), and thus, `cell_size` value is represented in meters (5,000
##' creates 5km x 5km grid). The smaller `cell_size`, the more processing time
##' is required.
##'
##' @param pollutant A string specifying an air pollutant to create a raster
##'   data cube. Must be one of CO2, SO2, NO2, Ozone, PM2.5 and PM10.
##' @param data_field A vector of strings specifying whether which data fields
##'   are used to summarize the data. Must be either 'NAAQS statistic',
##'   'arithmetic_mean', or both. 'NAAQS_statistic' try to chooses an
##'   appropriate field based on National Ambient Air Quality Standards (NAAQS)
##'   in the AQS yearly data (e.g, for CO 1-hour average, 'second_max_value'
##'   would be chosen). 'arithmetic_mean' represents the measure of central
##'   tendency in the yearly data. Ignored when `by_month = TRUE`.
##' @param event_filter A vector of strings indicating whether data measured
##'   during exceptional events are included in the summary. 'Events Included'
##'   means that events occurred and the data from theme is included in the
##'   summary. 'Events Excluded' means that events occurred but data from them
##'   is excluded from the summary. 'Concurred Events Excluded' means that
##'   events occurred but only EPA concurred exclusions are removed from the
##'   summary. If multiple values are specified, pollutant levels for each
##'   filter are stored in `event` dimension in the resulting output.
##' @param year A vector of 4-digit numeric values specifying years to retrieve
##'   pollutant levels.
##' @param by_month A logical value indicating whether data summarized at
##'   monthly level instead of yearly level.
##' @param cell_size A numeric value specifying a cell size of grid cells in
##'   meters.
##' @param nmax An integer value specifying the number of nearest observations
##'   that should be used for spatial interpolation.
##' @param aqs_email A string specifying the registered email for AQS API
##'   service.
##' @param aqs_key A string specifying the registered key for AQS API service.
##' @param download_chunk_size A string specifying a chunk size for AQS API
##'   daily data download to prevent an unexpected server timeout error. Ignored
##'   when `by_month = FALSE`.
##'
##' @return A stars object containing the interpolated pollutant levels.
##'
##' @examples
##'\dontrun{
##'
##' ## Set your AQS API key first using [raqs::set_aqs_user] to run the example.
##'
##' ## SO2 and CO concentrations through 2020 to 2022
##' so2 <- create_pargasite_data("SO2", "Events Included", year = 2020:2022)
##' co <- create_pargasite_data("CO", "Events Included", year = 2020:2022)
##'
##' ## Combine them; can combine other pollutant grids in the same way
##' pargasite_input <- c(so2, co)
##' }
##'
##' @export
create_pargasite_data <- function(pollutant = c("CO", "SO2", "NO2", "Ozone",
                                                "PM2.5", "PM10"),
                                  data_field = c("NAAQS_statistic",
                                                 "arithmetic_mean"),
                                  event_filter = c("Events Included",
                                                   "Events Excluded",
                                                   "Concurred Events Excluded"),
                                  year, by_month = FALSE, cell_size = 5000,
                                  nmax = Inf, aqs_email = get_aqs_email(),
                                  aqs_key = get_aqs_key(),
                                  download_chunk_size = c("2-week", "month")) {
  ## Verify pollutant input
  pollutant <- match.arg(pollutant)
  ## Verify data field to use
  data_field <- match.arg(
    data_field, c("NAAQS_statistic", "arithmetic_mean"), several.ok = TRUE
  )
  ## Verify event handler
  event_filter <- match.arg(
    event_filter,
    c("Events Included", "Events Excluded", "Concurred Events Excluded"),
    several.ok = TRUE
  )
  ## Verify year format
  year <- .verify_year(year)
  ## Verify cell size
  .is_nonnegative_number(cell_size)
  ## Convert string to param code
  parameter_code <- .map_pollutant_to_param(pollutant)
  ## Create raster for US CONUS in EPSG 6350 (NAD83 / Conus Albers)
  create_raster(
    parameter_code = parameter_code, data_field = data_field,
    event_filter = event_filter, year = year, by_month = by_month,
    cell_size = cell_size, nmax = nmax, download_chunk_size = download_chunk_size
  )
}

## This is a more general version of raster creation function with a
## user-specified bounding box.
create_raster <- function(parameter_code, pollutant_standard = NULL, data_field,
                          event_filter, year,  by_month = FALSE,
                          minlat = 24, maxlat = 50, minlon = -124, maxlon = -66,
                          crs = 6350, cell_size = 5000,
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
      data_field = data_field, event_filter = event_filter, year = year,
      by_month = by_month, crs = crs, aqs_email = aqs_email, aqs_key = aqs_key,
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
      data_field = data_field, event_filter = event_filter, year = year,
      by_month = by_month, crs = crs, aqs_email = aqs_email, aqs_key = aqs_key,
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
