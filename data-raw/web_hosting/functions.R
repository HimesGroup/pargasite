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

.map_standard_to_ulim <- function(standard, scale = 1.2) {
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
    "pm25_annual_2012" = 15 * scale
  )
}

## `make.names` with underscore
.make_names <- function(names, ...) {
  gsub("\\.", "_", tolower(make.names(names = names, ...)))
}

pollutant_ui <- function(pollutant_list, field_list, event_list, year_list,
                         month_list = NULL, summary_list) {
  ## Month full name
  if (!is.null(month_list)) {
    names(month_list) <- month.name[as.integer(month_list)]
  }
  fluidRow(
    column(
      12,
      ## h3("Map View", style = "font-weight: bold; color: #54B4D3; margin-top: 10px; margin-bottom: 20px"),
      ## hr(),
      h3("Choose a raster attribute to visualize",
         style = "font-weight: bold; color: #DC4C64; margin-top:10px; margin-bottom: 15px"),
      selectizeInput(
        inputId = "pollutant",
        label = NULL,
        choice = pollutant_list,
        selected = NULL,
        multiple = FALSE
      ),
      ## h4("Data Info", style = "font-weight: bold; color: #EEEEEE"),
      h4("Data Info", style = "font-weight: bold; color: #332D2D"),
      p(span("Source: ", style = "font-weight: bold; color: orange"),
        textOutput("dat_src", inline = TRUE)),
      p("Field used:",
        style = "font-weight: bold; color: orange; margin-bottom: -15px"),
      selectizeInput(
        inputId = "dat_field",
        label = "",
        choice = field_list,
        multiple = FALSE
      ),
      helpText(
        icon("circle-info"),
        "Please check",
        a(href = "https://aqs.epa.gov/aqsweb/documents/AQS_Data_Dictionary.html",
          "AQS Data Dictionary", target = "_blank"), "for field descriptions.",
        style = "color: #3B71CA;"
      ),
      hr(),
      ## h4("Pollutant Standard Info", style = "font-weight: bold; color: #EEEEEE"),
      h4("Pollutant Standard Info", style = "font-weight: bold; color: #332D2D"),
      p(span("Pollutant standard: ", style = "font-weight: bold; color: orange"),
        textOutput("pollutant_std", inline = TRUE)),
      p(span("Primary Standard Level: ", style = "font-weight: bold; color: orange"),
        textOutput("primary_level", inline = TRUE)),
      p(span("Standard Unit: ", style = "font-weight: bold; color: orange"),
        textOutput("pollutant_unit", inline = TRUE)),
      p(span("Description: ", style = "font-weight: bold; color: orange"),
        textOutput("pollutant_desc", inline = TRUE)),
      p(span("NAAQS Basis: ", style = "font-weight: bold; color: orange"),
        textOutput("naaqs_basis", inline = TRUE)),
      p(span("NAAQS Statistic: ", style = "font-weight: bold; color: orange"),
        textOutput("naaqs_stat", inline = TRUE)),
      helpText(
        icon("circle-info"),
        "Please visit",
        a(href = "https://aqs.epa.gov/aqsweb/documents/codetables/pollutant_standards.html",
          "AQS Code List", target = "_blank"), "for details.",
        style = "color: #3B71CA"
      ),
      hr(),
      selectizeInput(
        inputId = "event",
        label = "Exceptional event",
        choice = event_list,
        multiple = FALSE
      ),
      hr(),
      selectizeInput(
        inputId = "year",
        label = "Year",
        choice = year_list,
        multiple = FALSE
      ),
      if (!is.null(month_list)) {
        selectizeInput(
          inputId = "month",
          label = "Month",
          ## choice = month.name[as.integer(month_list)],
          choice = month_list,
          multiple = FALSE
        )
      },
      if (length(summary_list) > 1) {
        hr()
      },
      if (length(summary_list) > 1) {
        radioButtons(
          inputId = "summary",
          label = "Summarize by",
          ## choices = c("None", "State", "County", "CBSA"),
          choices = summary_list,
          inline = TRUE
        )
      },
      hr(),
      h4("Pollutant value", style = "font-weight: bold; color: #9CCC65"),
      h5(htmlOutput("pollutant_val"))
    )
  )
}

.recover_from_standard <- function(x, y = .criteria_pollutants) {
  d <- within(y, key <- .make_names(pollutant_standard))
  d <- merge(list(key = names(x)), d, sort = FALSE)
  d <- within(d, name <- paste0(parameter, " (", parameter_code, ")"))
  ## Preserve order
  d$name <- factor(d$name, levels = unique(d$name))
  lapply(split(d$pollutant_standard, d$name), as.list)
}

get_tl_shape <- function(url = NULL, quiet = TRUE, force = FALSE, ...) {
  if (is.null(url)) {
    url <- "https://www2.census.gov/geo/tiger/TIGER2022/STATE/tl_2022_us_state.zip"
  }
  ## tmp <- tempdir()
  ## file_dir <- file.path(
  ##   tmp, "pargasite_tl_shape"
  ## )
  file_dir <- getOption("pargasite.shape_dir")
  dir.create(file_dir, showWarnings = FALSE)
  file_path <- file.path(file_dir, basename(url))
  if (!file.exists(file_path) || force) {
    message("Processing TIGER/TL shape file...")
    download.file(url, file_path, mode = "wb", quiet = FALSE)
    unzip(file_path, exdir = file_dir, overwrite = TRUE)
  }
  shape_file <- sub("\\.zip$", "", basename(url))
  sf::st_read(dsn = file_dir, layer = shape_file, quiet = quiet, ...)
}

.get_carto_url <- function(x) {
  switch(
    x,
    "state" = "https://www2.census.gov/geo/tiger/GENZ2022/shp/cb_2022_us_state_20m.zip",
    "county" = "https://www2.census.gov/geo/tiger/GENZ2022/shp/cb_2022_us_county_20m.zip",
    "cbsa" = "https://www2.census.gov/geo/tiger/GENZ2021/shp/cb_2021_us_cbsa_20m.zip"
  )
}

.subset_stars <- function(x, i = TRUE, dim = dimnames(x),
                          value = stars::st_get_dimension_values(x, dim),
                          drop = FALSE) {
  if (!inherits(x, "stars")) {
    stop("'x' must be a stars object.")
  }
  ## Would not allow to select a dimension by numeric index
  dim <- match.arg(dim)
  ## Would not allow to subset by numeric indices
  value <- match.arg(value)
  ## Create missing arguments to generate a function call
  ## Check rlang::missing_arg example
  nms <- dimnames(x)
  args <- rep(list(rlang::missing_arg()), length(nms))
  args[[which(dim == nms)]] <- value
  ## !!! to unquote many arguments
  rlang::eval_tidy(rlang::call2(`[`, rlang::expr(x), i = i, !!!args, drop = drop))
}

dimsub <- function(x, dim, value, drop = FALSE) {
  .subset_stars(x = x, i = TRUE, dim = dim, value = value, drop = drop)
}


"%ni%" <- function(x, table) match(x, table, nomatch = 0L) == 0L
