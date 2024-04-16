## Extract pollutant value from pollutant grid using mouse click events
.extract_grid_value <- function(x, click_pos) {
  x <- setNames(x, "Value")
  x <- st_extract(x, st_transform(click_pos, st_crs(x)))
  if (any(c("year", "month") %in% dimnames(x))) {
    x <- st_as_sf(x, long = TRUE)
  } else {
    x <- st_as_sf(x)
  }
  .rename_xy(x)
}

.get_click_pos <- function(long, lat) {
  x <- st_point(c(long, lat))
  st_sfc(x, crs = 4326)
}

.rename_xy <- function(d) {
  d <- st_transform(d, 4326) # back to WGS84
  d <- cbind(d, st_coordinates(d))
  d <- setNames(d, sub("X", "Longitude", names(d)))
  d <- setNames(d, sub("Y", "Latitude", names(d)))
  if ("month" %in% names(d)) {
    d$month <- month.abb[d$month]
  }
  d <- as.data.frame(d)[, !grepl("geometry", names(d))]
  d$Value <- sprintf("%.4f", d$Value)
  ## Capitalize year and month
  setNames(d, .capwords(names(d)))
}

## Capitalize fun from toupper() help page
.capwords <- function(s, strict = FALSE) {
  cap <- function(s) paste(toupper(substring(s, 1, 1)),
  {s <- substring(s, 2); if(strict) tolower(s) else s},
  sep = "", collapse = " " )
  sapply(strsplit(s, split = " "), cap, USE.NAMES = !is.null(names(s)))
}
