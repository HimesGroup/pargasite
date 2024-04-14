## Download Cartographic boundary shape files to temporary folder.
## All files are deleted after function exits.
.get_pargasite_map <- function(x, boundary = c("state", "county", "cbsa")) {
  x_bbox <- st_bbox(st_transform(x, 4269))
  x_wkt_filter <- st_as_text(st_as_sfc(x_bbox))
  st_transform(
    .get_tiger_shape(boundary, wkt_filter = x_wkt_filter),
    st_crs(x)
  )
}

.get_tiger_shape <- function(boundary = c("state", "county", "cbsa"),
                          quiet = TRUE, force = FALSE, ...) {
  boundary <- match.arg(boundary)
  url <- .get_map_url(boundary)
  file_dir <- getOption("pargasite.shape_dir")
  dir.create(file_dir, showWarnings = FALSE)
  file_path <- file.path(file_dir, basename(url))
  if (!file.exists(file_path) || force) {
    message("Processing US shape file...")
    download.file(url, file_path, mode = "wb", quiet = FALSE)
    unzip(file_path, exdir = file_dir, overwrite = TRUE)
  }
  shape_file <- sub("\\.zip$", "", basename(url))
  sf::st_read(dsn = file_dir, layer = shape_file, quiet = quiet, ...)
}

.get_map_url <- function(x = c("state", "county", "cbsa"),
                         simplified = TRUE) {
  if (simplified) {
    .get_carto_url(x)
  } else {
    .get_tl_url(x)
  }
}

.get_tl_url <- function(x) {
  switch(
    x,
    "state" = "https://www2.census.gov/geo/tiger/TIGER2022/STATE/tl_2022_us_state.zip",
    "county" = "https://www2.census.gov/geo/tiger/TIGER2022/COUNTY/tl_2022_us_county.zip",
    "cbsa" = "https://www2.census.gov/geo/tiger/TIGER2021/CBSA/tl_2021_us_cbsa.zip"
  )
}

.get_carto_url <- function(x) {
  switch(
    x,
    "state" = "https://www2.census.gov/geo/tiger/GENZ2022/shp/cb_2022_us_state_20m.zip",
    "county" = "https://www2.census.gov/geo/tiger/GENZ2022/shp/cb_2022_us_county_20m.zip",
    "cbsa" = "https://www2.census.gov/geo/tiger/GENZ2021/shp/cb_2021_us_cbsa_20m.zip"
  )
}

.get_gadm_shape <- function(url = NULL, admin_level = 1, quiet = TRUE,
                            force = FALSE, ...) {
  if (is.null(url)) {
    url <- "https://geodata.ucdavis.edu/gadm/gadm4.1/shp/gadm41_USA_shp.zip"
  }
  file_dir <- getOption("pargasite.shape_dir")
  dir.create(file_dir, showWarnings = FALSE)
  file_path <- file.path(file_dir, basename(url))
  if (!file.exists(file_path) || force) {
    message("Processing GADM shape file...")
    download.file(url, file_path, mode = "wb", quiet = FALSE)
    unzip(file_path, exdir = file_dir, overwrite = TRUE)
  }
  shape_file <- sub("shp.zip$", paste0(admin_level, ".shp"), basename(url))
  sf::st_read(dsn = file.path(file_dir, shape_file), quiet = quiet, ...)
}
