## Aggregate pollutant grid by TIGER/Line geographic entities
aggregate_by_tl <- function(pollutant_grid, level = c("state", "cbsa", "county")) {
  if (!inherits(pollutant_grid, "stars")) {
    stop("'pollutant_grid' must be a stars object.")
  }
  level <- match.arg(level)
  url <- .get_tl_url(level)
  us_shape <- get_tl_shape(url = url) |>
    st_transform(st_crs(pollutant_grid))
  ## Suppress warning; spatially constant
  us_shape <- suppressWarnings(st_crop(us_shape, pollutant_grid))
  aggregate(pollutant_grid, by = us_shape, FUN = mean)
}

.get_tl_url <- function(x) {
  switch(
    x,
    "state" = "https://www2.census.gov/geo/tiger/TIGER2022/STATE/tl_2022_us_state.zip",
    "county" = "https://www2.census.gov/geo/tiger/TIGER2022/COUNTY/tl_2022_us_county.zip",
    "cbsa" = "https://www2.census.gov/geo/tiger/TIGER2021/CBSA/tl_2021_us_cbsa.zip"
  )
}
