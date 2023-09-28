## Download TIGER/Line or GADM shape files to temporary folder. All files are
## deleted after function exits.
get_tl_shape <- function(url = NULL, quiet = TRUE, ...) {
  message("Processing TIGER/TL shape file...")
  if (is.null(url)) {
    url <- "https://www2.census.gov/geo/tiger/TIGER2022/STATE/tl_2022_us_state.zip"
  }
  tmp <- tempdir()
  file_dir <- file.path(
    tmp, paste(sample(letters, 15, replace = TRUE), collapse = "")
  )
  dir.create(file_dir, showWarnings = FALSE)
  on.exit(unlink(file_dir, recursive = TRUE))
  file_path <- file.path(file_dir, basename(url))
  download.file(url, file_path, mode = "wb", quiet = FALSE)
  unzip(file_path, exdir = file_dir)
  shape_file <- sub("\\.zip$", "", basename(url))
  sf::st_read(dsn = file_dir, layer = shape_file, quiet = quiet, ...)
}

get_gadm_shape <- function(url = NULL, admin_level = 1, quiet = TRUE, ...) {
  message("Processing GADM shape file...")
  if (is.null(url)) {
    url <- "https://geodata.ucdavis.edu/gadm/gadm4.1/shp/gadm41_USA_shp.zip"
  }
  tmp <- tempdir()
  file_dir <- file.path(
    tmp, paste(sample(letters, 15, replace = TRUE), collapse = "")
  )
  dir.create(file_dir, showWarnings = FALSE)
  on.exit(unlink(file_dir, recursive = TRUE))
  file_path <- file.path(file_dir, basename(url))
  download.file(url, file_path, mode = "wb", quiet = FALSE)
  unzip(file_path, exdir = file_dir)
  shape_file <- sub("shp.zip$", paste0(admin_level, ".shp"), basename(url))
  sf::st_read(dsn = file.path(file_dir, shape_file), quiet = quiet, ...)
}
