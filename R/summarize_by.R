##' Summarized PARGASITE pollutant data by geographic boundaries
##'
##' A function to compute areal means of grid samples falling inside the target
##' geographic boundaries, including State, County, and Core Based Statistical
##' Area (CBSA). The US shape files are automatically downloaded to R's
##' temporary directory once for the current session and removed when R is
##' closed.
##'
##' @param x A stars object created by [create_pargasite_data].
##' @param level A string specifying a geographic boundary.
##'
##' @return A stars object containing pollutant levels summarized by geographic
##'   boundaries.
##'
##' @examples
##'
##' ## State-level summary
##' summarize_by_boundaries(ozone20km, "state")
summarize_by_boundaries <- function(x , level = c("state", "county", "cbsa")) {
  if (!inherits(x, "stars")) {
    stop("'x' must be a stars object.")
  }
  level <- match.arg(level)
  x_bbox <- st_bbox(st_transform(x, 4269))
  x_wkt_filter <- st_as_text(st_as_sfc(x_bbox))
  us_map <- st_transform(
    get_tl_shape(.get_carto_url(level), wkt_filter = x_wkt_filter),
    st_crs(x)
  )
  aggregate(x, by = us_map, FUN = function(x) mean(x, na.rm = TRUE))
}
