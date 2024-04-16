## Compute areal means of grid samples falling inside the target geographic
## boundaries.
.summarize_by_boundaries <- function(x, us_map) {
  if (!inherits(x, "stars")) {
    stop("'x' must be a stars object.")
  }
  ## stars would return NA for some boundaries.
  ## sf doesn't have this issue
  ## see https://github.com/r-spatial/stars/issues/317
  x <- setNames(x, "value")
  x <- aggregate(st_as_sf(x)["value"], by = us_map, FUN = function(x) mean(x, na.rm = TRUE))
  st_transform(st_join(us_map, x, join = st_equals), 4326) # WGS84
}

.summarize_pargasite_data <- function(x, us_map, year, month) {
  if (is.null(month)) {
    if (length(year) > 1) {
      x <- lapply(year, function(k) {
        y <- .dimsub(x, dim = "year", value = k, drop = TRUE)
        y <- .summarize_by_boundaries(y, us_map)
        y$year <- k
        y
      })
      x  <- do.call(rbind, x)
    } else {
      x <- .summarize_by_boundaries(x, us_map)
      x$year <- year
    }
  } else {
    if (length(month) > 1) {
      x <- lapply(month, function(k) {
        y <- .dimsub(x, dim = "month", value = k, drop = TRUE)
        y <- .summarize_by_boundaries(y, us_map)
        y$month <- k
        y
      })
      x <- do.call(rbind, x)
    } else {
      x <- .summarize_by_boundaries(x, us_map)
      x$month <- month
    }
    x$year <- year
  }
  x
}
